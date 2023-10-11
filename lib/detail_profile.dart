import 'dart:convert';


import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:meflisy_service/profile_image.dart';
import 'package:meflisy_service/report.dart';
import 'package:meflisy_service/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:intl/intl.dart';

class detail_profile extends StatefulWidget {
  final String title, state, city, locality;
  final String sub_profession;
  final String name;
  final String address;
  final String phone;
  final String description;
  final String image;
  final String keyword;

  detail_profile(
      this.title,
      this.state,
      this.city,
      this.locality,
      this.sub_profession,
      this.name,
      this.address,
      this.phone,
      this.description,
      this.image,
      this.keyword);

  @override
  _detail_profileState createState() => _detail_profileState();
}

class _detail_profileState extends State<detail_profile> {
  List<Photo> list;
  List data, data2;
  bool check = false;
  List<Photo2> list2;
  String userPhone, userName, nowdate, userreview;
  double rating1 = 0.0;

  getDate() {
    var paymentdate = new DateTime.now();
    setState(() {
      nowdate = new DateFormat("yyyy-MM-dd").format(paymentdate).toString();
    });
  }

  Future<String> showCommentsandReviews() async {
    String localityurl = "http://meflisyservice.com/review_rating_show.php";
    http.Client client = new http.Client();
    var response = await client.post(Uri.encodeFull(localityurl),
        body: {'partnerid': widget.phone, 'profession': widget.title});
    setState(() {
      if (response.statusCode == 200) {
        data = json.decode(response.body);
        list = (json.decode(response.body) as List)
            .map((data) => new Photo.fromJson(data))
            .toList();
        print(data);
        if (list.length <= 0 && list.isEmpty) {
          check = false;
        } else
          check = true;
      } else {
        check = false;
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });
    client.close();
    return 'Success';
  }

  Future<String> postCommentsandReviews() async {
    String localityurl = "http://meflisyservice.com/review_rating_upload.php";
    http.Client client = new http.Client();
    var response = await client.post(Uri.encodeFull(localityurl), body: {
      'partnerid': widget.phone,
      'profession': widget.title,
      'username': userName,
      'rating': rating1.toString(),
      'date': nowdate,
      'review': userreview,
      'userid': userPhone,
      'state': widget.state,
      'city': widget.city
    });

    if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Post is save", timeInSecForIos: 4);
      } else {
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }

    client.close();
    return 'Success';
  }

