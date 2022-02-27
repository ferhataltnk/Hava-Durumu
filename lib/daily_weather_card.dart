import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';

class DailyWeather extends StatelessWidget {
  final String image;
  final String temp;
  final String date;

  const DailyWeather(
      {Key key, @required this.image, @required this.temp, @required this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar'
    ];
    String weekday = weekdays[DateTime.parse(date).weekday - 1];

    return Card(
      elevation: 2,
      color: Colors.transparent,
      child: GlowContainer(
        color: Color(0xFF030317),
        glowColor: Colors.white.withOpacity(0.2),

        borderRadius: BorderRadius.all(
           Radius.circular(20)),
        spreadRadius: 0.1,
        height: 120,
        width: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              'https://www.metaweather.com/static/img/weather/png/$image.png',
              height: 50,
              width: 50,
            ),
            Text('$temp ° C'),
            Text(weekday)
          ],
        ),
      ),
    );
  }
}
