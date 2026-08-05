import 'package:thinkup_sdk/at_base_response.dart';

enum ATCommonAdStatus {
  adShowRevenuePaid,
  unknown,
}

/// `CommonADCall` payload; mainly impression revenue (`adShowRevenueCallbackKey` → [ATCommonAdStatus.adShowRevenuePaid]).
class ATCommonAdResponse extends BaseResponse {
  final ATCommonAdStatus status;
  final Map extraMap;

  ATCommonAdResponse(
    this.status,
    this.extraMap,
    String errStr,
    String placementID,
  ) : super(errStr, placementID, null);

  factory ATCommonAdResponse.withMap(Map map) {
    final requestMessage = map['requestMessage'] ?? "";
    final placementID = map['placementID'] ?? "";
    final callbackName = map['callbackName'];

    final extra = map.containsKey('extraDic')
        ? (map['extraDic'] as Map)
        : {'message': 'No additional information'};

    ATCommonAdStatus status;
    if (callbackName == 'adShowRevenueCallbackKey') {
      status = ATCommonAdStatus.adShowRevenuePaid;
    } else {
      status = ATCommonAdStatus.unknown;
    }
    print('adShowRevenueCallback: $status, $extra, $requestMessage, $placementID');
    return ATCommonAdResponse(status, extra, requestMessage, placementID);
  }
}
