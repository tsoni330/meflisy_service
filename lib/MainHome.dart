import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:meflisy_service/my_flutter_app_icons.dart';
import 'package:meflisy_service/size_config.dart';
import 'Tabs/Home.dart';
import 'Tabs/Profile.dart';
import 'Tabs/Company.dart';
import 'Tabs/History.dart';
class MainHome extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String uid = '';

  @override
  void initState() {
    super.initState();
  }

  static int _counterIndex = 0;

  Widget pageSelection(int index) {
    switch (index) {
      case 0:
        return Home();
      case 1:
        return History();
      case 2:
        return Profile();
      case 3:
        return Company();
        break;
      default:
        return Home();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints){
        SizeConfig().init(constraints);
        return new Scaffold(
          body: pageSelection(_counterIndex),
          bottomNavigationBar: FFNavigationBar(
            theme: FFNavigationBarTheme(
              barHeight:13*SizeConfig.imageSizeMultiplier,
              barBackgroundColor: Colors.white,
              showSelectedItemShadow: false,
              selectedItemBorderColor: Colors.white,
              selectedItemBackgroundColor: Color(0xff00ACC1),
              selectedItemIconColor: Colors.white,
              selectedItemLabelColor: Colors.black,
            ),
            selectedIndex: _counterIndex,
            onSelectTab: (index) {
              setState(() {
                _counterIndex = index;
              });
            },
            items: [
              FFNavigationBarItem(
                iconData: Icons.home,
                label: 'Home',
              ),
              FFNavigationBarItem(
                iconData:const IconData(0xe804, fontFamily: 'MyFlutterApp',),
                label: 'History',
              ),
              FFNavigationBarItem(
                iconData: Icons.person_outline,
                label: 'Profile',
              ),
              FFNavigationBarItem(
                iconData: const IconData(0xe801, fontFamily: 'MyFlutterApp',),
                label: 'Partner',
              ),
            ],
          ),
          /*bottomNavigationBar: new BottomNavigationBar(
              currentIndex: _counterIndex,
              onTap: onTabTapped,

              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Color(0xFF00ACC1),
              selectedLabelStyle: TextStyle(color: Color(0xFF00ACC1),fontSize: 12),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home,size: 6.3*SizeConfig.imageSizeMultiplier,),
                  title: Text("Home"),
                ),
                BottomNavigationBarItem(
                    icon: Icon(const IconData(0xe804, fontFamily: 'MyFlutterApp',),size: 6.6*SizeConfig.imageSizeMultiplier,),
                    title: Text("History")),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person,size: 6.3*SizeConfig.imageSizeMultiplier),
                    title: Text("Profile")),
                BottomNavigationBarItem(
                    icon: Icon(
                      const IconData(0xe801, fontFamily: 'MyFlutterApp'),
                      size: 8.5*SizeConfig.imageSizeMultiplier,
                    ),
                    title: Text("Partner"))
              ]),*/
        );
      }
    );

  }

  void onTabTapped(int Index) {
    setState(() {
      _counterIndex = Index;
    });
  }
}
