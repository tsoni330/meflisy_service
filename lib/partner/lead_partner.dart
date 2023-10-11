import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:meflisy_service/partner/leads_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../MainHome.dart';
import '../size_config.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../size_config.dart';

class lead_partner extends StatefulWidget {
  @override
  _lead_partnerState createState() => _lead_partnerState();
}

class _lead_partnerState extends State<lead_partner> {
  String state, city, locality, sub_profession, partner_id, nowdate;
  List data = new List();
  List<Photo> list;
  bool check = true;

  getDate() {
    var paymentdate = new DateTime.now();
    setState(() {
      nowdate = new DateFormat("yyyy-MM-dd").format(paymentdate).toString();
      print("The date is {$nowdate}");
    });
  }

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.get("meflisy_state");
    city = prefs.get("meflisy_city");
    locality = prefs.get("meflisy_locality");
    sub_profession = prefs.get("meflisy_sub_profession");
    partner_id = prefs.get("meflisy_mobile");
    getleads();
  }

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

  Future getleads() async {
    String url = 'http://meflisyservice.com/getleads.php';
    http.Client client = new http.Client();

    final response = await client.post(url,
        body: {'state': state, 'city': city, 'partner_id': partner_id});
    setState(() {
      if (response.statusCode == 200) {
        data = json.decode(response.body);
        list = (json.decode(response.body) as List)
            .map((data) => new Photo.fromJson(data))
            .toList();
        print("The data is " + data.toString());
        if (list.length <= 0 && list.isEmpty) {
          check = false;
        }
      } else {
        check = false;
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });
  }

  Future updateleads(String date, String user_name, String user_phone) async {
    String url = 'http://meflisyservice.com/update_seen.php';
    http.Client client = new http.Client();

    final response = await client.post(url, body: {
      'partner_id': partner_id,
      'user_name': user_name,
      'user_phone': user_phone,
      'date': date
    });
    setState(() {
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: " Seen done ", timeInSecForIos: 4);
      } else {
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDate();
    getData();
  }


  @override
  void dispose() {
    print("Ya it dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        backgroundColor: Color(0xFF00ACC1),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xFF00ACC1),
          title: Text("Leads"),
          actions: <Widget>[
            IconButton(
              icon: IconButton(
                padding: EdgeInsets.only(right: 20, bottom: 10),
                icon: Icon(
                  Icons.assessment,
                  color: Colors.white,
                  size: 10 * SizeConfig.imageSizeMultiplier,
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => leads_data(partner_id)));
                },
              ),
            ),
          ],
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
              topLeft: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
            ),
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
                    list != null && check
                        ? SizedBox()
                        : SizedBox(),
                    list != null && check
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                  child: Card(
                                margin: EdgeInsets.all(10),
                                elevation: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        new BorderRadius.circular(13.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 2,
                                              child: new Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  list[index].user_name != null
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: new Text(
                                                            list[index]
                                                                .user_name,
                                                            style: TextStyle(
                                                                fontSize: 2.5 *
                                                                    SizeConfig
                                                                        .textMultiplier,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        )
                                                      : Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                  list[index].sub_pro != null
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: new Text(
                                                            "Looking For :- " +
                                                                list[index]
                                                                    .sub_pro
                                                                    .toUpperCase(),
                                                            style: TextStyle(
                                                              fontSize: 2 *
                                                                  SizeConfig
                                                                      .textMultiplier,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        )
                                                      : Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                  list[index].locality != null
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: new Text(
                                                            "Area :- " +
                                                                list[index]
                                                                    .locality,
                                                            style: TextStyle(
                                                                fontSize: 1.8 *
                                                                    SizeConfig
                                                                        .textMultiplier,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        )
                                                      : Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: <Widget>[
                                                      GestureDetector(
                                                        onTap: () {
                                                          launch('sms:+91' +
                                                              list[index]
                                                                  .user_phone);
                                                        },
                                                        child: Icon(
                                                          Icons.message,
                                                          size: 7.5 *
                                                              SizeConfig
                                                                  .imageSizeMultiplier,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          updateleads(
                                                              nowdate,
                                                              list[index]
                                                                  .user_name,
                                                              list[index]
                                                                  .user_phone);
                                                          setState(() {
                                                            launch('tel:+91' +
                                                                list[index]
                                                                    .user_phone);
                                                          });
                                                        },
                                                        child: Icon(
                                                          Icons.call,
                                                          size: 7.5 *
                                                              SizeConfig
                                                                  .imageSizeMultiplier,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    height: 30 *
                                                        SizeConfig
                                                            .imageSizeMultiplier,
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          "http://meflisyservice.com/sub_catogery images/" +
                                                              list[index]
                                                                  .sub_pro +
                                                              ".jpg",
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  13.0),
                                                          image:
                                                              DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                      ),
                                                      placeholder:
                                                          (context, url) =>
                                                              SpinKitWave(
                                                        color:
                                                            Color(0xFF00ACC1),
                                                        size: 30.0,
                                                        type: SpinKitWaveType
                                                            .start,
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 2 *
                                                        SizeConfig
                                                            .imageSizeMultiplier,
                                                  ),
                                                  list[index].date != null
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 2.0,
                                                          ),
                                                          child: new Text(
                                                            list[index].date,
                                                            style: TextStyle(
                                                                fontSize: 1.8 *
                                                                    SizeConfig
                                                                        .textMultiplier,
                                                                color: Colors
                                                                    .black),
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
                                      ],
                                    ),
                                  ),
                                ),
                              ));
                            })
                        : check
                            ? Shimmer.fromColors(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(10.0),
                                    title: Container(
                                      height:
                                          4 * SizeConfig.imageSizeMultiplier,
                                      width:
                                          14 * SizeConfig.imageSizeMultiplier,
                                      color: Colors.black,
                                    ),
                                    leading: Container(
                                      width:
                                          16.2 * SizeConfig.imageSizeMultiplier,
                                      height:
                                          16.2 * SizeConfig.imageSizeMultiplier,
                                      color: Colors.black,
                                    ),
                                    subtitle: Container(
                                      height:
                                          4 * SizeConfig.imageSizeMultiplier,
                                      width:
                                          10 * SizeConfig.imageSizeMultiplier,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                highlightColor: Colors.grey,
                                baseColor: Colors.grey[300],
                              )
                            : Container(
                                margin: EdgeInsets.only(top: 20),
                                child: Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "Ops No Leads Found",
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Photo {
  final String user_name;
  final String date;
  final String state;
  final String city;
  final String user_phone;
  final String sub_pro;
  final String visiblity;
  final String locality;

  Photo._(
      {this.user_name,
      this.date,
      this.user_phone,
      this.state,
      this.city,
      this.sub_pro,
      this.visiblity,
      this.locality});

  factory Photo.fromJson(Map json) {
    return new Photo._(
        user_name: json['user_name'],
        user_phone: json['user_phone'],
        date: json['date'],
        state: json['state'],
        sub_pro: json['sub_profession'],
        city: json['city'],
        visiblity: json['seen'],
        locality: json['locality']);
  }
}
