import 'dart:io';

void main(){
Map<String, int> players = {};

int choice = 0;

do {

print("\n==============================");
print("GAME TOURNAMENT MANAGEMENT");

print("==============================");

print( "1. Rigister Player");
print( "2. View Players");
print( "3. Search Player");
print( "4. Add MatchResult");
print( "5. Leaderboard");
print( "6. Statistics");
print( "7. Remove Player");
print( "8. Exit");

print("==============================");
print("Enter you choice");

String input = (stdin.readLineSync()!);
if (int.tryParse(input) == null){
  print("Please enter a number from 1 to 8.");

continue;
}
choice = int.parse(input);
if (choice == 1) {
  print( " Enter Player name:");

String name = stdin.readLineSync()!;


if (name.trim().isEmpty) {
    print("Player name cannot be empty!");
  }
   else if 
  (players.containsKey(name)) {
    print("Player already exists!");
}
else {
players[name]= 0;

print("Player registered successfully!");
  }
  }
else if (choice == 2){
  print("\nRegisteredPlayers");
if (players.isEmpty) {
   print("No Players Registered yet.");
}
else {
  for (String player in players.keys ) {

     print ("$player - ${players[player]}points");
  }
}
}
else if (choice == 3) {
   print("\nEnter player name to search:");

   String searchName = stdin.readLineSync()!;

   if(players.containsKey(searchName)){

    print("Player found: $searchName");

    print("Score: ${players[searchName]}points");
   }
   else {
    print("Player not found.");
    }
}
else if (choice == 4) {
   print("\nEnter player name:");

   String playerName = stdin.readLineSync()!;


   if (players.containsKey(playerName)) {
    print("Enter points:");
    int points = int.parse(stdin.readLineSync()!);
    if (points < 0) {

      print ("points cannot be negative!");
    }
      else {

        players[playerName] = players[playerName]! + points;


        print("Match reasult added!");

        print("New score: ${players[playerName]}points");
        
      }
   }

      else {
        print ("Player not found.");
      }
    
}
   else if (choice == 5) {
   print("\nLEADERBOARD:");

   if (players.isEmpty) {

     print("No Players Registered yet.");

   }

   else {
    var leaderboard = players.entries.toList();

    leaderboard.sort((a, b) => b.value.compareTo(a.value),);
    for (int i = 0; i < leaderboard.length; i++ ){
print("${i+1}.${leaderboard[i].key}- ${leaderboard[i].value}points");
    }
   }
   }


   else if (choice == 6)  {
print("\nSTATISTICS:");

   if (players.isEmpty) {

     print("No Players Registered yet.");
   }
     else {
      int totalPlayers = players.length;
      int highestScore = players.values.reduce((a, b)=> a > b ? a : b,);

      int totalScore = 0;
      for (int score in players.values) {
        totalScore = totalScore + score;
      }
      double averageScore = totalScore / totalPlayers;
      print("Total players: $totalPlayers");
      print("HighestScore: $highestScore");
      print("AverageScore: ${averageScore.toStringAsFixed(2)}");
     }
   }

   else if (choice == 7) {

    print("\nEnter player name to remove:");

    String playerName = stdin.readLineSync()!;

    if (players.containsKey(playerName)){

      players.remove(playerName);

      print("Player removed successfully!");
    }

    else {

      print ("player not found.");
    }
   }

  else if (choice == 8) {
  print( " Goodbye!");
  }
else {
   print( "This feature is coming soon.");

}
}
while (choice !=8);
}


