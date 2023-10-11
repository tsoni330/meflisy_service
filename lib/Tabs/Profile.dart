

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../MainHome.dart';
import '../size_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  String name, address, phone, pincode;
  final FocusNode _firstInputFocusNode = new FocusNode();
  final FocusNode _secondInputFocusNode = new FocusNode();
  final FocusNode _thirdInputFocusNode = new FocusNode();
  String url;
  var data;

  final TextEditingController _namecontroller = new TextEditingController();
  final TextEditingController _addresscontroller = new TextEditingController();
  final TextEditingController _pincodecontroller = new TextEditingController();

  Future<String> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // url=prefs.getString("update_url");
      phone = prefs.getString("phone_number");
      _getStates(http.Client());

    });
  }

  Future<String> _getStates(http.Client client) async {
    final prefs = await SharedPreferences.getInstance();
    print("Get state phone is ${phone}");
    final response =
        await client.post('http://meflisyservice.com/get_user.php', body: {
      'phone_number': phone,
    });

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
      });
      setState(() {
        for (var u in data) {
          name = u['name'];
          address = u['address'];
          pincode = u['pincode'];
          if (name == null || name == '') {
            prefs.setString("user_name", name);
            name = "Enter your name";
            _namecontroller.text=name;
          }else{
            _namecontroller.text=name;
          }
          if(address==null || address==''){
            address="Address (House No, Building, Street, Area)";
            _addresscontroller.text=address;
          }else{
            _addresscontroller.text=address;
          }
          if(pincode==null || pincode==''){
            pincode="Pincode";
            _pincodecontroller.text=pincode;
          }else{
            _pincodecontroller.text=pincode;
          }
        }
      });
    } else {
      Fluttertoast.showToast(msg: "Please Refresh it again");
    }


    client.close();
  }
  Future<String> _setUser(http.Client client, url) async {
    final response = await client.post(url, body: {
      'name': name,
      'address': address,
      'pincode': pincode,
      'phone_number': phone
    });
    client.close();
  }

  @override
  void initState() {
    getPhone();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00ACC1),
      appBar: AppBar(

        elevation: 0,
        backgroundColor: Color(0xFF00ACC1),
        title: Text(
          "PROFILE",
          style: TextStyle(fontSize: 2.3 * SizeConfig.textMultiplier),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(7*SizeConfig.imageSizeMultiplier),
              topLeft: Radius.circular(7*SizeConfig.imageSizeMultiplier),
            )
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height:7*SizeConfig.imageSizeMultiplier ,),
            Expanded(
              child: ListView(
                children: <Widget>[
                  data != null
                      ? Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Column(
                            children: <Widget>[
                              name!=null?TextField(
                                controller: _namecontroller,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                                decoration: InputDecoration(
                                  labelText: "Name"+" *",
                                  labelStyle:
                                      TextStyle(color: Colors.black54, fontSize: 12),
                                ),
                                keyboardType: TextInputType.text,
                                onChanged: (value) => name = value,
                                focusNode: _firstInputFocusNode,
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_secondInputFocusNode),
                                textInputAction: TextInputAction.next,
                              ):Center(child: CircularProgressIndicator(),),

                              Padding(padding: EdgeInsets.only(top: 15)),

                              address!=null?TextField(
                                controller: _addresscontroller,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                                decoration: InputDecoration(
                                  labelText:
                                      "Address"+" *",
                                  labelStyle:
                                      TextStyle(color: Colors.black54, fontSize: 12),
                                  fillColor: Colors.black54,
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                focusNode: _secondInputFocusNode,
                                onEditingComplete: () => FocusScope.of(context)
                                    .requestFocus(_thirdInputFocusNode),
                                onChanged: (value) => address = value,
                                textInputAction: TextInputAction.next,
                              ):Center(child: CircularProgressIndicator(),),

                              Padding(padding: EdgeInsets.only(top: 15)),

                              pincode!=null?TextField(
                                controller: _pincodecontroller,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                                decoration: InputDecoration(
                                  labelText: "Pincode"+" *",
                                  labelStyle:
                                      TextStyle(color: Colors.black54, fontSize: 12),
                                  fillColor: Colors.black54,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => pincode = value,
                                focusNode: _thirdInputFocusNode,
                                textInputAction: TextInputAction.done,
                              ):Center(child: CircularProgressIndicator(),),

                              Align(
                                child: Container(
                                  margin: EdgeInsets.only(top: 20.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        child: RaisedButton(
                                          color: Color(0xFF00BCD4),
                                          onPressed: () {
                                            _setUser(http.Client(),
                                                "http://meflisyservice.com/edit_user.php");
                                            Future.delayed(Duration(seconds: 1), () {
                                              final snackBar = SnackBar(
                                                  content: Text(
                                                      "Your information is saved"));
                                              Scaffold.of(context)
                                                  .showSnackBar(snackBar);
                                            });
                                          },
                                          textColor: Colors.white,
                                          padding: const EdgeInsets.all(10.0),
                                          child: new Text(
                                            "SAVE",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ) // Let's get started button
                            ],
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(top: 10),
                          alignment: Alignment.center,
                          child: SpinKitFadingCircle(
                            size: 60,
                            color: Color(0xFF00ACC1),
                          ),
                        ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
