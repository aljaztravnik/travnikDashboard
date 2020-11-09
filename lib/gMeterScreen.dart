import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sensors/sensors.dart';


class GMeterScreen extends StatefulWidget
{
  GMeterScreen({Key key,}) : super(key: key);
  @override
  _GMeterScreen createState() => _GMeterScreen();
}

class _GMeterScreen extends State<GMeterScreen>
{
  double _y, _z;
  List<StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  void initState()
  {
    super.initState();
    // [AccelerometerEvent (x: 0.0, y: 9.8, z: 0.0)]
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _y = event.y;
        _z = event.z;
        if(event.y < 0) print("GOING RIGHT: $_y");
        else if(event.y > 0) print("GOING LEFT: $_y");
        if(event.z < 0) print("ACCELERATING: $_z");
        else if(event.z > 0) print("BRAKING: $_z");
      }); // z = gas, brakes
          //    z > 0 --> bremzamo, z < 0 --> pospesujemo
          // y = left, right
          //    y > 0 --> going left, y < 0 --> going right
    }));
  }

  void dispose()
  {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
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
        onPressed: () {Navigator.pop(context);},
        backgroundColor: Colors.white,
        child: Icon(MdiIcons.arrowLeft, color: Colors.black),
      ),
      body: Column
      (
        children: <Widget>
        [
          /*Padding(padding: EdgeInsets.only(top: 25)),
          Container
          (
            alignment: Alignment.centerLeft,
            //width: MediaQuery.of(context).size.width / 10,
            //height: MediaQuery.of(context).size.height / 5,
            child: RaisedButton
            (
              elevation: 5.0,
              onPressed: () {Navigator.pop(context);},
              padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.white,
              child: Icon(MdiIcons.arrowLeft, color: Colors.black),
            ),
          ),*/
          Container
          (
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CustomPaint(
              painter: OpenPainter(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height, _y, _z),
            ),
          ),
        ],
      )
    );
  }
}

class OpenPainter extends CustomPainter
{
  double widthh, heightt, _y, _z;
  @override
  void paint(Canvas canvas, Size size)
  {
    if(_y > 10) _y = 10;
    else if(_y < -10) _y = -10;
    if(_z > 10) _z = 10;
    else if(_z < -10) _z = -10;
    double offsetX = ((widthh / 2) + ((_y*50) / 10));
    double offsetY = ((heightt / 2) + ((_z*50) / 10));
    var paint1 = Paint()
      ..color = Color(0xffffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset((widthh / 2), (heightt / 2)), 100, paint1);
    canvas.drawCircle(Offset(offsetX, offsetY), 10, paint1);
    //canvas.drawCircle(Offset(0, 0), 100, paint1);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
  OpenPainter(this.widthh, this.heightt, this._y, this._z);
}