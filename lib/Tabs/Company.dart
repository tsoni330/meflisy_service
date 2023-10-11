import 'package:flutter/material.dart';
import 'package:meflisy_service/size_config.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:meflisy_service/company_screen/Advertisement.dart';
import 'package:meflisy_service/company_screen/Contactus.dart';

import 'package:meflisy_service/company_screen/Frachisor.dart';
import 'package:share/share.dart';

import 'package:meflisy_service/partner/splashPartner.dart';

import '../MainHome.dart';

class Company extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CompanyState();
  }
}



Future<bool> _askExit(BuildContext context){

  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Do you want to exit this application?'),
          content: new Text('We hate to see you leave...'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: new Text('No'),
            ),
            new FlatButton(
              child: new Text('yes'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      }) ??
      false;

}


class CompanyState extends State<Company> {
  String partner_name="";

  getPartnername() async{
    final prefs= await SharedPreferences.getInstance();
    partner_name=prefs.getString("partner_name");

    setState(() {
      if(partner_name!=null && partner_name.length>0){
        partner_name="Welcome $partner_name";
      }else{
        partner_name="Service Partner";
      }
    });
  }


  @override
  void initState() {
    super.initState();
    getPartnername();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints){
        SizeConfig().init(constraints);
        return WillPopScope(
          onWillPop: ()=>_askExit(context),
          child: Scaffold(
            backgroundColor: Color(0xFF00ACC1),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Color(0xFF00ACC1),
              title: Text("COMPANY SERVICES",style: TextStyle(fontSize: 2.3*SizeConfig.textMultiplier),),
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(7*SizeConfig.imageSizeMultiplier),
                    topLeft: Radius.circular(7*SizeConfig.imageSizeMultiplier),
                  )
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height:2*SizeConfig.imageSizeMultiplier,),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        InkWell(
                          onTap: (){
                            setState(() {
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                                  splashPartner()), (Route<dynamic> route) => false);
                            });
                          },
                          child:  Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.white, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0.0, 5.0),
                                      blurRadius: 7),
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0.0, -5.0),
                                      blurRadius: 7),
                                ]),
                            margin: EdgeInsets.all(15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundImage: ExactAssetImage('images/company.png'),
                                  minRadius: 7.8*SizeConfig.imageSizeMultiplier,
                                  maxRadius: 9*SizeConfig.imageSizeMultiplier,
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      partner_name.toUpperCase(),
                                      style: TextStyle(fontSize: 2.1*SizeConfig.textMultiplier,color: Color(0xFF00ACC1)),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Earn Money as much you want",style: TextStyle(fontSize: 1.7*SizeConfig.textMultiplier),),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),

                        //  Become Parner





                        InkWell(  // Franchisor
                          onTap: (){
                            setState(() {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Frachisor()));

                            });
                          },
                          child: Container(
                            height: 28.5 * SizeConfig.imageSizeMultiplier,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage("images/franchisecard.png"),
                                    fit: BoxFit.fill),
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0.0, 5.0),
                                      blurRadius: 7),
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0.0, -5.0),
                                      blurRadius: 7),
                                ]),
                            margin: EdgeInsets.all(14),
                          ),
                        ),

                        // Become Franchiser


                        InkWell( // Meflisy Advertise ment
                          onTap: (){
                            setState(() {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Advertisement()));
                            });
                          },
                          child:  Container(
                            height: 28.5 * SizeConfig.imageSizeMultiplier,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage("images/advertise.png"),
                                    fit: BoxFit.fill),
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0.0, 5.0),
                                      blurRadius: 7),
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0.0, -5.0),
                                      blurRadius: 7),
                                ]),
                            margin: EdgeInsets.all(14),
                          ),
                        ),

                        // Advertisment us




                        // Company Information


                        InkWell(
                          onTap: (){
                            setState(() {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> Contactus()));
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.white, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0.0, 5.0),
                                      blurRadius: 7),
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0.0, -5.0),
                                      blurRadius: 7),
                                ]),
                            margin: EdgeInsets.all(15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundImage: ExactAssetImage('images/company.png'),
                                  minRadius: 7.8*SizeConfig.imageSizeMultiplier,
                                  maxRadius: 9*SizeConfig.imageSizeMultiplier,
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "CONTACT US",
                                      style: TextStyle(fontSize: 2.1*SizeConfig.textMultiplier,color: Color(0xFF00ACC1)),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Instant Connect with Our Help Center",style: TextStyle(fontSize: 1.7*SizeConfig.textMultiplier),),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Contact US
                        InkWell(
                          onTap: (){
                            setState(() {
                              Share.share("https://play.google.com/store/apps/details?id=com.meflisy.meflisy_service");
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.white, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0.0, 5.0),
                                      blurRadius: 7),
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0.0, -5.0),
                                      blurRadius: 7),
                                ]),
                            margin: EdgeInsets.all(15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundImage: ExactAssetImage('images/company.png'),
                                  minRadius: 7.8*SizeConfig.imageSizeMultiplier,
                                  maxRadius: 9*SizeConfig.imageSizeMultiplier,
                                ),
                                Padding(padding: EdgeInsets.only(left: 10)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "SHARE NOW",
                                      style: TextStyle(fontSize: 2.1*SizeConfig.textMultiplier,color: Color(0xFF00ACC1)),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text("Share and Earn",style: TextStyle(fontSize: 1.7*SizeConfig.textMultiplier),),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );

  }
}
