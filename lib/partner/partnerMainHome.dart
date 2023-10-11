import 'package:flutter/material.dart';
import 'package:meflisy_service/partner/lead_partner.dart';

import '../size_config.dart';
import 'home_partner.dart';
import 'profile_partner.dart';
import 'edit_profile.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';

class partnerMainHome extends StatefulWidget {
  @override
  _partnerMainHomeState createState() => _partnerMainHomeState();
}

class _partnerMainHomeState extends State<partnerMainHome> {
  @override
  void initState() {
    super.initState();
  }

  static int counterIndex = 0;

  Widget pageSelection(int index) {
    switch (index) {
      case 0:
        return home_partner();
      case 1:
        return lead_partner();
      case 2:
        return profile_partner();
      case 3:
        return edit_profile();
        break;
      default:
        return home_partner();
    }
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints){
        SizeConfig().init(constraints);
        return new Scaffold(
          body: pageSelection(counterIndex),
          bottomNavigationBar:FFNavigationBar(
            theme: FFNavigationBarTheme(
              barHeight:13*SizeConfig.imageSizeMultiplier,
              barBackgroundColor: Colors.white,
              showSelectedItemShadow: false,
              selectedItemBorderColor: Colors.white,
              selectedItemBackgroundColor: Color(0xff00ACC1),
              selectedItemIconColor: Colors.white,
              selectedItemLabelColor: Colors.black,
            ),
            selectedIndex: counterIndex,
            onSelectTab: (index) {
              setState(() {
                counterIndex = index;
              });
            },
            items: [
              FFNavigationBarItem(
                iconData: Icons.home,
                label: 'Home',

              ),
              FFNavigationBarItem(
                iconData:Icons.assignment,
                label: 'Leads',

              ),
              FFNavigationBarItem(
                iconData: Icons.person_outline,
                label: 'Profile',

              ),
              FFNavigationBarItem(
                iconData: Icons.mode_edit,
                label: 'Edit',

              ),
            ],
          ), /*new BottomNavigationBar(
              currentIndex: counterIndex,
              onTap: onTabTapped,
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home,
                      size: 6.3*SizeConfig.imageSizeMultiplier,
                    ),
                    title: Padding(padding: EdgeInsets.all(0))
                ),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.assignment,
                      size: 6.3*SizeConfig.imageSizeMultiplier,
                    ),
                    title: Padding(padding: EdgeInsets.all(0))
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline,size: 6.3*SizeConfig.imageSizeMultiplier),
                    title: Padding(padding: EdgeInsets.all(0))),

                BottomNavigationBarItem(
                    icon: Icon(Icons.mode_edit,size: 6.3*SizeConfig.imageSizeMultiplier),
                    title:Padding(padding: EdgeInsets.all(0))),

              ]),*/
        );
      },
    );
  }

  void onTabTapped(int Index) {
    setState(() {
      counterIndex = Index;
    });
  }
}
