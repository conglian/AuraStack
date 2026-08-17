
import 'aurastackh5plugin_platform_interface.dart';

class Aurastackh5plugin {
  Future<String?> getPlatformVersion() {
    return Aurastackh5pluginPlatform.instance.getPlatformVersion();
  }
}
