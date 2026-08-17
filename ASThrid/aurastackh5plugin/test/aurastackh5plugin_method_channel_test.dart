import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aurastackh5plugin/aurastackh5plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAurastackh5plugin platform = MethodChannelAurastackh5plugin();
  const MethodChannel channel = MethodChannel('aurastackh5plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
