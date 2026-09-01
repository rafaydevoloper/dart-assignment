void main () {

Map<String,String> student = {
  "name": "rafay",
  "city": "karachi",
  "age": "18",
};
 print (student);

print(student["name"]);

print (student.remove("age"));
print (student.containsKey("name"));
print (student.containsKey("country"));
print (student.containsValue("18"));

print (student.length);

print (student.keys);

}



 Map<String, String> newMethod(Map<String, String> student) => student; 

