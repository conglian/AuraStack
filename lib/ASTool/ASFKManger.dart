import 'dart:convert';

import 'package:flutter/services.dart';

import '../ASModel/ASFKModel.dart';
import 'ASLogger.dart';

class ASFKManger {
  ASFKManger._internal();

  static final ASFKManger _instance = ASFKManger._internal();

  factory ASFKManger() => _instance;

  static ASFKManger get instance => _instance;

  static const String _localAssetPath = 'assets/File/c153_risk_control.json';

  ASFkModel fkModel = const ASFkModel();

  Future<ASFkModel> initFKJson() => loadLocalData();

  Future<ASFkModel> loadLocalData() async {
    try {
      final jsonString = await rootBundle.loadString(_localAssetPath);
      final jsonObject = jsonDecode(jsonString);

      if (jsonObject is! Map<String, dynamic>) {
        throw const FormatException(
          'c153_risk_control.json must contain a JSON object.',
        );
      }

      fkModel = ASFkModel.fromJson(jsonObject);
      asLog.success(
        'Local risk-control configuration loaded: ${fkModel.toJson()}',
        tag: 'ASFKManger',
      );
      return fkModel;
    } catch (error, stackTrace) {
      asLog.error(
        'Failed to load $_localAssetPath',
        tag: 'ASFKManger',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
