import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:meflisy_service/detail_profile.dart';
import 'package:meflisy_service/localProfession2.dart';
import 'package:meflisy_service/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'profile_image.dart';

import 'package:url_launcher/url_launcher.dart';

class localProfession extends StatefulWidget {
  String title, state, city, locality;

  localProfession(this.title, this.state, this.city, this.locality);

// localProfession({Key key, @required this.title,this.state,this.city,this.locality}) : super(key: key);

  @override
  _localProfessionState createState() => _localProfessionState();
}

class _localProfessionState extends State<localProfession> {
  List<Photo> list;
  List<SubPhoto> sublist;
  bool check=true;
  bool avg_check=true;
  var data;
  String userid,nowdate,user_name,user_phone;
  var avg;
  getDate() {
    var paymentdate = new DateTime.now();
    setState(() {
      nowdate = new DateFormat("yyyy-MM-dd").format(paymentdate).toString();
      print("The date is {$nowdate}");
    });
  }

  Future recent_call(String phone,String image, String name) async {
    String url = 'http://meflisyservice.com/recent.php';
    http.Client client = new http.Client();

    final response = await client.post(url, body: {

      'state': widget.state,
      'city': widget.city,
      'partnerid':phone,
      'userid':userid,
      'profession':widget.title,
      'image':image,
      'date':nowdate,
      'name':name
    });
    setState(() {
      if (response.statusCode == 200) {
        print("Data save in recent ");
      } else {
        Fluttertoast.showToast(
            msg: " Something went wronge "+response.statusCode.toString(), timeInSecForIos: 4);
      }
    });
  }

