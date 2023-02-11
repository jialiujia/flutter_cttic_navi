import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_cttic_navi/flutter_cttic_navi.dart';
import 'package:flutter_cttic_navi/nav_point.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterCtticNaviPlugin = FlutterCtticNavi();
  var endPoint, endPoint2;
  List<NavPoint> intermediatePoints = [];
  List<NavPoint> intermediatePoints2 = [];

  @override
  void initState() {
    super.initState();
    endPoint = NavPoint(name: "外二");
    endPoint2 = NavPoint(name: "出口", latitude: 31.36789296787859, longitude: 121.56662522100687);
    var point1 = NavPoint(name: "西藏北路");
    var point2 = NavPoint(name: "静安寺");
    var point3 = NavPoint(name: '5J-1', latitude:0.0, longitude:0.0);
    var point4 = NavPoint(name: '5J-2', latitude:0.0, longitude:0.0);
    var point5 = NavPoint(name: '5J-2', latitude:0.0, longitude:0.0);
    intermediatePoints.add(point1);intermediatePoints.add(point2);
    intermediatePoints2.add(point3);intermediatePoints2.add(point4);
    intermediatePoints2.add(point5);
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(onPressed: () async {
                await _flutterCtticNaviPlugin.startAmapNavigation(context, "13917745806", "test1", "沪牌",
                    null, endPoint, intermediatePoints, onComplete: () => {
                      print("完成场外导航")
                    },
                    onCancel: ()=> print("未完成场外导航")
                );
              }, child: const Text("厂区外"),),
              TextButton(onPressed: () async {
                await _flutterCtticNaviPlugin.startDockNavigation(context, "13917745806", "test1", "沪牌",
                    null, endPoint2, intermediatePoints2, onComplete: ()=> print("完成场內导航"),
                    onCancel: ()=> print("未完成场內导航")
                );
              }, child: const Text("厂区內"),),
            ],
          )
      ),
    );
  }
}