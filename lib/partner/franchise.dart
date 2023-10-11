import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';



import 'package:flutter/cupertino.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../size_config.dart';

class franchise extends StatefulWidget {
  @override
  _franchiseState createState() => _franchiseState();
}

class _franchiseState extends State<franchise> {

  List data = new List();
  String image,firstheading,aboutheading,secondheading,aboutsecond,contact,phone,email;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recent_data();
  }

  Future recent_data() async {
    print("ya its working");
    String url = 'http://meflisyservice.com/franchise.php';
    http.Client client = new http.Client();

    final response = await client.get(url);
    var resbody = jsonDecode(response.body);
    setState(() {
      if (response.statusCode == 200) {
        data = resbody;
        print("The data is ${data}");
        if (data.length > 0) {
          for (var u in data) {
            image = u['image'];
            firstheading = u['firstheading'];
            aboutheading = u['aboutheading'];
            secondheading = u['secondheading'];
            aboutsecond = u['aboutsecond'];
            contact = u['contact'];
            phone = u['phone'];
            email=u['email'];
          }
          // print("The about is "+about);
          client.close();
        } else {
          client.close();
        }
      } else {
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(
          "Become Franchise",
          style: TextStyle(color: Color(0xFF00ACC1)),
        ),
        automaticallyImplyLeading: true,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          image!=null?Container(
            height: 100*SizeConfig.imageSizeMultiplier,
            child: CachedNetworkImage(
              imageUrl: image,
              imageBuilder: (context,
                  imageProvider) =>
                  Container(
                    decoration:
                    BoxDecoration(
                      borderRadius:
                      new BorderRadius
                          .circular(
                          13.0),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
              placeholder: (context,
                  url) =>
                  SpinKitWave(
                    color: Color(0xFF00ACC1),
                    size: 50.0,
                    type: SpinKitWaveType.start,
                  ),
              errorWidget:
                  (context, url,
                  error) =>
                  Icon(Icons
                      .error),
            ),
          ):SpinKitWave(
            color: Color(0xFF00ACC1),
            size: 50.0,
            type: SpinKitWaveType.start,
          ),
          Card(
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                firstheading!=null?Container(
                  margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                  child: Text(
                    firstheading,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ):SizedBox(),
                aboutheading!=null?Container(
                  margin: EdgeInsets.only(top: 5, left: 5, right: 5),
                  child: Text(
                    aboutheading,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ):SizedBox(),
              ],
            ),
          ),
          Card(
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                secondheading!=null?Container(
                  margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                  child: Text(
                    secondheading,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ):SizedBox(),
                aboutsecond!=null?Container(
                  margin: EdgeInsets.only(top: 5, left: 5, right: 5),
                  child: Text(
                    aboutsecond,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ):SizedBox(),
              ],
            ),
          ),
          Card(
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                contact!=null?Container(
                  margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                  child: Text(
                    contact,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ):SizedBox(),
                phone!=null?Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        launch('tel:+91'+phone);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10, left: 10),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(0xFF00ACC1),
                      ),
                      child: Row(

                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.call,
                            color: Colors.white,
                            size:35,
                          ),
                          Text(
                            phone,
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),

                ):SizedBox(),

                email!=null?Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        launch("mailto:"+email);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10, left: 10),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(0xFF00ACC1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: <Widget>[
                          Icon(
                            Icons.mail,
                            color: Colors.white,
                            size:35,
                          ),
                          Text(
                            "info@meflisyservice.com",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),

                ):SizedBox(),
              ],
            ),
          ),





        ],
      ),
    );
  }
}
