import 'package:json_annotation/json_annotation.dart';

part 'ASFKModel.g.dart';

@JsonSerializable(explicitToJson: true)
class ASFkModel {
  final ASUIModel ui;
  final List<String> device;

  const ASFkModel({
    this.ui = const ASUIModel(),
    this.device = const <String>[],
  });

  factory ASFkModel.fromJson(Map<String, dynamic> json) =>
      _$ASFkModelFromJson(json);

  Map<String, dynamic> toJson() => _$ASFkModelToJson(this);
}

@JsonSerializable()
class ASUIModel {
  final int number;
  final int device;

  const ASUIModel({
    this.number = 0,
    this.device = 0,
  });

  factory ASUIModel.fromJson(Map<String, dynamic> json) =>
      _$ASUIModelFromJson(json);

  Map<String, dynamic> toJson() => _$ASUIModelToJson(this);
}
