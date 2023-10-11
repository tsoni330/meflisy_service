import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:meflisy_service/size_config.dart';
import 'package:url_launcher/url_launcher.dart';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'MainHome.dart';

class theme extends StatefulWidget {
  @override
  _themeState createState() => _themeState();
}


class _themeState extends State<theme> {

  List data = new List();
  String image,firstheading,aboutheading,secondheading,aboutsecond,contact,phone,email;
  String firstimage,firstabout,secondimage,secondabout,thirdimage,thirdabout;
  String fourthimage,fourthabout,fifthimage,fifthabout,sixthimage,sixthabout;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recent_data();
  }

  Future recent_data() async {
    print("ya its working");
    String url = 'http://meflisyservice.com/theme.php';
    http.Client client = new http.Client();

    final response = await client.get(url);
    var resbody = jsonDecode(response.body);
    setState(() {
      if (response.statusCode == 200) {
        data = resbody;
        print("The data is ${data}");
        if (data.length > 0) {
          for (var u in data) {
            image = u['image'];
            firstheading = u['firstheading'];
            aboutheading = u['aboutheading'];
            secondheading = u['secondheading'];
            aboutsecond = u['aboutsecond'];
            contact = u['contact'];
            phone = u['phone'];
            email=u['email'];
            firstimage=u['firstimage'];
            firstabout=u['firstabout'];
            secondimage=u['secondimage'];
            secondabout=u['secondabout'];
            thirdimage=u['thirdimage'];
            thirdabout=u['thirdabout'];
            fourthimage=u['fourthimage'];
            fourthabout=u['fourthabout'];
            fifthimage=u['fifthimage'];
            fifthabout=u['fifthabout'];
            sixthimage=u['sixthimage'];
            sixthabout=u['sixthabout'];
          }
          //print("The about is "+about);
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
  Future<bool> _exitApp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainHome()),
            (Route<dynamic> route) => false);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(

        appBar: AppBar(
          title: Text(
            "Welcome",
            style: TextStyle(color: Color(0xFF00ACC1)),
          ),
          automaticallyImplyLeading: true,
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            image!=null?Container(
              height: 100*SizeConfig.imageSizeMultiplier,
              child: CachedNetworkImage(
                imageUrl: image,
                imageBuilder: (context,
                    imageProvider) =>
                    Container(
                      decoration:
                      BoxDecoration(
                        borderRadius:
                        new BorderRadius
                            .circular(
                            13.0),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                placeholder: (context,
                    url) =>
                    SpinKitWave(
                      color: Color(0xFF00ACC1),
                      size: 50.0,
                      type: SpinKitWaveType.start,
                    ),
                errorWidget:
                    (context, url,
                    error) =>
                    Icon(Icons
                        .error),
              ),
            ):SpinKitWave(
              color: Color(0xFF00ACC1),
              size: 50.0,
              type: SpinKitWaveType.start,
            ),
            Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  firstheading!=null?Container(
                    margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                    child: Text(
                      firstheading,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ):SizedBox(),
                  aboutheading!=null?Container(
                    margin: EdgeInsets.only(top: 5, left: 5, right: 5),
                    child: Text(
                      aboutheading,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ):SizedBox(),
                ],
              ),
            ),
            Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  secondheading!=null?Container(
                    margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                    child: Text(
                      secondheading,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ):SizedBox(),
                  aboutsecond!=null?Container(
                    margin: EdgeInsets.only(top: 5, left: 5, right: 5),
                    child: Text(
                      aboutsecond,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ):SizedBox(),
                ],
              ),
            ),
            Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  firstabout!=null?Container(
                    margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                    child: Text(
                      firstabout,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ):SizedBox(),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  firstimage!=null?Center(
                    child: Container(
                      height: 70*SizeConfig.imageSizeMultiplier,
                      width: 70*SizeConfig.imageSizeMultiplier,
                      child: CachedNetworkImage(
                        imageUrl: firstimage,
                        imageBuilder: (context,
                            imageProvider) =>
                            Container(
                              decoration:
                              BoxDecoration(
                                borderRadius:
                                new BorderRadius
                                    .circular(
                                    13.0),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                        placeholder: (context,
                            url) =>
                            SpinKitWave(
                              color: Color(0xFF00ACC1),
                              size: 50.0,
                              type: SpinKitWaveType.start,
                            ),
                        errorWidget:
                            (context, url,
                            error) =>
                            Icon(Icons
                                .error),
                      ),
                    ),
                  ):SpinKitWave(
                    color: Color(0xFF00ACC1),
                    size: 50.0,
                    type: SpinKitWaveType.start,
                  ),
                ],
              ),
            ),//first image

            Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  secondabout!=null?Container(
                    margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                    child: Text(
                      secondabout,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ):SizedBox(),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  secondimage!=null?Center(
                    child: Container(
                      height: 70*SizeConfig.imageSizeMultiplier,
                      width: 70*SizeConfig.imageSizeMultiplier,
                      child: CachedNetworkImage(
                        imageUrl: secondimage,
                        imageBuilder: (context,
                            imageProvider) =>
                            Container(
                              decoration:
                              BoxDecoration(
                                borderRadius:
                                new BorderRadius
                                    .circular(
                                    13.0),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                        placeholder: (context,
                            url) =>
                            SpinKitWave(
                              color: Color(0xFF00ACC1),
                              size: 50.0,
                              type: SpinKitWaveType.start,
                            ),
                        errorWidget:
                            (context, url,
                            error) =>
                            Icon(Icons
                                .error),
                      ),
                    ),
                  ):SpinKitWave(
                    color: Color(0xFF00ACC1),
                    size: 50.0,
                    type: SpinKitWaveType.start,
                  ),
                ],
              ),
            ),//second image

            Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  thirdabout!=null?Container(
                    margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                    child: Text(
                      thirdabout,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ):SizedBox(),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  thirdimage!=null?Center(
                    child: Container(
                      height: 70*SizeConfig.imageSizeMultiplier,
                      width: 70*SizeConfig.imageSizeMultiplier,
                      child: CachedNetworkImage(
                        imageUrl: thirdimage,
                        imageBuilder: (context,
                            imageProvider) =>
                            Container(
                              decoration:
                              BoxDecoration(
                                borderRadius:
                                new BorderRadius
                                    .circular(
                                    13.0),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                        placeholder: (context,
                            url) =>
                            SpinKitWave(
                              color: Color(0xFF00ACC1),
                              size: 50.0,
                              type: SpinKitWaveType.start,
                            ),
                        errorWidget:
                            (context, url,
                            error) =>
                            Icon(Icons
                                .error),
                      ),
                    ),
                  ):SpinKitWave(
                    color: Color(0xFF00ACC1),
                    size: 50.0,
                    type: SpinKitWaveType.start,
                  ),
                ],
              ),
            ),//third image

            Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  fourthabout!=null?Container(
                    margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                    child: Text(
                      fourthabout,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ):SizedBox(),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  fourthimage!=null?Center(
                    child: Container(
                      height: 70*SizeConfig.imageSizeMultiplier,
                      width: 70*SizeConfig.imageSizeMultiplier,
                      child: CachedNetworkImage(
                        imageUrl: fourthimage,
                        imageBuilder: (context,
                            imageProvider) =>
                            Container(
                              decoration:
                              BoxDecoration(
                                borderRadius:
                                new BorderRadius
                                    .circular(
                                    13.0),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                        placeholder: (context,
                            url) =>
                            SpinKitWave(
                              color: Color(0xFF00ACC1),
                              size: 50.0,
                              type: SpinKitWaveType.start,
                            ),
                        errorWidget:
                            (context, url,
                            error) =>
                            Icon(Icons
                                .error),
                      ),
                    ),
                  ):SpinKitWave(
                    color: Color(0xFF00ACC1),
                    size: 50.0,
                    type: SpinKitWaveType.start,
                  ),
                ],
              ),
            ),//forth image

            Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  fifthabout!=null?Container(
                    margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                    child: Text(
                      fifthabout,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ):SizedBox(),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  fifthimage!=null?Center(
                    child: Container(
                      height: 70*SizeConfig.imageSizeMultiplier,
                      width: 70*SizeConfig.imageSizeMultiplier,
                      child: CachedNetworkImage(
                        imageUrl: fifthimage,
                        imageBuilder: (context,
                            imageProvider) =>
                            Container(
                              decoration:
                              BoxDecoration(
                                borderRadius:
                                new BorderRadius
                                    .circular(
                                    13.0),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                        placeholder: (context,
                            url) =>
                            SpinKitWave(
                              color: Color(0xFF00ACC1),
                              size: 50.0,
                              type: SpinKitWaveType.start,
                            ),
                        errorWidget:
                            (context, url,
                            error) =>
                            Icon(Icons
                                .error),
                      ),
                    ),
                  ):SpinKitWave(
                    color: Color(0xFF00ACC1),
                    size: 50.0,
                    type: SpinKitWaveType.start,
                  ),
                ],
              ),
            ),//fifth image

            Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  sixthabout!=null?Container(
                    margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                    child: Text(
                      sixthabout,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ):SizedBox(),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  sixthimage!=null?Center(
                    child: Container(
                      height: 70*SizeConfig.imageSizeMultiplier,
                      width: 70*SizeConfig.imageSizeMultiplier,
                      child: CachedNetworkImage(
                        imageUrl: sixthimage,
                        imageBuilder: (context,
                            imageProvider) =>
                            Container(
                              decoration:
                              BoxDecoration(
                                borderRadius:
                                new BorderRadius
                                    .circular(
                                    13.0),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                        placeholder: (context,
                            url) =>
                            SpinKitWave(
                              color: Color(0xFF00ACC1),
                              size: 50.0,
                              type: SpinKitWaveType.start,
                            ),
                        errorWidget:
                            (context, url,
                            error) =>
                            Icon(Icons
                                .error),
                      ),
                    ),
                  ):SpinKitWave(
                    color: Color(0xFF00ACC1),
                    size: 50.0,
                    type: SpinKitWaveType.start,
                  ),
                ],
              ),
            ),//sixth image

            Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  contact!=null?Container(
                    margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                    child: Text(
                      contact,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ):SizedBox(),
                  phone!=null?Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          launch('tel:+91'+phone);
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 10, left: 10),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xFF00ACC1),
                        ),
                        child: Row(

                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.call,
                              color: Colors.white,
                              size:35,
                            ),
                            Text(
                              phone,
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ):SizedBox(),

                  email!=null?Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          launch("mailto:"+email);
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 10, left: 10),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xFF00ACC1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: <Widget>[
                            Icon(
                              Icons.mail,
                              color: Colors.white,
                              size:35,
                            ),
                            Text(
                              "info@meflisyservice.com",
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ):SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );


  }
}
