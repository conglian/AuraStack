import 'package:flutter_test/flutter_test.dart';
import 'package:aurastackh5plugin/aurastackh5plugin.dart';
import 'package:aurastackh5plugin/aurastackh5plugin_platform_interface.dart';
import 'package:aurastackh5plugin/aurastackh5plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAurastackh5pluginPlatform
    with MockPlatformInterfaceMixin
    implements Aurastackh5pluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final Aurastackh5pluginPlatform initialPlatform = Aurastackh5pluginPlatform.instance;

  test('$MethodChannelAurastackh5plugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAurastackh5plugin>());
  });

  test('getPlatformVersion', () async {
    Aurastackh5plugin aurastackh5pluginPlugin = Aurastackh5plugin();
    MockAurastackh5pluginPlatform fakePlatform = MockAurastackh5pluginPlatform();
    Aurastackh5pluginPlatform.instance = fakePlatform;

    expect(await aurastackh5pluginPlugin.getPlatformVersion(), '42');
  });
}
