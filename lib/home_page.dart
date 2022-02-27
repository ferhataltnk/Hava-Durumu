import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'daily_weather_card.dart';
import 'search_page.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String sehir = 'Ankara';
  int sicaklik;
  var locationData;
  var woeid;
  String abbr = 'c';
  Position position;
  List<int> temps = List(5);
  List<String> abbrs = List(5);
  List<String> dates = List(5);

  Future<void> getDevicePosition() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (e) {
      print('Şu hata oluştu $e');
    }

    print(position);
  }

  Future<void> getLocationTemperature() async {
    var response =
        await http.get('https://www.metaweather.com/api/location/$woeid/');
    var temperatureDataParsed = jsonDecode(response.body);

    setState(() {
      sicaklik =
          temperatureDataParsed['consolidated_weather'][0]['the_temp'].round();
      abbr = temperatureDataParsed['consolidated_weather'][0]
          ['weather_state_abbr'];
      for (int i = 0; i < temps.length; i++) {
        temps[i] = temperatureDataParsed['consolidated_weather'][i + 1]
                ['the_temp']
            .round();
        abbrs[i] = temperatureDataParsed['consolidated_weather'][i + 1]
            ['weather_state_abbr'];
        dates[i] = temperatureDataParsed['consolidated_weather'][i + 1]
            ['applicable_date'];
      }
    });
  }

  Future<void> getLocationData() async {
    locationData = await http
        .get('https://www.metaweather.com/api/location/search/?query=$sehir');
    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]['woeid'];
  }

  Future<void> getLocationDataLatLong() async {
    locationData = await http.get(
        'https://www.metaweather.com/api/location/search/?lattlong=${position.latitude},${position.longitude}');
    // var locationDataParsed = jsonDecode((locationData.body));
    var locationDataParsed = jsonDecode(utf8.decode(locationData.bodyBytes));

    woeid = locationDataParsed[0]['woeid'];
    sehir = locationDataParsed[0]['title'];
  }

  void getDataFromAPI() async {
    await getDevicePosition();
    await getLocationDataLatLong();
    getLocationTemperature();
  }

  void getDataFromAPIbyCity() async {
    await getLocationData();
    getLocationTemperature();
  }

  @override
  void initState() {
    getDataFromAPI();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(

            color: Color(0xFF030317),
          ),
          child: sicaklik == null
              ? Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    currentWeather(
                      context: context,
                      widget: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            right: MediaQuery.of(context).size.width-300,
                            child: Center(
                              child:
                                  Text(
                                    '$sehir',
                                    style: TextStyle(
                                        fontSize: 40,
                                        shadows: <Shadow>[
                                          Shadow(
                                              color: Colors.white,
                                              blurRadius: 5,
                                              offset: Offset(-1, 1))
                                        ]),
                                  ),




                            ),
                          ),
                          Positioned(
                            top:0,
                            left:MediaQuery.of(context).size.width-100,
                            child: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () async {
                                  sehir = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SearchPage()));
                                  //getDataFromAPIbyCity();
                                  setState(() {
                                    sehir = sehir;
                                  });
                                }),
                          ),
                          SizedBox(
                            height: 100,
                          ),
                          Positioned(
                            top:150,
                            left:70,

                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    height: 200,
                                    width: 200,
                                    child: Image.network(
                                        'https://www.metaweather.com/static/img/weather/png/$abbr.png'),
                                  ),
                                  Text(
                                    '$sicaklik° C',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 50,
                                        shadows: <Shadow>[
                                          Shadow(
                                              color: Colors.white,
                                              blurRadius: 5,
                                              offset: Offset(-1, 1))
                                        ]),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                    buildDailyWeatherCards(context),
                    SizedBox(height: 15),
                  ],
                )),
    );
  }

  GlowContainer currentWeather({
    BuildContext context,
    @required Widget widget,
  }) {
    return GlowContainer(
      height: MediaQuery.of(context).size.height - 200,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(2),
      padding: EdgeInsets.only(top: 50, left: 30, right: 30),
      glowColor: Color(0xff00A1FF).withOpacity(0.5),
      color: Color(0xff00A1FF),
      spreadRadius: 5,
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
      child: widget,
    );
  }

  Container buildDailyWeatherCards(BuildContext context) {
    List<Widget> cards = List(5);

    for (int i = 0; i < cards.length; i++) {
      cards[i] = DailyWeather(
          image: abbrs[i], temp: temps[i].toString(), date: dates[i]);
    }

    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }
}
