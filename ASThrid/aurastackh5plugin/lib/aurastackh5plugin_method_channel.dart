import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'aurastackh5plugin_platform_interface.dart';

/// An implementation of [Aurastackh5pluginPlatform] that uses method channels.
class MethodChannelAurastackh5plugin extends Aurastackh5pluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('aurastackh5plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
