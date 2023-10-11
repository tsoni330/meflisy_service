import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:meflisy_service/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Report extends StatefulWidget {

  String partnerid,state,city,profession;
  Report(this.partnerid,this.state,this.city,this.profession);
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {

  String report,nowdate,userPhone,partnerid;

  getDate() {
    var paymentdate = new DateTime.now();
    setState(() {
      nowdate = new DateFormat("yyyy-MM-dd").format(paymentdate).toString();
    });
  }
  getUserDetail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userPhone = prefs.getString("phone_number");
      print("The user number is " + userPhone);
    });
  }

  Future<String> postReport() async {
    String localityurl = "http://meflisyservice.com/complaint.php";
    http.Client client = new http.Client();
    var response = await client.post(Uri.encodeFull(localityurl), body: {
      'partnerid': widget.partnerid,
      'profession': widget.profession,
      'date': nowdate,
      'message': report,
      'userid': userPhone,
      'state': widget.state,
      'city': widget.city
    });
    setState(() {
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Report is Submit", timeInSecForIos: 4);
      } else {
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });
    client.close();
    return 'Success';
  }

  @override
  void initState() {
    super.initState();
    getDate();
    getUserDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Tell us what happen",
          style: TextStyle(color: Color(0xFF00ACC1)),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF00ACC1)),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
              Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Column(
                  children: <Widget>[

                    TextField(
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      decoration: InputDecoration(
                        labelText:"What happen *",
                        labelStyle: TextStyle(color: Colors.black54,fontSize: 12),
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (value) => report = value,

                      textInputAction: TextInputAction.done,
                    ),


                    Align(
                      child: Container(
                        width: 25*SizeConfig.imageSizeMultiplier,
                        margin: EdgeInsets.only(top: 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              child: RaisedButton(
                                color: Color(0xFF00BCD4),
                                onPressed: () {
                                  if(report!=null){
                                    postReport();
                                  }else{
                                    Fluttertoast.showToast(
                                        msg: "Enter Something ", timeInSecForIos: 4);
                                  }
                                },
                                textColor: Colors.white,
                                padding: const EdgeInsets.all(10.0),
                                child: new Text(
                                  "Report",
                                  style: TextStyle(fontSize: 2*SizeConfig.textMultiplier),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ) // Let's get started button
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
