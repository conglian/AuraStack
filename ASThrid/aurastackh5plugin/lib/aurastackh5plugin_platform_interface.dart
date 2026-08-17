import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'aurastackh5plugin_method_channel.dart';

abstract class Aurastackh5pluginPlatform extends PlatformInterface {
  /// Constructs a Aurastackh5pluginPlatform.
  Aurastackh5pluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static Aurastackh5pluginPlatform _instance = MethodChannelAurastackh5plugin();

  /// The default instance of [Aurastackh5pluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelAurastackh5plugin].
  static Aurastackh5pluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Aurastackh5pluginPlatform] when
  /// they register themselves.
  static set instance(Aurastackh5pluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
