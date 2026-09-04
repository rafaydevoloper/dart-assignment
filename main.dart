// // Assignmnent=3
// //  Question=1

// void main(){

// List<String> names = ['Hamza', 'Ali', 'Umar', 'john', 'ben'];

// print(names);
// }


// // Question=2 Creat an empty list of days and add 7days

// // void main(){

//   List<String> days =[];

// days.add('Monday');

// days.add('Tuesday');

// days.add('Wednesday');

// days.add('Thursday');

// days.add('Friday');

// days.add('Saturday');

// days.add('Sunday');

// print(days);
// }


// Question=3   Creat a list of days and remove

// void main(){

//   List<String> days =[

//   'Monday',

//   'Tuesday',

//   'Wednesday',

//   'Thursday',

//   'Friday',

//   'Saturday',

//   'Sunday'];

//   while(days.isNotEmpty){

//     print(days.removeLast());
//   }
// }
  

// Question=4    Creat a list of numbers and find the smallest and largest number

// void main(){

//   List<int> numbers =[10,5,25,3,50,8];
  

// int smallest = numbers[0];

// int largest = numbers[0];

// for(int number in numbers) {

//   if(number < smallest) {

//     smallest = number;
//   }
//   if(number > largest){

//     largest = number;
//   }
// }

// print('Smallest number: $smallest');

// print('Largest number: $largest');
// }


// Question=5 Map + find keys with length 4

// void main() {
  
// Map<String, int> contacts = {

//   'Ali': 9505,

//   'Hamza': 9056,

//   'Umar': 7867,

//   'John': 9290,

//   'Ben': 8808
// };

// var keys =contacts.keys.where((key) => key.length == 4);

// print(keys);
// }


// Question=6  Nested countries Map 

// void main() {

// Map<String, dynamic > world ={

// "countries": {

//   "Pakistan": {

//     "capital": "Islamabad",

//     "currency": "PKR",

//     "language": "Urdu"
//   },

//   "India": {

//     "capital": "delhi",

//     "currency1": "Rupee",

//     "language": "Hindi"
//   },
//  }
// };

// print(world["countries"]["Pakistan"]["capital"]);

// print(world["countries"]["Pakistan"]["currency"]);

// }


// Question=7  Check fri in expences

// void main() {
  
//   Map<String, double> expenses = {

//     'sun': 3000.0,

//     'mon': 3000.0,

//     'tue': 3234.0, 
//   };

//   if (expenses.containsKey('fri')) {

//    print(true);

//   } else {

//     expenses["fri"] = 5000.0;
//   }

// print (expenses);
// }


// Question=8  Remove false value

// void main() {
  
// List<Map<String, dynamic>>

// usersEligibility = [

//   {'name': 'Ali', 'Eligible': true},

//   {'name': 'Hamza', 'Eligible': false},

//   {'name': 'Umar', 'Eligible': true},

//   {'name': 'John', 'Eligible': true},

//   {'name': 'Ben', 'Eligible': false}
  
// ];

// usersEligibility.removeWhere((user) => user["Eligible"] == false);

// print(usersEligibility);
// }


// QUESTION=9  Maximum value

// void main() {
  
//   List<int> numbers =[10,25,5,40,15];

// int maximum = numbers[0]; 

// for(int number in numbers) {

//   if(number > maximum) {

//     maximum = number;
//   }
// }

// print("Maximum : $maximum");
// }


// Question=10  Remove duplicates string

// void main() {
  
//   List<String> names = ['Ali', 'Hamza', 'Umar', 'John', 'Ben', 'Ali', 'Hamza'];
  
//   List<String> uniqueNames = names.toSet().toList();
  
//   print(uniqueNames);
// }


// Question=11  find n elements 

// void main() {
  
//   List<int> numbers =[10,25,5,40,15];
  
//   int n = 3; 
  
//   List<int> result = numbers.take(n).toList();
  
//   print("result: $result");
// }
  

//   Question=12  Reverse list without changing orignal

// void main() {
  
//   List<String> names =['Ali', 'Hamza', 'Umar', 'John', 'Ben'];
  
//   List<String> reversedNames = names.reversed.toList();
  
//   print(reversedNames);

//   print(names);
// }


// Question=13  Unique integer list

// void main() {
  
//   List<int> numbers = [1, 2, 3, 4, 5, 1, 2, 3];
  
//   List<int> uniqueNumbers = numbers.toSet().toList();
  
//   print(uniqueNumbers);
// }


// Question=14  Sort ascending without changing original

// void main (){
  
//   List<int> numbers = [5, 2, 8, 1, 4];
  
//   List<int> sortedNumbers = List.from(numbers)..sort();

//   print(sortedNumbers);
  
//   print(numbers);
// }


// Question=15  Filter positive numbers using where

//  void main() {
  
//   List<int> numbers = [-5, 2, -8, 1, 4];
  
//   List<int> positiveNumbers = numbers.where((number) => number > 0).toList();
  
//   print(positiveNumbers);
//   }


// Question=16  Filter even numbers using where

// void main() {
  
//   List<int> numbers = [1, 2, 3, 4, 5, 6];
  
//   List<int> evenNumbers = numbers.where((number) => number % 2 == 0).toList();
  
//   print(evenNumbers);
// }


// Question=17  Square of numbers using map

//  void main() {
  
//   List<int> numbers = [1, 2, 3, 4, 5];
  
//   List<int> squaredNumbers = numbers.map((number) => number * number).toList();
  
//   print(squaredNumbers);
//  }


// Question=18  Student and over 18

// void main (){

// Map<String, dynamic> students = {

//   "name": "Ali",

//   "age": 25,

//   "isStudent": true

// };

// if (students["isStudent"] == true && students["age"] > 18) {

//   print("Eligible");
// }

//  else {

//   print("Not eligible");
//  };
// }


// Question=19  Product in stock

// void main() {
  
//   Map<String, dynamic> product = {

//     "name": "Laptop",

//     "price": 50000,

//     "quantity": 5

//   };

//   if (product["quantity"] > 0) {

//     print("Product in stocks ");

//   } else {

//     print("Product out of stock");
//   }
// }


// Question=20 Car is red sedan

// void main() {
  
//   Map<String, dynamic> car = {

//     'brand': "Toyota",

//     "color": "red",

//     "is sedan": true,

//   };

//   if (car["is sedan"] == true && car["color"] == "red") {
    
//     print(" Match");

//   } else {

//     print("No match");
//   }
// }


// question=21  Check active admin

// void main() {
  
//   Map<String, dynamic> user = {

//     "name": "Ali",

//     "isAdmin": true,

//     "isActive": true
//   };

//   if (user["isAdmin"] == true && user["isActive"] == true) {

//     print("User is an Active admin");

//   } else {

//     print("User is not an Active admin");
//   }
// }


// //  QUESTION=22  Check if Apple exist

void main() {
  
  Map<String, int> cart = {
    "Apple": 5,
    "Banana": 10,
    
    "Mango": 12
  };
  
  if (cart.containsKey("Apple")) {
    
    print("product found");
  
  } else {
    
    print("product not found");
  }
}



