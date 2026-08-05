import 'package:json_annotation/json_annotation.dart';

part 'ASAdModel.g.dart';

@JsonSerializable()
class ASAdModel {
  late int xjgrpkac = 0;
  late int wgcmmsne = 0;
  late bool olstk_switch = false;
  late List<ASAdModellist> olstk_int = [];
  late List<ASAdModellist> olstk_rv = [];
  ASAdModel();

  // 工厂构造函数，用于反序列化
  factory ASAdModel.fromJson(Map<String, dynamic> json) => _$ASAdModelFromJson(json);

  // 序列化方法
  Map<String, dynamic> toJson() => _$ASAdModelToJson(this);
}

@JsonSerializable()
class ASAdModellist {
  // id
  late String ayyibgmi = "";
  // type
  late String ckovkxxo = "";
  // ad_type
  late String ichurcix = "";
  //
  late int tavomvmz = 0;
  //
  late double? ecpm = 0;

  ASAdModellist();

  // 工厂构造函数，用于反序列化
  factory ASAdModellist.fromJson(Map<String, dynamic> json) => _$ASAdModellistFromJson(json);

  // 序列化方法
  Map<String, dynamic> toJson() => _$ASAdModellistToJson(this);
}