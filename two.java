
import 'dart :io';

void main (){

List<String> students =[];

print ("Enter student name ");
String name = stdin.readLineSync()!;

students.add(name);
print ("student added!");
print ("student: $students ");


}