import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meflisy_service/Tabs/Company.dart';
import 'package:meflisy_service/MainHome.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../size_config.dart';
import 'signupPartner.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'partnerMainHome.dart';

class loginPartner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return loginState();
  }
}

class loginState extends State<loginPartner> {

  String error = "";
  String phoneNumber;
  String smsCode;
  String verificationCode;
  String token;

  String dropdownValue = "Select State";
  String nameCity = "";

  String user_error = "";
  String name, address;

  String _mySelection, _myCitySelection;

  final String url = 'http://meflisyservice.com/working_states.php';

  List data, city_data;

  List user_data;

  Future<String> getStateData() async {
    http.Client client = new http.Client();
    var res = await client.get(Uri.encodeFull(url));

    var resBody = json.decode(res.body);
    setState(() {
      data = resBody;
      print("The data after setState is ${data}");
    });
    client.close();
    return 'Success';
  }

 /* fcm() async{
    await _firebaseMessaging.getToken().then((onvalue){
      token=onvalue;
    });
  }*/

  @override
  void initState() {
    super.initState();
    getStateData();
  }

  Future<String> getCityData(String cityname) async {
    String cityurl = "http://meflisyservice.com/get_cityname.php";
    http.Client client = new http.Client();
    final response = await client.post(cityurl, body: {
      'state': cityname,
    });
    var resBody = json.decode(response.body);
    setState(() {
      city_data = resBody;
      print("The data after setState is ${city_data}");
    });

    client.close();
    return 'Success';
  }

  Future _loginUser(http.Client client, url, String number) async {
    final prefs = await SharedPreferences.getInstance();

    if (_mySelection == null &&
        _mySelection.length <= 0 &&
        _myCitySelection == null &&
        _myCitySelection.length <= 0) {
      setState(() {
        user_error = "Oops! Please select State or City";
        client.close();
      });
    } else {
      final response = await client.post(url, body: {
        'state': _mySelection,
        'phone_number': phoneNumber,
        'city': _myCitySelection
      });
      var resbody = jsonDecode(response.body);
      setState(() {
        user_error = "";
        user_data = resbody;
        if (user_data.length > 0) {
          print("The data is ${user_data}");

          client.close();
          _submit(number);
        } else {
          user_error = "Oops! You don't have account.\n Please create account";
          client.close();
        }
      });
    }
  }

  Future<void> _submit(String number) async {
    final PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout = (String verId) {
      this.verificationCode = verId;
    };

    final PhoneCodeSent phoneCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationCode = verId;
      smsCodeDialog(context).then((value) => print("Signed In"));
      setState(() {
        error = " ";
      });
    };

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {
      print("PhoneverificationCompleted is working");

      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);

