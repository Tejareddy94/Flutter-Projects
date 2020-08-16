import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  CustomCircleAvatar({Key key, this.firstName, this.lastName, this.font, this.parentContext})
      : super(key: key);
  final firstName;
  final lastName;
  final font;
  final parentContext;

  String getInitials(firstName, lastName) {
    // var splited = name.split(" ");
    final first = firstName == null || firstName == "" ? '' : firstName[0].toUpperCase();
    final last = lastName == null || lastName == "" ? '' : lastName[0].toUpperCase();
    return (first + last);
  }

  Color getColor(name) {
    var colors = {
      'a': Colors.red,
      'b': Colors.orangeAccent,
      'c': Colors.deepPurpleAccent,
      'd': Colors.cyanAccent,
      'e': Colors.yellow,
      'f': Colors.blueAccent,
      'g': Colors.green,
      'h': Colors.greenAccent,
      'i': Colors.blue,
      'j': Colors.blueAccent,
      'k': Colors.lightBlueAccent,
      'l': Colors.indigoAccent,
      'm': Colors.purple,
      'n': Colors.purpleAccent,
      'o': Colors.orange,
      'p': Colors.orangeAccent,
      'q': Colors.greenAccent,
      'r': Colors.green,
      's': Colors.lightBlue,
      't': Colors.indigo,
      'u': Colors.deepPurple,
      'v': Colors.deepPurpleAccent,
      'w': Colors.lime,
      'x': Colors.pink,
      'y': Colors.teal,
      'z': Colors.pinkAccent,
    };
    return name == null || name == "" || name == "?" ? Colors.pink : colors[name[0].toLowerCase()];
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        child: Center(
          child: Text(getInitials(firstName, lastName), style: TextStyle(color: Colors.white, fontSize: 38.0,),),
        ),
        color: getColor(firstName),
        width: MediaQuery.of(parentContext).size.width * 0.23,
        height: MediaQuery.of(parentContext).size.width * 0.23,
      ),
    );
  }
}
