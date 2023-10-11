import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:meflisy_service/adsScreen.dart';
import 'package:meflisy_service/cityProfession.dart';
import 'package:meflisy_service/model/message.dart';
import 'package:meflisy_service/partner/splashPartner.dart';
import 'package:meflisy_service/theme.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meflisy_service/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity/connectivity.dart';
import 'package:meflisy_service/size_config.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:meflisy_service/categories.dart';
import 'package:meflisy_service/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localProfession.dart';
import '../shortcut.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return homeScreen();
  }
}

class homeScreen extends State<Home> {
  String pincode = "", phonenumber, nowdate, topheading;
  String state, city, locality, imageurl;
  String updatepincode, user_name;
  bool checkads = true, check_recommanded = true, update_version = false;
  List adslist, recommanded_list;
  List data = new List();
  List<String> urls = new List();
  List<String> shortcuts_icons = new List();
  List<String> localprofession = new List();
  List<String> cityprofession = new List();
  bool check = true,
      nearcheck = true,
      historycheck = true,
      shortcut_check = false,
      theme_check = false;
  int i = 0, newversion;
  List<Photo> list;
  List shortcuts;
  List<Photo2> list1;
  List<CallHistory> callhistory;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String token;
  String msg;
  final List<Message> messages = [];
  var _connectionStatus = 'Unknown';
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;

  getDate() {
    var paymentdate = new DateTime.now();
    setState(() {
      nowdate = new DateFormat("yyyy-MM-dd").format(paymentdate).toString();
    });
  }

  Future local_category() async {
    String url = 'http://meflisyservice.com/local_catogery.php';
    http.Client client = new http.Client();
    if (state != null && city != null) {
      final response = await client.post(url,
          body: {'state': state, 'city': city, 'locality': locality});
      setState(() {
        if (response.statusCode == 200) {
          list = (json.decode(response.body) as List)
              .map((data) => new Photo.fromJson(data))
              .toList();
          if (list.length <= 0 || list.isEmpty) {
            nearcheck = false;
          }
        } else {
          nearcheck = false;
          Fluttertoast.showToast(
              msg: " Something went wronge ", timeInSecForIos: 4);
        }
      });
    }
  }

  Future city_category() async {
    String url = 'http://meflisyservice.com/city_catogery.php';
    http.Client client = new http.Client();
    if (state != null && city != null) {
      final response = await client.post(url,
          body: {'state': state, 'city': city, 'locality': locality});
      setState(() {
        if (response.statusCode == 200) {
          list1 = (json.decode(response.body) as List)
              .map((data) => new Photo2.fromJson(data))
              .toList();
          if (list1.length <= 0 || list1.isEmpty) {
            check = false;
          }
        } else {
          check = false;
          Fluttertoast.showToast(
              msg: " Something went wronge ", timeInSecForIos: 4);
        }
      });
    }
  }

  static const APP_STORE_URL =
      'https://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=com.meflisy.meflisy_service&mt=8';
  static const PLAY_STORE_URL =
      'https://play.google.com/store/apps/details?id=com.meflisy.meflisy_service';

  Future checkversion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();

    var version_code = int.parse(info.buildNumber.toString());
    print("The version code is " + version_code.toString());

