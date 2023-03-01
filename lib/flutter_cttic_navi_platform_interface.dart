import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_cttic_navi_method_channel.dart';
import 'nav_point.dart';

abstract class FlutterCtticNaviPlatform extends PlatformInterface {
  /// Constructs a FlutterCtticNaviPlatform.
  FlutterCtticNaviPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterCtticNaviPlatform _instance = MethodChannelFlutterCtticNavi();

  /// The default instance of [FlutterCtticNaviPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterCtticNavi].
  static FlutterCtticNaviPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterCtticNaviPlatform] when
  /// they register themselves.
  static set instance(FlutterCtticNaviPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isMsdAppInstalled() {
    throw UnimplementedError('isMsdAppInstalled() has not been implemented.');
  }

  Future<bool> startAmapNavigation(String userId,
      String deviceId, String carNo, NavPoint? startPoint,
      NavPoint endPoint, List<NavPoint>intermediatePoints) {
    throw UnimplementedError('startAmapNavigation(String, String, String, String?, String, List<String>) has not been implemented.');
  }

  Future<bool> startDockNavigation(String userId,
      String deviceId, String carNo, NavPoint? startPoint,
      NavPoint endPoint, List<NavPoint>intermediatePoints, {simulationEnabled=false}) {
    throw UnimplementedError('startDockNavigation(String, String, String, String?, String, List<String>) has not been implemented.');
  }
}
