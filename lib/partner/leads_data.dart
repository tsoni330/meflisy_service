import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meflisy_service/size_config.dart';
import 'dart:convert';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:http/http.dart' as http;

class leads_data extends StatefulWidget {
  String partner_id;

  leads_data(this.partner_id);

  @override
  _leads_dataState createState() => _leads_dataState();
}

class _leads_dataState extends State<leads_data> {
  static var data1;
  static var data2;
  static double total = -1, seen = -1, result = 0;
  bool check = false;

  Map<String, double> dataMap = new Map();

  List<CircularStackEntry> circularData = <CircularStackEntry>[
    new CircularStackEntry(
      <CircularSegmentEntry>[
        new CircularSegmentEntry(total, Color(0xff4285F4), rankKey: 'Q1'),
        new CircularSegmentEntry(seen, Color(0xfff3af00), rankKey: 'Q2'),
        new CircularSegmentEntry(result, Colors.purple, rankKey: 'Q3')
      ],
      rankKey: 'Data',
    ),
  ];

  get_data_totallead(String partner_id) async {
    String url = 'http://meflisyservice.com/leads_data_totalLead.php';
    http.Client client = new http.Client();

    final response = await client.post(url, body: {'partner_id': partner_id});
    setState(() {
      if (response.statusCode == 200) {
        data1 = json.decode(response.body);
        total = double.parse(data1.toString());
        print(data1.toString());
      } else {
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });
    String url1 = 'http://meflisyservice.com/leads_data_seenlead.php';
    http.Client client1 = new http.Client();

    final response1 =
        await client1.post(url1, body: {'partner_id': partner_id});
    setState(() {
      if (response1.statusCode == 200) {
        data2 = json.decode(response1.body);
        seen = double.parse(data2.toString());
        print(data2.toString());
      } else {
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
      result = total - seen;
      if (data1 > 0 && data2 > 0) {
        print("yaa not null and the value is " + result.toString());
        dataMap.putIfAbsent("Total Leads ", () => total);
        dataMap.putIfAbsent("Lead Used", () => seen);
      } else {
        dataMap.putIfAbsent("Total Leads ", () => 0);
        dataMap.putIfAbsent("Lead Used", () => 0);
      }
    });
  }

  /*get_data_seenlead(String partner_id) async {
    String url = 'http://meflisyservice.com/leads_data_seenlead.php';
    http.Client client = new http.Client();

    final response = await client.post(url, body: {'partner_id': partner_id});
    setState(() {
      if (response.statusCode == 200) {
        data2 = json.decode(response.body);

        print(data2.toString());
      } else {
        Fluttertoast.showToast(
            msg: " Something went wronge ", timeInSecForIos: 4);
      }
    });
  }*/

  @override
  void initState() {
    get_data_totallead(widget.partner_id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        SizeConfig().init(constraints);
        return Scaffold(
          backgroundColor: Color(0xFF00ACC1),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(0xFF00ACC1),
            title: Text("Leads Information"),
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
                topLeft: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 7 * SizeConfig.imageSizeMultiplier,
                ),
                dataMap != null && dataMap.length > 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Information",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Color(0xff4285F4),
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          CircleAvatar(
                                            backgroundColor: Color(0xFFff7675),
                                          ),
                                          Text(" Total Leads " +
                                              total.toString())
                                        ],
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          CircleAvatar(
                                            backgroundColor: Color(0xFF74b9ff),
                                          ),
                                          Text(" Used Leads " + seen.toString())
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : SizedBox(
                  height: 1,
                ),
                SizedBox(
                  height: 10,
                ),
                dataMap != null && dataMap.length > 0
                    ? PieChart(
                        dataMap: dataMap,
                        animationDuration: Duration(milliseconds: 1300),
                        chartLegendSpacing: 32.0,
                        chartRadius: MediaQuery.of(context).size.width / 1.7,
                        showChartValuesInPercentage: false,
                        showChartValues: true,
                        showChartValuesOutside: false,
                        chartValueBackgroundColor: Colors.grey[200],
                        showLegends: true,
                        legendPosition: LegendPosition.right,
                        decimalPlaces: 1,
                        showChartValueLabel: true,
                        initialAngle: 0,
                        chartValueStyle: defaultChartValueStyle.copyWith(
                          color: Colors.blueGrey[900].withOpacity(0.9),
                        ),
                        chartType: ChartType.disc,
                      )
                    : SizedBox(
                        height: 20,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

}
