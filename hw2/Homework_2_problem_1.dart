import 'dart:io';
import 'package:intl/intl.dart';
/*
Create a program that stores a list of your top 3 favorite movie names
and a fixed set of their release years. Print both the movie titles and their corresponding years.
(10 point)
*/


  void taskMovies() {
    List<String> movies = ["Game of Thrones", "The Matrix", "Banakum"];
    List<int> years = [2011, 1999, 2009];
    print("My Top 3 Favorite Movies and Their Release Years:");

    for (int i = 0; i < movies.length; i++) {
      print("${movies[i]} - ${years[i]}");
    }
  }

/*
Create a string variable and perform various string manipulations such as
concatenation, substring extraction, and changing case, then print the modified string.
(10 points)
*/
  void taskStringManipulation(){
      var str = 'Hello World';
      var newstr = str + 'MobileAppDev';
      var substr = str.substring(1,4);
      var uppstr = substr.toUpperCase();
      var lowstr = str.substring(3,8).toLowerCase();
      print(newstr);
      print(substr);
      print(uppstr);
      print(lowstr);



    }
/*Declare a map with key-value pairs and iterate through it to print both keys and values.
(10 points)
*/
  void mapTask(){
       Map<String, int> map = {"A": 1, "B": 2, "C": 30};
       map.forEach((key, value) {
         print('$key  $value ');
       });
  }
/*Write a function that takes an integer as input and returns a string indicating whether
it's positive, negative, or zero. Call this function with different integer inputs and print the results.
(10 point)
*/
  String intToStr(int num) {
    if (num == 0) {
      return "The number is neither positive nor negative";
    } else if (num < 0) {
      return "The number is negative";
    } else {
      return "The number is positive";
    }
  }

/*
Create a program that asks the user for their name and age,
then prints a personalized greeting with their name and a message based on their age.
(5 points)
*/
  void askAndGreet() {
    stdout.write("Enter your name: ");
    String? name = stdin.readLineSync();
    stdout.write("Enter your age: ");
    int age = int.parse(stdin.readLineSync()!);

    print("Hello dear, $name");

    if (age < 18) {
      print("You are a teenager");
    } else if (age < 60) {
      print("You are an adult.");
    } else {
      print("You are a grandfather.");
    }
  }

/*
Write a function that takes two numbers as input and divides them.
Implement error handling to handle division by zero and print an appropriate message.
(10 point)
*/
  void divideNumbers(num a, num b) {
    try {
      var result = a ~/ b;
      print("$a ~/ $b = $result");
    } catch (e) {
      print("Error: $e");
    }
  }


/*
Get the current date and time, format it, and print it.
(5 point)
 */
  void CurrentDate() {
    DateTime currentdt = DateTime.now();
    String formattedDate = DateFormat('yyyy/MM/dd – kk:mm:ss').format(currentdt);
    print("Current date and time: $formattedDate");
  }



/*
Define a class representing a simple "Person" with properties like name and age.
Create an object of this class and print its properties.
(10 point)
*/
class Person{
  String name;
  int age;

  Person(this.name, this.age);

  void printDetails() {
    print("Name is: $name, He is: $age" " " "years old");
  }
}
/*void main(){
Person person1 = Person("Vahe", 23);
person1.printDetails();
}
*/

/*
Extend Person class and write a function that takes a person's age as input and returns a string
indicating their life stage (e.g., "Child," "Teenager," "Adult”).
(10 point)
*/
class LifeStage extends Person{
  LifeStage(String name, int age) : super(name, age);
  String ageStage(int age){
    if(age < 18){
      return "child";
    }else if(age >18 && age<40){
      return "Teenager";
    }else
      return "Adult";
  }
}
/*void main(){
  LifeStage p1 = LifeStage("Vahe", 22);
  p1.printDetails();
  print("Life Stage: ${p1.ageStage(25)}");

  LifeStage p2 = LifeStage("Sona", 10);
  p2.printDetails();
  print("Life Stage: ${p2.ageStage(44)}");
}
*/
/*
Declare a list of integers and use a lambda function to filter and
print only the even numbers from the list.
(10 point)
*/
void useLambda(){
  List<int> list = [1,2,7,9,11,22,23,27,4,8,16,32,64,128,256];
  List<int> evenNumbers = list.where((n) => n % 2 == 0).toList();
  print("Even numbers: $evenNumbers");
}
void main(){
  useLambda();
  taskMovies();
  taskStringManipulation();
  mapTask();
  intToStr(10);
  divideNumbers(15,5);
  CurrentDate();
  askAndGreet(); //while inputing name and age after filling each field press space and then enter

}