  getUserDetail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userPhone = prefs.getString("phone_number");
      print("The user number is " + userPhone);
      getUserName();
      showCommentsandReviews();
    });
  }

  Future<String> getUserName() async {
    String localityurl = "http://meflisyservice.com/get_user.php";
    http.Client client = new http.Client();
    var response = await client
        .post(Uri.encodeFull(localityurl), body: {'phone_number': userPhone});
    setState(() {
      if (response.statusCode == 200) {
        data2 = json.decode(response.body);
        list2 = (json.decode(response.body) as List)
            .map((data) => new Photo2.fromJson(data))
            .toList();
        print(data2);
        if (list2.length <= 0 && list2.isEmpty) {
          check = false;
        } else {
          for (var u in data2) {
            userName = u['name'];
          }
          if (userName == null) {
            userName = "No Name";
          }
          print("The username is " + userName);
        }
      } else {
        check = false;
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });
    client.close();
    return 'Success';
  }

  @override
  void initState() {
    super.initState();
    getDate();
    getUserDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: TextStyle(color: Color(0xFF00ACC1)),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF00ACC1)),
        actions: <Widget>[
          IconButton(
            icon: IconButton(
              padding: EdgeInsets.only(right: 20, bottom: 10),
              icon: Icon(
                Icons.report,
                color: Color(0xFF00ACC1),
                size: 8 * SizeConfig.imageSizeMultiplier,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Report(widget.phone,widget.state,widget.city,widget.title)));
              },
            ),
          ),
        ],
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 5, top: 5),
            width: MediaQuery.of(context).size.width,
            height: 48 * SizeConfig.imageSizeMultiplier,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    widget.title != null
                        ? Container(
                            width: 28.5 * SizeConfig.imageSizeMultiplier,
                            height: 28.5 * SizeConfig.imageSizeMultiplier,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(
                                        "http://meflisyservice.com/category%20images/" +
                                            widget.title +
                                            ".png"),
                                    fit: BoxFit.fill)),
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                    displaySelectedFile(widget.image),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            launch('sms:+91' + widget.phone);
                          },
                          child: Icon(
                            Icons.message,
                            size: 7.2 * SizeConfig.imageSizeMultiplier,
                            color: Color(0xFF00ACC1),
                          ),
                        ),
                        Text(
                          "Message",
                          style: TextStyle(color: Color(0xFF00ACC1)),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              launch('tel:+91' + widget.phone);
                            });
                          },
                          child: Icon(
                            Icons.call,
                            size: 7.2 * SizeConfig.imageSizeMultiplier,
                            color: Color(0xFF00ACC1),
                          ),
                        ),
                        Text(
                          "Call",
                          style: TextStyle(color: Color(0xFF00ACC1)),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            launch('https://wa.me/+91' + widget.phone);
                          },
                          child: Container(
                            width: 9.55 * SizeConfig.imageSizeMultiplier,
                            height: 7.2 * SizeConfig.imageSizeMultiplier,
                            child: Image.asset("images/WhatsApp.png"),
                          ),
                        ),
                        Text(
                          "Whatsapp",
                          style: TextStyle(color: Color(0xFF00ACC1)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Text(
                    "Services",
                    style: TextStyle(color: Colors.black, fontSize: 2.25*SizeConfig.textMultiplier),
                  ),
                ),
                Container(
                  child: Text(
                    widget.sub_profession
                        .toUpperCase()
                        .replaceAll(',', '\n'),
                    style: TextStyle(color: Colors.black54, fontSize: 1.8*SizeConfig.textMultiplier),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Text(
                    "About MySelf",
                    style: TextStyle(color: Colors.black, fontSize: 2.25*SizeConfig.textMultiplier),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: widget.description != null && widget.description != ''
                      ? Text(
                          widget.description,
                          style: TextStyle(color: Colors.black54, fontSize: 2*SizeConfig.textMultiplier),
                        )
                      : Text("He is not write anything"),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Text(
                    "Address",
                    style: TextStyle(color: Colors.black, fontSize: 2.25*SizeConfig.textMultiplier),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.address,
                    style: TextStyle(color: Colors.black54, fontSize: 2*SizeConfig.textMultiplier),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Text(
                    "Ratings and Reviews",
                    style: TextStyle(color: Colors.black, fontSize: 2.25*SizeConfig.textMultiplier),
                  ),
                ),
                check
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          list[index].username,
                                          style: TextStyle(fontSize: 2.2*SizeConfig.textMultiplier),
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: SmoothStarRating(
                                                allowHalfRating: false,
                                                starCount: 5,
                                                rating: double.parse(
                                                    list[index].rating),
                                                size: 4*SizeConfig.imageSizeMultiplier,
                                                color: Color(0xFF00Acc1),
                                                borderColor: Color(0xff00Acc1),
                                                spacing: 1.0),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Text(
                                              list[index].date,
                                              style: TextStyle(fontSize:1.5*SizeConfig.textMultiplier),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          list[index].review,
                                          style: TextStyle(fontSize: 1.9*SizeConfig.textMultiplier),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                    : Container(
                        child: Text(
                          "No Ratings and Reviews yet",
                          style: TextStyle(color: Colors.black54, fontSize: 2*SizeConfig.textMultiplier),
                        ),
                      ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Text(
                    "Rate this service",
                    style: TextStyle(color: Colors.black, fontSize: 2.25*SizeConfig.textMultiplier),
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: SmoothStarRating(
                            allowHalfRating: false,
                           /* onRatingChanged: (v) {
                              rating1 = v;
                              setState(() {});
                            },*/
                            onRated: (v){
                              rating1=v;
                              setState(() {
                              });
                            },
                            starCount: 5,
                            rating: rating1,
                            size: 7.2*SizeConfig.imageSizeMultiplier,
                            color: Color(0xFF00Acc1),
                            borderColor: Color(0xff00Acc1),
                            spacing: 1.0),
                      ),
                      TextField(
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 2.25*SizeConfig.textMultiplier),
                        decoration: InputDecoration(
                          labelText: "Write your exprience *",
                          labelStyle:
                              TextStyle(color: Colors.black54, fontSize: 1.5*SizeConfig.textMultiplier),
                          fillColor: Colors.black54,
                        ),
                        keyboardType: TextInputType.multiline,
                        onChanged: (value) => userreview = value,
                        textInputAction: TextInputAction.done,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (userreview == null) {
                            userreview = " ";
                          }
                          postCommentsandReviews();
                          setState(() {

                          });
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                  color: Color(0xFF00acc1), width: 2),
                            ),
                            margin: EdgeInsets.only(top: 10.0),
                            child: Text(
                              "Post",
                              style: TextStyle(fontSize: 2.5*SizeConfig.textMultiplier),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget displaySelectedFile(String file) {
    return GestureDetector(
      child: new Container(
        margin: EdgeInsets.only(right: 15),
        width: 30 * SizeConfig.imageSizeMultiplier,
        height: 30* SizeConfig.imageSizeMultiplier,
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
  final String review;
  final String date;
  final String rating;
  final String username;

  Photo._({this.review, this.date, this.rating, this.username});

  factory Photo.fromJson(Map json) {
    return new Photo._(
        review: json['review'],
        date: json['date'],
        rating: json['rating'],
        username: json['username']);
  }
}

class Photo2 {
  final String name;

  Photo2._({this.name});

  factory Photo2.fromJson(Map json) {
    return new Photo2._(
      name: json['name'],
    );
  }
}
