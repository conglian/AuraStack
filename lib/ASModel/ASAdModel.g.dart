// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ASAdModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ASAdModel _$ASAdModelFromJson(Map<String, dynamic> json) => ASAdModel()
  ..xjgrpkac = (json['xjgrpkac'] as num).toInt()
  ..wgcmmsne = (json['wgcmmsne'] as num).toInt()
  ..olstk_switch = json['olstk_switch'] as bool
  ..olstk_int = (json['olstk_int'] as List<dynamic>)
      .map((e) => ASAdModellist.fromJson(e as Map<String, dynamic>))
      .toList()
  ..olstk_rv = (json['olstk_rv'] as List<dynamic>)
      .map((e) => ASAdModellist.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$ASAdModelToJson(ASAdModel instance) => <String, dynamic>{
      'xjgrpkac': instance.xjgrpkac,
      'wgcmmsne': instance.wgcmmsne,
      'olstk_switch': instance.olstk_switch,
      'olstk_int': instance.olstk_int,
      'olstk_rv': instance.olstk_rv,
    };

ASAdModellist _$ASAdModellistFromJson(Map<String, dynamic> json) =>
    ASAdModellist()
      ..ayyibgmi = json['ayyibgmi'] as String
      ..ckovkxxo = json['ckovkxxo'] as String
      ..ichurcix = json['ichurcix'] as String
      ..tavomvmz = (json['tavomvmz'] as num).toInt()
      ..ecpm = (json['ecpm'] as num?)?.toDouble();

Map<String, dynamic> _$ASAdModellistToJson(ASAdModellist instance) =>
    <String, dynamic>{
      'ayyibgmi': instance.ayyibgmi,
      'ckovkxxo': instance.ckovkxxo,
      'ichurcix': instance.ichurcix,
      'tavomvmz': instance.tavomvmz,
      'ecpm': instance.ecpm,
    };
