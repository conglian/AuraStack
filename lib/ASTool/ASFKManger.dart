import 'dart:convert';
import 'dart:developer';
import 'package:AuraStackFK/AuraStackFK.dart';
import 'package:aurastack/ASTool/ASLogger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tba_info/flutter_tba_info.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../ASModel/ASFKModel.dart';
import 'ASTBAEventTool.dart';
import 'as_LocalProvider.dart';
import 'as_extension_help.dart';

class ASFKManger {
  static final ASFKManger _instance = ASFKManger._internal();

  factory ASFKManger() {
    return _instance;
  }

  ASFKManger._internal();

  ASFkModel fkModel = ASFkModel();

  Future<void> initFKJson() async {
    if (fkModel.ui.device == 0) {
      String jsonString = await rootBundle.loadString("c153_risk_control".jsons());
      asLog.info('risk_control=$jsonString');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      fkModel = ASFkModel.fromJson(jsonMap);
    }
  }
  
  Future<void> initFK() async {
    as_checkRoot();
    as_checkVpn();
    as_checkSim();
    as_checkSimulator();
    as_checkDeveloper();
    as_checkStore();
    as_checkIP();
    as_checkNum();
  }

  // 是否需要打开风控
  Future<bool> as_checkAllStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String types = 'number';
    // behavior
    // bool behavior = await as_checkUser();
    // asLog.info('behavior=$behavior');
    // if (behavior){
    //   types = 'behavior';
    // }
    // number
    bool number = prefs.getBool('as_fk_number_status') ?? false;
    asLog.info('number=$number');
    if (number){
      types = 'number';
    }
    // device
    bool device = prefs.getBool('as_fk_decvice_status') ?? false;
    asLog.info('device=$device');
    if (device){
      types = 'device';
    }
    if (number || device){
      as_event_fire(
        "nskdh_fk_head_off",
        {
          "type": types,
        },
      );
      return true;
    }
    return false;
  }

  // 获取用户异常行为状态
  Future<bool> as_checkUser() async {
    // 开关未打开
    // if(fkModel.ui.behavior == 0){
    //   return false;
    // }
    final prefs = await SharedPreferences.getInstance();
    // 两次rv间隔时间小于30s，3次以上
    if(prefs.getBool('as_fk_ad_short_show') == true){
      return true;
    }
    // RV 从播放到收到关闭回调时间小于20s，3次以上
    if(prefs.getBool('as_fk_ad_short_close') == true){
      return true;
    }
    // // //现金金额达到提现门槛,视频数少于3次
    // if((prefs.getInt('as_ad_all_number') ?? 0) < fkModel.behavior.wrong_deem_ad_less && (prefs.getInt('as_dolas_old_number') ?? 0) >= 1000){
    //   as_event_fire('risk_chance', {'risk_from' : 'wrong_deem_ad_less'});
    //   return true;
    // }
    // // 用户观看90次RV(不包含插屏)，未到提现门槛
    // if((prefs.getInt('as_ad_reawrd_all_number') ?? 0) >= fkModel.behavior.wrong_deem_ad_more && (prefs.getInt('as_dolas_old_number') ?? 0) < 1000){
    //   as_event_fire('risk_chance', {'risk_from' : 'wrong_deem_ad_more'});
    //   return true;
    // }
    return false;
  }

  // 数字联盟
  as_checkNum()async{
    var numberUnitID = await AuraStackFK.instance.as_getNumberUnitID();
    var url = Uri.parse('https://sg-ddi.shuzilm.cn/q');
    try {
      var response = await http.post(
        url,
        headers: eventHeader,
        body: jsonEncode({"protocol":2,"pkg":await FlutterTbaInfo.instance.getBundleId(),"did":numberUnitID}),
      );
      asLog.success("upload event [Number] success ${response.body}");

      try{
        //{"protocol":2,"ver":"1.0.1","err":0,"device_type":0,"normal_times":0,
        // "duplicate_times":0,"update_times":1,"recall_times":0}
        var json = jsonDecode(response.body);
        if(json["err"] == 0 && json["device_type"] != 0 && fkModel.ui.number == 1){
          as_event_fire('risk_chance', {'risk_from' : 'number'});
          await ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_number_statusName,true);
        }else{
          await ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_number_statusName,false);
        }
      }catch(e){
        await ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_number_statusName,false);
      }

    } catch (e) {
      await ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_number_statusName,false);
      asLog.error('upload event [Number] faild');
    }

  }

  Map<String, String> eventHeader = {
    'Content-Type': 'application/json',
  };

  // 设备 Ip
  as_checkIP()async{

    var url = Uri.parse('https://ip-prod.lccstackauraascratch.com/api/crabbit');
    try {
      var response = await http.post(
        url,
        headers: eventHeader,
        body: jsonEncode({
          "aduck" : await FlutterTbaInfo.instance.getAndroidId(),
        }),
      );
      asLog.success("upload event [IP] success ${response.body}");
      //{"code":200,"msg":"Success","data":{"blion":false}}
      var result = BoomUniqueStringUtil.decrypt(response.body, 61);
      asLog.success("upload event [IP] success ${result}");
      try{
        var bfrog = jsonDecode(result)["data"]["bfrog"];
        if(bfrog && fkModel.device.contains('ip') && fkModel.ui.device == 1){
          as_event_fire('risk_chance', {'risk_from' : 'ip'});
          await ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_ip_statusName,true);
        }
      }catch(e){
        await ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_ip_statusName,false);
      }

    } catch (e) {
      await ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_ip_statusName,false);
      asLog.error('upload event [IP] faild');
    }
  }

  as_add_tabsession_custom() async {

    bool root = await as_checkRoot();
    bool vpn = await as_checkVpn();
    bool sim = await as_checkSim();
    bool simulator = await as_checkSimulator();
    bool developer = await as_checkDeveloper();
    bool googleplay = await as_checkStore();
    Map<String, dynamic> customer = {
      'root' : root ? 1 : 0,
      'vpn' : vpn ? 1 : 0,
      'sim' : sim ? 1 : 0,
      'simulator' : simulator ? 1 : 0,
      'developer' : developer ? 1 : 0,
      'googleplay' : googleplay ? 1 : 0,
    };
    as_event_fire('session_custom', customer);

  }

  Future<bool> as_checkRoot() async {
    var result = await AuraStackFK.instance.as_root();
    if(fkModel.ui.device == 0){
      return false;
    }
    if(result && fkModel.device.contains('root')){
      as_event_fire('risk_chance', {'risk_from' : 'root'});
      ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_decvice_statusName,true);
      return true;
    }
    return false;
  }

  Future<bool> as_checkVpn() async {
    var result = await AuraStackFK.instance.as_vpn();
    if(fkModel.ui.device == 0){
      return false;
    }
    if(result && fkModel.device.contains('vpn')){
      as_event_fire('risk_chance', {'risk_from' : 'vpn'});
      ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_decvice_statusName,true);
      return true;
    }
    return false;
  }

  Future<bool> as_checkSim() async {
    var result = await AuraStackFK.instance.as_sim();
    if(fkModel.ui.device == 0){
      return false;
    }
    if(!result && fkModel.device.contains('sim')){
      as_event_fire('risk_chance', {'risk_from' : 'sim'});
      ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_decvice_statusName,true);
      return true;
    }
    return false;
  }

  Future<bool> as_checkSimulator() async {
    var result = await AuraStackFK.instance.as_simulator();
    if(fkModel.ui.device == 0){
      return false;
    }
    if(result && fkModel.device.contains('simulator')){
      as_event_fire('risk_chance', {'risk_from' : 'simulator'});
      ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_decvice_statusName,true);
      return true;
    }
    return false;
  }

  Future<bool> as_checkDeveloper() async {
    var result = await AuraStackFK.instance.as_developer();
    if(fkModel.ui.device == 0){
      return false;
    }
    if(result && fkModel.device.contains('developer')){
      as_event_fire('risk_chance', {'risk_from' : 'developer'});
      ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_decvice_statusName,true);
      return true;
    }
    return false;
  }

  Future<bool> as_checkStore() async {
    var result = await AuraStackFK.instance.as_store();
    if(fkModel.ui.device == 0){
      return false;
    }
    if(!result && fkModel.device.contains('googleplay')){
      as_event_fire('risk_chance', {'risk_from' : 'googleplay'});
      ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_decvice_statusName,true);
      return true;
    }
    return false;
  }
}