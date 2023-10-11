import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:meflisy_service/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';

import 'cityProfession.dart';
import 'localProfession.dart';

class categories extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _categoriesstate();
  }
}

class _categoriesstate extends State<categories> {
  List<Photo> list;
  List<Photo2> list1;
  bool photocheck = true, photo2check = true;

  String state, city, locality;
  bool check = true, nearcheck = true;

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString("state");
    city = prefs.getString("city");
    locality = prefs.getString("locality");
    local_category();
    city_category();
  }

  Future local_category() async {
    String url = 'http://meflisyservice.com/local_catogery.php';
    http.Client client = new http.Client();
    if (state != null && city != null) {
      final response = await client.post(url,
          body: {'state': state, 'city': city, 'locality': locality});
      setState(() {
        if (response.statusCode == 200) {
          list = (json.decode(response.body) as List)
              .map((data) => new Photo.fromJson(data))
              .toList();
          if (list.length <= 0 || list.isEmpty) {
            nearcheck = false;
          }
          print("the local list is "+list.toString());
        } else {
          nearcheck = false;
          Fluttertoast.showToast(
              msg: " Something went wronge ", timeInSecForIos: 4);
        }
      });
    }
  }

  Future city_category() async {
    String url = 'http://meflisyservice.com/city_catogery.php';
    http.Client client = new http.Client();
    if (state != null && city != null) {
      final response = await client.post(url,
          body: {'state': state, 'city': city, 'locality': locality});
      setState(() {
        if (response.statusCode == 200) {
          list1 = (json.decode(response.body) as List)
              .map((data) => new Photo2.fromJson(data))
              .toList();
          if (list1.length <= 0 || list1.isEmpty) {
            check = false;
          }
          print("the local list is "+list1.toString());
        } else {
          check = false;
          Fluttertoast.showToast(
              msg: " Something went wronge ", timeInSecForIos: 4);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: Color(0xFF00ACC1),
        title: Text("Category"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: <Widget>[
            nearcheck
                ? Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10),
                    child: Text(
                      "Nearest Service Providers",
                      style: TextStyle(
                        fontSize: 2.3*SizeConfig.textMultiplier,
                          fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Padding(padding: const EdgeInsets.only(top: 10, left: 10)),
            list != null && nearcheck
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        elevation: 0,
                        child: Container(
                          margin: EdgeInsets.all(5),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(5.0),
                            title: new Text(
                              list[index].title,
                              style: TextStyle(fontSize: 2.3*SizeConfig.textMultiplier),
                            ),
                            leading: Container(
                              child: CachedNetworkImage(
                                imageUrl: "http://meflisyservice.com/category%20images/" +
                                    list[index].title +
                                    ".png",
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
                                      size: 30.0,
                                      type: SpinKitWaveType.start,
                                    ),
                                errorWidget:
                                    (context, url,
                                    error) =>
                                    Icon(Icons
                                        .error),

                              ),
                              padding: EdgeInsets.all(1),
                              width: 17.2*SizeConfig.imageSizeMultiplier,
                              height: 17.2*SizeConfig.imageSizeMultiplier,
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => localProfession(
                                          list[index].title,
                                          state,
                                          city,
                                          locality)));
                            },
                            subtitle: new Text(
                                "All services of " + list[index].title,
                            style: TextStyle(fontSize: 2*SizeConfig.textMultiplier),),
                          ),
                        ),
                      );
                    })
                : new Center(
                    child: nearcheck
                        ? Shimmer.fromColors(
                      child:ListTile(
                        contentPadding: EdgeInsets.all(10.0),
                        title:  Container(
                          height: 4 * SizeConfig.imageSizeMultiplier,
                          width: 14 * SizeConfig.imageSizeMultiplier,
                          color: Colors.black,
                        ),
                        leading: Container(
                          width: 16.2*SizeConfig.imageSizeMultiplier,
                          height: 16.2*SizeConfig.imageSizeMultiplier,
                          color: Colors.black,
                        ),
                        subtitle: Container(
                          height: 4 * SizeConfig.imageSizeMultiplier,
                          width: 10* SizeConfig.imageSizeMultiplier,
                          color: Colors.black,
                        ),
                      ),
                      highlightColor: Colors.grey,
                      baseColor: Colors.grey[300],
                    )
                        : Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Column(
                              children: <Widget>[
                                Image.asset("images/nothinfound.png"),
                                GestureDetector(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      "We are continously adding service providers. We will add within somedays at your location",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
            check
                ? Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10),
                    child: Text(
                      "Service Providers at Your City/Village",
                      style: TextStyle(
                        fontSize:2.3*SizeConfig.textMultiplier,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10),
                  ),
            list1 != null && check
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: list1.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        elevation: 0,
                        child: Container(
                          margin: EdgeInsets.all(5),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(5.0),
                            title: new Text(
                              list1[index].title,
                              style: TextStyle(fontSize:2.3*SizeConfig.textMultiplier),
                            ),
                            leading: Container(
                              child: CachedNetworkImage(
                                imageUrl: "http://meflisyservice.com/category%20images/" +
                                    list1[index].title +
                                    ".png",
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
                              padding: EdgeInsets.all(1),
                              width: 17.2*SizeConfig.imageSizeMultiplier,
                              height: 17.2*SizeConfig.imageSizeMultiplier,
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => cityProfession(
                                          list1[index].title,
                                          state,
                                          city,
                                          locality)));
                            },
                            subtitle: new Text(
                                "All services of " + list1[index].title,
                            style: TextStyle(fontSize:2*SizeConfig.textMultiplier),),
                          ),
                        ),
                      );
                    })
                : new Center(
                    child: check ?
                    Shimmer.fromColors(
                      child:ListTile(
                        contentPadding: EdgeInsets.all(10.0),
                        title:  Container(
                          height: 4 * SizeConfig.imageSizeMultiplier,
                          width: 14 * SizeConfig.imageSizeMultiplier,
                          color: Colors.black,
                        ),
                        leading: Container(
                          width: 16.2*SizeConfig.imageSizeMultiplier,
                          height: 16.2*SizeConfig.imageSizeMultiplier,
                          color: Colors.black,
                        ),
                        subtitle: Container(
                          height: 4 * SizeConfig.imageSizeMultiplier,
                          width: 10* SizeConfig.imageSizeMultiplier,
                          color: Colors.black,
                        ),
                      ),
                      highlightColor: Colors.grey,
                      baseColor: Colors.grey[300],
                    ):
                    SizedBox(),
                  )
          ],
        ),
      ),
    );
  }
}

class Photo {
  final String title;

  Photo._({this.title});

  factory Photo.fromJson(Map json) {
    return new Photo._(title: json['profession']);
  }
}

class Photo2 {
  final String title;

  Photo2._({this.title});

  factory Photo2.fromJson(Map json) {
    return new Photo2._(title: json['profession']);
  }
}
