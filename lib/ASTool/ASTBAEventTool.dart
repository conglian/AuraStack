import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tba_info/flutter_tba_info.dart';
import 'ASLogger.dart';


void as_session_fire() async {
  var baseBody = await ASRequestHelpers().baseBody();
  baseBody["buddy"] = {};
  ASRequestHelpers().post(baseBody, 2);
}

void as_ad_fire(Map<String, dynamic> body) async {
  var baseBody = await ASRequestHelpers().baseBody();
  Map<String, dynamic> bliss = {};
  for (String key in body.keys){
    bliss[key] = body[key];
  }
  baseBody["bliss"] = bliss;
  ASRequestHelpers().post(baseBody, 3);
}

void as_event_fire(String name, Map<String, dynamic> body) async {
  var baseBodys = await ASRequestHelpers().baseBody();
  baseBodys["flash"] = name;
  for (String key in body.keys){
    baseBodys['${key}\$chintzy'] = body[key];
  }
  ASRequestHelpers().post(baseBodys, 0);
}

void as_install_fire() async {
  var baseBody = await ASRequestHelpers().baseBody();
  var map = await FlutterTbaInfo.instance.getReferrerMap();
  Map<String, dynamic> riga = {
    "italic": map['build'],
    'caustic' : map['referrer_url'],
    "phoebe": map['install_version'],
    "krill": map['user_agent'],
    "kennedy": 'touch',
    "value": map['referrer_click_timestamp_seconds'],
    "dumpty": map['install_begin_timestamp_seconds'],
    "maze": map['referrer_click_timestamp_server_seconds'],
    "railroad": map['install_begin_timestamp_server_seconds'],
    "lundberg": map['install_first_seconds'],
    "baneful": map['last_update_seconds'],
  };
  baseBody["riga"] = riga;
  ASRequestHelpers().post(baseBody, 1);
}

class ASRequestHelpers {
  static final ASRequestHelpers _instance = ASRequestHelpers._internal();

  factory ASRequestHelpers() {
    return _instance;
  }

  ASRequestHelpers._internal();

  static String cloak_Url =
      "https://pegging.lccstackauraascratch.com/succeed/brute/brad";

  static String tba_event_Url_test =
      "https://test-pullover.lccstackauraascratch.com/baron/soybean/annulus";

  static String tba_event_Url_release =
      "https://pullover.lccstackauraascratch.com/welt/moliere";

  static String tba_event_Url = kDebugMode ? tba_event_Url_test : tba_event_Url_release;

  final Map<String, String> normalHeader = {
    'Content-Type': 'application/json',
  };

  Map<String, String> eventHeader = {
    'Content-Type': 'application/json',
  };

  Future<dynamic> getCloak() async {
    var url = Uri.parse("${cloak_Url}?smelly=${await FlutterTbaInfo.instance.getBundleId()}&eruption=lucid&hardin=${await FlutterTbaInfo.instance.getAppVersion()}&waken=${DateTime.now().millisecondsSinceEpoch}");
    asLog.info("aurastack play land config request ${url}");
    try {
      var response = await http.get(
        url,
        headers: normalHeader,
      );
      return _handleResponse(response);
    } catch (e) {
      asLog.error("upload event [cloak] faild error $e");
    }
  }

  Future<dynamic> post(dynamic data, int type) async {
    var eventName = "";
    if (type == 0) {
      eventName = "event";
    } else if (type == 1) {
      eventName = "install";
    } else if (type == 2) {
      eventName = "session";
    } else {
      eventName = "ad";
    }
    var url = Uri.parse(
        "${tba_event_Url}");
    asLog.info("upload event [${eventName}] url ${url} \n ${data}");
    try {
      var response = await http.post(
        url,
        headers: eventHeader,
        body: jsonEncode(data),
      );
      asLog.success("upload event [${eventName}] success ${response.body}");
      // "upload event [${eventName}] success ${response.body}".log();
      return _handleResponse(response);
    } catch (e) {
      asLog.error("upload event [${eventName}] faild error $e");
      // throw Exception('Failed to perform POST request: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  void _refreshHeader() async {
    eventHeader = {
      'Content-Type': 'application/json',
    };
  }

  void init() {
    _refreshHeader();
  }


}
// request parmerters
extension RequestHelpersExtension on ASRequestHelpers {
  Future<String> getConfigQueryString() async {
    var queryBody = {
      "smelly": await FlutterTbaInfo.instance.getBundleId(),
      "eruption": 'lucid',
      "hardin": await FlutterTbaInfo.instance.getAppVersion(),
    };
    asLog.debug(
      'queryBody=$queryBody',
    );
    return Uri(queryParameters: queryBody).query;
  }
  // 通用字段
  Future<Map<String, dynamic>> baseBody() async {
    Map<String, dynamic> baseBody = {};

    Map<String, dynamic> calf = {
      "smelly": await FlutterTbaInfo.instance.getBundleId(),
      "eruption": 'lucid',
      'hardin' : await FlutterTbaInfo.instance.getAppVersion(),
      'preston' : await FlutterTbaInfo.instance.getDistinctId(),
      "eastman": await FlutterTbaInfo.instance.getLogId(),
      'waken' : DateTime.now().millisecondsSinceEpoch,
      "palermo": await FlutterTbaInfo.instance.getManufacturer(),
      'ague' : await FlutterTbaInfo.instance.getBrand(),
      "connally": await FlutterTbaInfo.instance.getDeviceModel(),
      'antelope' : await FlutterTbaInfo.instance.getOsVersion(),
      'hoop' : await FlutterTbaInfo.instance.getOperator(),
      'handsome' : await FlutterTbaInfo.instance.getSystemLanguage(),
      'hearst' : await FlutterTbaInfo.instance.getAndroidId(),
      "fix": await FlutterTbaInfo.instance.getGaid(),
      "manifold": await FlutterTbaInfo.instance.getOsCountry(),
    };
    baseBody['calf'] = calf;
    return baseBody;
  }

}