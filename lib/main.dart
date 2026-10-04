import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const WhatsAppApp());
}

class WhatsAppApp extends StatelessWidget {
  const WhatsAppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhatsApp',color: Colors.black,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ================= HOME PAGE =================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    ChatsPage(),
    StatusPage(),
    CallsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            selectedIcon: Icon(Icons.circle),
            label: 'Status',
          ),
          NavigationDestination(
            icon: Icon(Icons.call_outlined),
            selectedIcon: Icon(Icons.call),
            label: 'Calls',
          ),
        ],
      ),
    );
  }
}

// ================= CHAT LIST =================

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  final List<Map<String, dynamic>> chats = const [
    {
      'name': 'Ali',
      'message': 'Hello bro!',
      'time': '6:30 PM',
      'color': Colors.blue,
    },
    {
      'name': 'Ahmed',
      'message': 'How are you?',
      'time': '5:45 PM',
      'color': Colors.orange,
    },
    {
      'name': 'Gaming Group',
      'message': 'Let\'s play PUBG',
      'time': '4:20 PM',
      'color': Colors.green,
    },
    {
      'name': 'Hamza',
      'message': 'See you tomorrow',
      'time': '3:10 PM',
      'color': Colors.purple,
    },
    {
      'name': 'Family',
      'message': 'Dinner at 9 PM',
      'time': '2:00 PM',
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // WhatsApp Header
          Container(
            color: const Color(0xFF075E54),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            child: Row(
              children: [
                const Text(
                  'WhatsApp',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Chat List
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 5,
                  ),

                  leading: CircleAvatar(
                    radius: 27,
                    backgroundColor: chat['color'],
                    child: Text(
                      chat['name'][0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  title: Text(
                    chat['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  subtitle: Text(chat['message']),

                  trailing: Text(chat['time']),

                  // OPEN CHAT
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          name: chat['name'],
                          color: chat['color'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CHAT SCREEN =================

class ChatPage extends StatefulWidget {
  final String name;
  final Color color;

  const ChatPage({
    super.key,
    required this.name,
    required this.color,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController =
      TextEditingController();

  final List<Map<String, dynamic>> messages = [
  {
    'text': 'Hello!',
    'time': '6:30 PM',
  },
  {
    'text': 'How are you?',
    'time': '6:31 PM',
  },
];

  void sendMessage() {
    String message = messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    setState(() {
      messages.add({                                              
  'text': message,
  'time': TimeOfDay.now().format(context),
});
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,

        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.color,
              child: Text(
                widget.name[0],
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Text(widget.name),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),

      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      messages[index]['text'],
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Box
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      prefixIcon: const Icon(
                        Icons.emoji_emotions_outlined,
                      ),
                    ),

                    onSubmitted: (_) {
                      sendMessage();
                    },
                  ),
                ),

                const SizedBox(width: 8),

                FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFF075E54),
                  onPressed: sendMessage,
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= STATUS PAGE =================

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final List<Map<String, dynamic>> statuses = [
    {
      'name': 'Ali',
      'time': 'Today, 5:30 PM',
      'color': Colors.blue,
    },
    {
      'name': 'Ahmed',
      'time': 'Today, 3:20 PM',
      'color': Colors.orange,
    },
    {
      'name': 'Hamza',
      'time': 'Today, 1:15 PM',
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: const Color(0xFF075E54),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            child: Row(
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
            title: const Text(
              'My status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Tap to add status update',
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  final controller = TextEditingController();

                  return AlertDialog(
                    title: const Text('Add Status'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Write your status',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            setState(() {
                              statuses.insert(0, {
                                'name': 'My Status',
                                'message': controller.text.trim(),
                                'time': 'Just now',
                                'color': Colors.green,
                              });
                            });

                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const Padding(
            padding: EdgeInsets.all(15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent updates',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final status = statuses[index];

                return ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: status['color'],
                    child: Text(
                      status['name'][0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  title: Text(
                    status['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                  '${status['message'] ?? status['time']} • ${status['time']}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// ================= CALLS PAGE =================

class CallsPage extends StatefulWidget {
  const CallsPage({super.key});

  @override
  State<CallsPage> createState() => _CallsPageState();
}
// ================= CALL SCREEN =================

class CallScreen extends StatefulWidget {
  final String name;

  const CallScreen({
    super.key,
    required this.name,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isMuted = false;
  bool isSpeakerOn = false;

  int seconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          seconds++;
        });
      },
    );
  }

  String get callTime {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111B21),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),

            // Person name
            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Call timer
            Text(
              callTime,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 40),

            // Profile picture
            CircleAvatar(
              radius: 75,
              backgroundColor: Colors.blue,
              child: Text(
                widget.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            // Call controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute
                _callButton(
                  icon: isMuted
                      ? Icons.mic_off
                      : Icons.mic,
                  label: 'Mute',
                  active: isMuted,
                  onPressed: () {
                    setState(() {
                      isMuted = !isMuted;
                    });
                  },
                ),

                // Speaker
                _callButton(
                  icon: isSpeakerOn
                      ? Icons.volume_up
                      : Icons.volume_down,
                  label: 'Speaker',
                  active: isSpeakerOn,
                  onPressed: () {
                    setState(() {
                      isSpeakerOn = !isSpeakerOn;
                    });
                  },
                ),

                // End call
                _callButton(
                  icon: Icons.call_end,
                  label: 'End',
                  active: true,
                  endCall: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _callButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onPressed,
    bool endCall = false,
  }) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: label,
          backgroundColor: endCall
              ? Colors.red
              : active
                  ? Colors.white
                  : Colors.white24,
          onPressed: onPressed,
          child: Icon(
            icon,
            color: endCall
                ? Colors.white
                : active
                    ? Colors.black
                    : Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _CallsPageState extends State<CallsPage> {
    List<Map<String, dynamic>> calls = [
    {
      'name': 'Ali',
      'time': 'Today, 6:30 PM',
      'incoming': true,
    },
    {
      'name': 'Ahmed',
      'time': 'Today, 4:15 PM',
      'incoming': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: const Color(0xFF075E54),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            child: Row(
              children: [
                const Text(
                  'Calls',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        calls.insert(0, {
                          'name': 'New Contact',
                          'time': 'Just now',
                          'incoming': false,
                        });
                      });
                    },
                    icon: const Icon(
                      Icons.add_call,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),

          const ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.link,
                color: Colors.white,
              ),
            ),
            title: Text(
              'Create call link',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Share a link for your WhatsApp call',
            ),
          ),

          Expanded(
  child: ListView.builder(
    itemCount: calls.length,
    itemBuilder: (context, index) {
      final call = calls[index];

      return Dismissible(
        key: Key(call['name'] + index.toString()),
        direction: DismissDirection.endToStart,

        onDismissed: (direction) {
          setState(() {
            calls.removeAt(index);
          });
        },

        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),

        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue,
            child: Text(
              call['name'][0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),

          title: Text(
            call['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          subtitle: Row(
            children: [
              Icon(
                call['incoming']
                    ? Icons.call_received
                    : Icons.call_made,
                color: call['incoming']
                    ? Colors.green
                    : Colors.red,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(call['time']),
            ],
          ),

          trailing: const Icon(
            Icons.call,
            color: Colors.green,
          ),
          onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(
              name: call['name'],
      ),
    ),
  );
},
        ),
      );
    },
  ),
),
        ],
      ),
    );
  }
}