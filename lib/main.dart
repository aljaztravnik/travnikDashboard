import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(TravnikDashboard());


class TravnikDashboard extends StatelessWidget 
{
  @override
  Widget build(BuildContext context) 
  {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return MaterialApp(
      title: 'travnikDashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String time;
  var geolocator = Geolocator();
  Position position;
  var speedInKmh = 0.0;

  void getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = formatDateTime(now);
    setState(() {
      time = formattedDateTime;
    });
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('MM/dd/yyyy hh:mm:ss').format(dateTime);
  }

  @override

  void initState() async
  {
    time = formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => getTime());

    position = await Geolocator.getLastKnownPosition();
    //var options = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    Geolocator.getPositionStream().listen((position) {
      speedInKmh = position.speed * 3.6; // position.speed is in m/s, so we have to multiply it by 3.6
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>
          [
            Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>
              [
                Text("$speedInKmh", style: TextStyle(color: Color(0x000000))),
                Text("$time", style: TextStyle(color: Color(0x000000))),
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>
              [
                FloatingActionButton
                (
                  onPressed: () => print("navigacija\n"),
                  child: Center(child: Text("Navigation", style: TextStyle(color: Color(0xffffff)),)),
                  backgroundColor: Color(0x404040),
                ),
                FloatingActionButton
                (
                  onPressed: () => print("g-meter\n"),
                  child: Center(child: Text("G-meter", style: TextStyle(color: Color(0xffffff)),)),
                  backgroundColor: Color(0x404040),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
