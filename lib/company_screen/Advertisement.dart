import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../adsScreen.dart';
import '../size_config.dart';

class Advertisement extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return AdvertisementState();
  }
}

class AdvertisementState extends State<Advertisement>{

  List data = new List();
  String image,firstheading,aboutheading,secondheading,aboutsecond,contact,phone,email;

  getData() async{
    final prefs= await SharedPreferences.getInstance();
    state=prefs.getString("state");
    city=prefs.getString("city");
    getLocalAds();
  }
  Future recent_data() async {
    print("ya its working");
    String url = 'http://meflisyservice.com/advertise.php';
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

  String state,city;
  List list;
  List<String> urls= new List();
  bool checkads = true;
  List adslist;
  Future getLocalAds() async {
    String url = "http://meflisyservice.com/local_ads.php";
    http.Client client = new http.Client();
    if (state != null && city != null) {
      final response =
      await client.post(url, body: {'state': state, 'city': city});
      setState(() {
        if (response.statusCode == 200) {
          adslist = json.decode(response.body);

          if (adslist.length <= 0 && adslist.isEmpty) {
            checkads = true;
            getAds();
          }else{
            checkads=false;
            for (var x in adslist) {
              urls.add(x['ads']);
              print("The complete ads are "+x['ads_code']);
            }
          }
        } else {
          checkads = true;
          Fluttertoast.showToast(
              msg: " Something went wronge ", timeInSecForIos: 4);
        }
      });
    }
    client.close();
  }

  Future getAds() async {
    String url = "http://meflisyservice.com/local_ads.php";
    http.Client client = new http.Client();
    if (state != null && city != null) {
      final response =
      await client.post(url, body: {'state': "adver", 'city': "adver"});
      setState(() {
        if (response.statusCode == 200) {
          adslist = json.decode(response.body);
          for (var x in adslist) {
            urls.add(x['ads']);
            print("The complete ads are "+x['ads_code']);
          }
          checkads=false;

        } else {
          checkads = true;
          Fluttertoast.showToast(
              msg: " Something went wronge ", timeInSecForIos: 4);
        }
      });
    }
    client.close();
  }


  @override
  void initState() {
    super.initState();

    recent_data();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        title: Text(
          "Advertise with Meflisy",
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                firstheading!=null?Container(
                  margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Text(
                    firstheading,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ):SizedBox(),
                aboutheading!=null?Container(
                  margin: EdgeInsets.only(top: 10, left: 10, right: 10),
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                ),
              ],
            ),
          ),




          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 20)),
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Text(
                  "Our Ads Examples",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              checkads != true
                  ? Container(
                margin: EdgeInsets.only(top: 5),
                child: CarouselSlider(
                  height: 40 * SizeConfig.imageSizeMultiplier,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.9,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration:
                  Duration(milliseconds: 1100),
                  pauseAutoPlayOnTouch: Duration(seconds: 1),
                  scrollDirection: Axis.horizontal,
                  items: urls.map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          adsScreen(i)));
                            },
                            child: Container(
                              height:
                              MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              margin:
                              EdgeInsets.symmetric(horizontal: 5.0),
                              child: CachedNetworkImage(
                                imageUrl: i,
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
                        );
                      },
                    );
                  }).toList(),
                ),
              )
                  : Center(
                child: Shimmer.fromColors(
                  child: Container(
                    height: 40 * SizeConfig.imageSizeMultiplier,
                    color: Colors.grey,
                  ),
                  highlightColor: Colors.white,
                  baseColor: Colors.grey[300],
                ),
              ),
            ],
          ),// ads section

        ],
      ),
    );
  }
}