      final prefs = await SharedPreferences.getInstance();

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          for (var u in user_data) {
            prefs.setString("partner_name", u['name']);
          }
          prefs.setString("login_state",_mySelection );
          prefs.setString("login_city",_myCitySelection);
          prefs.setString("login_mobile",phoneNumber );
          prefs.setString("login_check", "true");
          print("login delay work");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => partnerMainHome()));
        });
      });
    };

    final PhoneVerificationFailed phoneVerificationFailed =
        (AuthException exception) {
      setState(() {
        error = exception.message;
      });
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: number,
        timeout: const Duration(seconds: 15),
        verificationCompleted: verificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: autoRetrievalTimeout);
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Text("Enter Code"),
            content: Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.all(2.0),
                child: Center(
                  child: PinPut(
                    textStyle: TextStyle(fontSize: 1.5*SizeConfig.textMultiplier),
                    fieldsCount: 6,
                    onSubmit: (String pin) {
                      this.smsCode = pin;
                      signIn();
                      Navigator.of(context).pop();
                    },
                    onClear: (String pin) => Text(""),
                  ),
                ),
              ),
            ),
            contentPadding: EdgeInsets.all(10.0),
          );
        });
  }

  signIn() async {
    final prefs = await SharedPreferences.getInstance();
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationCode,
      smsCode: smsCode,
    );

    final FirebaseUser user = (await FirebaseAuth.instance
        .signInWithCredential(credential)).user;

    print("AuthCrendential is work and goes to next");
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        for (var u in user_data) {
          prefs.setString("partner_name", u['name']);
        }
        prefs.setString("login_state",_mySelection );
        prefs.setString("login_city",_myCitySelection);
        prefs.setString("login_mobile",phoneNumber );
        prefs.setString("login_check", "true");
        print("login delay work");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => partnerMainHome()));
      });
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: new Scaffold(
        backgroundColor: Color(0xFF005E6A),
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            "PARTNER LOGIN",
            style: TextStyle(color: Colors.white,fontSize: 2.25*SizeConfig.textMultiplier),
          ),
          backgroundColor: Color(0xFF005E6A),
        ),
        body: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
                topLeft: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
              ),
            color: Colors.white
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        "images/meflogin.png",
                        height: 28.5*SizeConfig.imageSizeMultiplier,
                        width: 28.5*SizeConfig.imageSizeMultiplier,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          ///   drop down
                          alignment: Alignment.centerLeft,
                          child: DropDown(data),
                        ),
                        Container(
                          ///   drop down
                          alignment: Alignment.centerRight,
                          child: DropDown2(_mySelection),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ListTile(
                          title: TextField(
                            style:
                                TextStyle(fontWeight: FontWeight.bold, fontSize: 2.25*SizeConfig.textMultiplier),
                            decoration: InputDecoration(
                              hintText: "Enter Phone Number",
                              hintStyle: TextStyle(color: Colors.grey),
                              labelText: "Phone Number *",
                              prefixText: "+91",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: new BorderSide(color: Colors.black)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: new BorderSide(color: Color(0xFF005E6A)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: new BorderSide(color: Color(0xFF005E6A)),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => phoneNumber = value,
                          ),
                        ),

                        Container(
                          //margin: EdgeInsets.only(bottom: 20),
                          margin: EdgeInsets.only(right: 50, left: 50, bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: <Widget>[
                              RaisedButton(
                                elevation: 0,
                                child: Text(
                                  "LOGIN",
                                  style: TextStyle(fontSize: 2.25*SizeConfig.textMultiplier, color: Colors.white),
                                ),
                                color: Color(0xFF005E6A),
                                onPressed: () {

                                  String user_url =
                                      'http://meflisyservice.com/login_partner.php';

                                  if (_mySelection != null &&
                                      _mySelection.length > 0 &&
                                      _myCitySelection != null &&
                                      _myCitySelection.length > 0){
                                    if(phoneNumber==null){
                                      setState(() {
                                        user_error = "Please Enter Phone Number";
                                      });
                                    }else{
                                      String Number = "+91" + phoneNumber;
                                      setState(() {
                                        Fluttertoast.showToast(msg: "Please Wait");
                                        _loginUser(http.Client(), user_url, Number);
                                      });
                                    }
                                  }
                                  else {
                                    setState(() {
                                      user_error = "Enter State/City and Town/Village";
                                    });
                                  }
                                },
                              ),
                              SizedBox(height: 20,),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) => signupPartner()));
                                        });
                                      },
                                      child: Text(
                                        "REGISTER NOW",
                                        style: TextStyle(color: Color(0xFF005E6A), fontSize:2.5*SizeConfig.textMultiplier,fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text("Create Your Account"),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ), // button



                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(bottom: 20, right: 30, left: 30),
                          child: Text(
                            "${user_error}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:2*SizeConfig.textMultiplier,
                                color: Colors.red),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 20, right: 30, left: 30),
                child: Text(
                  "You will recieve OTP on your number",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 2*SizeConfig.textMultiplier,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget DropDown(List data) {
    if (data != null) {
      return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.only(left: 10, right: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, 5.0),
                  blurRadius: 7),
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, -5.0),
                  blurRadius: 7),
            ]),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            icon: Icon(
              Icons.arrow_drop_down,
              color: Color(0xFF005E6A),
            ),
            items: data.map((item) {
              return new DropdownMenuItem(
                child: new Text(
                  item['state_name'],
                  style: TextStyle(fontSize: 2.0*SizeConfig.textMultiplier,fontWeight: FontWeight.bold),
                ),
                value: item['state_name'].toString(),
              );
            }).toList(),
            hint: Text(
              "Select City/State",
              style: TextStyle(
                  color:Color(0xFF005E6A) ,
              ),
            ),
            onChanged: (newVal) {
              setState(() {
                _mySelection = newVal;
                city_data=null;
                _myCitySelection=null;
                getCityData(_mySelection);
              });
            },
            value: _mySelection,
          ),
        ),
      );
    } else {
      return new Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget DropDown2(String cityname) {
    if (cityname != null) {
      if (city_data != null) {
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.only(left: 10, right: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0.0, 5.0),
                    blurRadius: 7),
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0.0, -5.0),
                    blurRadius: 7),
              ]),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF005E6A),
              ),
              items: city_data.map((item) {
                return new DropdownMenuItem(
                  child: new Text(
                    item['name'],
                    style: TextStyle(fontSize:2.0*SizeConfig.textMultiplier,fontWeight: FontWeight.bold),
                  ),
                  value: item['name'].toString(),
                );
              }).toList(),
              hint: Text(
                "Select Town/Village",
                style: TextStyle(
                  color: Color(0xFF005E6A),
                ),
              ),
              onChanged: (newVal) {
                setState(() {
                  _myCitySelection = newVal;
                });
              },
              value: _myCitySelection,
            ),
          ),
        );
      } else {
        return new Center(
          child: CircularProgressIndicator(),
        );
      }
    }
  }
}
