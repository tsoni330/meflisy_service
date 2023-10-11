import 'dart:convert';

import 'package:flutter/material.dart';

class profile_image extends StatefulWidget {
  String name, image;

  profile_image(this.name, this.image);

  @override
  _profile_imageState createState() => _profile_imageState();
}

class _profile_imageState extends State<profile_image> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Hero(
          tag: widget.name,
          child: displaySelectedFile(widget.image),
        ),
      ),
    );
  }

  Widget displaySelectedFile(String file) {
    return GestureDetector(
      child: new Container(
        margin: EdgeInsets.only(right: 15),
        height: 300,
        width: MediaQuery.of(context).size.width,
        child: file == null
            ? new Center(
          child: Container(
            color: Colors.transparent,
            child: CircularProgressIndicator(),
          ),
        )
            : new Image.memory(
          base64Decode(file),
          width: MediaQuery
              .of(context)
              .size
              .width,
          height:MediaQuery.of(context).size.height/2,
        ),
      ),
    );
  }
}