  Future local_Partners() async {
    String url = 'http://meflisyservice.com/local_partners.php';
    http.Client client = new http.Client();
    String partnerid;
    final response = await client.post(url, body: {
      'state': widget.state,
      'city': widget.city,
      'locality': widget.locality,
      'profession': widget.title
    });
    setState(() {
      print("The profession are " + widget.title);
      if (response.statusCode == 200) {
        data = json.decode(response.body);
        for(var u in data){
          print("The phone numbers are "+u['phone_number']);
        }
        list = (json.decode(response.body) as List)
            .map((data) => new Photo.fromJson(data))
            .toList();
        print(data);
        if(list.length<=0 && list.isEmpty){
          check=false;
        }
      } else {
        check=false;
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });
  }

  Future<String> getSubCategoryData(String profession) async {
    String localityurl = "http://meflisyservice.com/category_full_list.php";
    http.Client client = new http.Client();
    var response = await client
        .post(Uri.encodeFull(localityurl), body: {'profession': profession});

    setState(() {
      if (response.statusCode == 200) {
        sublist = (json.decode(response.body) as List)
            .map((data) => new SubPhoto.fromJson(data))
            .toList();
      } else {
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });

    client.close();
    return 'Success';
  }

  getUserid() async{
    final prefs= await SharedPreferences.getInstance();
    setState(() {
      userid=prefs.getString("phone_number");
      print(userid);
    });
  }

  @override
  void initState() {
    super.initState();
    getDate();
    getUserid();
    user_information(http.Client());
    local_Partners();
    getSubCategoryData(widget.title);
  }
  Future<String> user_information(http.Client client) async {
    print("The function user information is working");
    final prefs= await SharedPreferences.getInstance();
    user_phone=prefs.getString("phone_number");
    final response =
    await client.post('http://meflisyservice.com/get_user.php', body: {
      'phone_number': user_phone,
    });

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
        for (var u in data) {
          user_name = u['name'];
          if (user_name == null || user_name == '') {
            user_name = "Not Given";
          }
          print("The username is "+user_name);
        }
      });
    } else {
      Fluttertoast.showToast(msg: "Please Refresh it again");
    }
    client.close();
  }

  upload_Lead(String sub_profession) async{

    String url = 'http://meflisyservice.com/uploadleads.php';
    http.Client client = new http.Client();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            title: Column(
              children: <Widget>[
                Container(
                  width: 18 *
                      SizeConfig
                          .imageSizeMultiplier,
                  height: 18 *
                      SizeConfig
                          .imageSizeMultiplier,
                  child: CachedNetworkImage(
                    imageUrl:
                    "http://meflisyservice.com/sub_catogery images/" +
                        sub_profession +
                        ".jpg",
                    imageBuilder: (context,
                        imageProvider) =>
                        Container(
                          decoration:
                          BoxDecoration(
                            border: Border.all(
                                color: Color(
                                    0xFF00ACC1),
                            ),
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
                          size: 40.0,
                          type: SpinKitWaveType.start,
                        ),
                    errorWidget:
                        (context, url,
                        error) =>
                        Icon(Icons
                            .error),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0,top: 10),
                    child: SafeArea(
                      child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Color(0xffdcfbff),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Text(
                                sub_profession.toUpperCase()+" वाले को ढूंढ रहे है ,कोई बात नहीं | \n\n"+sub_profession.toUpperCase()+" पर अच्छे ऑफर पाने के लिए Ok पर Click करे | हमारे Partners आपको अपने आप Call करे लेंगे |",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                              ),
                            ),
                            Positioned(
                                bottom: 5,
                                right: 10,
                                child: CustomPaint(
                                  painter: ChatBubbleTriangle(),
                                )
                            )
                          ]
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: new FlatButton(
                        onPressed: () async {
                          final response = await client.post(url, body: {
                            'state': widget.state,
                            'city': widget.city,
                            'locality':widget.locality,
                            'user_phone': user_phone,
                            'user_name': user_name,
                            'date': nowdate,
                            'sub_profession':sub_profession

                          });
                          setState(() {
                            if (response.statusCode == 200) {
                              Fluttertoast.showToast(
                                  msg: " Your request is send " + response.statusCode.toString(),
                                  timeInSecForIos: 4);
                            } else {
                              Fluttertoast.showToast(
                                  msg: " Something went wronge " + response.statusCode.toString(),
                                  timeInSecForIos: 4);
                            }
                          });
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      localProfession2(
                                          widget.title,
                                          widget.state,
                                          widget.city,
                                          widget.locality,
                                          sub_profession)
                              )
                          );
                        },
                        child: new Text('Ok'),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: new FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      localProfession2(
                                          widget.title,
                                          widget.state,
                                          widget.city,
                                          widget.locality,
                                          sub_profession)
                              )
                          );
                        },
                        child: new Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),

          );
        });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Color(0xFF00ACC1),
      ),
      body: Container(

        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: <Widget>[


            Card(
              elevation: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10,left: 10),
                    child: Text(
                      "What are you looking for",
                      style: TextStyle(fontSize:2.3*SizeConfig.textMultiplier, fontWeight: FontWeight.bold),
                    ),
                  ),
                  sublist != null
                      ? GridView.builder(
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.2),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: sublist.length,
                      itemBuilder: (BuildContext context, int index) {
                        return new GestureDetector(
                          onTap: () {
                            upload_Lead(sublist[index].name);
                           /* Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => localProfession2(
                                        widget.title,
                                        widget.state,
                                        widget.city,
                                        widget.locality,
                                        sublist[index].name)
                                )
                            );*/
                          },
                          child: Card(
                            elevation: 0,
                            child: Container(
                              height: 16 * SizeConfig.imageSizeMultiplier,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    child: Card(
                                      elevation:0 ,
                                      color: Colors.white,
                                      child: Container(
                                        width: 15 *
                                            SizeConfig
                                                .imageSizeMultiplier,
                                        height: 15 *
                                            SizeConfig
                                                .imageSizeMultiplier,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                          "http://meflisyservice.com/sub_catogery images/" +
                                              sublist[index].name +
                                              ".jpg",
                                          imageBuilder: (context,
                                              imageProvider) =>
                                              Container(
                                                decoration:
                                                BoxDecoration(
                                                  border: Border.all(
                                                      color: Color(
                                                          0xFF00ACC1)),
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
                                                size: 40.0,
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
                                  ),
                                  Expanded(
                                    child: Container(
                                        child:
                                        Text(sublist[index].name.toUpperCase(),style: TextStyle(fontSize:1.2*SizeConfig.textMultiplier,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)

                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        );
                      })
                      : new Center(
                    child: Shimmer.fromColors(
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
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
            ),
            check?Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
              child: Text("Service Providers ",style: TextStyle(fontSize:2.3*SizeConfig.textMultiplier,fontWeight: FontWeight.bold),),
            ):SizedBox(),
            list != null && check
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => detail_profile(
                                        widget.title,
                                        widget.state,
                                        widget.city,
                                        widget.locality,
                                        list[index].sub_profession,
                                        list[index].name,
                                        list[index].address,
                                        list[index].phone,
                                        list[index].description,
                                        list[index].image,
                                        list[index].keyword)));
                          },
                          child: new Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1.0),
                            ),
                            color: Colors.white,
                            elevation: 0,
                            child: Container(
                              margin:
                                  EdgeInsets.only(top: 1, left: 1, right: 1),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        displaySelectedFile(list[index].image,
                                            list[index].phone),
                                        new Expanded(
                                          child: new Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              list[index].name != null
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: new Text(
                                                        list[index].name,
                                                        style: TextStyle(
                                                            fontSize: 2.4*SizeConfig.textMultiplier,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    )
                                                  : Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                              widget.title != null
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: new Text(
                                                        widget.title.toUpperCase(),
                                                        style: TextStyle(
                                                            fontSize: 2*SizeConfig.textMultiplier,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    )
                                                  : Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                              list[index].sub_profession != null
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5.0),
                                                      child: new Text(
                                                        list[index]
                                                            .sub_profession
                                                            .replaceAll(
                                                                ", ,", "")
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            fontSize: 1.5*SizeConfig.textMultiplier,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    )
                                                  : Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4.0, bottom: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          int.parse(list[index].rating.toString()).toInt()!=0?
                                          SmoothStarRating(
                                              allowHalfRating: false,
                                              starCount: 5,
                                              rating:int.parse(list[index].rating.toString()).toInt().toDouble(),
                                              size: 5*SizeConfig.imageSizeMultiplier,
                                              color: Color(0xFF00Acc1),
                                              borderColor: Color(0xff00Acc1),
                                              spacing: 1.0):Text("No rating yet"),
                                          Column(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  launch('sms:+91' +
                                                      list[index].phone);
                                                },
                                                child: Icon(
                                                  Icons.message,
                                                  size: 7.2*SizeConfig.imageSizeMultiplier,
                                                  color: Color(0xFF00ACC1),
                                                ),
                                              ),
                                              Text("Message"),
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    recent_call(list[index].phone, list[index].image, list[index].name);
                                                    launch('tel:+91' +
                                                        list[index].phone);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.call,
                                                  size: 7.2*SizeConfig.imageSizeMultiplier,
                                                  color: Color(0xFF00ACC1),
                                                ),
                                              ),
                                              Text("Call"),
                                            ],
                                          ),
                                          Column(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  launch('https://wa.me/+91' +
                                                      list[index].phone);
                                                },
                                                child: Container(
                                                  width: 9.55*SizeConfig.imageSizeMultiplier,
                                                  height: 7.2*SizeConfig.imageSizeMultiplier,
                                                  child: Image.asset(
                                                      "images/WhatsApp.png"),
                                                ),
                                              ),
                                              Text("Whatsapp"),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget displaySelectedFile(String file, String name) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => profile_image(name, file)));
      },
      child: new Container(
        margin: EdgeInsets.only(right: 15),
        height: 21.5*SizeConfig.imageSizeMultiplier,
        width: 21.5*SizeConfig.imageSizeMultiplier,
        child: file == null
            ? new Center(
                child: Container(
                  color: Colors.transparent,
                  child: CircularProgressIndicator(),
                ),
              )
            : new CircleAvatar(
                maxRadius: 12*SizeConfig.imageSizeMultiplier,
                minRadius: 7.2*SizeConfig.imageSizeMultiplier,
                backgroundColor: Colors.transparent,
                backgroundImage: MemoryImage(base64Decode(file)),
              ),
      ),
    );
  }
}

class Photo {
  final String sub_profession;
  final String name;
  final String address;
  final String phone;

  final String description;
  final String image;
  final String keyword;
  final String rating;

  Photo._(
      {this.name,
      this.address,
      this.phone,
      this.description,
      this.image,
      this.sub_profession,
      this.keyword,
      this.rating});

  factory Photo.fromJson(Map json) {
    return new Photo._(
      name: json['name'],
      address: json['address'],
      phone: json['phone_number'],
      image: json['profile_image'],
      description: json['description'],
      keyword: json['keyword'], 
      sub_profession: json['sub_profession'],
      rating: json['rating']
    );
  }
}

class SubPhoto {
  final String name;

  SubPhoto._({this.name});

  factory SubPhoto.fromJson(Map json) {
    return new SubPhoto._(name: json['sub_category']);
  }
}

class ChatBubbleTriangle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Color(0xffdcfbff);

    var path = Path();
    path.lineTo(-80, 0);
    path.lineTo(0,30);
    path.lineTo(-30, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}