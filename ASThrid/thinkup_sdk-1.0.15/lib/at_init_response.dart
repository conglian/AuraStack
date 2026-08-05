/*GDPR rating */
enum InitConsentSet {
  initConsentSetUnknown,
  initConsentSetPersonalized,
  initConsentSetNonpersonalized
}

/*User location */
enum InitUserLocation {
  initUserLocationUnknown,
  initUserLocationInEU,
  initUserLocationOutOfEU
}

class ATInitResponse {
  final consentSet;
  final userLocation;
  /// `InitCallName` dismiss payload: `Map` with `infoMsg` / `dismissType`, or legacy `String`.
  final consentDismiss;

  ATInitResponse(this.consentSet, this.userLocation, this.consentDismiss);

  /// Human-readable summary for UI / logs (UMP consent dialog dismiss).
  static String? formatConsentDismiss(dynamic consentDismiss) {
    if (consentDismiss == null) {
      return null;
    }
    if (consentDismiss is Map) {
      final infoMsg = consentDismiss['infoMsg']?.toString() ?? '';
      final dismissType = consentDismiss['dismissType']?.toString() ?? '';
      return 'infoMsg=$infoMsg, dismissType=$dismissType';
    }
    final text = consentDismiss.toString();
    return text.isEmpty ? '(dismissed)' : text;
  }

  String? get consentDismissSummary => formatConsentDismiss(consentDismiss);

  bool get hasConsentDismiss => consentDismiss != null;

  factory ATInitResponse.withMap(Map map) {
    var tempConsentSet;

    var tempUserLocation;

    var tempConsentDismiss;

    if (map.containsKey('location')) {
      if (map['location'] == '1') {
        tempUserLocation = InitUserLocation.initUserLocationInEU;
      } else if (map['location'] == '2') {
        tempUserLocation = InitUserLocation.initUserLocationOutOfEU;
      } else {
        tempUserLocation = InitUserLocation.initUserLocationUnknown;
      }
    } else {
      tempUserLocation = null;
    }

    if (map.containsKey('consentSet')) {
      if (map['consentSet'] == '1') {
        tempConsentSet = InitConsentSet.initConsentSetPersonalized;
      } else if (map['consentSet'] == '2') {
        tempConsentSet = InitConsentSet.initConsentSetNonpersonalized;
      } else {
        tempConsentSet = InitConsentSet.initConsentSetUnknown;
      }
    } else {
      tempConsentSet = null;
    }

    if (map.containsKey('consentDismiss')) {
      tempConsentDismiss = map['consentDismiss'];
    } else {
      tempConsentDismiss = null;
    }

    return ATInitResponse(tempConsentSet, tempUserLocation, tempConsentDismiss);
  }
}
