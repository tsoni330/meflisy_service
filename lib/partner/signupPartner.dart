import 'dart:io';

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meflisy_service/partner/payment.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:url_launcher/url_launcher.dart';
import '../size_config.dart';

class signupPartner extends StatefulWidget {
  @override
  _signupPartnerState createState() => _signupPartnerState();
}

class _signupPartnerState extends State<signupPartner>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  bool accept = false;

  String _mySelection,
      _myCitySelection,
      _myLocalitySelection,
      _myCategorySelection;

  FocusNode name, aadhar, address, mobile, state;

  final String url = 'http://meflisyservice.com/working_states.php';

  List data, city_data, locality_data, category_data, subcategory_data;

  bool _processing = false;

  List<bool> inputs = new List<bool>();
  List<String> location;
  List<bool> subinputs = new List<bool>();
  List<String> sublocation, subkeywords;

  List user_data;
  String error = "";
  String phoneNumber;
  String smsCode;
  String verificationCode, only_number;
  String locationString = '', sublocationString = '', keywordString = '';

  var name_controller = TextEditingController();
  var aadhar_controller = TextEditingController();
  var address_controller = TextEditingController();
  var mobile_controller = TextEditingController();
  var refrence_controller = TextEditingController();

  Animation animation;
  AnimationController animationContorller;

  String full_name,
      aadharcard_number,
      complete_address,
      refrence_id,
      image_path;

  File getcameraFile, setcameraFile;

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

  Future<String> getCategoryData() async {
    http.Client client = new http.Client();
    var res = await client
        .get(Uri.encodeFull("http://meflisyservice.com/category_name.php"));
    var resBody = json.decode(res.body);
    setState(() {
      category_data = resBody;
      print("The category's data after setState is ${category_data}");
    });

    client.close();
    return 'Success';
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

  Future<String> getLocalityData(String cityname, String statename) async {
    String localityurl = "http://meflisyservice.com/locality.php";
    http.Client client = new http.Client();
    var res = await client.post(Uri.encodeFull(localityurl),
        body: {'state': statename, 'city': cityname});
    var resBody = json.decode(res.body);
    setState(() {
      location = new List<String>();
      inputs = [];
      locality_data = resBody;
      for (int i = 0; i < locality_data.length; i++) {
        inputs.add(false);
        //location.add("");
      }
      print("The data after select city is ${locality_data}");
    });

    client.close();
    return 'Success';
  }

  Future<String> getSubCategoryData(String profession) async {
    String localityurl = "http://meflisyservice.com/category_full_list.php";
    http.Client client = new http.Client();
    var res = await client
        .post(Uri.encodeFull(localityurl), body: {'profession': profession});
    var resBody = json.decode(res.body);

    setState(() {
      sublocation = new List<String>();
      subkeywords = new List<String>();
      subinputs = [];

      subcategory_data = resBody;
      for (int i = 0; i < subcategory_data.length; i++) {
        subinputs.add(false);
        //sublocation.add("");
        subkeywords.add("");
      }
      print("The data after select city is ${subcategory_data}");
    });

    client.close();
    return 'Success';
  }

  imageSelectorCamera() async {
    getcameraFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: getcameraFile.path,
      aspectRatio: CropAspectRatio(ratioX:1.0,ratioY:1.0),
      maxHeight: 512,
      maxWidth: 512,
    );
    var result = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path, getcameraFile.path,
        quality: 70);

    String base64 = base64Encode(result.readAsBytesSync());

    setState(() {
      setcameraFile = result;
      image_path = base64;
    });
  }

  PermissionStatus _status;

  void ItemChange(bool val, int index) {
    setState(() {
      if (val == false) {
        inputs[index] = val;
        location.remove(locality_data[index]['locality']);

        locationString = '';
        location.forEach((item) {
          locationString += '$item,';
        });

        if (locationString.length > 0) {
          print("The length is " + locationString);
          locationString =
              locationString.substring(0, locationString.length - 1);
        } else {
          print("The else length is " + locationString);
        }

        print(locationString);
      } else {
        inputs[index] = val;
        location.add(locality_data[index]['locality']);
        locationString = '';
        location.forEach((item) {
          locationString += '$item,';
        });
        locationString = locationString.substring(0, locationString.length - 1);
        print(locationString);
      }
    });
  }

  void SubItemChange(bool val, int index) {
    setState(() {
      if (val == false) {
        subinputs[index] = val;
        sublocation.remove(subcategory_data[index]['sub_category']);

        sublocationString = '';

        sublocation.forEach((item) {
          sublocationString += '$item,';
        });

        if (sublocationString.length > 0) {
          print("The length is " + sublocationString);
          sublocationString =
              sublocationString.substring(0, sublocationString.length - 1);
        } else {
          print("The else length is " + sublocationString);
        }
        print(sublocationString);
      } else {
        subinputs[index] = val;
        sublocation.add(subcategory_data[index]['sub_category']);
        //sublocation[index] = subcategory_data[index]['sub_category'];
        //subkeywords[index] = subcategory_data[index]['keyword'];

        sublocationString = '';
        // keywordString = '';

        sublocation.forEach((item) {
          sublocationString += '$item,';
        });
        /*subkeywords.forEach((item) {
          keywordString += ' $item,';
        });*/
        sublocationString =
            sublocationString.substring(0, sublocationString.length - 1);
        print(sublocationString);
        //print(keywordString);
      }
    });
  }

  void _updateStatus(PermissionStatus status) {
    if (status != null) {
      setState(() {
        _status = status;
      });
    } else {
      _askPermission();
    }
  }

  void _askPermission() {
    PermissionHandler()
        .requestPermissions([PermissionGroup.camera]).then(_onStatusRequested);
  }

  void _onStatusRequested(Map<PermissionGroup, PermissionStatus> statuses) {
    final status = statuses[PermissionGroup.camera];
    if (status != PermissionStatus.granted) {
      PermissionHandler().openAppSettings();
    } else
      _updateStatus(status);
  }

  Future checkUserAccount(
      http.Client client, String number, String only_number) async {
    final prefs = await SharedPreferences.getInstance();
    String localityurl = 'http://meflisyservice.com/login_partner.php';
    if (_mySelection == null &&
        _mySelection.length <= 0 &&
        _myCitySelection == null &&
        _myCitySelection.length <= 0) {
      setState(() {
        error = "Oops! Please select State or City";
        client.close();
      });
    } else {
      final response = await client.post(localityurl, body: {
        'state': _mySelection,
        'phone_number': only_number,
        'city': _myCitySelection
      });
      var resbody = jsonDecode(response.body);
      setState(() {
        error = "";
        user_data = resbody;
        if (user_data.length <= 0) {
          client.close();
          _submit(number);
        } else {
          print("The data is $user_data");
          error = "This number is already register at this city";
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
        error = "";
      });
    };

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {
      print("PhoneverificationCompleted is working");

      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);

      final prefs = await SharedPreferences.getInstance();
      if (refrence_id == null) {
        refrence_id = "No Refrence";
      }
      // checkUserAccount();
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          print("login delay work");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => payment(
                      name_controller.text,
                      aadhar_controller.text,
                      address_controller.text,
                      mobile_controller.text,
                      _mySelection,
                      _myCitySelection,
                      locationString,
                      _myCategorySelection,
                      sublocationString,
                      keywordString,
                      refrence_id,
                      image_path)));
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
                    textStyle: TextStyle(fontSize: 12),
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

    final FirebaseUser user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;

    print("AuthCrendential is work and goes to next");

    //checkUserAccount();

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        print("login delay work");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => payment(
                    name_controller.text,
                    aadhar_controller.text,
                    address_controller.text,
                    mobile_controller.text,
                    _mySelection,
                    _myCitySelection,
                    locationString,
                    _myCategorySelection,
                    sublocationString,
                    keywordString,
                    refrence_id,
                    image_path)));
      });
    });
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void initState() {
    getStateData();
    // checkUserAccount1();
    getCategoryData();
    super.initState();
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.camera)
        .then(_updateStatus);

    aadhar = FocusNode();
    address = FocusNode();
    mobile = FocusNode();
    state = FocusNode();
    name = FocusNode();

    animationContorller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);

    animation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationContorller, curve: Curves.fastOutSlowIn));

    animationContorller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFF005E6A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF005E6A),
        title: Text(
          "REGISTRATION",
          style: TextStyle(
              color: Colors.white, fontSize: 2.25 * SizeConfig.textMultiplier),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: new Container(
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
              child: new Form(
                key: this._formKey,
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: new ListView(
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          maxRadius: 16 * SizeConfig.imageSizeMultiplier,
                          backgroundColor: Color(0xFFE8F9FB),
                          child: Image.asset("images/meflogin.png"),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Please Enter Detail carefully, Because some information you can't change later",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 2 * SizeConfig.textMultiplier),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Material(
                        elevation: 2.0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.only(topRight: Radius.circular(15.0))),
                        child: Padding(
                          padding: EdgeInsets.all(3),
                          child: TextFormField(
                            focusNode: name,
                            controller: name_controller,
                            textInputAction: TextInputAction.next,
                            style:
                            TextStyle(fontSize: 2.5 * SizeConfig.textMultiplier),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              border: InputBorder.none,
                              hintText: "Full Name",
                              hintStyle: TextStyle(
                                  color: Color(0xFFE1E1E1),
                                  fontSize: 2.25 * SizeConfig.textMultiplier),
                            ),
                            onChanged: (value) {
                              full_name = value;
                            },
                            onFieldSubmitted: (term) {
                              _fieldFocusChange(context, name, aadhar);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please your name text';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Material(
                        elevation: 2.0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.only(topRight: Radius.circular(15.0))),
                        child: Padding(
                          padding: EdgeInsets.all(3),
                          child: TextFormField(
                            focusNode: aadhar,
                            style:
                            TextStyle(fontSize: 2.5 * SizeConfig.textMultiplier),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              border: InputBorder.none,
                              hintText: "AadharCard Number",
                              hintStyle: TextStyle(
                                  color: Color(0xFFE1E1E1),
                                  fontSize: 2.25 * SizeConfig.textMultiplier),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            controller: aadhar_controller,
                            onFieldSubmitted: (term) {
                              _fieldFocusChange(context, aadhar, address);
                            },
                            onChanged: (value) {
                              aadharcard_number = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter AadharCard number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Material(
                        elevation: 2.0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.only(topRight: Radius.circular(15.0))),
                        child: Padding(
                          padding: EdgeInsets.all(3),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            maxLines: 3,
                            focusNode: address,
                            style:
                            TextStyle(fontSize: 2.5 * SizeConfig.textMultiplier),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              border: InputBorder.none,
                              hintText: "Complete Address",
                              hintStyle: TextStyle(
                                  color: Color(0xFFE1E1E1),
                                  fontSize: 2.25 * SizeConfig.textMultiplier),
                            ),
                            controller: address_controller,
                            onChanged: (value) {
                              complete_address = value;
                            },
                            onFieldSubmitted: (term) {
                              _fieldFocusChange(context, address, mobile);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter Complete Address';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Material(
                        elevation: 2.0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.only(topRight: Radius.circular(15.0))),
                        child: Padding(
                          padding: EdgeInsets.all(3),
                          child: TextFormField(
                            focusNode: mobile,
                            style:
                            TextStyle(fontSize: 2.5 * SizeConfig.textMultiplier),
                            controller: mobile_controller,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              border: InputBorder.none,
                              hintText: "Mobile Number",
                              hintStyle: TextStyle(
                                  color: Color(0xFFE1E1E1),
                                  fontSize: 2.25 * SizeConfig.textMultiplier),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              phoneNumber = "+91" + value;
                              only_number = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter mobile number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        alignment: Alignment.center,
                        child: DropDown(data),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: DropDown2(_mySelection),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: DropDown3(_myCitySelection, _mySelection),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Category(category_data),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Subcategory(_myCategorySelection),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () => imageSelectorCamera(),
                        child: Container(
                          height: 47 * SizeConfig.imageSizeMultiplier,
                          width: 47 * SizeConfig.imageSizeMultiplier,
                          child: displaySelectedFile(setcameraFile),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Material(
                        elevation: 2.0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.only(topRight: Radius.circular(15.0))),
                        child: Padding(
                          padding: EdgeInsets.all(3),
                          child: TextFormField(
                            style: TextStyle(fontSize: 20),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              border: InputBorder.none,
                              hintText: "Have any Refrence ID",
                              hintStyle: TextStyle(
                                  color: Color(0xFFE1E1E1),
                                  fontSize: 2.25 * SizeConfig.textMultiplier),
                            ),
                            keyboardType: TextInputType.text,
                            controller: refrence_controller,
                            onChanged: (value) {
                              if (value == null) {
                                refrence_id = "No Refrence";
                              } else
                                refrence_id = value;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: errormsg(error),
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            Checkbox(
                                value: accept,
                                onChanged: (bool value) {
                                  setState(() {
                                    accept = value;
                                  });
                                }),
                            GestureDetector(
                              onTap: () {
                                launch("http://meflisyservice.com/policy.docx");
                              },
                              child: Text(
                                "I agree Terms and Conditions",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 2 * SizeConfig.textMultiplier),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        child: GestureDetector(
                          onTap: () {
                            if (_formKey.currentState.validate()) {
                              if (_myCategorySelection != null &&
                                  _myCitySelection != null &&
                                  sublocationString != null &&
                                  _mySelection != null &&
                                  locationString != null &&
                                  image_path != null) {
                                if (accept == true) {
                                  if (mobile_controller.text != refrence_id) {
                                    checkUserAccount(
                                        http.Client(), phoneNumber, only_number);
                                    Fluttertoast.showToast(
                                        msg: " Wait... ", timeInSecForIos: 4);
                                  } else {
                                    setState(() {
                                      error =
                                      "You can't use your mobile number as refrence id";
                                    });
                                  }
                                } else {
                                  setState(() {
                                    error = "Please agree to term and condition";
                                  });
                                }
                              } else {
                                setState(() {
                                  error =
                                  "Please select State, city, profession, upload image etc";
                                });
                              }
                            } else {
                              setState(() {
                                error = "Please fill form carefully";
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 15, right: 15, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                                color: Color(0xFF005E6A),
                                borderRadius: BorderRadius.circular(18.0),
                                border:
                                Border.all(color: Color(0xFF005E6A), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0.0, 10.0),
                                      blurRadius: 7),
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0.0, -10.0),
                                      blurRadius: 7),
                                ]),
                            margin: EdgeInsets.only(top: 15.0),
                            child: Text(
                              "Save and Next",
                              style: TextStyle(
                                fontSize: 3 * SizeConfig.textMultiplier,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget errormsg(String error) {
    return GestureDetector(
      child: new Container(
        child: error != null
            ? new Center(
                child: Container(
                  color: Colors.transparent,
                  child: Text(
                    error,
                    style: TextStyle(
                        fontSize: 2 * SizeConfig.textMultiplier,
                        color: Colors.red),
                  ),
                ),
              )
            : new Opacity(opacity: 0.0),
      ),
    );
  }

  Widget displaySelectedFile(File file) {
    return GestureDetector(
      child: new Container(
        height: 40 * SizeConfig.imageSizeMultiplier,
        width: 40 * SizeConfig.imageSizeMultiplier,
        child: file == null
            ? new Center(
                child: Container(
                  color: Colors.transparent,
                  child: Text(
                    "Click to Take photo",
                    style: TextStyle(
                        fontSize: 2.6 * SizeConfig.textMultiplier,
                        color: Colors.black),
                  ),
                ),
              )
            : new Image.file(
                file,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
      ),
    );
  }

  Widget DropDown(List data) {
    if (data != null) {
      return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.only(left: 5, right: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, 2.0),
                  blurRadius: 7),
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, -2.0),
                  blurRadius: 7),
            ]),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            icon: Icon(
              Icons.arrow_drop_down,
              color: Color(0xFFE1E1E1),
            ),
            items: data.map((item) {
              return new DropdownMenuItem(
                child: new Text(
                  item['state_name'],
                  style: TextStyle(fontSize: 2.25 * SizeConfig.textMultiplier),
                ),
                value: item['state_name'].toString(),
              );
            }).toList(),
            hint: Text(
              "Select your State/Cities",
              style: TextStyle(
                color: Color(0xFFE1E1E1),
              ),
            ),
            onChanged: (newVal) {
              setState(() {
                _mySelection = newVal;
                city_data = null;
                _myCitySelection = null;
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
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.only(left: 10, right: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0.0, 2.0),
                    blurRadius: 7),
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0.0, -2.0),
                    blurRadius: 7),
              ]),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Color(0xFFE1E1E1),
              ),
              items: city_data.map((item) {
                return new DropdownMenuItem(
                  child: new Text(
                    item['name'],
                    style:
                        TextStyle(fontSize: 2.25 * SizeConfig.textMultiplier),
                  ),
                  value: item['name'].toString(),
                );
              }).toList(),
              hint: Text(
                "Select your Town/Village",
                style: TextStyle(
                  color: Color(0xFFE1E1E1),
                ),
              ),
              onChanged: (newVal) {
                setState(() {
                  _myCitySelection = newVal;
                  locality_data = null;
                  getLocalityData(_myCitySelection, _mySelection);
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

  Widget DropDown3(String cityname, String statename) {
    double maxWidth = MediaQuery.of(context).size.width;
    if (cityname != null) {
      if (locality_data != null) {
        return Container(
          alignment: Alignment.center,
          width: maxWidth,
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.only(left: 10, right: 5),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Select your location where you want to give your services",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 2 * SizeConfig.textMultiplier),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: locality_data == null ? 0 : locality_data.length,
                itemBuilder: (BuildContext context, int index) {
                  return new Card(
                    child: new Container(
                      padding: new EdgeInsets.all(3.0),
                      child: new Column(
                        children: <Widget>[
                          new CheckboxListTile(
                              value: inputs[index],
                              title: new AutoSizeText(
                                locality_data[index]['locality'],
                                maxLines: 6,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (bool val) {
                                ItemChange(val, index);
                              })
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      } else {
        return new Center(
          child: CircularProgressIndicator(),
        );
      }
    }
  }

  Widget Category(List data) {
    if (data != null) {
      return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.only(left: 10, right: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, 2.0),
                  blurRadius: 7),
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, -2.0),
                  blurRadius: 7),
            ]),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            icon: Icon(
              Icons.arrow_drop_down,
              color: Color(0xFFE1E1E1),
            ),
            items: data.map((item) {
              return new DropdownMenuItem(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: CachedNetworkImage(
                        imageUrl:
                            "http://meflisyservice.com/category%20images/" +
                                item['category'].toString() +
                                ".png",
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
                        placeholder: (context, url) => SpinKitWave(
                          color: Color(0xFF00ACC1),
                          size: 20.0,
                          type: SpinKitWaveType.start,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                      margin: EdgeInsets.only(right: 9),
                      width: 10 * SizeConfig.imageSizeMultiplier,
                      height: 10 * SizeConfig.imageSizeMultiplier,
                    ),
                    new AutoSizeText(
                      item['category'],
                      style:
                          TextStyle(fontSize: 2.25 * SizeConfig.textMultiplier),
                      maxLines: 2,
                    ),
                  ],
                ),
                value: item['category'].toString(),
              );
            }).toList(),
            hint: AutoSizeText(
              "Select your profession",
              style: TextStyle(
                color: Color(0xFFE1E1E1),
              ),
              maxLines: 2,
            ),
            onChanged: (newVal) {
              setState(() {
                _myCategorySelection = newVal;
                subcategory_data = null;
                getSubCategoryData(_myCategorySelection);
              });
            },
            value: _myCategorySelection,
          ),
        ),
      );
    } else {
      return new Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget Subcategory(String profession) {
    double maxWidth = MediaQuery.of(context).size.width;
    if (profession != null) {
      if (subcategory_data != null) {
        return Container(
          alignment: Alignment.center,
          width: maxWidth,
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.only(left: 10, right: 5),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Select what you do",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 2.25 * SizeConfig.textMultiplier),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount:
                    subcategory_data == null ? 0 : subcategory_data.length,
                itemBuilder: (BuildContext context, int index) {
                  return new Card(
                    child: new Container(
                      padding: new EdgeInsets.all(3.0),
                      child: new Column(
                        children: <Widget>[
                          new CheckboxListTile(
                              value: subinputs[index],
                              title: Row(
                                children: <Widget>[
                                  Container(
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "http://meflisyservice.com/sub_catogery images/" +
                                              subcategory_data[index]
                                                  ['sub_category'] +
                                              ".jpg",
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color(0xFF00ACC1)),
                                          borderRadius:
                                              new BorderRadius.circular(13.0),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          SpinKitWave(
                                        color: Color(0xFF00ACC1),
                                        size: 20.0,
                                        type: SpinKitWaveType.start,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                    margin: EdgeInsets.only(right: 5),
                                    width: 10 * SizeConfig.imageSizeMultiplier,
                                    height: 10 * SizeConfig.imageSizeMultiplier,
                                  ),
                                  Expanded(
                                    child: new AutoSizeText(
                                      subcategory_data[index]['sub_category'],
                                      maxLines: 3,
                                    ),
                                  ),
                                ],
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (bool val) {
                                SubItemChange(val, index);
                              })
                        ],
                      ),
                    ),
                  );
                  //return AutoSizeText(locality_data[index]['locality']);
                },
              ),
            ],
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
