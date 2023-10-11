import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:meflisy_service/partner/partnerMainHome.dart';

import 'dart:convert';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../size_config.dart';

class payment extends StatefulWidget {

  final String name,aadhar,address,mobile,state,city,locality;
  final String catogery,subcatogery,keyword,refrenceid,image;

  payment(this.name, this.aadhar, this.address, this.mobile, this.state, this.city, this.locality, this.catogery, this.subcatogery, this.keyword, this.refrenceid, this.image);
  @override
  _paymentState createState() => _paymentState();
}

class _paymentState extends State<payment> {

  FirebaseMessaging _firebaseMessaging=new FirebaseMessaging();
  String nowdate;
  Razorpay _razorpay;
  List pricinglist;
  List<String> urls= new List();
  int pricing=0;
  String payment_id;
  String token;


  fcm() async{
   await _firebaseMessaging.getToken().then((onvalue){
     token=onvalue;
   });
  }

  getDate() {
    var paymentdate = new DateTime.now();
    setState(() {
      nowdate = new DateFormat("yyyy-MM-dd").format(paymentdate).toString();
      print("The date is {$nowdate}");
    });
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    fcm();
    getDate();
    getPricing();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }


  Future removeData()async{
    final prefs= await SharedPreferences.getInstance();
    prefs.remove("partner_fullname");
    prefs.remove("partner_completeaddress");
    prefs.remove("partner_mobilenumber");
    prefs.remove("partner_aadharcard");
    prefs.remove("partner_state");
    prefs.remove("partner_city");
    prefs.remove("partner_locality");
    prefs.remove("partner_refrenceid");
    prefs.remove("partner_profession");
    prefs.remove("partner_subprofession");
    prefs.remove("partner_keyword");
    prefs.remove("partner_image");
  }

  Future<String> getLocalityData() async {
    String localityurl = "http://meflisyservice.com/register_partner.php";
    http.Client client = new http.Client();
    var res = await client.post(Uri.encodeFull(localityurl), body: {
      'name': widget.name,
      'aadhar': widget.aadhar,
      'address': widget.address,
      'phone_number': widget.mobile,
      'state': widget.state,
      'city': widget.city,
      'locality': widget.locality,
      'profession': widget.catogery,
      'sub_profession': widget.subcatogery,
      'keyword': widget.keyword,
      'payment_id': payment_id,
      'profile_image': widget.image,
      'idno': widget.refrenceid,
      'date': nowdate,
      'token':token
    }
    );
    client.close();
    return 'Success';
  }

