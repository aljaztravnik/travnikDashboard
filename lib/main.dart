import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key,}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String time;
  LocationPermission permission;
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
    //return DateFormat.jms().format(dateTime);
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  void requestPerms() async
  {
    permission = await Geolocator.requestPermission();
    position = await Geolocator.getLastKnownPosition();
  }

  @override

  void initState()
  {
    time = formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => getTime());
    //var options = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    Geolocator.getPositionStream().listen((position) {
      speedInKmh = position.speed * 3.6; // position.speed is in m/s, so we have to multiply it by 3.6
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold
    (
      backgroundColor: Colors.lightBlue,
      body: Container
      (
        child: Column
        (
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>
          [
            Container
            (
              alignment: Alignment.topRight,
              child: Text("$time", style: TextStyle(color: Colors.white, fontSize: 30)),
            ),
            Container
            (
              alignment: Alignment.center,
              child: Text("${speedInKmh.round()} km/h", style: TextStyle(color: Colors.white, fontSize: 50)),
            ),
            Padding(padding: EdgeInsets.only(bottom: 10.0)),
            Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>
              [
                SizedBox
                (
                  width: MediaQuery.of(context).size.width / 4,
                  child: RaisedButton
                  (
                    onPressed: () => print("navigation"),
                    child: Icon(MdiIcons.navigationOutline, color: Colors.black, size: 40),
                    color: Colors.white,
                    elevation: 5.0,
                  ),  
                ),
                SizedBox
                (
                  width: MediaQuery.of(context).size.width / 4,
                  child: RaisedButton
                  (
                    onPressed: () => print("g-meter\n"), // go to G-meter screen
                    child: Center(child: Text("G-meter", style: TextStyle(color: Colors.black, fontSize: 30))),
                    color: Colors.white,
                    elevation: 5.0,
                  ),
                ),
              ],
            ),
            

          ],
        ),
      ),
    );
  }
}
