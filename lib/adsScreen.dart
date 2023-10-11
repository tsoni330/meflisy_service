import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meflisy_service/size_config.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class adsScreen extends StatefulWidget {
  String image;
  adsScreen(this.image);
  @override
  _adsScreenState createState() => _adsScreenState();
}

class _adsScreenState extends State<adsScreen> {
  List adsdata = new List();
  String name, number, type, about, address, website, website_type, email, services;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recent_data();
  }

  Future recent_data() async {
    String url = 'http://meflisyservice.com/adsblog.php';
    http.Client client = new http.Client();

    final response = await client.post(url, body: {'ads': widget.image});
    var resbody = jsonDecode(response.body);
    setState(() {
      if (response.statusCode == 200) {
        adsdata = resbody;
        if (adsdata.length > 0) {
          print("The data is ${adsdata}");
          for (var u in adsdata) {
            name = u['name'];
            number = u['number'];
            address = u['address'];
            type = u['type'];
            about = u['about'];
            website = u['website'];
            website_type = u['website_type'];
            email=u['email'];
            services=u['services'];
          }
         // print("The about is "+about);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 200,
              pinned: false,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: CachedNetworkImage(
                    imageUrl: widget.image,
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
            ),
            SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                 name!=null?Card(
                    elevation: 0,
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(top: 10,left: 5),
                          child: name != null
                              ? Text(
                                  name,
                                  style: TextStyle(
                                      fontSize: 2.5 * SizeConfig.textMultiplier
                                  ),
                                )
                              : Text(
                                  "Loading...",
                                  style: TextStyle(
                                      fontSize: 2.3 * SizeConfig.textMultiplier
                                  ),
                                ),
                        ),
                        type!=null?Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(top: 10,left: 5),
                          child:Text(
                            type,
                            style: TextStyle(
                                fontSize: 2.0 * SizeConfig.textMultiplier
                            ),
                          )
                        ):SizedBox(),
                        Divider(),
                        address!=null?Row(
                          children: <Widget>[
                            Container(
                              child: Center(
                                child: IconButton(
                                  padding:EdgeInsets.all(0),
                                  icon: IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(
                                      Icons.location_on,
                                      color: Color(0xFF00ACC1),
                                      size: 6 * SizeConfig.imageSizeMultiplier,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                address,
                                style: TextStyle(
                                    fontSize: 1.8 * SizeConfig.textMultiplier
                                ),
                              ),
                            )
                          ],
                        ):SizedBox(),
                        email!=null?Row(
                          children: <Widget>[
                            Container(
                              child: Center(
                                child: IconButton(
                                  padding:EdgeInsets.all(0),
                                  icon: IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(
                                      Icons.email,
                                      color: Color(0xFF00ACC1),
                                      size: 6 * SizeConfig.imageSizeMultiplier,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              child: Text(
                                email,
                                style: TextStyle(
                                    fontSize: 1.8 * SizeConfig.textMultiplier
                                ),
                              ),
                            )
                          ],
                        ):SizedBox(),
                        number!=null?Row(
                          children: <Widget>[
                            Container(
                              child: Center(
                                child: IconButton(
                                  padding:EdgeInsets.all(0),
                                  icon: IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(
                                      Icons.phone,
                                      color: Color(0xFF00ACC1),
                                      size: 6 * SizeConfig.imageSizeMultiplier,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              child: Text(
                                number,
                                style: TextStyle(
                                    fontSize: 1.8 * SizeConfig.textMultiplier
                                ),
                              ),
                            )
                          ],
                        ):SizedBox(),
                      ],
                    ),
                  ):
                 SpinKitWave(
                   color: Color(0xFF00ACC1),
                   size: 50.0,
                   type: SpinKitWaveType.start,
                 ),
                  about!=null?Card(
                    elevation: 0,
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(top: 10,left: 5),
                          child:Text(
                            "About",
                            style: TextStyle(
                                fontSize: 2.5 * SizeConfig.textMultiplier
                            ),
                          ),
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.all(10),
                                child: Text(
                                  about,
                                  style: TextStyle(
                                      fontSize: 2.2 * SizeConfig.textMultiplier
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ):SizedBox(),

                  services!=null?Card(
                    elevation: 0,
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(top: 10,left: 5),
                          child:Text(
                            "Our Services",
                            style: TextStyle(
                                fontSize: 2.5 * SizeConfig.textMultiplier
                            ),
                          ),
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.all(10),
                                child: Text(
                                  services,
                                  style: TextStyle(
                                      fontSize: 2.2 * SizeConfig.textMultiplier
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ):SizedBox(),
                  number!=null || email!=null || website!=null?Card(
                    elevation: 0,
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(top: 10,left: 5),
                          child:Text(
                            "Contact Us",
                            style: TextStyle(
                                fontSize: 2.5 * SizeConfig.textMultiplier
                            ),
                          )

                        ),

                        Divider(),
                        number!=null || email!=null || website!=null?Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[

                            Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 3,bottom: 3),
                                  child: Center(
                                    child: IconButton(
                                      onPressed: (){
                                        setState(() {
                                          launch('mailto:' +
                                              email);
                                        });
                                      },
                                      padding:EdgeInsets.all(0),
                                      icon: IconButton(
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(
                                          Icons.email,
                                          color: Color(0xFF00ACC1),
                                          size: 10* SizeConfig.imageSizeMultiplier,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),


                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 3,bottom: 3),
                                  child: Center(
                                    child: IconButton(
                                      padding:EdgeInsets.all(0),
                                      icon: IconButton(
                                        onPressed: (){
                                          setState(() {
                                            launch('tel:+91' +
                                                number);
                                          });
                                        },
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(
                                          Icons.phone,
                                          color: Color(0xFF00ACC1),
                                          size: 10* SizeConfig.imageSizeMultiplier,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),


                              ],
                            ),
                            Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    launch('https://wa.me/+91' +
                                        number);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 3,bottom: 3),
                                    width:9.5 *
                                        SizeConfig
                                            .imageSizeMultiplier,
                                    height: 9.5*
                                        SizeConfig
                                            .imageSizeMultiplier,
                                    child: Image.asset(
                                        "images/WhatsApp.png"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ):SizedBox(),

                        website.isNotEmpty?Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _launchURL(website);
                                });
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(
                                            0xFF00ACC1)),
                                    borderRadius:
                                    new BorderRadius
                                        .circular(13.0),
                                    // Box decoration takes a gradient

                                      gradient: LinearGradient(
                                        end: Alignment.centerLeft,
                                        begin: Alignment.centerRight,
                                        colors: [Color(0xFF00f2f2), Color(0xFF00b0b0)],
                                      ),

                                  ),
                                  margin: EdgeInsets.only(top: 13,bottom: 13),
                                  padding: EdgeInsets.all(5),
                                  child: website_type!=null?Text(
                                    website_type,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 3*SizeConfig.textMultiplier
                                    ),
                                  ):SizedBox()
                                ),

                            ),


                          ],
                        ):SizedBox(),
                      ],
                    ),
                  ):SizedBox(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
_launchURL(String website) async {
  if (await canLaunch(website)) {
    await launch(website);
  } else {
    Fluttertoast.showToast(msg: "The Link is not correct");
  }
}