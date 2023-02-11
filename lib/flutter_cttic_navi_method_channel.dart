import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cttic_navi/nav_enity.dart';

import 'flutter_cttic_navi_platform_interface.dart';
import 'nav_point.dart';

/// An implementation of [FlutterCtticNaviPlatform] that uses method channels.
class MethodChannelFlutterCtticNavi extends FlutterCtticNaviPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_cttic_navi');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> isMsdAppInstalled() async {
    bool result =  await methodChannel.invokeMethod("isMsdAppInstalled");
    return result;
  }

  @override
  Future<bool> startAmapNavigation(String userId,
      String deviceId, String carNo, NavPoint? startPoint,
      NavPoint endPoint, List<NavPoint>intermediatePoints) async {
    bool result;
    NavEnity enity = NavEnity(NavType.OUT, userId, deviceId, carNo, endPoint, startPoint: startPoint, intermediatePoints: intermediatePoints);
    String navJson = json.encode(enity);
    result = await methodChannel.invokeMethod("startAmapNavigation", <String, dynamic> {
      'enity': navJson
    });
    return result;
  }

  @override
  Future<bool> startDockNavigation(String userId,
      String deviceId, String carNo, NavPoint? startPoint,
      NavPoint endPoint, List<NavPoint>intermediatePoints) async {
    bool result;
    NavEnity enity = NavEnity(NavType.IN, userId, deviceId, carNo, endPoint, startPoint: startPoint, intermediatePoints: intermediatePoints);
    String navJson = json.encode(enity);
    result = await methodChannel.invokeMethod("startDockNavigation", <String, dynamic> {
      'enity': navJson
    });
    return result;
  }
}