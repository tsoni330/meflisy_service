import 'package:flutter/material.dart';



class favourit extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _favouritstate();
  }
  
}

class _favouritstate extends State<favourit>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00ACC1),
        title: Text("Favourit"),
      ),
    );
  }
  
  
}