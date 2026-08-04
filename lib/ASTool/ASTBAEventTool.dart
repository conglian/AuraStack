import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tba_info/flutter_tba_info.dart';
import 'as_extension_help.dart';


void as_session_fire() async {
  var baseBody = await ASRequestHelpers().baseBody();
  baseBody["arccos"] = 'cal';
  ASRequestHelpers().post(baseBody, 2);
}

void as_ad_fire(Map<String, dynamic> body) async {
  var baseBody = await ASRequestHelpers().baseBody();
  baseBody["yakima"] = body;
  ASRequestHelpers().post(baseBody, 3);
}

void as_event_fire(String name, Map<String, dynamic> body) async {
  var baseBodys = await ASRequestHelpers().baseBody();
  baseBodys["arccos"] = name;
  baseBodys['soil'] = body;
  ASRequestHelpers().post(baseBodys, 0);
}

void as_install_fire() async {
  var baseBody = await ASRequestHelpers().baseBody();
  var map = await FlutterTbaInfo.instance.getReferrerMap();
  Map<String, dynamic> mannitol = {
    "yipping": map['build'],
    'mercator' : map['referrer_url'],
    "vary": map['install_version'],
    "exercise": map['user_agent'],
    "juicy": 'molar',
    "generous": map['referrer_click_timestamp_seconds'],
    "sorry": map['install_begin_timestamp_seconds'],
    "derriere": map['referrer_click_timestamp_server_seconds'],
    "nassau": map['install_begin_timestamp_server_seconds'],
    "oxen": map['install_first_seconds'],
    "bindery": map['last_update_seconds'],
  };
  baseBody["mannitol"] = mannitol;
  ASRequestHelpers().post(baseBody, 1);
}

class ASRequestHelpers {
  static final ASRequestHelpers _instance = ASRequestHelpers._internal();

  factory ASRequestHelpers() {
    return _instance;
  }

  ASRequestHelpers._internal();

  static String cloak_Url =
      "https://fancy.scratchcardearngopro.com/sault/commute";

  // static String tba_event_Url =
  //     "https://test-mark.scratchcardearngopro.com/molten/pimp/girt";

  static String tba_event_Url =
      "https://mark.scratchcardearngopro.com/brant/schooner/highland";

  final Map<String, String> normalHeader = {
    'Content-Type': 'application/json',
  };

  Map<String, String> eventHeader = {
    'Content-Type': 'application/json',
  };

  Future<dynamic> getCloak() async {
    var url = Uri.parse("${cloak_Url}?risen=${await FlutterTbaInfo.instance.getBundleId()}&toluene=soon&species=${await FlutterTbaInfo.instance.getAppVersion()}&qs=${DateTime.now().millisecondsSinceEpoch}");
    "scratch play land config request ${url}".log();
    try {
      var response = await http.get(
        url,
        headers: normalHeader,
      );
      return _handleResponse(response);
    } catch (e) {
      "upload event [cloak] faild error $e".log();
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
    "upload event [${eventName}] url ${url} \n ${data}".log();
    try {
      var response = await http.post(
        url,
        headers: eventHeader,
        body: jsonEncode(data),
      );
      print("upload event [${eventName}] success ${response.body}");
      // "upload event [${eventName}] success ${response.body}".log();
      return _handleResponse(response);
    } catch (e) {
      "upload event [${eventName}] faild error $e".log();
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
      "risen": await FlutterTbaInfo.instance.getBundleId(),
      "toluene": 'soon',
      "species": await FlutterTbaInfo.instance.getAppVersion(),
    };
    'queryBody=$queryBody'.log();
    return Uri(queryParameters: queryBody).query;
  }

  Future<Map<String, dynamic>> baseBody() async {
    Map<String, dynamic> baseBody = {};

    Map<String, dynamic> apical = {
      "risen": await FlutterTbaInfo.instance.getBundleId(),
      "shrank": await FlutterTbaInfo.instance.getLogId(),
      "palomar": await FlutterTbaInfo.instance.getDeviceModel(),
      'guffaw' : await FlutterTbaInfo.instance.getOperator(),
    };
    baseBody['apical'] = apical;

    Map<String, dynamic> stuck = {
      "toluene": 'soon',
      'species' : await FlutterTbaInfo.instance.getAppVersion(),
      'qs' : DateTime.now().millisecondsSinceEpoch,
      "argo": await FlutterTbaInfo.instance.getManufacturer(),
      'ease' : await FlutterTbaInfo.instance.getBrand(),
      'gurgle' : await FlutterTbaInfo.instance.getOsVersion(),
      "codify": await FlutterTbaInfo.instance.getGaid(),
    };
    baseBody['stuck'] = stuck;

    Map<String, dynamic> kimberly = {
      'tonk' : await FlutterTbaInfo.instance.getDistinctId(),
      'helmsman' : await FlutterTbaInfo.instance.getSystemLanguage(),
      'synoptic' : await FlutterTbaInfo.instance.getAndroidId(),
      "susan": await FlutterTbaInfo.instance.getOsCountry(),
    };
    baseBody['kimberly'] = kimberly;
    return baseBody;
  }

}