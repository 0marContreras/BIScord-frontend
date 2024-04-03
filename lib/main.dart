import 'package:biscord/chatscreen.dart';
import 'login.dart';
import 'register.dart';
import 'chatscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "VsCord",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,

      ),
    home: ChatScreen(),
    

    );

  }

  // This widget is the root of your application.

}

