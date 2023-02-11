import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_cttic_navi/flutter_cttic_navi_method_channel.dart';

void main() {
  MethodChannelFlutterCtticNavi platform = MethodChannelFlutterCtticNavi();
  const MethodChannel channel = MethodChannel('flutter_cttic_navi');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
