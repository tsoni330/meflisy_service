import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:meflisy_service/profile_image.dart';
import 'package:http/http.dart' as http;
import 'package:meflisy_service/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:url_launcher/url_launcher.dart';

import 'detail_profile.dart';

class cityProfession2 extends StatefulWidget {
  String title, state, city, locality, sub_profession;

  cityProfession2(
      this.title, this.state, this.city, this.locality, this.sub_profession);

  @override
  _cityProfession2State createState() => _cityProfession2State();
}

class _cityProfession2State extends State<cityProfession2> {
  List<Photo> list;
  List data;
  bool notEmpty = true;

  String userid, nowdate;

  getDate() {
    var paymentdate = new DateTime.now();
    setState(() {
      nowdate = new DateFormat("yyyy-MM-dd").format(paymentdate).toString();
      print("The date is {$nowdate}");
    });
  }

  getUserid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString("phone_number");
      print(userid);
    });
  }

  Future recent_call(String phone, String image, String name) async {
    final prefs = await SharedPreferences.getInstance();

    String url = 'http://meflisyservice.com/recent.php';
    http.Client client = new http.Client();

    final response = await client.post(url, body: {
      'state': widget.state,
      'city': widget.city,
      'partnerid': phone,
      'userid': userid,
      'profession': widget.title,
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

  Future local_Partners() async {
    String url = 'http://meflisyservice.com/city_partner2.php';
    http.Client client = new http.Client();

    final response = await client.post(url, body: {
      'state': widget.state,
      'city': widget.city,
      'locality': widget.locality,
      'profession': widget.title,
      'sub_profession': widget.sub_profession
    });
    setState(() {
      print("The sub_profession are " + widget.sub_profession);
      if (response.statusCode == 200) {
        data = json.decode(response.body);
        list = (json.decode(response.body) as List)
            .map((data) => new Photo.fromJson(data))
            .toList();
        print(data);
        if (list.length <= 0 || list.isEmpty) {
          notEmpty = false;
        }
      } else {
        Fluttertoast.showToast(
            msg: " Something went wronge " + response.statusCode.toString(),
            timeInSecForIos: 4);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getDate();
    getUserid();
    local_Partners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00ACC1),
        title: Text(
          widget.sub_profession.toUpperCase(),
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            list != null && notEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => detail_profile(
                                        widget.title,
                                        widget.state,
                                        widget.city,
                                        widget.locality,
                                        list[index].sub_profession,
                                        list[index].name,
                                        list[index].address,
                                        list[index].phone,
                                        list[index].description,
                                        list[index].image,
                                        list[index].keyword)));
                          },
                          child: new Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1.0),
                            ),
                            color: Colors.white,
                            elevation: 3,
                            child: Container(
                              margin:
                                  EdgeInsets.only(top: 1, left: 1, right: 1),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        displaySelectedFile(list[index].image,
                                            list[index].phone),
                                        new Expanded(
                                          child: new Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              list[index].name != null
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: new Text(
                                                        list[index].name,
                                                        style: TextStyle(
                                                            fontSize: 2.4 *
                                                                SizeConfig
                                                                    .textMultiplier,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    )
                                                  : Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                              widget.title != null
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: new Text(
                                                        widget.title,
                                                        style: TextStyle(
                                                            fontSize: 2 *
                                                                SizeConfig
                                                                    .textMultiplier,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    )
                                                  : Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                              list[index].sub_profession != null
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5.0),
                                                      child: new Text(
                                                        list[index]
                                                            .sub_profession
                                                            .replaceAll(
                                                                ", ,", "")
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            fontSize: 1.5 *
                                                                SizeConfig
                                                                    .textMultiplier,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    )
                                                  : Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4.0, bottom: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          int.parse(list[index]
                                                          .rating
                                                          .toString())
                                                      .toInt() !=
                                                  0
                                              ? SmoothStarRating(
                                                  allowHalfRating: false,
                                                  starCount: 5,
                                                  rating: int.parse(list[index]
                                                          .rating
                                                          .toString())
                                                      .toInt()
                                                      .toDouble(),
                                                  size: 5 *
                                                      SizeConfig
                                                          .imageSizeMultiplier,
                                                  color: Color(0xFF00Acc1),
                                                  borderColor:
                                                      Color(0xff00Acc1),
                                                  spacing: 1.0)
                                              : Text("No rating yet"),
                                          Column(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  launch('sms:+91' +
                                                      list[index].phone);
                                                },
                                                child: Icon(
                                                  Icons.message,
                                                  size: 7.2 *
                                                      SizeConfig
                                                          .imageSizeMultiplier,
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
                                                        list[index].phone,
                                                        list[index].image,
                                                        list[index].name);
                                                    launch('tel:+91' +
                                                        list[index].phone);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.call,
                                                  size: 7.2 *
                                                      SizeConfig
                                                          .imageSizeMultiplier,
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
                                                      list[index].phone);
                                                },
                                                child: Container(
                                                  width: 9.55 *
                                                      SizeConfig
                                                          .imageSizeMultiplier,
                                                  height: 7.2 *
                                                      SizeConfig
                                                          .imageSizeMultiplier,
                                                  child: Image.asset(
                                                      "images/WhatsApp.png"),
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
                    })
                : new Center(
                    child: notEmpty
                        ? Shimmer.fromColors(
                      child:ListTile(
                        contentPadding: EdgeInsets.all(10.0),
                        title:  Container(
                          height: 4 * SizeConfig.imageSizeMultiplier,
                          width: 14 * SizeConfig.imageSizeMultiplier,
                          color: Colors.black,
                        ),
                        leading: Container(
                          width: 16.2*SizeConfig.imageSizeMultiplier,
                          height: 16.2*SizeConfig.imageSizeMultiplier,
                          color: Colors.black,
                        ),
                        subtitle: Container(
                          height: 4 * SizeConfig.imageSizeMultiplier,
                          width: 10* SizeConfig.imageSizeMultiplier,
                          color: Colors.black,
                        ),
                      ),
                      highlightColor: Colors.grey,
                      baseColor: Colors.grey[300],
                    )
                        : Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Column(
                              children: <Widget>[
                                Image.asset("images/nothinfound.png"),
                                GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "We are continously adding service providers. We will add within somedays at your location",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  )
          ],
        ),
      ),
    );
  }

  Widget displaySelectedFile(String file, String name) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => profile_image(name, file)));
      },
      child: new Container(
        margin: EdgeInsets.only(right: 15),
        height: 21.5 * SizeConfig.imageSizeMultiplier,
        width: 21.5 * SizeConfig.imageSizeMultiplier,
        child: file == null
            ? new Center(
                child: Container(
                  color: Colors.transparent,
                  child: CircularProgressIndicator(),
                ),
              )
            : new CircleAvatar(
                maxRadius: 12 * SizeConfig.imageSizeMultiplier,
                minRadius: 7.2 * SizeConfig.imageSizeMultiplier,
                backgroundColor: Colors.transparent,
                backgroundImage: MemoryImage(base64Decode(file)),
              ),
      ),
    );
  }
}

class Photo {
  final String sub_profession;
  final String name;
  final String address;
  final String phone;
  final String description;
  final String image;
  final String keyword;
  final String rating;

  Photo._(
      {this.name,
      this.address,
      this.phone,
      this.description,
      this.image,
      this.sub_profession,
      this.keyword,
      this.rating});

  factory Photo.fromJson(Map json) {
    return new Photo._(
        name: json['name'],
        address: json['address'],
        phone: json['phone_number'],
        image: json['profile_image'],
        description: json['description'],
        keyword: json['keyword'],
        sub_profession: json['sub_profession'],
        rating: json['rating']);
  }
}
