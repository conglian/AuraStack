// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ASFKModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ASFkModel _$ASFkModelFromJson(Map<String, dynamic> json) => ASFkModel(
      ui: json['ui'] == null
          ? const ASUIModel()
          : ASUIModel.fromJson(json['ui'] as Map<String, dynamic>),
      device: (json['device'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$ASFkModelToJson(ASFkModel instance) => <String, dynamic>{
      'ui': instance.ui.toJson(),
      'device': instance.device,
    };

ASUIModel _$ASUIModelFromJson(Map<String, dynamic> json) => ASUIModel(
      number: (json['number'] as num?)?.toInt() ?? 0,
      device: (json['device'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ASUIModelToJson(ASUIModel instance) => <String, dynamic>{
      'number': instance.number,
      'device': instance.device,
    };
