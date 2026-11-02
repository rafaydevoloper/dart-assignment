
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

const Color navy = Color(0xFF07111F);
const Color panel = Color(0xFF111F32);
const Color blue = Color(0xFF2684FF);
const Color cyan = Color(0xFF36D9F5);

const List<String> sortOptions = [
  'Newest',
  'Oldest',
  'Name A-Z',
  'Longest',
];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VoiceRecorderApp());
}

class VoiceRecorderApp extends StatelessWidget {
  const VoiceRecorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlueWave Recorder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const RecorderHome(),
    );
  }
}

class SavedRecording {
  final String id;
  String name;
  String path;
  final DateTime createdAt;
  int duration;
  bool isFavorite;

  SavedRecording({
    required this.id,
    required this.name,
    required this.path,
    required this.createdAt,
    required this.duration,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration,
      'isFavorite': isFavorite,
    };
  }

  factory SavedRecording.fromJson(Map<String, dynamic> json) {
    return SavedRecording(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      duration: json['duration'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}

class RecorderHome extends StatefulWidget {
  const RecorderHome({super.key});

  @override
  State<RecorderHome> createState() => _RecorderHomeState();
}

class _RecorderHomeState extends State<RecorderHome> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  List<SavedRecording> _recordings = [];

  String? _playingId;

  int _elapsedSeconds = 0;

  bool _isRecording = false;
  bool _isPaused = false;
  bool _isLoading = true;
  bool _showFavoritesOnly = false;
  StreamSubscription<Amplitude>? _amplitudeSubscription;

double _micLevel = 0.0;

  int _selectedTab = 0;

  String _searchQuery = '';
  String _sortOption = 'Newest';

  @override
  void initState() {
    super.initState();
    _loadRecordings();

    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playingId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  
  // LOAD SAVED RECORDINGS

  Future<void> _loadRecordings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedData = prefs.getString('bluewave_recordings');
      final savedSort = prefs.getString('bluewave_sort_option');

      List<SavedRecording> loaded = [];

      if (savedData != null) {
        final List<dynamic> decoded = jsonDecode(savedData);

        for (final item in decoded) {
          try {
            final recording = SavedRecording.fromJson(
              Map<String, dynamic>.from(item),
            );

            if (await File(recording.path).exists()) {
              loaded.add(recording);
            }
          } catch (e) {
            debugPrint('Could not load a recording: $e');
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _recordings = loaded;

        if (savedSort != null && sortOptions.contains(savedSort)) {
          _sortOption = savedSort;
        }

        _isLoading = false;
      });

      await _saveRecordings();
    } catch (e) {
      debugPrint('Loading error: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // START AMPLITUDE MONITORING

  void _startAmplitudeMonitoring() {
    _amplitudeSubscription?.cancel();

    _amplitudeSubscription = _recorder
        .onAmplitudeChanged(
          const Duration(milliseconds: 80),
        )
        .listen((amplitude) {
      if (!mounted || !_isRecording || _isPaused) return;

      final db = amplitude.current;

      final level = db < -50
          ? 0.0
          : ((db + 50) / 50).clamp(0.0, 1.0).toDouble();

      setState(() {
        _micLevel = level;
      });
    });
  }

  // STOP AMPLITUDE MONITORING

  Future<void> _stopAmplitudeMonitoring() async {
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;

    if (mounted) {
      setState(() {
        _micLevel = 0.0;
      });
    }
  }

  // SAVE RECORDINGS

  Future<void> _saveRecordings() async {
    final prefs = await SharedPreferences.getInstance();

    final data = jsonEncode(
      _recordings.map((recording) => recording.toJson()).toList(),
    );

    await prefs.setString('bluewave_recordings', data);
  }

  // SAVE SORTING PREFERENCE

  Future<void> _saveSortOption() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'bluewave_sort_option',
      _sortOption,
    );
  }                                                       

  // FAVORITES

  Future<void> _toggleFavorite(SavedRecording recording) async {
    setState(() {
      recording.isFavorite = !recording.isFavorite;
    });

    await _saveRecordings();

    _message(
      recording.isFavorite
          ? 'Added to favorites'
          : 'Removed from favorites',
    );
  }

  // SEARCH, FILTER AND SORT

  List<SavedRecording> _getVisibleRecordings() {
    List<SavedRecording> visible = List.from(_recordings);

    if (_showFavoritesOnly) {
      visible = visible
          .where((recording) => recording.isFavorite)
          .toList();
    }

    final query = _searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      visible = visible.where((recording) {
        return recording.name.toLowerCase().contains(query);
      }).toList();
    }

    switch (_sortOption) {
      case 'Oldest':
        visible.sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
        );
        break;

      case 'Name A-Z':
        visible.sort(
          (a, b) => a.name.toLowerCase().compareTo(
                b.name.toLowerCase(),
              ),
        );
        break;

      case 'Longest':
        visible.sort(
          (a, b) => b.duration.compareTo(a.duration),
        );
        break;

      default:
        visible.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
    }

    return visible;
  }

  // START RECORDING

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();

      if (!hasPermission) {
        _message('Microphone permission is required');
        return;
      }

      final directory = await getApplicationDocumentsDirectory();

      final folder = Directory(
        '${directory.path}/BlueWaveRecordings',
      );

      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final path = '${folder.path}/recording_$timestamp.m4a';

      await _player.stop();

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: path,
      );

