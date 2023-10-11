import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MainHome.dart';
import 'Tabs/Home.dart';
import 'login.dart';
import 'size_config.dart';

Future<void> main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(mainApp());
  });
}

class mainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Meflisy Service",
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return shared();
  }
}

class shared extends State<MyApp> {
  Widget login1;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () {
      checkcurrent();
    });
  }

  checkcurrent() async {
    await FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        if (val == null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => login()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainHome()));
        }
      });
    }).catchError((e) {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      SizeConfig().init(constraints);
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: 50 * SizeConfig.imageSizeMultiplier,
                width: 50 * SizeConfig.imageSizeMultiplier,
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                      image: new AssetImage('images/icon.png'),
                      fit: BoxFit.fill),
                ),
              ),
              SpinKitFadingCircle(
                color: Color(0xFF00ACC1),
                size: 60.0,
                //type: SpinKitWaveType.start,
              ),
              Text(
                "Copyrigte \u00A9 Meflisy Servive Pvt. Ltd.",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      );
    });
  }
}