    String url = 'http://meflisyservice.com/pricing.php';
    http.Client client = new http.Client();
    List pricinglist;
    int newversioncode = 0;
    final response = await client.get(url);
    var resbody = jsonDecode(response.body);
    setState(() {
      if (response.statusCode == 200) {
        pricinglist = resbody;

        if (pricinglist.length > 0) {
          for (var u in pricinglist) {
            newversioncode = int.parse(u['version_code']);
          }
          if (newversioncode > version_code) {
            update_version = true;
          } else {
            update_version = false;
          }
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

  Future<String> _getIntFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final checkstate = prefs.getString('state');
    final checkcity = prefs.getString('city');
    if (checkstate == null && checkcity == null) {
      return null;
    }
    return checkstate;
  }

  Future<String> _incrementStartup() async {
    final prefs = await SharedPreferences.getInstance();
    String lastpincode = await _getIntFromSharedPref();

    setState(() {
      state = lastpincode;
      city = prefs.getString("city");
      locality = prefs.getString("locality");

      if (lastpincode == null && city == null && locality == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => location()));
      } else {
        getLocalAds();
        local_category();
        city_category();
        getShortcuts();
        themedata();
        user_information(http.Client());
      }
    });
  }

  getUid() {}

  Future recent_data() async {
    String url = 'http://meflisyservice.com/recent_show.php';
    http.Client client = new http.Client();

    final response = await client.post(url, body: {'userid': phonenumber});
    setState(() {
      if (response.statusCode == 200) {
        callhistory = (json.decode(response.body) as List)
            .map((data) => new CallHistory.fromJson(data))
            .toList();
        if (callhistory.length <= 0 && callhistory.isEmpty) {
          historycheck = false;
        }
      } else {
        historycheck = false;
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });
  }

  getUserid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      phonenumber = prefs.getString("phone_number");
      if (phonenumber != null) {
        recent_data();
      }
    });
  }

  Future getLocalAds() async {
    String url = "http://meflisyservice.com/local_ads.php";
    http.Client client = new http.Client();
    if (state != null && city != null) {
      final response =
          await client.post(url, body: {'state': state, 'city': city});
      setState(() {
        if (response.statusCode == 200) {
          adslist = json.decode(response.body);

          if (adslist.length <= 0 && adslist.isEmpty) {
            checkads = true;
            getAds();
          } else {
            checkads = false;
            for (var x in adslist) {
              urls.add(x['ads']);
              //print("The complete ads are " + x['ads_code']);
            }
          }
        } else {
          checkads = true;
          Fluttertoast.showToast(
              msg: " Something went wronge ", timeInSecForIos: 4);
        }
      });
    }
    client.close();
  }

  Future getAds() async {
    String url = "http://meflisyservice.com/local_ads.php";
    http.Client client = new http.Client();
    if (state != null && city != null) {
      final response =
          await client.post(url, body: {'state': "adver", 'city': "adver"});
      setState(() {
        if (response.statusCode == 200) {
          adslist = json.decode(response.body);
          for (var x in adslist) {
            urls.add(x['ads']);
            //print("The complete ads are " + x['ads_code']);
          }
          checkads = false;
        } else {
          checkads = true;
          Fluttertoast.showToast(
              msg: " Something went wronge ", timeInSecForIos: 4);
        }
      });
    }
    client.close();
  }

  Future getShortcuts() async {
    String url = "http://meflisyservice.com/sub_profession_home_icon.php";
    http.Client client = new http.Client();
    if (state != null && city != null && locality != null) {
      final response = await client.post(url,
          body: {'state': state, 'city': city, 'locality': locality});
      setState(() {
        if (response.statusCode == 200) {
          // print("ya its work " + i.toString());
          i = i + 1;
          shortcuts = json.decode(response.body);
          shortcuts_icons = [];
          for (var x in shortcuts) {
            shortcuts_icons.add(x);
          }
          if (shortcuts_icons.length <= 0 || shortcuts_icons.isEmpty) {
            shortcut_check = true;
          } else {
            shortcut_check = false;
          }
          //print("The shortcuts icon is "+shortcuts_icons.toString());
        } else {
          shortcut_check = true;
          Fluttertoast.showToast(
              msg: " Something went wronge ", timeInSecForIos: 4);
        }
      });
    }
    client.close();
  }

  Future themedata() async {
    String url = 'http://meflisyservice.com/theme.php';
    http.Client client = new http.Client();
    final response = await client.get(url);
    var resbody = jsonDecode(response.body);
    setState(() {
      if (response.statusCode == 200) {
        data = resbody;
        // print("The data is ${data}");
        if (data.length > 0) {
          theme_check = true;
          client.close();
        } else {
          theme_check = false;
          client.close();
        }
      } else {
        theme_check = false;
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });
  }

  checkcurrent() async {
    await FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        if (val == null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => login()));
        } else {
          _incrementStartup();
        }
      });
    }).catchError((e) {});
  }

  checkConnectivity() {
    connectivity = new Connectivity();

    connectivity.checkConnectivity().then((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        setState(() {
          getUserid();
          checkcurrent();
        });
      } else {
        smsCodeDialog(context);
      }
    });
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result.toString();

      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        setState(() {
          checkcurrent();
          getUserid();
        });
      } else {
        smsCodeDialog(context);
      }
    });
  }

  Future<String> user_information(http.Client client) async {
    final prefs = await SharedPreferences.getInstance();
    final response =
        await client.post('http://meflisyservice.com/get_user.php', body: {
      'phone_number': prefs.get("phone_number"),
    });

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
        for (var u in data) {
          user_name = u['name'];
          if (user_name == null || user_name == '') {
            user_name = "Not Given";
          }
          //print("The username is "+user_name);
        }
      });
    } else {
      Fluttertoast.showToast(msg: "Please Refresh it again");
    }
    client.close();
  }

  upload_Lead(String sub_profession) async {
    String url = 'http://meflisyservice.com/uploadleads.php';
    http.Client client = new http.Client();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 18 * SizeConfig.imageSizeMultiplier,
                    height: 18 * SizeConfig.imageSizeMultiplier,
                    child: CachedNetworkImage(
                      imageUrl:
                          "http://meflisyservice.com/sub_catogery images/" +
                              sub_profession +
                              ".jpg",
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF00ACC1)),
                          borderRadius: new BorderRadius.circular(13.0),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => SpinKitFadingCircle(
                        color: Color(0xFF00ACC1),
                        size: 40.0,
                        // type: SpinKitWaveType.start,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
                      child: SafeArea(
                        child: Stack(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Color(0xffdcfbff),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Text(
                              sub_profession.toUpperCase() +
                                  " वाले को ढूंढ रहे है ,कोई बात नहीं | \n\n" +
                                  sub_profession.toUpperCase() +
                                  " पर अच्छे ऑफर पाने के लिए Ok पर Click करे | हमारे Partners आपको अपने आप Call करे लेंगे |",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                              bottom: 5,
                              right: 10,
                              child: CustomPaint(
                                painter: ChatBubbleTriangle(),
                              ))
                        ]),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: new FlatButton(
                          onPressed: () async {
                            final response = await client.post(url, body: {
                              'state': state,
                              'city': city,
                              'locality': locality,
                              'user_phone': phonenumber,
                              'user_name': user_name,
                              'date': nowdate,
                              'sub_profession': sub_profession
                            });
                            setState(() {
                              if (response.statusCode == 200) {
                                Fluttertoast.showToast(
                                    msg:
                                        " Your request is send to our partners ",
                                    timeInSecForIos: 4);
                              } else {
                                Fluttertoast.showToast(
                                    msg: " Something went wronge ",
                                    timeInSecForIos: 4);
                              }
                            });
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => shortcut(
                                        sub_profession,
                                        state,
                                        city,
                                        locality)));
                          },
                          child: new Text(
                            'Ok',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: new FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => shortcut(
                                        sub_profession,
                                        state,
                                        city,
                                        locality)));
                          },
                          child: new Text('Cancel',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    checkversion();
    getDate();
    checkConnectivity();

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        // print("onMessage: $message");
        final notification = message['data'];
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                contentPadding: EdgeInsets.only(top: 10.0),
                content: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      notification['image'] != null
                          ? Container(
                              width: 18 * SizeConfig.imageSizeMultiplier,
                              height: 18 * SizeConfig.imageSizeMultiplier,
                              child: CachedNetworkImage(
                                imageUrl: notification['image'],
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Color(0xFF00ACC1)),
                                    borderRadius:
                                        new BorderRadius.circular(13.0),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) =>
                                    SpinKitFadingCircle(
                                  color: Color(0xFF00ACC1),
                                  size: 40.0,
                                  // type: SpinKitWaveType.start,
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 5.0,
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
                          child: SafeArea(
                            child: Stack(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Color(0xffdcfbff),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      notification['title'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      notification['body'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                  bottom: 5,
                                  right: 10,
                                  child: CustomPaint(
                                    painter: ChatBubbleTriangle(),
                                  ))
                            ]),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: new FlatButton(
                              onPressed: () {
                                switch (notification['screen']) {
                                  case 'Partner':
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                splashPartner()));
                                    break;
                                  case 'Theme':
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => theme()));
                                    break;
                                }
                              },
                              child: new Text('Check Now'),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: new FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: new Text('Cancel'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
      },
      onResume: (Map<String, dynamic> message) async {
        //print("onResume: $message");
        final notification = message['data'];
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                contentPadding: EdgeInsets.only(top: 10.0),
                content: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      notification['image'] != null
                          ? Container(
                              width: 18 * SizeConfig.imageSizeMultiplier,
                              height: 18 * SizeConfig.imageSizeMultiplier,
                              child: CachedNetworkImage(
                                imageUrl: notification['image'],
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Color(0xFF00ACC1)),
                                    borderRadius:
                                        new BorderRadius.circular(13.0),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) =>
                                    SpinKitFadingCircle(
                                  color: Color(0xFF00ACC1),
                                  size: 40.0,
                                  // type: SpinKitWaveType.start,
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 5.0,
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
                          child: SafeArea(
                            child: Stack(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Color(0xffdcfbff),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      notification['title'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      notification['body'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                  bottom: 5,
                                  right: 10,
                                  child: CustomPaint(
                                    painter: ChatBubbleTriangle(),
                                  ))
                            ]),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: new FlatButton(
                              onPressed: () {
                                switch (notification['screen']) {
                                  case 'Partner':
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                splashPartner()));
                                    break;
                                  case 'Theme':
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => theme()));
                                    break;
                                }
                              },
                              child: new Text('Check Now'),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: new FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: new Text('Cancel'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
    //versionCheck(context);
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            contentPadding: EdgeInsets.only(top: 10.0, bottom: 10),
            content: Container(
              height: 20 * SizeConfig.imageSizeMultiplier,
              margin: EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
                child: SafeArea(
                  child: Stack(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Color(0xffdcfbff),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "No internet connection found",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        bottom: 5,
                        right: 10,
                        child: CustomPaint(
                          painter: ChatBubbleTriangle(),
                        ))
                  ]),
                ),
              ),
            ),
            title: IconButton(
              icon: Icon(
                Icons.signal_wifi_off,
                color: Color(0xFF00ACC1),
                size: 16 * SizeConfig.imageSizeMultiplier,
              ),
            ),
            /**/
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: new Text('Ok'),
              ),
            ],
          );
        });
  }

  Widget buildMessage(Message message) => ListTile(
        title: Text(message.title),
        subtitle: Text(message.body),
      );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return LayoutBuilder(
      builder: (context, constraints) {
        SizeConfig().init(constraints);
        return Scaffold(
          backgroundColor: Color(0xFF00ACC1),
          appBar: AppBar(
            titleSpacing: 0,
            elevation: 0,
            backgroundColor: Color(0xFF00ACC1),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0, bottom: 10),
                    child: IconButton(
                        icon: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 8 * SizeConfig.imageSizeMultiplier,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => location()));
                        }),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => location()));
                    });
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            "Your Location",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontStyle: FontStyle.normal),
                          ),
                        ),
                        city != null
                            ? Container(
                                child: AutoSizeText(
                                  "${city.toUpperCase()} ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: IconButton(
                  padding: EdgeInsets.only(right: 20, bottom: 10),
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 8 * SizeConfig.imageSizeMultiplier,
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => categories()));
                  },
                ),
              ),
            ],
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
                  topLeft: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
                )),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 7 * SizeConfig.imageSizeMultiplier,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(
                              7 * SizeConfig.imageSizeMultiplier),
                          topLeft: Radius.circular(
                              7 * SizeConfig.imageSizeMultiplier),
                        )),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey[50],
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: update_version
                              ? Container(
                                  height: 20 * SizeConfig.imageSizeMultiplier,
                                  child: Card(
                                    color: Colors.green[50],
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Container(
                                          width: 20 *
                                              SizeConfig.imageSizeMultiplier,
                                          decoration: new BoxDecoration(
                                            image: new DecorationImage(
                                                image: new AssetImage(
                                                    'images/icon.png'),
                                                fit: BoxFit.fill),
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              " Meflisy Service ",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 2.2 *
                                                      SizeConfig.textMultiplier,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "Need to be update",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 1.8 *
                                                    SizeConfig.textMultiplier,
                                                color: Color(0xff00acc1),
                                              ),
                                            ),
                                          ],
                                        ),
                                        RaisedButton(
                                          onPressed: () {
                                            _launchURL(PLAY_STORE_URL);
                                          },
                                          color: Color(0xff00acc1),
                                          child: Text(
                                            "Update",
                                            style: TextStyle(
                                                fontSize: 1.8 *
                                                    SizeConfig.textMultiplier,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 4.0),
                        ),
                        SliverToBoxAdapter(
                          child: checkads != true
                              ? Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: CarouselSlider(
                                    height: 40 * SizeConfig.imageSizeMultiplier,
                                    aspectRatio: 16 / 9,
                                    viewportFraction: 0.9,
                                    enableInfiniteScroll: true,
                                    autoPlay: true,
                                    autoPlayInterval: Duration(seconds: 3),
                                    autoPlayAnimationDuration:
                                        Duration(milliseconds: 1100),
                                    pauseAutoPlayOnTouch: Duration(seconds: 1),
                                    scrollDirection: Axis.horizontal,
                                    items: urls.map((i) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Card(
                                            elevation: 0,
                                            color: Colors.transparent,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            adsScreen(i)));
                                              },
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 5.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: i,
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          new BorderRadius
                                                              .circular(13.0),
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  ),
                                                  placeholder: (context, url) =>
                                                      SpinKitFadingCircle(
                                                    color: Color(0xFF00ACC1),
                                                    size: 50.0,
                                                    // type: SpinKitWaveType.start,
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                )
                              : /*Center(
                                  child: Shimmer.fromColors(
                                    child: Container(
                                      height: 40 * SizeConfig.imageSizeMultiplier,
                                      color: Colors.grey,
                                    ),
                                    highlightColor: Colors.white,
                                    baseColor: Colors.grey[300],
                                  ),
                                )*/
                              SizedBox(),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 4.0),
                        ),
                        shortcuts_icons != null && shortcuts_icons.isNotEmpty
                            ? SliverToBoxAdapter(
                                child: new Card(
                                  elevation: 0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                      ),
                                      shortcuts_icons != null &&
                                              shortcuts_icons.isNotEmpty
                                          ? Container(
                                              margin: EdgeInsets.only(top: 1),
                                              child: GridView.builder(
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 4,
                                                          childAspectRatio:
                                                              0.9),
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      shortcuts_icons.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        upload_Lead(
                                                            shortcuts_icons[
                                                                index]);
                                                        /*upload_Lead(
                                                            shortcuts_icons[index]);*/
                                                        /*Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    shortcut(
                                                                        shortcuts_icons[
                                                                            index],
                                                                        state,
                                                                        city,
                                                                        locality)));*/
                                                      },
                                                      child: Card(
                                                        elevation: 0,
                                                        child: Container(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Container(
                                                                child: Card(
                                                                  elevation: 0,
                                                                  color: Colors
                                                                      .white,
                                                                  child:
                                                                      Container(
                                                                    width: 15 *
                                                                        SizeConfig
                                                                            .imageSizeMultiplier,
                                                                    height: 15 *
                                                                        SizeConfig
                                                                            .imageSizeMultiplier,
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      imageUrl: "http://meflisyservice.com/sub_catogery images/" +
                                                                          shortcuts_icons[
                                                                              index] +
                                                                          ".jpg",
                                                                      imageBuilder:
                                                                          (context, imageProvider) =>
                                                                              Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(color: Color(0xFF00ACC1)),
                                                                          borderRadius:
                                                                              new BorderRadius.circular(13.0),
                                                                          image:
                                                                              DecorationImage(
                                                                            image:
                                                                                imageProvider,
                                                                            fit:
                                                                                BoxFit.fill,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      placeholder:
                                                                          (context, url) =>
                                                                              SpinKitFadingCircle(
                                                                        color: Color(
                                                                            0xFF00ACC1),
                                                                        size:
                                                                            40.0,
                                                                        /*type:
                                                                            SpinKitWaveType.start,*/
                                                                      ),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Icon(Icons
                                                                              .error),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                    child: Text(
                                                                  shortcuts_icons[
                                                                          index]
                                                                      .toUpperCase(),
                                                                  style: TextStyle(
                                                                      fontSize: 1.2 *
                                                                          SizeConfig
                                                                              .textMultiplier,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                )),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }))
                                          : shortcuts_icons.length == 0 &&
                                                  shortcut_check == true
                                              ? Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 2))
                                              : SpinKitFadingCircle(
                                                  color: Color(0xFF00ACC1),
                                                  size: 40.0,
                                                  // type: SpinKitWaveType.start,
                                                ),
                                    ],
                                  ),
                                ),
                              )
                            : shortcuts_icons.length == 0 &&
                                    shortcut_check == true
                                ? SliverPadding(
                                    padding: EdgeInsets.only(top: 2))
                                : SliverToBoxAdapter(
                                    child: SpinKitFadingCircle(
                                      color: Color(0xFF00ACC1),
                                      size: 50.0,
                                      //type: SpinKitWaveType.start,
                                    ),
                                  ),
                        SliverToBoxAdapter(
                          child: new Card(
                            elevation: 0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                nearcheck
                                    ? Container(
                                        padding:
                                            EdgeInsets.only(top: 10, left: 5),
                                        child: Text(
                                          "At Your Location",
                                          style: TextStyle(
                                              fontSize:
                                                  2 * SizeConfig.textMultiplier,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : SizedBox(),
                                Container(
                                  margin: EdgeInsets.only(top: 1),
                                  child: list != null && nearcheck
                                      ? GridView.builder(
                                          shrinkWrap: true,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  childAspectRatio: 1.2),
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: list.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            localProfession(
                                                                list[index]
                                                                    .title,
                                                                state,
                                                                city,
                                                                locality)));
                                              },
                                              child: Container(
                                                margin: EdgeInsets.all(2),
                                                child: Card(
                                                  elevation: 0,
                                                  child: Container(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Container(
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl:
                                                                "http://meflisyservice.com/category%20images/" +
                                                                    list[index]
                                                                        .title +
                                                                    ".png",
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image:
                                                                      imageProvider,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                            ),
                                                            placeholder: (context,
                                                                    url) =>
                                                                SpinKitFadingCircle(
                                                              color: Color(
                                                                  0xFF00ACC1),
                                                              size: 50.0,
                                                              //type: SpinKitWaveType.start,
                                                            ),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                          ),
                                                          width: 17 *
                                                              SizeConfig
                                                                  .imageSizeMultiplier,
                                                          height: 17 *
                                                              SizeConfig
                                                                  .imageSizeMultiplier,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 10),
                                                              child:
                                                                  AutoSizeText(
                                                                list[index]
                                                                    .title
                                                                    .toUpperCase(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize: 1.8 *
                                                                        SizeConfig
                                                                            .textMultiplier),
                                                                maxLines: 3,
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          })
                                      : new Center(
                                          child: nearcheck
                                              ? Shimmer.fromColors(
                                                  child: ListTile(
                                                    contentPadding:
                                                        EdgeInsets.all(10.0),
                                                    title: Container(
                                                      height: 4 *
                                                          SizeConfig
                                                              .imageSizeMultiplier,
                                                      width: 14 *
                                                          SizeConfig
                                                              .imageSizeMultiplier,
                                                      color: Colors.black,
                                                    ),
                                                    leading: Container(
                                                      width: 16.2 *
                                                          SizeConfig
                                                              .imageSizeMultiplier,
                                                      height: 16.2 *
                                                          SizeConfig
                                                              .imageSizeMultiplier,
                                                      color: Colors.black,
                                                    ),
                                                    subtitle: Container(
                                                      height: 4 *
                                                          SizeConfig
                                                              .imageSizeMultiplier,
                                                      width: 10 *
                                                          SizeConfig
                                                              .imageSizeMultiplier,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  highlightColor: Colors.grey,
                                                  baseColor: Colors.grey[300],
                                                )
                                              : list1 != null && list != null
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                          top: 20),
                                                      child: Column(
                                                        children: <Widget>[
                                                          Image.asset(
                                                              "images/nothinfound.png"),
                                                          GestureDetector(
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              child: Text(
                                                                "We are continously adding service providers. We will add within somedays at your location",
                                                                style: TextStyle(
                                                                    fontSize: 2.1 *
                                                                        SizeConfig
                                                                            .textMultiplier,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : SizedBox(),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        list1 != null && check
                            ? SliverToBoxAdapter(
                                child: new Card(
                                  elevation: 0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      check
                                          ? Container(
                                              padding: EdgeInsets.only(
                                                  left: 5, top: 10),
                                              child: city != null
                                                  ? Text(
                                                      "At " +
                                                          city.toUpperCase(),
                                                      style: TextStyle(
                                                          fontSize: 2 *
                                                              SizeConfig
                                                                  .textMultiplier,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  : Text("At your City"),
                                            )
                                          : SizedBox(),
                                      Container(
                                        margin: EdgeInsets.only(top: 1),
                                        child: list1 != null && check
                                            ? GridView.builder(
                                                shrinkWrap: true,
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3,
                                                        childAspectRatio: 1.2),
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemCount: list1.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  cityProfession(
                                                                      list1[index]
                                                                          .title,
                                                                      state,
                                                                      city,
                                                                      locality)));
                                                    },
                                                    child: Card(
                                                      elevation: 0,
                                                      child: Container(
                                                        child: Column(
                                                          children: <Widget>[
                                                            Container(
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: "http://meflisyservice.com/category%20images/" +
                                                                    list1[index]
                                                                        .title +
                                                                    ".png",
                                                                imageBuilder:
                                                                    (context,
                                                                            imageProvider) =>
                                                                        Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                                      image:
                                                                          imageProvider,
                                                                      fit: BoxFit
                                                                          .fill,
                                                                    ),
                                                                  ),
                                                                ),
                                                                placeholder: (context,
                                                                        url) =>
                                                                    SpinKitFadingCircle(
                                                                  color: Color(
                                                                      0xFF00ACC1),
                                                                  size: 30.0,
                                                                  /*type: SpinKitWaveType
                                                                      .start,*/
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Icon(Icons
                                                                        .error),
                                                              ),
                                                              width: 17 *
                                                                  SizeConfig
                                                                      .imageSizeMultiplier,
                                                              height: 17 *
                                                                  SizeConfig
                                                                      .imageSizeMultiplier,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              10),
                                                                  child:
                                                                      AutoSizeText(
                                                                    list1[index]
                                                                        .title
                                                                        .toUpperCase(),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            1.8 *
                                                                                SizeConfig.textMultiplier),
                                                                    maxLines: 3,
                                                                  )),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                })
                                            : new Center(
                                                child: check
                                                    ? Shimmer.fromColors(
                                                        child: ListTile(
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  10.0),
                                                          title: Container(
                                                            height: 4 *
                                                                SizeConfig
                                                                    .imageSizeMultiplier,
                                                            width: 14 *
                                                                SizeConfig
                                                                    .imageSizeMultiplier,
                                                            color: Colors.black,
                                                          ),
                                                          leading: Container(
                                                            width: 16.2 *
                                                                SizeConfig
                                                                    .imageSizeMultiplier,
                                                            height: 16.2 *
                                                                SizeConfig
                                                                    .imageSizeMultiplier,
                                                            color: Colors.black,
                                                          ),
                                                          subtitle: Container(
                                                            height: 4 *
                                                                SizeConfig
                                                                    .imageSizeMultiplier,
                                                            width: 10 *
                                                                SizeConfig
                                                                    .imageSizeMultiplier,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        highlightColor:
                                                            Colors.grey,
                                                        baseColor:
                                                            Colors.grey[300],
                                                      )
                                                    : list == null
                                                        ? Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 20),
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Image.asset(
                                                                    "images/nothinfound.png"),
                                                                GestureDetector(
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            10),
                                                                    child: Text(
                                                                      "We are continously adding service providers. We will add within somedays at your location",
                                                                      style: TextStyle(
                                                                          fontSize: 2.1 *
                                                                              SizeConfig
                                                                                  .textMultiplier,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : SizedBox(),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SliverPadding(
                                padding: EdgeInsets.only(top: 1),
                              ),
                        theme_check != false
                            ? SliverToBoxAdapter(
                                child: InkWell(
                                  // Meflisy Advertise ment
                                  onTap: () {
                                    setState(() {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => theme()));
                                    });
                                  },
                                  child: Container(
                                    height: 38 * SizeConfig.imageSizeMultiplier,
                                    padding: EdgeInsets.all(2),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "http://meflisyservice.com/other%20images/theme.png",
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              new BorderRadius.circular(13.0),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          SpinKitFadingCircle(
                                        color: Color(0xFF00ACC1),
                                        size: 50.0,
                                        //type: SpinKitWaveType.start,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                    margin: EdgeInsets.all(7),
                                  ),
                                ),
                              )
                            : SliverToBoxAdapter(
                                child: SpinKitFadingCircle(
                                  color: Color(0xFF00ACC1),
                                  size: 50.0,
                                  //type: SpinKitWaveType.start,
                                ),
                              ),
                        callhistory != null && historycheck
                            ? SliverToBoxAdapter(
                                child: Card(
                                  elevation: 0,
                                  child: new Container(
                                    color: Colors.white,
                                    width: 50,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        historycheck
                                            ? Container(
                                                padding:
                                                    EdgeInsets.only(left: 5),
                                                child: Text(
                                                  "History ",
                                                  style: TextStyle(
                                                      fontSize: 2.1 *
                                                          SizeConfig
                                                              .textMultiplier,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )
                                            : SizedBox(),
                                        Container(
                                            height:
                                                35 * SizeConfig.textMultiplier,
                                            margin: EdgeInsets.only(top: 1),
                                            child:
                                                callhistory != null &&
                                                        historycheck
                                                    ? ListView.builder(
                                                        shrinkWrap: true,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount:
                                                            callhistory.length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return GestureDetector(
                                                            child: new Card(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                              color:
                                                                  Colors.white,
                                                              elevation: 3,
                                                              child: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 1,
                                                                        left: 1,
                                                                        right:
                                                                            1),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          12.0),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceAround,
                                                                    children: <
                                                                        Widget>[
                                                                      displaySelectedFile(
                                                                          callhistory[index]
                                                                              .image),
                                                                      callhistory[index].name !=
                                                                              null
                                                                          ? Padding(
                                                                              padding: const EdgeInsets.all(2.0),
                                                                              child: new Text(
                                                                                callhistory[index].name,
                                                                                style: TextStyle(fontSize: 2.1 * SizeConfig.textMultiplier, color: Colors.black, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            )
                                                                          : Center(
                                                                              child: CircularProgressIndicator(),
                                                                            ),
                                                                      callhistory[index].profession !=
                                                                              null
                                                                          ? Padding(
                                                                              padding: const EdgeInsets.all(2.0),
                                                                              child: new Text(
                                                                                callhistory[index].profession,
                                                                                style: TextStyle(
                                                                                  fontSize: 2 * SizeConfig.textMultiplier,
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : Center(
                                                                              child: CircularProgressIndicator(),
                                                                            ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: <
                                                                            Widget>[
                                                                          callhistory[index].city != null
                                                                              ? Padding(
                                                                                  padding: const EdgeInsets.all(2.0),
                                                                                  child: new Text(
                                                                                    callhistory[index].city,
                                                                                    style: TextStyle(fontSize: 1.8 * SizeConfig.textMultiplier, color: Colors.black),
                                                                                  ),
                                                                                )
                                                                              : Center(
                                                                                  child: CircularProgressIndicator(),
                                                                                ),
                                                                          callhistory[index].date != null
                                                                              ? Padding(
                                                                                  padding: const EdgeInsets.only(top: 2.0, left: 10),
                                                                                  child: new Text(
                                                                                    callhistory[index].date,
                                                                                    style: TextStyle(fontSize: 1.8 * SizeConfig.textMultiplier, color: Colors.black),
                                                                                  ),
                                                                                )
                                                                              : Center(
                                                                                  child: CircularProgressIndicator(),
                                                                                ),
                                                                        ],
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            recent_call(
                                                                                callhistory[index].partnerid,
                                                                                callhistory[index].image,
                                                                                callhistory[index].name,
                                                                                callhistory[index].state,
                                                                                callhistory[index].city,
                                                                                phonenumber,
                                                                                callhistory[index].profession,
                                                                                nowdate);
                                                                            launch('tel:+91' +
                                                                                callhistory[index].partnerid);
                                                                          });
                                                                        },
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .call,
                                                                          size: 7 *
                                                                              SizeConfig.imageSizeMultiplier,
                                                                          color:
                                                                              Color(0xFF00ACC1),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                          "Call"),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        })
                                                    : historycheck
                                                        ? Shimmer.fromColors(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: ListTile(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10.0),
                                                                title:
                                                                    Container(
                                                                  height: 4 *
                                                                      SizeConfig
                                                                          .imageSizeMultiplier,
                                                                  width: 14 *
                                                                      SizeConfig
                                                                          .imageSizeMultiplier,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                leading:
                                                                    Container(
                                                                  width: 16.2 *
                                                                      SizeConfig
                                                                          .imageSizeMultiplier,
                                                                  height: 16.2 *
                                                                      SizeConfig
                                                                          .imageSizeMultiplier,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                subtitle:
                                                                    Container(
                                                                  height: 4 *
                                                                      SizeConfig
                                                                          .imageSizeMultiplier,
                                                                  width: 10 *
                                                                      SizeConfig
                                                                          .imageSizeMultiplier,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                            highlightColor:
                                                                Colors.grey,
                                                            baseColor: Colors
                                                                .grey[300],
                                                          )
                                                        : SizedBox()),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : SliverPadding(
                                padding: EdgeInsets.only(top: 1),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                  child: SpinKitFadingCircle(
                    color: Color(0xFF00ACC1),
                    size: 30.0,
                    //type: SpinKitWaveType.start,
                  ),
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
  final String title;

  Photo._({this.title});

  factory Photo.fromJson(Map json) {
    return new Photo._(title: json['profession']);
  }
}

class Shortcuts {
  final String title;

  Shortcuts._({this.title});

  factory Shortcuts.fromJson(Map json) {
    return new Shortcuts._(title: json['profession']);
  }
}

class Photo2 {
  final String title;

  Photo2._({this.title});

  factory Photo2.fromJson(Map json) {
    return new Photo2._(title: json['profession']);
  }
}

class CallHistory {
  final String name;
  final String profession;
  final String partnerid;
  final String date;
  final String image;
  final String state;
  final String city;

  CallHistory._(
      {this.name,
      this.profession,
      this.partnerid,
      this.date,
      this.image,
      this.state,
      this.city});

  factory CallHistory.fromJson(Map json) {
    return new CallHistory._(
        name: json['name'],
        profession: json['profession'],
        partnerid: json['partnerid'],
        image: json['image'],
        date: json['date'],
        state: json['state'],
        city: json['city']);
  }
}

class ChatBubbleTriangle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Color(0xffdcfbff);

    var path = Path();
    path.lineTo(-80, 0);
    path.lineTo(0, 30);
    path.lineTo(-30, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
