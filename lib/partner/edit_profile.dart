import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meflisy_service/MainHome.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fluttertoast/fluttertoast.dart';

import '../size_config.dart';
import 'loginPartner.dart';

class edit_profile extends StatefulWidget {
  const edit_profile({Key key}) : super(key: key);

  @override
  _edit_profileState createState() => _edit_profileState();
}

class _edit_profileState extends State<edit_profile> {
  File getcameraFile, setcameraFile;

  FocusNode description, addressfocus;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  var address_controller = TextEditingController();
  var name_controller = TextEditingController();
  var description_controller = TextEditingController();

  String address,
      phone,
      statename,
      cityname,
      locality,
      profession,
      sub_profession,
      image,
      image64,
      newdescription,
      newaddress,
      descp,
      newname;

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

  imageSelectorCamera() async {
    final prefs = await SharedPreferences.getInstance();
    getcameraFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: getcameraFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      maxHeight: 512,
      maxWidth: 512,
    );
    var result = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path, getcameraFile.path,
        quality: 70);
    String base64 = base64Encode(result.readAsBytesSync());
    print("You selected camera image : " + getcameraFile.path);
    setState(() {
      setcameraFile = result;
      image64 = base64;
      image = image64;
    });
  }

  Future<String> update() async {
    final prefs = await SharedPreferences.getInstance();
    String localityurl = "http://meflisyservice.com/edit_partner.php";
    http.Client client = new http.Client();


    var res = await client.post(Uri.encodeFull(localityurl), body: {
      'address': address,
      'phone_number': phone,
      'state': statename,
      'city': cityname,
      'profile_image': image,
      'description': newdescription,
      'name': newname
    });
    if (res.statusCode == 200) {
      prefs.setString("meflisy_description", newdescription);
      prefs.setString("meflisy_address", newaddress);
      prefs.setString("meflisy_image", image);
      prefs.setString("meflisy_name", newname);
      Fluttertoast.showToast(msg: "Your Data is Save", timeInSecForIos: 8);
    }
    client.close();
    return 'Success';
  }

  setValued() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      newname = prefs.getString("meflisy_name");
      phone = prefs.getString("meflisy_mobile");
      address = prefs.getString("meflisy_address");
      statename = prefs.getString("meflisy_state");
      cityname = prefs.getString("meflisy_city");
      locality = prefs.getString("meflisy_locality");
      sub_profession = prefs.getString("meflisy_sub_profession");
      image = prefs.getString("meflisy_image");
      if (prefs.getString("meflisy_description") != null) {
        descp = prefs.getString("meflisy_description");
        newdescription = descp;
      }
      address_controller.text = address;
      description_controller.text = newdescription;
      name_controller.text = newname;
    });
  }

  logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("login_check", "false");
    prefs.remove("partner_name");
    prefs.remove("login_state");
    prefs.remove("login_city");
    prefs.remove("login_mobile");
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
          title: Text("Edit Profile"),
          backgroundColor: Color(0xFF00ACC1),
          elevation: 0,
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
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: <Widget>[
                            GestureDetector(
                              child: new Card(
                                elevation: 0,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: 1, left: 1, right: 1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(children: <Widget>[
                                      displaySelectedFile(image),
                                      GestureDetector(
                                        onTap: () {
                                          imageSelectorCamera();
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(top: 10),
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Color(0xFF00ACC1),
                                          ),
                                          child: Text(
                                            "Edit Photo",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 2.5 *
                                                    SizeConfig.textMultiplier),
                                          ),
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
                                              "Change Name",
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
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Align(
                                            child: Material(
                                              elevation: 2.0,
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  15.0))),
                                              child: Padding(
                                                padding: EdgeInsets.all(3),
                                                child: TextFormField(
                                                  maxLines: 1,
                                                  focusNode: addressfocus,
                                                  controller: name_controller,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  style: TextStyle(
                                                      fontSize: 2.2 *
                                                          SizeConfig
                                                              .textMultiplier),
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(5),
                                                    border: InputBorder.none,
                                                    hintText: newname,
                                                    hintStyle: TextStyle(
                                                        color:
                                                            Color(0xFFE1E1E1),
                                                        fontSize: 2.2 *
                                                            SizeConfig
                                                                .textMultiplier),
                                                  ),
                                                  onChanged: (value) {
                                                    newname = value;
                                                  },
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      newname = newname;
                                                    }
                                                    return null;
                                                  },
                                                ),
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
                                              "Change Address",
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
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Align(
                                            child: Material(
                                              elevation: 2.0,
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  15.0))),
                                              child: Padding(
                                                padding: EdgeInsets.all(3),
                                                child: TextFormField(
                                                  maxLines: null,
                                                  focusNode: addressfocus,
                                                  controller:
                                                      address_controller,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  style: TextStyle(
                                                      fontSize: 2.2 *
                                                          SizeConfig
                                                              .textMultiplier),
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(5),
                                                    border: InputBorder.none,
                                                    hintText: address,
                                                    hintStyle: TextStyle(
                                                        color:
                                                            Color(0xFFE1E1E1),
                                                        fontSize: 2.2 *
                                                            SizeConfig
                                                                .textMultiplier),
                                                  ),
                                                  onChanged: (value) {
                                                   address = value;
                                                  },
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      address = address;
                                                    }
                                                    return null;
                                                  },
                                                ),
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
                                              "Write Something about Service, Pricing",
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
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Align(
                                            child: Material(
                                              elevation: 2.0,
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  15.0))),
                                              child: Padding(
                                                padding: EdgeInsets.all(3),
                                                child: TextFormField(
                                                  maxLines: null,
                                                  focusNode: description,
                                                  controller:
                                                      description_controller,
                                                  style: TextStyle(
                                                      fontSize: 2.2 *
                                                          SizeConfig
                                                              .textMultiplier),
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(5),
                                                    border: InputBorder.none,
                                                    hintText: newdescription,
                                                    hintStyle: TextStyle(
                                                        color:
                                                            Color(0xFFE1E1E1),
                                                        fontSize: 2.2 *
                                                            SizeConfig
                                                                .textMultiplier),
                                                  ),
                                                  onChanged: (value) {
                                                    newdescription = value;
                                                  },
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      newdescription = descp;
                                                    }
                                                    return null;
                                                  },
                                                ),
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
                                color: Colors.transparent,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: 1, left: 1, right: 1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          if (_formKey.currentState
                                              .validate()) {
                                            update();
                                          }
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(top: 10),
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Color(0xFF00ACC1),
                                          ),
                                          child: Text(
                                            "  Save Details  ",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 2.5 *
                                                    SizeConfig.textMultiplier),
                                          ),
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
                                  margin: EdgeInsets.only(
                                      top: 1, left: 1, right: 1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 1.0),
                                          child: Align(
                                            child: Text(
                                              "Important Note :- ",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 2 *
                                                      SizeConfig.textMultiplier,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            alignment: Alignment.topLeft,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 1.0),
                                          child: Align(
                                            child: Text(
                                              "You cannot change your Aadhar card no., Profession and Phone Number. if you want to change then contact us 8882191868\n\n आप अपना आधार कार्ड नंबर, पेशा नहीं बदल सकते हैं, अगर बदलना चाहते हैं तो हमसे संपर्क करें 8882191868",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 2 *
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
                              onTap: () {
                                logout();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => loginPartner()));
                              },
                              child: new Card(
                                elevation: 0,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      top: 1, left: 1, right: 1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: <Widget>[
                                        IconButton(
                                          icon: IconButton(
                                            padding: EdgeInsets.only(
                                                right: 20, bottom: 10),
                                            icon: Icon(
                                              Icons.exit_to_app,
                                              color: Colors.grey,
                                              size: 8 *
                                                  SizeConfig
                                                      .imageSizeMultiplier,
                                            ),
                                            onPressed: () {
                                              logout();
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          loginPartner()));
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 1.0),
                                          child: Align(
                                            child: Text(
                                              "Log Out",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 2.5 *
                                                      SizeConfig.textMultiplier,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
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
                          ],
                        ),
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
        height: 40 * SizeConfig.imageSizeMultiplier,
        width: 40 * SizeConfig.imageSizeMultiplier,
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
