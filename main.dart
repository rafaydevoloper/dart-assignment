

// Assignment  04
// Question 1: Print numbers from 1 to 10
void main (){
for (int i = 1; i <= 10; i++) {
  print(i);
}
}



// Question 2: Creat a list of 5 names and print all names using loop
void main() {
  List<String> names = ['Ali', 'Ahmed', 'Rafay', 'Dan', 'Eva'];
  for (String name in names) {
    print(name);
  }
}



// Question 3: Print number from 10 to 1 using a while loop  
 void main() {
   int i = 10;
   while (i >= 1) {
    print(i);
     i--;
   }
 }



// Question 4: Take a number from user and print its table up to 10
import 'dart:io';
void main() {
print("Enter a number :");
  int number = int.parse(stdin.readLineSync()!);
    for (int i = 1; i <= 10; i++) {
      print('$number x $i = ${number * i}');
    }
  }
 


//  Question 5: Create a list simple menue that keeps showing until the user chosses exist
import 'dart:io';
void main() {
int choice ;
do {
    print("1. Add");
    print("2. Subtract");
    print("1. Exit");
    print("1. Enter your choice");
choice = int.parse(stdin.readLineSync()!) ;
if (choice == 1) {
    print("You selected Add");
}
else if (choice == 2) {
    print("You selected Subtract");
}
else if (choice == 3) {
print("Goodbye!");
}
else {
   print("Invalid choice"); 
}

} while (choice != 3);

}



// Question 6: Even Number 1 to 20
void main (){
for (int i = 1; i <= 20; i++)  {
    if (i % 2 == 0) {
        print (i);
    }
  }
}



// Question 7: Find the total sum
void main (){
List<int> numbers = [10, 20,30,40,50,];
int sum =0;
for (int number in numbers ) {
    sum = sum + number;
}
 print("total sum: $sum");
}



// Question 8: Print number 1 to 5 using 

void main(){
int i =1;
do{
    print(i);
    i++;
}
while (i<= 5);
}

 

// Question 9: Take a number from user and print 
import 'dart:io';
void main(){
    print ("Enter a number:");
    int number = int.parse(stdin.readLineSync()!);
int i = 1;
while (i <= number) {
    print(i);
    i++;
}
}



// Question 10: Print all 

void main(){
List<String> fruits = ["Apple", "Banana", "Mango", "Orange", "Grapes" ];
for (String fruit in fruits) {
    print (fruit);
}
}



// Question 11: Table of using while
void main (){
int i = 1;
while (i <= 10) {
    print ("7 *$i = ${7 * i}");
    i++;
}
}



// Question 12: Print number 20 to 1
void main(){
int i =20;
do {
print(i);
i--;
}
while (i >=1);
}



// Question 13: Take 5 number from user
import 'dart:io';
void main(){
for (int i =1; i <= 5; i++) {
    print("Enter number $i:");
    int number =int.parse(stdin.readLineSync()!);
    print("You enterd :$number");
}
}



// Question 14: Print mark greater than 50
void main (){
List<int> marks = [45,67,32,89,55,40];
  for (int mark in marks) {
    if (mark > 50){
        print(mark);
    }
  }
}
 


// Question 15: Sum of 1 to 10 using while
void main(){
int i = 1;
int sum = 0;
while (i <= 10) {
    sum = sum +i;
    i++;
}
print ("Sum: $sum ");
}



// Question 16: Odd number 1 to 15 using do-while
void main (){
int i =1;
do {
    if (i % 2 != 0) {
        print (i);
    }
    i++;
}
while (i <= 15);
}



// Question 17: print all cities
void main(){
List<String> cities =[
"Karachi",
"Lahore",
"Islamabad",
"Peshawar",
"Quetta",
];
 for (String city in cities) {
    print (city);
 }
}
  


// Question 18: Table from 1 to 10
void main(){
print("Enter a number:");
int number = int.parse(stdin.readLineSync()!);
for (int i = 10; i >= 1; i--) {
    print ("$number * $i = ${number * i}");
 }
}



// Question 19: Keep asking until user enter 0
import 'dart:io';
void main(){
int number = 1;
while (number != 0){
    print("Enter a number:");
      number = int.parse(stdin.readLineSync()!);
  print("you entered:  $number");
}
 print("Program ended.");
}



// Question 20: Print Prices with "Rs"
void main (){
List<double> prices = [100.0,250.0,500.0,750.0,1000.0,];
 for (double price in prices) {
    print("Rs. $price");
 }
}

