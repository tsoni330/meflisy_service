import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:meflisy_service/MainHome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import '../size_config.dart';
import 'home_partner.dart';
import 'edit_profile.dart';
import 'package:http/http.dart' as http;

class profile_partner extends StatefulWidget {
  const profile_partner({Key key}) : super(key: key);

  @override
  _profile_partnerState createState() => _profile_partnerState();
}

class _profile_partnerState extends State<profile_partner> {
  String name,
      aadhar,
      address,
      phone,
      statename,
      cityname,
      locality,
      profession,
      sub_profession,
      image,
      description,
      date;
  var newdatetime, difference;

  String pref_image;
  List<Photo> list;
  List data;
  bool check = false;

  Future<bool> _exitApp(BuildContext context) {
    return showDialog(
            context: context,
            builder: (BuildContext context) {
              return new AlertDialog(
                title: new Text('Do you want to close Service Partner'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: new Text('No'),
                  ),
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => MainHome()),
                        (Route<dynamic> route) => false),
                    child: new Text('Yes'),
                  ),
                ],
              );
            }) ??
        false;
  }

  setValued() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("meflisy_name");
      phone = prefs.getString("meflisy_mobile");
      aadhar = prefs.getString("meflisy_aadhar");
      address = prefs.getString("meflisy_address");
      statename = prefs.getString("meflisy_state");
      cityname = prefs.getString("meflisy_city");
      locality = prefs.getString("meflisy_locality");
      profession = prefs.getString("meflisy_profession");
      sub_profession = prefs.getString("meflisy_sub_profession");
      image = prefs.getString("meflisy_image");
      date = prefs.getString("meflisy_data");

      var dateobj = new DateFormat("yyyy-MM-dd").parse(date);
      newdatetime = new DateTime(dateobj.year + 1, dateobj.month, dateobj.day);

      if (prefs.getString("meflisy_description") != null) {
        description = prefs.getString("meflisy_description");
      } else {
        description = "Please add something about service in Edit Profile";
      }
      showCommentsandReviews();
    });
  }

  Future<String> showCommentsandReviews() async {
    String localityurl = "http://meflisyservice.com/review_rating_show.php";
    http.Client client = new http.Client();
    var response = await client.post(Uri.encodeFull(localityurl),
        body: {'partnerid': phone, 'profession': profession});
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

  @override
  void initState() {
    super.initState();

    setValued();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        backgroundColor: Color(0xFF00ACC1),
        appBar: AppBar(
          elevation: 0,
          title: Text("Partner Profile"),
          backgroundColor: Color(0xFF00ACC1),
        ),
        body: checkdata(image),
      ),
    );
  }

  Widget checkdata(String image) {
    return new Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
            topLeft: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
          ),
        ),
        child: image != null
            ? Column(
                children: <Widget>[
                  SizedBox(
                    height: 7 * SizeConfig.imageSizeMultiplier,
                  ),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      margin: EdgeInsets.all(1),
                      child: ListView(
                        children: <Widget>[
                          GestureDetector(
                            child: new Card(
                              elevation: 0,
                              child: Container(
                                margin: EdgeInsets.only(left: 1, right: 1),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(children: <Widget>[
                                    displaySelectedFile(image),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: new Text(
                                        name,
                                        style: TextStyle(
                                            fontSize:
                                                2.5 * SizeConfig.textMultiplier,
                                            color: Color(0xFF00ACC1),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: new Text(
                                        profession,
                                        style: TextStyle(
                                            fontSize:
                                                2 * SizeConfig.textMultiplier,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: new Text(
                                        '${cityname[0].toUpperCase()}${cityname.substring(1)}',
                                        style: TextStyle(
                                            fontSize: 2.25 *
                                                SizeConfig.textMultiplier,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            child: new Card(
                              elevation: 0,
                              child: Container(
                                margin:
                                    EdgeInsets.only(top: 1, left: 1, right: 1),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Align(
                                          child: Text(
                                            "Your Services Areas",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 2 *
                                                    SizeConfig.textMultiplier,
                                                color: Color(0xFF00ACC1),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Align(
                                          child: Text(
                                            locality
                                                .replaceAll(', ,', '')
                                                .toUpperCase(),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize:
                                                  2 * SizeConfig.textMultiplier,
                                            ),
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            child: new Card(
                              elevation: 0,
                              child: Container(
                                margin:
                                    EdgeInsets.only(top: 1, left: 1, right: 1),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Align(
                                          child: Text(
                                            "Your Services",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF00ACC1),
                                                fontSize: 2 *
                                                    SizeConfig.textMultiplier,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Align(
                                          child: Text(
                                            sub_profession
                                                .replaceAll(', ,', '')
                                                .toUpperCase(),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize:
                                                  2 * SizeConfig.textMultiplier,
                                            ),
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            child: new Card(
                              elevation: 0,
                              child: Container(
                                margin:
                                    EdgeInsets.only(top: 1, left: 1, right: 1),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Align(
                                          child: Text(
                                            "Contact Information",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Color(0xFF00ACC1),
                                                fontSize: 2 *
                                                    SizeConfig.textMultiplier,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Align(
                                          child: Text(
                                            "Mobile No. : " + phone,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize:
                                                  2 * SizeConfig.textMultiplier,
                                            ),
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 1.0),
                                        child: Align(
                                          child: Text(
                                            "Address : " + address,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize:
                                                  2 * SizeConfig.textMultiplier,
                                            ),
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            child: new Card(
                              elevation: 0,
                              child: Container(
                                margin:
                                    EdgeInsets.only(top: 1, left: 1, right: 1),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Align(
                                          child: Text(
                                            "Aadharcard Number",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 2 *
                                                    SizeConfig.textMultiplier,
                                                color: Color(0xFF00ACC1),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Align(
                                          child: Text(
                                            aadhar,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize:
                                                  2 * SizeConfig.textMultiplier,
                                            ),
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Align(
                                          child: Text(
                                            "Note : We will not share your aadhar card number anyone and not even to our user\n \nहम आपके आधार कार्ड नंबर को किसी को भी साझा नहीं करेंगे और हमारे उपयोगकर्ता को भी नहीं",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 1.8 *
                                                  SizeConfig.textMultiplier,
                                            ),
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            child: new Card(
                              elevation: 0,
                              child: Container(
                                margin:
                                    EdgeInsets.only(top: 1, left: 1, right: 1),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Align(
                                          child: Text(
                                            "About Service",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 2 *
                                                    SizeConfig.textMultiplier,
                                                color: Color(0xFF00ACC1),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          alignment: Alignment.topLeft,
                                        ),
                                      ),
                                      description != null
                                          ? new Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              child: Align(
                                                child: Text(
                                                  description,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: 2 *
                                                        SizeConfig
                                                            .textMultiplier,
                                                  ),
                                                ),
                                                alignment: Alignment.topLeft,
                                              ),
                                            )
                                          : new Opacity(opacity: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          newdatetime.toString() != null
                              ? GestureDetector(
                                  child: new Card(
                                    elevation: 0,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          top: 1, left: 1, right: 1),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              child: Align(
                                                child: Text(
                                                  "Date of Expiry Service",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: 2 *
                                                          SizeConfig
                                                              .textMultiplier,
                                                      color: Color(0xFF00ACC1),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                alignment: Alignment.topLeft,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              child: Align(
                                                child: Text(
                                                  newdatetime
                                                      .toString()
                                                      .substring(0, 10),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: 2 *
                                                        SizeConfig
                                                            .textMultiplier,
                                                  ),
                                                ),
                                                alignment: Alignment.topLeft,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : CircularProgressIndicator(),
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
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            2.25 * SizeConfig.textMultiplier),
                                  ),
                                ),
                                check
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: list.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Container(
                                            child: new Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1.0),
                                              ),
                                              color: Colors.white,
                                              elevation: 3,
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: 1, left: 1, right: 1),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Text(
                                                          list[index].username,
                                                          style: TextStyle(
                                                              fontSize: 2.2 *
                                                                  SizeConfig
                                                                      .textMultiplier),
                                                        ),
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2.0),
                                                            child: SmoothStarRating(
                                                                allowHalfRating:
                                                                    false,
                                                                starCount: 5,
                                                                rating: double
                                                                    .parse(list[
                                                                            index]
                                                                        .rating),
                                                                size: 15.0,
                                                                color: Color(
                                                                    0xFF00Acc1),
                                                                borderColor: Color(
                                                                    0xff00Acc1),
                                                                spacing: 1.0),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2.0),
                                                            child: Text(
                                                              list[index].date,
                                                              style: TextStyle(
                                                                  fontSize: 1.5 *
                                                                      SizeConfig
                                                                          .textMultiplier),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Text(
                                                          list[index].review,
                                                          style: TextStyle(
                                                              fontSize: 2 *
                                                                  SizeConfig
                                                                      .textMultiplier),
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
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 2 *
                                                  SizeConfig.textMultiplier),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : new Center(child: CircularProgressIndicator()));
  }

  Widget displaySelectedFile(String file) {
    return GestureDetector(
      child: new Container(
        margin: EdgeInsets.only(right: 15),
        height: 40.5 * SizeConfig.imageSizeMultiplier,
        width: 40.5 * SizeConfig.imageSizeMultiplier,
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
