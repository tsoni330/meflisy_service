import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:meflisy_service/partner/clam.dart';

import '../size_config.dart';

class wallet_meflisy extends StatefulWidget {
  String refrenceid;

  wallet_meflisy(this.refrenceid);

  @override
  _wallet_meflisyState createState() => _wallet_meflisyState();
}

class _wallet_meflisyState extends State<wallet_meflisy> {
  List<Photo> list;
  List<Photo2> list2;

  List data, clamdata;
  bool check = true;
  bool clamcheck = true;
  bool maincheck = true;
  int wallet=0;
  List pricinglist;

  Future getPricing() async {
    String url = 'http://meflisyservice.com/pricing.php';
    http.Client client = new http.Client();

    final response = await client.get(url);
    var resbody = jsonDecode(response.body);
    setState(() {
      if (response.statusCode == 200) {
        pricinglist = resbody;

        if (pricinglist.length > 0) {

          for (var u in pricinglist) {
            wallet = int.parse(u['wallet']);
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
    String localityurl = "http://meflisyservice.com/refrence_show.php";
    http.Client client = new http.Client();
    var response = await client.post(Uri.encodeFull(localityurl),
        body: {'refrenceid': widget.refrenceid});
    setState(() {
      if (response.statusCode == 200) {
        data = json.decode(response.body);
        list = (json.decode(response.body) as List)
            .map((data) => new Photo.fromJson(data))
            .toList();

        if (list.length <= 0 && list.isEmpty) {
          check = false;
        }
      } else {
        check = false;
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });
    client.close();
    return 'Success';
  }

  Future<String> showClam() async {
    String localityurl = "http://meflisyservice.com/clam_show.php";
    http.Client client = new http.Client();
    var response = await client.post(Uri.encodeFull(localityurl),
        body: {'refrenceid': widget.refrenceid});
    setState(() {
      if (response.statusCode == 200) {
        clamdata = json.decode(response.body);
        list2 = (json.decode(response.body) as List)
            .map((data) => new Photo2.fromJson(data))
            .toList();

        if (list2.length <= 0 && list2.isEmpty) {
          clamcheck = false;
          setRefrence();
        } else {
          check = false;
          maincheck = false;
        }
      } else {
        clamcheck = false;
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });
    client.close();
    return 'Success';
  }

  @override
  void initState() {

    getPricing();
    showClam();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        centerTitle: true,
        backgroundColorEnd: Color(0xFF00f2f2),
        backgroundColorStart: Color(0xFF00b0b0),
        title: Text(
          "Wallet",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[
            list2 != null && clamcheck
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "You already clam for money ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
            list2 != null && clamcheck
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: list2.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        child: new Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.0),
                          ),
                          color: Colors.white,
                          elevation: 3,
                          child: Container(
                            margin: EdgeInsets.only(top: 1, left: 1, right: 1),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Amount",
                                        style: TextStyle(fontSize: 2 * SizeConfig.textMultiplier),
                                      ),
                                      Text(
                                        list2[index].amount,
                                        style: TextStyle(fontSize: 2 * SizeConfig.textMultiplier),
                                      )
                                    ],
                                  ),
                                  Padding(padding: EdgeInsets.all(8)),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Account Number ",
                                        style: TextStyle(fontSize: 2 * SizeConfig.textMultiplier),
                                      ),
                                      Text(
                                        list2[index].accountno,
                                        style: TextStyle(fontSize:2 * SizeConfig.textMultiplier),
                                      )
                                    ],
                                  ),
                                  Padding(padding: EdgeInsets.all(8)),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Amount Holder Name",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        list2[index].accountname,
                                        style: TextStyle(fontSize: 2 * SizeConfig.textMultiplier),
                                      )
                                    ],
                                  ),
                                  Padding(padding: EdgeInsets.all(8)),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Clam Status",
                                        style: TextStyle(fontSize: 2 * SizeConfig.textMultiplier),
                                      ),
                                      Text(
                                        list2[index].clamstatus,
                                        style: TextStyle(fontSize: 2 * SizeConfig.textMultiplier),
                                      )
                                    ],
                                  ),
                                  Padding(padding: EdgeInsets.all(8)),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Request Id",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        list2[index].requestid,
                                        style: TextStyle(fontSize: 2 * SizeConfig.textMultiplier),
                                      )
                                    ],
                                  ),
                                  Padding(padding: EdgeInsets.all(8)),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Request Date",
                                        style: TextStyle(fontSize: 2 * SizeConfig.textMultiplier),
                                      ),
                                      Text(
                                        list2[index].clamdate,
                                        style: TextStyle(fontSize: 2 * SizeConfig.textMultiplier),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                : new Center(
                    child: clamcheck
                        ? SpinKitFadingCircle(color: Color(0xff00ACC1),size: 50,)
                        :SizedBox(),
                  ),
            GestureDetector(
              child: list != null
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          end: Alignment.centerLeft,
                          begin: Alignment.centerRight,
                          colors: [Color(0xFF00f2f2), Color(0xFF00b0b0)],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text("Total earning money",
                              style:
                                  TextStyle(fontSize: 1.9 * SizeConfig.textMultiplier, color: Colors.white)),
                          Text(
                            "\u20B9 " + (list.length * wallet).toString(),
                            style: TextStyle(fontSize: 7.5 * SizeConfig.textMultiplier, color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => clam(
                                          widget.refrenceid,
                                          list.length * wallet)));
                            },
                            child:list.length!=0? Container(
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(top: 5, right: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                          color: Color(0xFF00BCD4), width: 1),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(left: 1),
                                          child: Text(
                                            "Clam Now",
                                            style: TextStyle(fontSize: 2.5* SizeConfig.textMultiplier),
                                          ),
                                        ),
                                        Icon(
                                          Icons.forward,
                                          size: 30,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ):Opacity(opacity: 0.0,),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
            ),
            list != null && check
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Total Partner add by you is " +
                                list.length.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Name",
                              style: TextStyle(
                                  fontSize: 2 * SizeConfig.textMultiplier, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Registration Date",
                              style: TextStyle(
                                  fontSize: 2 * SizeConfig.textMultiplier, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
            list != null && check
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        child: new Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.0),
                          ),
                          color: Colors.white,
                          elevation: 3,
                          child: Container(
                            margin: EdgeInsets.only(top: 1, left: 1, right: 1),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    list[index].name,
                                    style: TextStyle(fontSize: 2 * SizeConfig.textMultiplier),
                                  ),
                                  Text(
                                    list[index].date,
                                    style: TextStyle(fontSize: 2 * SizeConfig.textMultiplier),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                : new Center(
                    child: check
                        ? SpinKitFadingCircle(color: Color(0xff00ACC1),size: 50,)
                        : maincheck
                            ? Container(
                                margin:
                                    EdgeInsets.only(top: 20, left: 5, right: 5),
                                child: Text(
                                  "You not register any partner\nShare the app now and register service provider and give your refrence id which is your register mobile number and earn "+wallet.toString()+ " rs per registration",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 2 * SizeConfig.textMultiplier, color: Colors.red),
                                ),
                              )
                            : SizedBox()),
          ],
        ),
      ),
    );
  }
}

class Photo {
  final String name;
  final String date;

  Photo._({this.name, this.date});

  factory Photo.fromJson(Map json) {
    return new Photo._(
      name: json['partner_name'],
      date: json['date'],
    );
  }
}

class Photo2 {
  final String amount;
  final String accountno;
  final String ifsccode;
  final String accountname;
  final String clamstatus;
  final String clamdate;
  final String requestid;

  Photo2._(
      {this.amount,
      this.accountno,
      this.ifsccode,
      this.accountname,
      this.clamstatus,
      this.clamdate,
      this.requestid});

  factory Photo2.fromJson(Map json) {
    return new Photo2._(
        amount: json['amount'],
        accountno: json['accountno'],
        ifsccode: json['ifsccode'],
        accountname: json['accountname'],
        clamstatus: json['clamstatus'],
        clamdate: json['clamdate'],
        requestid: json['requestid']);
  }
}
