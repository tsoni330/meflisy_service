import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../size_config.dart';

class Contactus extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ContactusState();
  }
}

class ContactusState extends State<Contactus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact us"),
        backgroundColor: Color(0xFF00ACC1),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: (){
                launch('mailto:info@meflisyservice.com');
              },
              child: ListTile(
                leading: Container(
                  width:10*SizeConfig.imageSizeMultiplier, // can be whatever value you want
                  alignment: Alignment.center,
                  child: Icon(Icons.mail,size:10*SizeConfig.imageSizeMultiplier ,),
                ),
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "info@meflisyservice.com",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: (){
                launch('tel:+918882191868');
              },
              child: ListTile(
                leading: Container(
                  width:10*SizeConfig.imageSizeMultiplier, // can be whatever value you want
                  alignment: Alignment.center,
                  child: Icon(Icons.call,size:10*SizeConfig.imageSizeMultiplier ,),
                ),
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "8882191868",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