      _startAmplitudeMonitoring();

      _stopwatch.reset();
      _stopwatch.start();

      setState(() {
        _isRecording = true;
        _isPaused = false;
        _elapsedSeconds = 0;
        _playingId = null;
      });

      _timer?.cancel();

      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          if (mounted && !_isPaused) {
            setState(() {
              _elapsedSeconds = _stopwatch.elapsed.inSeconds;
            });
          }
        },
      );

      _message('Recording started');
    } catch (e) {
      _message('Could not start recording: $e');
    }
  }

  // PAUSE RECORDING

  Future<void> _pauseRecording() async {
    try {
      await _recorder.pause();
      await _stopAmplitudeMonitoring();
      _stopwatch.stop();

      _timer?.cancel();

      setState(() {
        _isPaused = true;
      });
    } catch (e) {
      _message('Could not pause recording');
    }
  }

  // RESUME RECORDING

  Future<void> _resumeRecording() async {
    try {
      await _recorder.resume();
      _startAmplitudeMonitoring();
      _stopwatch.start();

      setState(() {
        _isPaused = false;
      });

      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          if (mounted && !_isPaused) {
            setState(() {
              _elapsedSeconds = _stopwatch.elapsed.inSeconds;
            });
          }
        },
      );
    } catch (e) {
      _message('Could not resume recording');
    }
  }

  // STOP AND SAVE RECORDING

  Future<void> _stopRecording() async {
    try {
      _timer?.cancel();
      _stopwatch.stop();

      final path = await _recorder.stop();
      await _stopAmplitudeMonitoring();             

      if (path == null) {
        _message('Recording could not be saved');
        return;
      }

      final duration = _stopwatch.elapsed.inSeconds;

      final recording = SavedRecording(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Recording ${_recordings.length + 1}',
        path: path,
        createdAt: DateTime.now(),
        duration: duration,
      );

      setState(() {
        _recordings.insert(0, recording);
        _isRecording = false;
        _isPaused = false;
        _elapsedSeconds = 0;
      });

      await _saveRecordings();

      _message('Recording saved successfully');
    } catch (e) {
      _message('Could not stop recording: $e');
    }
  }
    // OPEN RECORDING DETAILS

  Future<void> _openRecordingDetails(
    SavedRecording recording,
  ) async {
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordingDetailsScreen(
          recording: recording,
        ),
      ),
    );
  }

  // PLAY RECORDING

  Future<void> _playRecording(SavedRecording recording) async {
    try {
      if (_playingId == recording.id) {
        await _player.stop();

        setState(() {
          _playingId = null;
        });

        return;
      }

      if (!await File(recording.path).exists()) {
        _message('Audio file not found');
        return;
      }

      await _player.stop();

      setState(() {
        _playingId = recording.id;
      });

      await _player.play(
        DeviceFileSource(recording.path),
      );
    } catch (e) {
      setState(() {
        _playingId = null;
      });

      _message('Could not play recording');
    }
  }

  // RENAME RECORDING

  Future<void> _renameRecording(SavedRecording recording) async {
    final controller = TextEditingController(
      text: recording.name,
    );

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename recording'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter recording name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null || newName.isEmpty) return;

    setState(() {
      recording.name = newName;
    });

    await _saveRecordings();

    _message('Recording renamed');
  }

  // DELETE RECORDING

  Future<void> _deleteRecording(SavedRecording recording) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete recording?'),
          content: Text(
            'Are you sure you want to delete "${recording.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      if (_playingId == recording.id) {
        await _player.stop();

        setState(() {
          _playingId = null;
        });
      }

      final file = File(recording.path);

      if (await file.exists()) {
        await file.delete();
      }

      setState(() {
        _recordings.removeWhere(
          (item) => item.id == recording.id,
        );
      });

      await _saveRecordings();

      _message('Recording deleted');
    } catch (e) {
      _message('Could not delete recording');
    }
  }

  // SHARE RECORDING

  Future<void> _shareRecording(SavedRecording recording) async {
    try {
      final file = File(recording.path);

      if (!await file.exists()) {
        _message('Audio file not found');
        return;
      }

      await SharePlus.instance.share(
        ShareParams(
          text: 'Shared from BlueWave Recorder',
          files: [
            XFile(recording.path),
          ],
        ),
      );
    } catch (e) {
      _message('Could not share recording');
    }
  }

  // HELPER FUNCTIONS

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day}/${date.month}/${date.year} '
        '$hour:$minute $period';
  }

  String _formatSize(String path) {
    try {
      final file = File(path);

      if (!file.existsSync()) return '';

      final bytes = file.lengthSync();

      if (bytes < 1024) {
        return '$bytes B';
      }

      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      }

      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return '';
    }
  }

  // MAIN SCREEN

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        title: const Row(
          children: [
            Icon(
              Icons.graphic_eq_rounded,
              color: cyan,
            ),
            SizedBox(width: 10),
            Text(
              'BlueWave',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'BlueWave Recorder',
                applicationVersion: '1.0.0',
                children: const [
                  Text(
                    'Your recordings stay on your device.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: _selectedTab == 0
          ? _buildRecorderScreen()
          : _buildLibrary(),
      bottomNavigationBar: NavigationBar(
        backgroundColor: panel,
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.mic_none_rounded),
            selectedIcon: Icon(Icons.mic_rounded),
            label: 'Recorder',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music_rounded),
            label: 'My Recordings',
          ),
        ],
      ),
    );
  }

  // RECORDER SCREEN

  Widget _buildRecorderScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Voice Recorder',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isRecording
                  ? (_isPaused ? 'Recording paused' : 'Recording in progress')
                  : 'Capture your moments',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // TIMER

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: blue.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _AnimatedWaveform(
                    isActive: _isRecording && !_isPaused,
                     level: _micLevel,          

                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // MICROPHONE BUTTON

            if (!_isRecording)
              _PulsingMicButton(
                onTap: _startRecording,
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlButton(
                    icon: _isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    label: _isPaused ? 'Resume' : 'Pause',
                    color: blue,
                    onTap: _isPaused
                        ? _resumeRecording
                        : _pauseRecording,
                  ),
                  const SizedBox(width: 40),
                  _ControlButton(
                    icon: Icons.stop_rounded,
                    label: 'Stop',
                    color: Colors.redAccent,
                    onTap: _stopRecording,
                  ),
                ],
              ),

            const SizedBox(height: 35),

            // RECENT RECORDINGS

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Recordings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTab = 1;
                    });
                  },
                  child: const Text('See all'),
                ),
              ],
            ),

            if (_recordings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Your recordings will appear here.',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            else
              ..._recordings.take(3).map(_recordingTile),
          ],
        ),
      ),
    );
  }

  // RECORDINGS LIBRARY

  Widget _buildLibrary() {
    final visibleRecordings = _getVisibleRecordings();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Recordings',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_recordings.length} recordings saved',
                  style: const TextStyle(
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 18),

                // SEARCH FIELD

                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search recordings...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: panel,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // FILTER AND SORT

                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: !_showFavoritesOnly,
                      onSelected: (_) {
                        setState(() {
                          _showFavoritesOnly = false;
                        });
                      },
                      selectedColor: blue,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      avatar: const Icon(
                        Icons.star_rounded,
                        size: 17,
                      ),
                      label: const Text('Favorites'),
                      selected: _showFavoritesOnly,
                      onSelected: (_) {
                        setState(() {
                          _showFavoritesOnly = true;
                        });
                      },
                      selectedColor: blue,
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      tooltip: 'Sort recordings',
                      initialValue: _sortOption,
                      onSelected: (value) {
                        setState(() {
                          _sortOption = value;
                        });

                        _saveSortOption();
                      },
                      itemBuilder: (context) {
                        return sortOptions.map((option) {
                          return PopupMenuItem<String>(
                            value: option,
                            child: Row(
                              children: [
                                if (_sortOption == option)
                                  const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: cyan,
                                  )
                                else
                                  const SizedBox(width: 18),
                                const SizedBox(width: 8),
                                Text(option),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: panel,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.sort_rounded,
                              size: 19,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _sortOption,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // RECORDINGS LIST

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : visibleRecordings.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          4,
                          16,
                          20,
                        ),
                        itemCount: visibleRecordings.length,
                        itemBuilder: (context, index) {
                          return _recordingTile(
                            visibleRecordings[index],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // EMPTY LIBRARY STATE

  Widget _emptyState() {
    String message;

    if (_searchQuery.trim().isNotEmpty) {
      message = 'No recordings match your search.';
    } else if (_showFavoritesOnly) {
      message = 'You have not added any favorites yet.';
    } else {
      message = 'No recordings yet. Start recording!';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showFavoritesOnly
                ? Icons.star_border_rounded
                : Icons.mic_none_rounded,
            size: 65,
            color: Colors.white24,
          ),
          const SizedBox(height: 15),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 15,
            ),
          ),
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              child: const Text('Clear search'),
            ),
        ],
      ),
    );
  }

  // RECORDING TILE

  Widget _recordingTile(SavedRecording recording) {
    final isPlaying = _playingId == recording.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // PLAY BUTTON

          IconButton(
            onPressed: () => _playRecording(recording),
            icon: Icon(
              isPlaying
                  ? Icons.stop_circle_rounded
                  : Icons.play_circle_fill_rounded,
              size: 38,
              color: cyan,
            ),
          ),

          const SizedBox(width: 7),

          // RECORDING DETAILS

                    Expanded(
            child: GestureDetector(
              onTap: () => _openRecordingDetails(recording),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recording.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_formatTime(recording.duration)}  •  '
                    '${_formatSize(recording.path)}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatDate(recording.createdAt),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // FAVORITE BUTTON

          IconButton(
            tooltip: recording.isFavorite
                ? 'Remove from favorites'
                : 'Add to favorites',
            onPressed: () => _toggleFavorite(recording),
            icon: Icon(
              recording.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: recording.isFavorite
                  ? Colors.amber
                  : Colors.white54,
            ),
          ),

          // MORE OPTIONS

          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'rename':
                  _renameRecording(recording);
                  break;
                case 'share':
                  _shareRecording(recording);
                  break;
                case 'delete':
                  _deleteRecording(recording);
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 10),
                    Text('Rename'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined),
                    SizedBox(width: 10),
                    Text('Share'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 10),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ANIMATED WAVEFORM

class _AnimatedWaveform extends StatelessWidget {
  final bool isActive;
  final double level;

  const _AnimatedWaveform({
    required this.isActive,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      width: double.infinity,
      child: CustomPaint(
        painter: _WaveformPainter(
          level: isActive ? level : 0.0,
          active: isActive,
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double level;
  final bool active;

  _WaveformPainter({
    required this.level,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final voiceLevel = level.clamp(0.0, 1.0);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF2684FF),
          Color(0xFF36D9F5),
          Color(0xFF2684FF),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final path = Path();

    const points = 100;

    for (int i = 0; i <= points; i++) {
      final x = size.width * i / points;
      final position = i / points;

      final envelope = math.sin(position * math.pi);

      final wave = math.sin(position * math.pi * 12);

      final height = active
          ? wave * envelope * (5 + voiceLevel * 45)
          : wave * envelope * 5;

      final y = centerY + height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Second subtle wave for a layered appearance.
    final secondPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF36D9F5).withValues(alpha: 0.35);      

    final secondPath = Path();

    for (int i = 0; i <= points; i++) {
      final x = size.width * i / points;
      final position = i / points;

      final envelope = math.sin(position * math.pi);
      final wave = math.sin(position * math.pi * 12 + 0.8);

      final height = active
          ? wave * envelope * (4 + voiceLevel * 25)
          : wave * envelope * 3;

      final y = centerY + height;

      if (i == 0) {
        secondPath.moveTo(x, y);
      } else {
        secondPath.lineTo(x, y);    
      }
    }

    canvas.drawPath(secondPath, secondPaint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.active != active;
  }
}


// PULSING MICROPHONE BUTTON

class _PulsingMicButton extends StatefulWidget {
  final VoidCallback onTap;

  const _PulsingMicButton({
    required this.onTap,
  });

  @override
  State<_PulsingMicButton> createState() => _PulsingMicButtonState();
}

class _PulsingMicButtonState extends State<_PulsingMicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1 + (_controller.value * 0.08);

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blue,
                boxShadow: [
                  BoxShadow(
                    color: blue.withValues(alpha: 0.35),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic_rounded,
                size: 55,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

// RECORDING CONTROL BUTTON

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class RecordingDetailsScreen extends StatefulWidget {
  final SavedRecording recording;

  const RecordingDetailsScreen({
    super.key,
    required this.recording,
  });

  @override
  State<RecordingDetailsScreen> createState() =>
      _RecordingDetailsScreenState();
}

class _RecordingDetailsScreenState
    extends State<RecordingDetailsScreen> {
  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;
  bool _hasStarted = false;

  double _speed = 1.0;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _duration = Duration(
      seconds: widget.recording.duration,
    );

    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _hasStarted = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _player.pause();

        setState(() {
          _isPlaying = false;
        });

        return;
      }

      if (!await File(widget.recording.path).exists()) {
        _showMessage('Audio file not found');
        return;
      }

      if (_hasStarted) {
        await _player.resume();
      } else {
        await _player.play(
          DeviceFileSource(widget.recording.path),
        );

        _hasStarted = true;
      }

      await _player.setPlaybackRate(_speed);

      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      _showMessage('Could not play recording: $e');
    }
  }

  Future<void> _changeSpeed(double speed) async {
    try {
      _speed = speed;

      await _player.setPlaybackRate(speed);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _showMessage('Could not change playback speed');
    }
  }

  Future<void> _seek(double seconds) async {
    final newPosition = Duration(
      milliseconds: (seconds * 1000).round(),
    );

    await _player.seek(newPosition);

    if (mounted) {
      setState(() {
        _position = newPosition;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _formatFileSize() {
    try {
      final file = File(widget.recording.path);

      if (!file.existsSync()) return 'File not found';

      final bytes = file.lengthSync();

      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      }

      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        title: const Text('Now Playing'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const SizedBox(height: 35),

              // ALBUM ART STYLE ICON

              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [blue, cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: blue.withValues(alpha: 0.25),
                      blurRadius: 35,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  size: 100,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 35),

              // RECORDING NAME

              Text(
                widget.recording.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'BlueWave Audio Player',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),

              const SizedBox(height: 35),

              // PLAYBACK PROGRESS

              StreamBuilder<Duration>(
                stream: _player.onPositionChanged,
                builder: (context, snapshot) {
                  final currentPosition =
                      snapshot.data ?? _position;

                  final totalSeconds =
                      _duration.inSeconds.toDouble();

                  final currentSeconds =
                      currentPosition.inSeconds.toDouble();

                  final sliderValue = totalSeconds > 0
                      ? currentSeconds.clamp(0.0, totalSeconds)
                      : 0.0;

                  return Column(
                    children: [
                      Slider(
                        value: sliderValue,
                        min: 0,
                        max: totalSeconds > 0
                            ? totalSeconds
                            : 1,
                        onChanged: totalSeconds > 0
                            ? _seek
                            : null,
                        activeColor: cyan,
                        inactiveColor: Colors.white24,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(currentPosition),
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 25),

              // PLAY / PAUSE BUTTON

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 35,
                    color: Colors.white70,
                    onPressed: () {
                      final newPosition =
                          _position - const Duration(seconds: 10);

                      _seek(
                        newPosition.inSeconds
                            .clamp(0, _duration.inSeconds)
                            .toDouble(),
                      );
                    },
                    icon: const Icon(
                      Icons.replay_10_rounded,
                    ),
                  ),

                  const SizedBox(width: 20),

                  Container(
                    width: 78,
                    height: 78,
                    decoration: const BoxDecoration(
                      color: blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _togglePlayback,
                      iconSize: 43,
                      color: Colors.white,
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  IconButton(
                    iconSize: 35,
                    color: Colors.white70,
                    onPressed: () {
                      final newPosition =
                          _position + const Duration(seconds: 10);

                      _seek(
                        newPosition.inSeconds
                            .clamp(0, _duration.inSeconds)
                            .toDouble(),
                      );
                    },
                    icon: const Icon(
                      Icons.forward_10_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // PLAYBACK SPEED

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.speed_rounded,
                          color: cyan,
                        ),
                        SizedBox(width: 10),
                        Text('Playback speed'),
                      ],
                    ),
                    DropdownButton<double>(
                      value: _speed,
                      underline: const SizedBox(),
                      dropdownColor: panel,
                      items: const [
                        DropdownMenuItem(
                          value: 0.5,
                          child: Text('0.5x'),
                        ),
                        DropdownMenuItem(
                          value: 1.0,
                          child: Text('1.0x'),
                        ),
                        DropdownMenuItem(
                          value: 1.5,
                          child: Text('1.5x'),
                        ),
                        DropdownMenuItem(
                          value: 2.0,
                          child: Text('2.0x'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _changeSpeed(value);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // RECORDING INFORMATION

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recording Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 18),

                    _infoRow(
                      Icons.calendar_today_rounded,
                      'Date',
                      '${widget.recording.createdAt.day}/'
                          '${widget.recording.createdAt.month}/'
                          '${widget.recording.createdAt.year}',
                    ),

                    const SizedBox(height: 14),

                    _infoRow(
                      Icons.timer_outlined,
                      'Duration',
                      _formatDuration(
                        Duration(
                          seconds: widget.recording.duration,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    _infoRow(
                      Icons.storage_rounded,
                      'File size',
                      _formatFileSize(),
                    ),

                    const SizedBox(height: 14),

                    _infoRow(
                      Icons.audio_file_rounded,
                      'Format',
                      'M4A Audio',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: cyan,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

