import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:meflisy_service/MainHome.dart';
import 'package:meflisy_service/partner/advertise.dart';
import 'package:meflisy_service/partner/franchise.dart';
import 'package:meflisy_service/partner/partnerMainHome.dart';
import 'package:share/share.dart';

import '../size_config.dart';
import 'wallet_meflisy.dart';
import 'loginPartner.dart';
import 'profile_partner.dart';
import 'edit_profile.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class home_partner extends StatefulWidget {
  const home_partner({Key key}) : super(key: key);

  @override
  _home_partnerState createState() => _home_partnerState();
}

class _home_partnerState extends State<home_partner> {
  FirebaseMessaging _firebaseMessaging= new FirebaseMessaging();
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
      date, description,token;

  String pref_image;

  fcm() async{
    await _firebaseMessaging.getToken().then((onvalue){
      token=onvalue;
      print("The token is "+token);
    });
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

  uploadfcm() async{
    http.Client client = new http.Client();
    String user_url = 'http://meflisyservice.com/uploadtoken.php';
    final prefs = await SharedPreferences.getInstance();
    String state = prefs.getString("login_state");
    String city = prefs.getString("login_city");
    String number = prefs.getString("login_mobile");
    final response = await client.post(user_url,
        body: {'state': state, 'phone_number': number, 'city': city, 'token':token});
    var resbody = jsonDecode(response.body);
    print("The resbody is "+resbody.toString());
  }

  List user_data, sub_list;

  Future _loginUser() async {
    http.Client client = new http.Client();
    String user_url = 'http://meflisyservice.com/login_partner.php';
    final prefs = await SharedPreferences.getInstance();
    String state = prefs.getString("login_state");
    String city = prefs.getString("login_city");
    String number = prefs.getString("login_mobile");
    if (state == null &&
        state.length <= 0 &&
        city == null &&
        city.length <= 0 &&
        token.length<=0
    ) {
      setState(() {
        client.close();
      });
    } else {
      final response = await client.post(user_url,
          body: {'state': state, 'phone_number': number, 'city': city});
      var resbody = jsonDecode(response.body);
      setState(() {
        user_data = resbody;
        if (user_data.length > 0) {
          uploadfcm();
          for (var u in user_data) {
            name = u['name'];
            aadhar = u['aadhar'];
            address = u['address'];
            phone = u['phone_number'];
            statename = u['state'];
            cityname = u['city'];
            locality = u['locality'];
            profession = u['profession'];
            sub_profession = u['sub_profession'];
            image = u['profile_image'];
            date = u['date'];
            description=u['description'];
          }
          prefs.setString("meflisy_name", name);
          prefs.setString("meflisy_mobile", phone);
          prefs.setString("meflisy_aadhar", aadhar);
          prefs.setString("meflisy_address", address);
          prefs.setString("meflisy_state", statename);
          prefs.setString("meflisy_city", cityname);
          prefs.setString("meflisy_locality", locality);
          prefs.setString("meflisy_profession", profession);
          prefs.setString("meflisy_sub_profession", sub_profession);
          prefs.setString("meflisy_image", image);
          prefs.setString("meflisy_data", date);
          if(description!=null){
            prefs.setString("meflisy_description", description);
          }else{
            prefs.setString("meflisy_description", description);
          }
          pref_image = prefs.getString("meflisy_image");
          if(sub_profession!=null){
            sub_list = sub_profession.replaceAll(', ,', '').split(" , ");
          }

          client.close();
        } else {
          client.close();
        }
      });
    }
  }

  @override
  void initState() {
    fcm();
    _loginUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        backgroundColor: Color(0xFF00ACC1),
        appBar: AppBar(
          title: Text("Partner Home"),
          elevation: 0,
          backgroundColor: Color(0xFF00ACC1),
        ),
        body: checkdata(user_data),
      ),
    );
  }

  Widget checkdata(List user_Data) {
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
      child: user_Data != null
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.all(8),
              child: ListView(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: phone != null
                          ? Text(
                              "Refer ID: " + phone.toString(),
                              style: TextStyle(
                                  fontSize: 2.3 * SizeConfig.textMultiplier,
                                  fontWeight: FontWeight.bold),
                            )
                          : Text("Wait..."),
                    ),
                  ),
                  GestureDetector(
                    child: new Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(top: 1, left: 1, right: 1),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Align(
                                  child: Text(
                                    "Profile View",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 2 * SizeConfig.textMultiplier,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  alignment: Alignment.topLeft,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  displaySelectedFile(image),
                                  new Expanded(
                                    child: new Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: name!=null?new Text(
                                            name,
                                            style: TextStyle(
                                                fontSize: 2.5 *
                                                    SizeConfig.textMultiplier,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ):new Text(
                                              "Loading...",
                                              style: TextStyle(
                                                  fontSize: 1.9 *
                                                      SizeConfig.textMultiplier,
                                                  color: Colors.black)
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: profession!=null?new Text(
                                            profession,
                                            style: TextStyle(
                                                fontSize: 2 *
                                                    SizeConfig.textMultiplier,
                                                color: Colors.black),
                                          ):new Text(
                                              "Loading...",
                                              style: TextStyle(
                                                  fontSize: 1.9 *
                                                      SizeConfig.textMultiplier,
                                                  color: Colors.black)
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: sub_profession!=null? new Text(
                                            sub_profession
                                                .replaceAll(", ,", "")
                                                .toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 1.9 *
                                                    SizeConfig.textMultiplier,
                                                color: Colors.black),
                                          ):new Text(
                                            "Loading...",
                                            style: TextStyle(
                                                fontSize: 1.9 *
                                                    SizeConfig.textMultiplier,
                                                color: Colors.black)
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 4.0, bottom: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.call,
                                          size: 7.2*SizeConfig.imageSizeMultiplier,
                                          color: Color(0xFF00ACC1),
                                        ),
                                        Text("Call"),
                                      ],
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.message,
                                          size: 7.2*SizeConfig.imageSizeMultiplier,
                                          color: Color(0xFF00ACC1),
                                        ),
                                        Text("Message"),
                                      ],
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Container(
                                          width: 9.55*SizeConfig.imageSizeMultiplier,
                                          height: 7.2*SizeConfig.imageSizeMultiplier,
                                          child: Image.asset(
                                              "images/WhatsApp.png"),
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
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => wallet_meflisy(phone)));
                    },
                    child: new Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Color(0xFFAAE6EE),
                      child: Container(
                        margin: EdgeInsets.only(top: 1, left: 1, right: 1),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 16.7*SizeConfig.imageSizeMultiplier,
                                    height: 16.7*SizeConfig.imageSizeMultiplier,
                                    child: Icon(
                                      Icons.account_balance_wallet,
                                      size: 16.7*SizeConfig.imageSizeMultiplier,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Meflisy Wallet",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 2.3 *
                                                  SizeConfig.textMultiplier),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Check your earning",
                                          style: TextStyle(
                                              fontSize: 1.9 *
                                                  SizeConfig.textMultiplier),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => advertise()));
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      width: MediaQuery.of(context).size.width,
                      height: 33.5 * SizeConfig.imageSizeMultiplier,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image: AssetImage("images/advertise.png"),
                              fit: BoxFit.fill),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.black,
                              blurRadius: 5.0,
                            ),
                          ]),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => franchise()));
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      width: MediaQuery.of(context).size.width,
                      height: 33.5 * SizeConfig.imageSizeMultiplier,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image: AssetImage("images/franchisecard.png"),
                              fit: BoxFit.fill),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.black,
                              blurRadius: 5.0,
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            )
          : new Center(child: SpinKitFadingCircle(
        color: Color(0xFF00ACC1),
        size: 60.0,
       // type: SpinKitWaveType.start,
      )),
    );
  }

  Widget displaySelectedFile(String file) {
    return GestureDetector(
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
