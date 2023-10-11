import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meflisy_service/size_config.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'MainHome.dart';
import 'package:auto_size_text/auto_size_text.dart';

class location extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _locationstate();
  }
}

class _locationstate extends State<location> {
  String _mySelection, _myCitySelection, _myLocalitySelection,selectedCity;

  final String url = 'http://meflisyservice.com/working_states.php';

  List data, city_data, locality_data;

  List<Note> _notes = List<Note>();
  List<Note> _notesForDisplay = List<Note>();
  List<City> _cities = List<City>();
  List<City> _citiesForDisplay = List<City>();

  saveLocation()async{
    final prefs= await SharedPreferences.getInstance();

    setState(() {
      prefs.setString("state", _mySelection);
      prefs.setString("city", _myCitySelection);
      prefs.setString("locality", _myLocalitySelection);

      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          MainHome()), (Route<dynamic> route) => false);
    });

  }

  Future<String> getStateData() async {
    http.Client client = new http.Client();
    var res = await client.get(Uri.encodeFull(url));
    var resBody = json.decode(res.body);
    setState(() {
      data = resBody;
      print("The data after setState is ${data}");
    });
    client.close();
    return 'Success';
  }

  Future<String> getCityData(String cityname) async {
    String cityurl = "http://meflisyservice.com/get_cityname.php";
    http.Client client = new http.Client();
    final res = await client.post(cityurl, body: {
      'state': cityname,
    });
    if(res.statusCode==200){
      var citiesJson = json.decode(res.body);
      setState(() {
        city_data = citiesJson;
        for (var noteJson in citiesJson) {
          _cities.add(City.fromJson(noteJson));
        }
        print("The _notes is "+_cities.length.toString());
        _citiesForDisplay = _cities;
      });
    }
    client.close();
    return 'Success';
  }

  Future<String> getLocalityData(String cityname, String statename) async {
    String localityurl = "http://meflisyservice.com/locality.php";
    http.Client client = new http.Client();
    var res = await client.post(Uri.encodeFull(localityurl),body: {
      'state':statename,'city':cityname
    });


    if(res.statusCode==200){
      var notesJson = json.decode(res.body);
      setState(() {
        locality_data = notesJson;
        for (var noteJson in notesJson) {
          _notes.add(Note.fromJson(noteJson));
        }
        print("The _notes is "+_notes.length.toString());
        _notesForDisplay = _notes;
      });

    }

    client.close();
    return 'Success';

  }

  @override
  void initState() {
    super.initState();
    getStateData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Color(0xFF005E6A),
      appBar: AppBar(
        backgroundColor: Color(0xFF005E6A),
        title: Text("Select Your Location"),
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
              topLeft: Radius.circular(7 * SizeConfig.imageSizeMultiplier),
            ),
          image: DecorationImage(
              image: AssetImage("images/partnerBackground.png"),
              fit: BoxFit.fill),
        ),

        child: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top:20),
              alignment: Alignment.center,
              child: DropDown(data),
            ),
            Container(
              ///   drop down
              alignment: Alignment.center,
              child: selectedCity==null?DropDown2(_mySelection):
              GestureDetector(
                onTap: (){
                  selectedCity=null;
                  setState(() {
                  });
                },
                child:Container(
                    margin: EdgeInsets.all( 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.white, width: 1),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0.0, 10.0),
                              blurRadius: 7),
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0.0, -10.0),
                              blurRadius: 7),
                        ]),
                    child: Text(
                      selectedCity,style: TextStyle(fontSize: 20),
                    )
                )
              )

            ),
             Container(
               alignment: Alignment.center,
               child: DropDown3(_myCitySelection, _mySelection),
              ),
          ],
        ),
      ),
    );
  }
  Widget DropDown(List data) {
    if (data != null) {
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.only(left: 10, right: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, 10.0),
                  blurRadius: 7),
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, -10.0),
                  blurRadius: 7),
            ]),
        child: DropdownButton(
          icon: Icon(
            Icons.arrow_drop_down,
            color:Colors.black,
          ),
          items: data.map((item) {
            return new DropdownMenuItem(
              child: new Text(
                item['state_name'],
                style: TextStyle(fontSize:2.0*SizeConfig.textMultiplier,fontWeight: FontWeight.bold),
              ),
              value: item['state_name'].toString(),
            );
          }).toList(),
          hint: Text(
            "Select your State/Cities",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          onChanged: (newVal) {
            setState(() {
              _mySelection = newVal;
              city_data=null;
              _cities=new List<City>();
              _myCitySelection=null;
              selectedCity=null;
              getCityData(_mySelection);
            });
          },
          value: _mySelection,
        ),
      );
    } else {
      return new Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget DropDown2(String cityname) {
    if (cityname != null) {
      if (city_data != null) {
        return Container(
          margin: EdgeInsets.all( 10),
          padding: EdgeInsets.only(left: 10, right: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0.0, 10.0),
                    blurRadius: 7),
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0.0, -10.0),
                    blurRadius: 7),
              ]),
          child:ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return index == 0 ? _searchCityBar() : _listCityItem(index-1);
            },
            itemCount: _citiesForDisplay.length+1,
          ),
        );
      } else {
        return new Center(
          child: CircularProgressIndicator(),
        );
      }
    }
  }



  Widget DropDown3(String cityname, String statename) {
    double maxWidth = MediaQuery.of(context).size.width * 0.9;
    if (cityname != null) {
      if (locality_data != null) {
        return Container(
          alignment: Alignment.center,
          width: maxWidth,
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.only(left: 10, right: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0.0, 10.0),
                    blurRadius: 7),
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0.0, -10.0),
                    blurRadius: 7),
              ]),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return index == 0 ? _searchBar() : _listItem(index-1);
            },
            itemCount: _notesForDisplay.length+1,
          ),
        );
      } else {
        return new Center(
          child: CircularProgressIndicator(),
        );
      }
    }
  }

  _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
            hintText: 'Search locality name...'
        ),
        onChanged: (text) {
          text = text.toLowerCase();
          setState(() {
            _notesForDisplay = _notes.where((note) {
              var noteTitle = note.title.toLowerCase();
              return noteTitle.contains(text);
            }).toList();
          });
        },
      ),
    );
  }
  _listItem(index) {
    return GestureDetector(
      onTap: (){
        _myLocalitySelection=_notesForDisplay[index].title;
        saveLocation();
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _notesForDisplay[index].title,
                style: TextStyle(
                    fontSize: 2*SizeConfig.textMultiplier,
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _searchCityBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
            hintText: 'Search Town/Village name...'
        ),

        onChanged: (text) {
          text = text.toLowerCase();
          setState(() {
            _citiesForDisplay = _cities.where((note) {
              var noteTitle = note.name.toLowerCase();
              return noteTitle.contains(text);
            }).toList();
          });
        },
      ),
    );
  }
  _listCityItem(index) {
    return GestureDetector(
      onTap: (){
        _myCitySelection=_citiesForDisplay[index].name;
        selectedCity=_citiesForDisplay[index].name;
        locality_data = null;
        _notes=new List<Note>();
        _myLocalitySelection=null;
        getLocalityData(_myCitySelection, _mySelection);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _citiesForDisplay[index].name,
                style: TextStyle(
                    fontSize: 2*SizeConfig.textMultiplier,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class Note {

  String title;
  Note(this.title);
  Note.fromJson(Map<String, dynamic> json) {
    title = json['locality'];
  }
}

class City {

  String name;
  City(this.name);
  City.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }
}