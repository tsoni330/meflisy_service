import 'package:flutter/material.dart';

class Howtobecome extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return HowtobecomeState();
  }
}

class HowtobecomeState extends State<Howtobecome>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Become Service Partner"),

        backgroundColor: Color(0xFF00ACC1),

      ),
    );
  }
}