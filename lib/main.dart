import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'gMeterScreen.dart';

void main() => runApp(TravnikDashboard());

class TravnikDashboard extends StatelessWidget 
{
  @override
  Widget build(BuildContext context)
  {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return MaterialApp
    (
      initialRoute: '/',
      routes: 
      {
        'gMeterScreen' : (context) => GMeterScreen(),
      },

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
  Position currPosition, prevPosition;
  var speedInKmh = 0.0;
  bool firstLocation = false;
  double distance = 0.0;
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';

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
    currPosition = await Geolocator.getLastKnownPosition();
  }

  void _listen() async
    {
      if(!_isListening)
      {
        bool available = await _speech.initialize(
          onStatus: (val) => print("onStatus: $val"),
          onError: (val) => print("onError: $val"),
        );
        if(available)
        {
          setState(() {
            _isListening = true;
          });
          _speech.listen(
            onResult: (val) => setState((){
              _text = val.recognizedWords;
            }),
          );
        }
      }
      else
      {
        setState(() {
        _isListening = false;
        });
        _speech.stop();
        print("RECEIVED TEXT: $_text");
        _text = '';
      }
    }

  @override

  void initState()
  {
    time = formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => getTime());
    //var options = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    Geolocator.getPositionStream().listen((currPosition) {
      speedInKmh = currPosition.speed * 3.6; // position.speed is in m/s, so we have to multiply it by 3.6
      prevPosition = currPosition;
      distance += (Geolocator.distanceBetween(prevPosition.latitude, prevPosition.longitude, currPosition.latitude, currPosition.longitude)) / 1000.0;
    });
    super.initState();
    _speech = stt.SpeechToText();
  }

  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      //backgroundColor: Colors.lightBlue,
      backgroundColor: Color(0xff444852),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton
      (
        onPressed: () {_listen();},
        backgroundColor: Colors.white,
        child: Icon(_isListening ? MdiIcons.microphoneOff : MdiIcons.microphone, color: Colors.black),
      ),
      body: Container
      (
        child: Column
        (
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>
          [
            Padding(padding: EdgeInsets.only(top: 15)),
            Container
            (
              alignment: Alignment.topRight,
              child: Text("$time", style: TextStyle(color: Colors.white, fontSize: 30)),
            ),
            Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>
              [
                Text("${speedInKmh.round()} km/h", style: TextStyle(color: Colors.white, fontSize: 50)),
                Text("${distance.toStringAsFixed(1)} km", style: TextStyle(color: Colors.white, fontSize: 50)),
              ],
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
                    onPressed: () => Navigator.pushNamed(context, 'gMeterScreen'), // go to G-meter screen
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