  Future getPricing() async {
    String url = 'http://meflisyservice.com/pricing.php';
    http.Client client = new http.Client();
    print("This function is working");
    final response = await client.get(url);
    var resbody = jsonDecode(response.body);
    setState(() {
      if (response.statusCode == 200) {
        pricinglist = resbody;
        print("The length of pricing list is ${pricinglist.length.toString()}");
        if (pricinglist.length > 0) {
          print("The data is ${pricinglist}");
          for (var u in pricinglist) {
            pricing = int.parse(u['pricing']);
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



  Future<String> setRefrence() async {
    String localityurl = "http://meflisyservice.com/refrence_upload.php";
    http.Client client = new http.Client();
    var res = await client.post(Uri.encodeFull(localityurl), body: {
      'name': widget.name,
      'state': widget.state,
      'city': widget.city,
      'date': nowdate,
      'refrenceid':widget.refrenceid
    });

    client.close();
    return 'Success';
  }

  Future _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId, timeInSecForIos: 4);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      payment_id = response.paymentId;
      prefs.setString("login_check","true");
      prefs.setString("partner_name", widget.name );
      prefs.setString("login_state",widget.state );
      prefs.setString("login_city",widget.city);
      prefs.setString("login_mobile", widget.mobile);
    });
    getLocalityData();
    setRefrence();
    removeData();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => partnerMainHome()));
      });
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message,
        timeInSecForIos: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response)async {

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString("login_check","true");
      prefs.setString("partner_name", widget.name );
      prefs.setString("login_state",widget.state );
      prefs.setString("login_city",widget.city);
      prefs.setString("login_mobile", widget.mobile);
      payment_id = response.walletName;

    });
    removeData();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        getLocalityData();
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => partnerMainHome()));
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_live_BsiB9gScybmIgN',//'''rzp_live_BsiB9gScybmIgN',//rzp_test_FtU548F56Fw0wC
      'amount': pricing*100,
      'name': widget.name,
      'description': 'Thanks for choosing us',
      'prefill': {'contact': widget.mobile},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Thanks for Choosing us"),
        backgroundColor: Color(0xFF00ACC1),
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/paymenbackground.png"),
              fit: BoxFit.fill),
        ),
        child: Container(
          alignment: Alignment.center,
            height: 28.5*SizeConfig.imageSizeMultiplier,
            margin: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 24.0,
            ),
            child: new Stack(
              children: <Widget>[

                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  margin: EdgeInsets.only(left:20,right:20,bottom:20,top:60),
                  padding: EdgeInsets.only(top:80),
                  decoration: BoxDecoration(
                      color: Color(0xFFE8F9FB),
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: Color(0xFFE8F9FB), width: 1),
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
                  child: ListView(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 7,bottom: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left:8.0,bottom: 10,top: 10),
                                child: Text("Name : ",style: TextStyle(fontSize: 2.25*SizeConfig.textMultiplier),),
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right:8.0,bottom: 10,top:10),
                                child: Text(widget.name,style: TextStyle(fontSize: 2.25*SizeConfig.textMultiplier),),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 7,bottom: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left:8.0,bottom: 10,top: 10),
                                child: Text("Mobile Number: ",style: TextStyle(fontSize: 2.25*SizeConfig.textMultiplier),),
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right:8.0,bottom: 10,top: 10),
                                child: Text(widget.mobile,style: TextStyle(fontSize: 2.25*SizeConfig.textMultiplier),),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 7,bottom: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left:8.0,bottom:10,top: 10),
                                child: Text("State : ",style: TextStyle(fontSize: 2.25*SizeConfig.textMultiplier),),
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right:8.0,bottom:10,top: 10),
                                child: Text(widget.state,style: TextStyle(fontSize: 2.25*SizeConfig.textMultiplier),),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 7,bottom: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left:8.0),
                                child: Text("City : ",style: TextStyle(fontSize: 2.25*SizeConfig.textMultiplier),),
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right:8.0,top: 10,bottom: 10),
                                child: Text(widget.city,style: TextStyle(fontSize: 2.25*SizeConfig.textMultiplier),),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 7,bottom: 7),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                        child: Row(

                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left:8.0),
                                child: Text("Total Amount : ",style: TextStyle(fontSize: 2.25*SizeConfig.textMultiplier),),
                              ),
                            ),

                            pricing>0?Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right:8.0),
                                child: Text(pricing.toString()+" rs / year\n Include GST",style: TextStyle(fontSize: 2.25*SizeConfig.textMultiplier),),
                              ),
                            ):Padding(
                              padding: const EdgeInsets.only(right:8.0),
                              child: Text(" wait rs / year\n Include GST",style: TextStyle(fontSize: 2.25*SizeConfig.textMultiplier),),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 7,bottom: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left:8.0,top: 10,bottom: 10),
                                child: Text("Date : ",style: TextStyle(fontSize:2.25*SizeConfig.textMultiplier),),
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right:8.0,top:10,bottom: 10),
                                child: Text(nowdate,style: TextStyle(fontSize:2.25*SizeConfig.textMultiplier),),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top:28.0),
                        child: Align(

                          child: GestureDetector(
                            onTap: () {
                              if(pricing>0){
                                openCheckout();
                              }else{
                                Fluttertoast.showToast(msg: "Wait Payment is loading...");
                              }
                            },
                            child: Container(

                              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                  color: Color(0xFF005E6A),
                                  borderRadius: BorderRadius.circular(18.0),
                                  border: Border.all(color: Color(0xFF005E6A), width: 1),
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
                                "Payment",
                                style: TextStyle(
                                  fontSize: 3*SizeConfig.textMultiplier,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: displaySelectedFile(widget.image),
                ),
              ],
            )
        ),
      ),
    );
  }


  Widget displaySelectedFile(String file) {
    return GestureDetector(
      child: new Container(

        height: 28.5*SizeConfig.imageSizeMultiplier,
        width: 28.5*SizeConfig.imageSizeMultiplier,
        child: file == null
            ? new Center(
                child: Container(
                  color: Colors.transparent,
                  child: Text(
                    "Please Take photo",
                    style: TextStyle(fontSize: 2*SizeConfig.textMultiplier, color: Colors.black),
                  ),
                ),
              )
            : new CircleAvatar(
                maxRadius: 12*SizeConfig.imageSizeMultiplier,
                minRadius: 7.5*SizeConfig.imageSizeMultiplier,
                backgroundColor: Colors.transparent,
                backgroundImage: MemoryImage(base64Decode(file)),
              ),
      ),
    );
  }
}

class Photo2 {
  final String title;

  Photo2._({this.title});

  factory Photo2.fromJson(Map json) {
    return new Photo2._(title: json['pricing']);
  }
}