import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meflisy_service/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MainHome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'size_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return register();
  }
}

class register extends State<login> {
  String error = "";
  String phoneNumber;
  String smsCode;
  String verificationCode;

  String name, address;
  String _mySelection;
  final String url = 'http://meflisyservice.com/working_states.php';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String token;

  List data, user_info;

  Future<String> getSWData() async {
    http.Client client = new http.Client();
    var response =
        await client.get('http://meflisyservice.com/working_states.php');
    if (response.statusCode == 200) {
      var resBody = jsonDecode(response.body);
      setState(() {
        data = resBody;
      });
    }
    client.close();
    return 'Success';
  }

  fcm() async {
    await _firebaseMessaging.getToken().then((onvalue) {
      token = onvalue;
      print("The token is " + token);
    });
  }

  getname() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name");
      address = prefs.getString("address");
    });
  }

  Future<String> _setUser(http.Client client, url) async {
    final response = await client.post(url, body: {
      'state': _mySelection,
      'phone_number': phoneNumber,
      'token': token
    });
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "Wait, Your data is loading", timeInSecForIos: 8);
    } else {
      Fluttertoast.showToast(
          msg: "Error : " + response.statusCode.toString(), timeInSecForIos: 8);
    }
    client.close();
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
      String user_url = 'http://meflisyservice.com/users.php';
      print("Print is checking ${user_url}");
      print("The phone number complete is ${phoneNumber}");
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("update_url", user_url);
      prefs.setString("phone_number", phoneNumber);
      _setUser(http.Client(), user_url);

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          print("login delay work");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainHome()));
        });
      });
    };

    final PhoneVerificationFailed phoneVerificationFailed =
        (AuthException exception) {
      //print(" This is working ${exception.message}");
      setState(() {
        error = exception.message;
        //print(error);
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
                    textStyle: TextStyle(fontSize: 12),
                    fieldsCount: 6,
                    onSubmit: (String pin) {
                      this.smsCode = pin;
                      FirebaseAuth.instance.currentUser().then((user) async {
                        if (user != null) {
                          Navigator.of(context).pop();
                          print("The user is not null in verify");

                          String user_url =
                              'http://meflisyservice.com/users.php';
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString("update_url", user_url);
                          prefs.setString("phone_number", phoneNumber);
                          _setUser(http.Client(), user_url);

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainHome()));
                        } else {
                          Navigator.of(context).pop();
                          signIn();
                        }
                      });
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
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationCode,
      smsCode: smsCode,
    );

    final FirebaseUser user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;

    final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    assert(user.uid == currentUser.uid);
    print("AuthCrendential is work and goes to next");

    String user_url = 'http://meflisyservice.com/users.php';

    final prefs = await SharedPreferences.getInstance();
    prefs.setString("update_url", user_url);
    prefs.setString("phone_number", phoneNumber);
    _setUser(http.Client(), user_url);

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MainHome()));
  }

  @override
  void initState() {
    super.initState();
    this.getSWData();
    fcm();
    getname();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return LayoutBuilder(builder: (context, constraints) {
      SizeConfig().init(constraints);
      return Scaffold(
        backgroundColor: Color(0xFF005E6A),
        appBar: AppBar(
          backgroundColor: Color(0xFF005E6A),
          elevation: 0,
          title: Text(
            "Login / Signup",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
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
          child: ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  "images/meflogin.png",
                  width: 28.5 * SizeConfig.imageSizeMultiplier,
                  height: 28.5 * SizeConfig.imageSizeMultiplier,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 20, right: 30, left: 30),
                child: Text(
                  "We'll send an SMS message to verify your identity, please enter your number right below!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 1.9 * SizeConfig.textMultiplier,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: DropDown(data),
              ),
              Column(

                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: TextField(
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 2.25 * SizeConfig.textMultiplier),
                      decoration: InputDecoration(
                        hintText: "Enter Phone Number",
                        hintStyle: TextStyle(color: Colors.grey),
                        labelText: "Phone Number",
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
                    child: RaisedButton(
                      elevation: 0,
                      child: Text(
                        "Get OTP",
                        style: TextStyle(
                            fontSize: 2.25 * SizeConfig.textMultiplier,
                            color: Colors.white),
                      ),
                      color: Color(0xFF00BCD4),
                      onPressed: () {
                        error = "";

                        if (_mySelection != null && _mySelection != '') {
                          if(phoneNumber==null){
                            setState(() {
                              error="Please Enter Number";
                            });
                          }else{
                            String Number = "+91"+ phoneNumber;
                            _submit(Number);
                            Fluttertoast.showToast(
                                msg: "Wait..", timeInSecForIos: 8);
                          }
                        } else {
                          setState(() {
                            error = "Please State/City first";
                          });
                        }
                      },
                    ),
                  ), // button
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 20, right: 30, left: 30),
                    child: Text(
                      "${error}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 1.9 * SizeConfig.textMultiplier,
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
      );
    });
  }

  Widget DropDown(List data) {
    if (data != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
              color: Colors.black, style: BorderStyle.solid, width: 0.80),
        ),
        child: DropdownButton(
          items: data.map((item) {
            return new DropdownMenuItem(
              child: new Text(
                item['state_name'],
                style: TextStyle(
                    fontSize: 2.0 * SizeConfig.textMultiplier,
                    fontWeight: FontWeight.bold),
              ),
              value: item['state_name'].toString(),
            );
          }).toList(),
          hint: Text(
            "Select your State/Cities",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          onChanged: (newVal) {
            setState(() {
              _mySelection = newVal;
            });
          },
          value: _mySelection,
        ),
      );
    } else {
      return new Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
