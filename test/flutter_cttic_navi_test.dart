import 'package:flutter_cttic_navi/nav_point.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_cttic_navi/flutter_cttic_navi.dart';
import 'package:flutter_cttic_navi/flutter_cttic_navi_platform_interface.dart';
import 'package:flutter_cttic_navi/flutter_cttic_navi_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterCtticNaviPlatform 
    with MockPlatformInterfaceMixin
    implements FlutterCtticNaviPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> startAmapNavigation(String userId,
      String deviceId, String carNo, NavPoint? startPoint,
      NavPoint endPoint, List<NavPoint>intermediatePoints) {
    // TODO: implement startAmapNavigation
    return Future.value(true);
  }

  @override
  Future<bool> isMsdAppInstalled() {
    // TODO: implement isMsdAppInstalled
    return Future.value(true);
  }

  @override
  Future<bool> startDockNavigation(String userId, String deviceId, String carNo, NavPoint? startPoint, NavPoint endPoint, List<NavPoint> intermediatePoints) {
    // TODO: implement startDockNavigation
    return Future.value(true);
  }
}

void main() {
  final FlutterCtticNaviPlatform initialPlatform = FlutterCtticNaviPlatform.instance;

  test('$MethodChannelFlutterCtticNavi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterCtticNavi>());
  });

  test('getPlatformVersion', () async {
    FlutterCtticNavi flutterCtticNaviPlugin = FlutterCtticNavi();
    MockFlutterCtticNaviPlatform fakePlatform = MockFlutterCtticNaviPlatform();
    FlutterCtticNaviPlatform.instance = fakePlatform;
  
    // expect(await flutterCtticNaviPlugin.getPlatformVersion(), '42');
  });
}
