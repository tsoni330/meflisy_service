import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../detail_profile.dart';
import '../profile_image.dart';

import 'package:http/http.dart' as http;

import '../size_config.dart';

class History extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HistoryState();
  }
}

class HistoryState extends State<History> {
  List data;
  String name;
  String profession;
  String partnerid;
  String userid, nowdate;
  bool check = true;

  getUserid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString("phone_number");
      // recent_data();
      print(userid);
    });
  }

  getDate() {
    var paymentdate = new DateTime.now();
    setState(() {
      nowdate = new DateFormat("yyyy-MM-dd").format(paymentdate).toString();
      print("The date is {$nowdate}");
    });
  }

  Future recent_call(String phone, String image, String name, String state,
      String city, String userid, String title, String nowdate) async {
    String url = 'http://meflisyservice.com/recent.php';
    http.Client client = new http.Client();

    final response = await client.post(url, body: {
      'state': state,
      'city': city,
      'partnerid': phone,
      'userid': userid,
      'profession': title,
      'image': image,
      'date': nowdate,
      'name': name
    });
    setState(() {
      if (response.statusCode == 200) {
        print("Data save in recent ");
      } else {
        Fluttertoast.showToast(
            msg: " Something went wronge " + response.statusCode.toString(),
            timeInSecForIos: 4);
      }
    });
  }

  Future<List<Photo>> recent_data() async {
    List<Photo> list1 = [];
    String url = 'http://meflisyservice.com/recent_show.php';
    http.Client client = new http.Client();

    final response = await client.post(url, body: {'userid': userid});
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      for (var u in jsonData) {
        Photo d = Photo(u['name'], u['profession'], u['partnerid'], u['date'],
            u['image'], u['state'], u['city']);
        list1.add(d);
      }
    } else {
      Fluttertoast.showToast(
          msg: " Something went wronge ", timeInSecForIos: 4);
    }

    return list1;
  }

  @override
  void initState() {
    getDate();
    getUserid();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder(
      future: recent_data(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Center(child: new Text('Check Your connection'));
          case ConnectionState.waiting:
            return Center(
                child: SpinKitFadingCircle(
              color: Color(0xFF00ACC1),
              size: 70,
            ));
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return createListView(context, snapshot);
        }
      },
    );
    // TODO: implement build
    return Scaffold(
      backgroundColor: Color(0xFF00ACC1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF00ACC1),
        title: Text(
          "HISTORY",
          style: TextStyle(fontSize: 2.3 * SizeConfig.textMultiplier),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
              topLeft: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
            )
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 7 * SizeConfig.imageSizeMultiplier,
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  futureBuilder
                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Photo> list = snapshot.data;
    if (list.length <= 0) {
      return Center(
          child: Container(
              margin: EdgeInsets.only(top: 20),
              child: Column(children: <Widget>[
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "You not call any service provider",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ])));
    } else {
      return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child: new Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1.0),
                ),
                color: Colors.white,
                elevation: 0,
                child: Container(
                  margin: EdgeInsets.only(top: 1, left: 1, right: 1),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            displaySelectedFile(list[index].image),
                            new Expanded(
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  list[index].name != null
                                      ? Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: new Text(
                                            list[index].name,
                                            style: TextStyle(
                                                fontSize: 2.1 *
                                                    SizeConfig.textMultiplier,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      : Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                  list[index].profession != null
                                      ? Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: new Text(
                                            list[index].profession,
                                            style: TextStyle(
                                              fontSize:
                                                  2 * SizeConfig.textMultiplier,
                                              color: Colors.black,
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                  Row(
                                    children: <Widget>[
                                      list[index].city != null
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: new Text(
                                                list[index].city,
                                                style: TextStyle(
                                                    fontSize: 1.8 *
                                                        SizeConfig
                                                            .textMultiplier,
                                                    color: Colors.black),
                                              ),
                                            )
                                          : Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                      list[index].date != null
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 2.0, left: 10),
                                              child: new Text(
                                                list[index].date,
                                                style: TextStyle(
                                                    fontSize: 1.8 *
                                                        SizeConfig
                                                            .textMultiplier,
                                                    color: Colors.black),
                                              ),
                                            )
                                          : Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      launch('sms:+91' + list[index].partnerid);
                                    },
                                    child: Icon(
                                      Icons.message,
                                      size:
                                          7.5 * SizeConfig.imageSizeMultiplier,
                                      color: Color(0xFF00ACC1),
                                    ),
                                  ),
                                  Text("Message"),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        recent_call(
                                            list[index].partnerid,
                                            list[index].image,
                                            list[index].name,
                                            list[index].state,
                                            list[index].city,
                                            userid,
                                            list[index].profession,
                                            nowdate);
                                        launch(
                                            'tel:+91' + list[index].partnerid);
                                      });
                                    },
                                    child: Icon(
                                      Icons.call,
                                      size:
                                          7.5 * SizeConfig.imageSizeMultiplier,
                                      color: Color(0xFF00ACC1),
                                    ),
                                  ),
                                  Text("Call"),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      launch('https://wa.me/+91' +
                                          list[index].partnerid);
                                    },
                                    child: Container(
                                      width:
                                          9.5 * SizeConfig.imageSizeMultiplier,
                                      height:
                                          7.5 * SizeConfig.imageSizeMultiplier,
                                      child: Image.asset("images/WhatsApp.png"),
                                    ),
                                  ),
                                  Text("Whatsapp"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
    }
  }

  Widget displaySelectedFile(String file) {
    return GestureDetector(
      child: new Container(
        margin: EdgeInsets.only(right: 15),
        height: 20.5 * SizeConfig.imageSizeMultiplier,
        width: 20.5 * SizeConfig.imageSizeMultiplier,
        child: file == null
            ? new Center(
                child: Container(
                  color: Colors.transparent,
                  child: CircularProgressIndicator(),
                ),
              )
            : new CircleAvatar(
                maxRadius: 12.5 * SizeConfig.imageSizeMultiplier,
                minRadius: 10.5 * SizeConfig.imageSizeMultiplier,
                backgroundColor: Colors.transparent,
                backgroundImage: MemoryImage(base64Decode(file)),
              ),
      ),
    );
  }
}

class Photo {
  final String name;
  final String profession;
  final String partnerid;
  final String date;
  final String image;
  final String state;
  final String city;

  Photo(this.name, this.profession, this.partnerid, this.date, this.image,
      this.state, this.city);
/*
  factory Photo.fromJson(Map json) {
    return new Photo._(
        name: json['name'],
        profession: json['profession'],
        partnerid: json['partnerid'],
        image: json['image'],
        date: json['date'],
        state: json['state'],
        city: json['city']);
  }*/
}
