import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:meflisy_service/partner/partnerMainHome.dart';
import 'dart:convert';

import 'package:meflisy_service/partner/wallet_meflisy.dart';

import '../size_config.dart';

class clam extends StatefulWidget {
  String phone;
  int amount;
  clam(this.phone,this.amount);

  @override
  _clamState createState() => _clamState();
}

class _clamState extends State<clam> {

  String amount,accountno,ifsccode,accountname,phone,clamdate,date;

  String clamstatus="Panding";
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final FocusNode _firstInputFocusNode = new FocusNode();
  final FocusNode _secondInputFocusNode = new FocusNode();
  final FocusNode _thirdInputFocusNode = new FocusNode();

  Future<String> sendRequest(String refrenceid) async {
    String localityurl = "http://meflisyservice.com/clam_upload.php";
    http.Client client = new http.Client();
    var res = await client.post(Uri.encodeFull(localityurl), body: {
      'amount':(widget.amount-5).toString(),
      'accountno':accountno,
      'accountname':accountname,
      'phone':widget.phone,
      'ifsccode':ifsccode,
      'clamstatus':clamstatus,
      'requestid':refrenceid,
      'clamdate':date
    });
    if(res.statusCode!=200){
      Fluttertoast.showToast(
          msg: "Something Went wornge. Try Again later ",
          timeInSecForIos: 4);
    }else{
      Fluttertoast.showToast(
          msg: "Your request is send",
          timeInSecForIos: 4);
    }
    client.close();
    return 'Success';
  }


  getDate() {
    var paymentdate = new DateTime.now();
    setState(() {
      date = new DateFormat("yyyy-MM-dd").format(paymentdate).toString();
      print("The date is {$date}");
    });
  }


  @override
  void initState() {
    super.initState();
    getDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFF00Acc1)),
        title:Text("Clam",style: TextStyle(color: Color(0xFF00acc1)),),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.only(bottom: 10),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(8)),
                  Text(
                    " \u20B9"+widget.amount.toString(),
                    style: TextStyle(fontSize:6.1*SizeConfig.textMultiplier, color: Colors.black),
                  ),
                  Text(
                    "Transaction fee - \u20B9 5",
                    style: TextStyle(fontSize: 2.5*SizeConfig.textMultiplier, color: Colors.black),
                  ),
                  Divider(color: Colors.black,),
                  Text(
                    " Total Amount  "+(widget.amount-5).toString()+" \u20B9 ",
                    style: TextStyle(fontSize: 2.5*SizeConfig.textMultiplier, color: Colors.black),
                  ),

                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 2.25*SizeConfig.textMultiplier),
                decoration: InputDecoration(
                  labelText: "Bank Account Number *",
                  labelStyle: TextStyle(color: Colors.black54,fontSize: 1.5*SizeConfig.textMultiplier),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => accountno = value,
                focusNode: _firstInputFocusNode,
                onEditingComplete: () => FocusScope.of(context)
                    .requestFocus(_secondInputFocusNode),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter Bank Account number';
                  }
                  return null;
                },

              ),
            ),

            Padding(padding: EdgeInsets.only(top: 15)),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 2.25*SizeConfig.textMultiplier),
                decoration: InputDecoration(
                  labelText: "Ifsc Code *",
                  labelStyle: TextStyle(color: Colors.black54,fontSize: 1.5*SizeConfig.textMultiplier),
                  fillColor: Colors.black54,
                ),

                focusNode: _secondInputFocusNode,
                onEditingComplete: () => FocusScope.of(context)
                    .requestFocus(_thirdInputFocusNode),
                keyboardType: TextInputType.text,
                maxLines: null,
                onChanged: (value) => ifsccode = value,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter Ifsc Code';
                  }
                  return null;
                },
              ),
            ),

            Padding(padding: EdgeInsets.only(top: 15)),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 2.25*SizeConfig.textMultiplier),
                decoration: InputDecoration(
                  labelText:"Account Holder Name *",
                  labelStyle: TextStyle(color: Colors.black54,fontSize:1.5*SizeConfig.textMultiplier),
                  fillColor: Colors.black54,
                ),
                keyboardType: TextInputType.text,
                onChanged: (value) => accountname = value,
                focusNode: _thirdInputFocusNode,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter Account Holder name';
                  }
                  return null;
                },
              ),
            ),

            GestureDetector(
              onTap: (){
                if(_formKey.currentState.validate()){
                  var rng = new Random();
                  int code = rng.nextInt(900000) + 100000;
                  sendRequest(code.toString());
                  Future.delayed(
                      Duration(seconds: 1),
                          (){
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context)=>partnerMainHome()));
                      }
                  );


                }else{
                  Fluttertoast.showToast(
                      msg: "Fill information carefully",
                      timeInSecForIos: 4);
                }
              },
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 15, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                            color: Color(0xFF00BCD4),
                            width: 1
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 1),
                            child: Text(
                              "Clam Now",
                              style: TextStyle(fontSize: 2.5*SizeConfig.textMultiplier),
                            ),
                          ),
                          Icon(
                            Icons.forward,
                            size: 8.3*SizeConfig.imageSizeMultiplier,
                          )
                        ],
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
