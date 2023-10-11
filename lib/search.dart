import 'package:flutter/material.dart';



class search extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _searchstate();
  }

}

class _searchstate extends State<search>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00ACC1),
        title: Text("Search"),
      ),
    );
  }


}