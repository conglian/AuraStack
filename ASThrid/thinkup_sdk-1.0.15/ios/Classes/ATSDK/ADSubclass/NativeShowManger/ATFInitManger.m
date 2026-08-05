//
//  ATFInitManger.m
//  Pods-Runner
//
//  Created by GUO PENG on 2021/6/26.
//

#import "ATFInitManger.h"
#import "ATFSendSignalManger.h"
#import "ATFCommonTool.h"
#import "ATFConfiguration.h"


//iOS 14
#import <AppTrackingTransparency/AppTrackingTransparency.h>

#define InitCallName  @"InitCallName"
#define UMPCallName  @"showGDPRConsentDialog"

#define DataConsentSetPersonalized  @"ATDataConsentSetPersonalized"
#define DataConsentSetNonpersonalized  @"ATDataConsentSetNonpersonalized"
#define DataConsentSetUnknown  @"ATDataConsentSetUnknown"


#pragma mark - setAdSourcePrivacyPolicy JSON keys / helpers

static NSString * const kATPolicyNetworkFirmIds = @"networkFirmIds";
static NSString * const kATPolicyAgreePrivacyStrategy = @"agreePrivacyStrategy";
static NSString * const kATPolicyCanUseAppList = @"isCanUseAppList";
static NSString * const kATPolicyCanUseGeneralData = @"isCanUseGeneralData";
static NSString * const kATPolicyCanUseWifiState = @"isCanUseWifiState";
static NSString * const kATPolicyCanUseMacAddress = @"isCanUseMacAddress";
static NSString * const kATPolicyCanUseWriteExternal = @"isCanUseWriteExternal";
static NSString * const kATPolicyCanUseRecordAudio = @"isCanUsePermissionRecordAudio";
static NSString * const kATPolicyCanUseAndroidId = @"isCanUseAndroidId";
static NSString * const kATPolicyCanUseOaid = @"isCanUseOaid";
static NSString * const kATPolicyCanUseLocation = @"isCanUseLocation";
static NSString * const kATPolicyCanUsePhoneState = @"isCanUsePhoneState";
static NSString * const kATPolicyCanUseIp = @"isCanUseIp";
static NSString * const kATPolicyCanPersonalRecommend = @"isCanPersonalRecommend";
static NSString * const kATPolicyCanShake = @"isCanShake";
static NSString * const kATPolicyForbidSensor = @"forbidSensor";
static NSString * const kATPolicyAllowHardDiskSizeKBytes = @"isAllowHardDiskSizeKBytes";
static NSString * const kATPolicyIdAllSwitch = @"idAllSwitch";
static NSString * const kATPolicyCanUseIdfa = @"isCanUseIdfa";
static NSString * const kATPolicyCustomAndroidId = @"customAndroidId";
static NSString * const kATPolicyCustomIMEI = @"customIMEI";
static NSString * const kATPolicyCustomOaid = @"customOaid";
static NSString * const kATPolicyCustomMacAddress = @"customMacAddress";
static NSString * const kATPolicyCustomIp = @"customIp";
static NSString * const kATPolicyCustomIDFA = @"customIDFA";
static NSString * const kATPolicyCustomLocation = @"customLocation";
static NSString * const kATPolicyLatitude = @"latitude";
static NSString * const kATPolicyLongitude = @"longitude";
static NSString * const kATPolicyShakeValue = @"shakeValue";
static NSString * const kATPolicyShakeAcceleration = @"acceleration";
static NSString * const kATPolicyShakeAngle = @"angle";
static NSString * const kATPolicyShakeTime = @"time";
static NSString * const kATPolicyInstalledPackageNames = @"installedPackageNames";

static BOOL at_policyBool(NSDictionary *dict, NSString *key, BOOL defaultValue) {
    if (![dict isKindOfClass:[NSDictionary class]] || key == nil) {
        return defaultValue;
    }
    id value = dict[key];
    if (value == nil) {
        return defaultValue;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)value boolValue];
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSString *s = (NSString *)value;
        if ([s isEqualToString:@"1"]) {
            return YES;
        }
        if ([s isEqualToString:@"0"]) {
            return NO;
        }
        return [s boolValue];
    }
    return defaultValue;
}

static NSString *at_policyString(NSDictionary *dict, NSString *key) {
    if (![dict isKindOfClass:[NSDictionary class]] || key == nil) {
        return @"";
    }
    id value = dict[key];
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString *)value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)value stringValue];
    }
    return @"";
}

static NSArray *at_policyArray(NSDictionary *dict, NSString *key) {
    if (![dict isKindOfClass:[NSDictionary class]] || key == nil) {
        return nil;
    }
    id value = dict[key];
    return [value isKindOfClass:[NSArray class]] ? (NSArray *)value : nil;
}

static NSDictionary *at_policyDictionary(NSDictionary *dict, NSString *key) {
    if (![dict isKindOfClass:[NSDictionary class]] || key == nil) {
        return nil;
    }
    id value = dict[key];
    return [value isKindOfClass:[NSDictionary class]] ? (NSDictionary *)value : nil;
}

@implementation ATFInitManger

/// 日志开关,默认为开
+ (void)setLogEnabled:(BOOL)logEnabled {
    [ATAPI setLogEnabled:logEnabled];
}

/// 设置渠道
+ (void)setChannelStr:(NSString *)channelStr{
    
    if (channelStr == nil) {
        return;
    }
    [ATSDKGlobalSetting sharedManager].channel = channelStr;
}

/// 设置子渠道
+ (void)setSubchannelStr:(NSString *)subchannelStr{
    if (subchannelStr == nil) {
        return;
    }
    [ATSDKGlobalSetting sharedManager].subchannel = subchannelStr;
}

/// 设置自定义规则
+ (void)setCustomDataDic:(NSDictionary *)customDataDic{
    
    if (customDataDic == nil || customDataDic.count == 0) {
        return;
    }
    [ATSDKGlobalSetting sharedManager].customData = customDataDic;
}

/// 设置排除交叉推广APP列表
+ (void)setExludeAppleIdArray:(NSArray *)exludeAppleIdArray{
    
    if (exludeAppleIdArray == nil || exludeAppleIdArray.count == 0) {
        return;
    }
    
    [[ATSDKGlobalSetting sharedManager] setExludeAppleIdArray:exludeAppleIdArray];
}

/// 设置placementid规则
+ (void)setPlacementCustomData:(NSDictionary *)customDataDic placementIDStr:(NSString *)placementIDStr{
    
    if (customDataDic == nil && placementIDStr == nil ) {
        return;
    }
    
    [[ATSDKGlobalSetting sharedManager] setCustomData:customDataDic forPlacementID:placementIDStr];
}

///  获取GDPR等级
+ (NSString *)getGDPRLevel{
    
    ATDataConsentSet consentSet = [ATAPI sharedInstance].dataConsentSet;
    NSString *levelStr;
    if (consentSet == ATDataConsentSetNonpersonalized) {
        levelStr = @"ATDataConsentSetNonpersonalized";
    }
    else if (consentSet == ATDataConsentSetPersonalized){
        levelStr = @"ATDataConsentSetPersonalized";
    }
    else{
        levelStr = @"ATDataConsentSetUnknown";
    }
    return  levelStr;
}

///  获取用户位置
+ (void)getUserLocation{
    
    ATDataConsentSet consentSet = [ATAPI sharedInstance].dataConsentSet;

    NSString *consentSetStr = [NSString stringWithFormat:@"%ld",(long)consentSet];
    
    [[ATAPI sharedInstance] getUserLocationWithCallback:^(ATUserLocation location) {
        if (location == ATUserLocationInEU) {
            ATFLog(@"Get user location----------ATUserLocationInEU");
            [self sendInitUserLocation:@"1" consentSet:consentSetStr];
        }else if (location == ATUserLocationOutOfEU){
            [self sendInitUserLocation:@"2" consentSet:consentSetStr];
            ATFLog(@"Get user location----------ATUserLocationOutOfEU");
        }else{
            [self sendInitUserLocation:@"0" consentSet:consentSetStr];
            ATFLog(@"Get user location----------ATUserLocationUnknown");
        }
    }];    
}

/// 初始化SDK
+ (void)initSDKAppID:(NSString *)appIdStr appKeyStr:(NSString *)appKeyStr requestError:(RequestErrorBlock) requestErrorBlock{
    
    [ATAPI integrationChecking];
    
    if (@available(iOS 14, *)) {
        //iOS 14
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            [self startSDK:appIdStr appKeyStr:appKeyStr requestError:requestErrorBlock];
        }];
    } else {
        [self startSDK:appIdStr appKeyStr:appKeyStr requestError:requestErrorBlock];
    }
}

///  展示GDPR授权界面
+ (void)showGDPRAuth{
    ATFLog(@"'presentDataConsentDialogInViewController:dismissalCallback:' is deprecated: use showGDPRConsentDialogInViewController:dismissalCallback: instead");
}

///  展示GDPR+UMP授权界面（兼容不带appId的旧调用）
+ (void)showGDPRConsentDialog {
    [self showGDPRConsentDialogWithAppId:nil];
}

///  展示GDPR+UMP授权界面（带appId；appId为空时走旧的无参接口，保持原有行为）
+ (void)showGDPRConsentDialogWithAppId:(NSString *)appId {
    UIViewController *rootVC = [ATFCommonTool getRootViewController];
    void (^dismissalCallback)(void) = ^{
        [SendEventManger sendMethod:InitCallName arguments:@{@"consentDismiss":@""} result:^(id result) {}];
    };
    if (appId.length > 0) {
        [[ATAPI sharedInstance] showGDPRConsentDialogWithAppID:appId
                                              inViewController:rootVC
                                             dismissalCallback:dismissalCallback];
    } else {
        [[ATAPI sharedInstance] showGDPRConsentDialogInViewController:rootVC
                                                   dismissalCallback:dismissalCallback];
    }
}

///  展示GDPR+UMP二次确认界面（原生接口的appID可空，appId为空时传nil）
+ (void)showGDPRConsentSecondDialogWithAppId:(NSString *)appId {
    UIViewController *rootVC = [ATFCommonTool getRootViewController];
    NSString *useAppId = (appId.length > 0) ? appId : nil;
    [[ATAPI sharedInstance] showSecondGDPRConsentDialogWithAppID:useAppId
                                                inViewController:rootVC
                                               dismissalCallback:^{
        [SendEventManger sendMethod:InitCallName arguments:@{@"consentDismiss":@""} result:^(id result) {}];
    }];
}

///  检查是否为欧盟流量（带appId；appId为空时走旧的无参接口）
+ (void)checkIsEuTrafficWithAppId:(NSString *)appId completion:(void (^)(BOOL isEuTraffic))completion {
    void (^locationCallback)(ATUserLocation) = ^(ATUserLocation location) {
        BOOL isEuTraffic = (location == ATUserLocationInEU);
        if (completion) {
            completion(isEuTraffic);
        }
    };
    if (appId.length > 0) {
        [[ATAPI sharedInstance] getUserLocationWithAppID:appId callback:locationCallback];
    } else {
        [[ATAPI sharedInstance] getUserLocationWithCallback:locationCallback];
    }
}

///  设置GDPR等级
+ (void)setDataConsentSet:(NSString *)gdprLevel{
    
    if ([gdprLevel isEqualToString:DataConsentSetNonpersonalized]) {
        [[ATAPI sharedInstance] setDataConsentSet:ATDataConsentSetNonpersonalized consentString:@{}];
    }
    else if ([gdprLevel isEqualToString:DataConsentSetPersonalized]){
        
        [[ATAPI sharedInstance] setDataConsentSet:ATDataConsentSetPersonalized consentString:@{}];
    }
}

///  限制这些隐私数据上报
+ (void)setDeniedUploadInfoArray:(NSArray *)infoArray{
    [[ATSDKGlobalSetting sharedManager] setDeniedUploadInfoArray:infoArray];
}

///  设置广告源隐私合规策略（参考 Unity ATUnityManager::setAdSourcePrivacyPolicy，解析 policyJson 并打印）
+ (void)setAdSourcePrivacyPolicy:(NSString *)policyJson {
    ATFLog(@"setAdSourcePrivacyPolicy: policyJson=%@", policyJson);
    if (![policyJson isKindOfClass:[NSString class]] || policyJson.length == 0) {
        return;
    }
    NSDictionary *policyDict = [NSJSONSerialization JSONObjectWithData:[policyJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    if (![policyDict isKindOfClass:[NSDictionary class]]) {
        ATFLog(@"setAdSourcePrivacyPolicy: invalid policyDict");
        return;
    }
    ATFLog(@"setAdSourcePrivacyPolicy: policyDict = %@", policyDict);

    // network filter
    NSArray *networkFirmIds = at_policyArray(policyDict, kATPolicyNetworkFirmIds);

    // permission / privacy switches
    BOOL agreePrivacyStrategy = at_policyBool(policyDict, kATPolicyAgreePrivacyStrategy, YES);
    BOOL isCanUseAppList = at_policyBool(policyDict, kATPolicyCanUseAppList, NO);
    BOOL isCanUseGeneralData = at_policyBool(policyDict, kATPolicyCanUseGeneralData, NO);
    BOOL isCanUseWifiState = at_policyBool(policyDict, kATPolicyCanUseWifiState, NO);
    BOOL isCanUseMacAddress = at_policyBool(policyDict, kATPolicyCanUseMacAddress, NO);
    BOOL isCanUseWriteExternal = at_policyBool(policyDict, kATPolicyCanUseWriteExternal, NO);
    BOOL isCanUsePermissionRecordAudio = at_policyBool(policyDict, kATPolicyCanUseRecordAudio, NO);
    BOOL isCanUseAndroidId = at_policyBool(policyDict, kATPolicyCanUseAndroidId, NO);
    BOOL isCanUseOaid = at_policyBool(policyDict, kATPolicyCanUseOaid, NO);
    BOOL isCanUseLocation = at_policyBool(policyDict, kATPolicyCanUseLocation, NO);
    BOOL isCanUsePhoneState = at_policyBool(policyDict, kATPolicyCanUsePhoneState, NO);
    BOOL isCanUseIp = at_policyBool(policyDict, kATPolicyCanUseIp, NO);
    BOOL isCanPersonalRecommend = at_policyBool(policyDict, kATPolicyCanPersonalRecommend, NO);
    BOOL isCanShake = at_policyBool(policyDict, kATPolicyCanShake, YES);
    BOOL forbidSensor = at_policyBool(policyDict, kATPolicyForbidSensor, NO);
    BOOL isAllowHardDiskSizeKBytes = at_policyBool(policyDict, kATPolicyAllowHardDiskSizeKBytes, NO);
    BOOL idAllSwitch = at_policyBool(policyDict, kATPolicyIdAllSwitch, NO);
    BOOL isCanUseIdfa = at_policyBool(policyDict, kATPolicyCanUseIdfa, NO);

    // developer-supplied device identifiers (when collection is disabled)
    NSString *customAndroidId = at_policyString(policyDict, kATPolicyCustomAndroidId);
    NSString *customIMEI = at_policyString(policyDict, kATPolicyCustomIMEI);
    NSString *customOaid = at_policyString(policyDict, kATPolicyCustomOaid);
    NSString *customMacAddress = at_policyString(policyDict, kATPolicyCustomMacAddress);
    NSString *customIp = at_policyString(policyDict, kATPolicyCustomIp);
    NSString *customIDFA = at_policyString(policyDict, kATPolicyCustomIDFA);

    // customLocation: { "latitude": double, "longitude": double }
    NSDictionary *customLocation = at_policyDictionary(policyDict, kATPolicyCustomLocation);
    double customLatitude = 0;
    double customLongitude = 0;
    if (customLocation != nil) {
        customLatitude = [customLocation[kATPolicyLatitude] doubleValue];
        customLongitude = [customLocation[kATPolicyLongitude] doubleValue];
    }

    // shakeValue: { "acceleration": double, "angle": double, "time": int }
    NSDictionary *shakeValue = at_policyDictionary(policyDict, kATPolicyShakeValue);
    double shakeAcceleration = 0;
    double shakeAngle = 0;
    NSInteger shakeTime = 0;
    if (shakeValue != nil) {
        shakeAcceleration = [shakeValue[kATPolicyShakeAcceleration] doubleValue];
        shakeAngle = [shakeValue[kATPolicyShakeAngle] doubleValue];
        shakeTime = [shakeValue[kATPolicyShakeTime] integerValue];
    }

    NSArray *installedPackageNames = at_policyArray(policyDict, kATPolicyInstalledPackageNames);

    if (!isCanShake || forbidSensor) {
        [[ATSDKGlobalSetting sharedManager] setNetworkSensorType:ATNetworkSensorTypeForbidAll networkSensorList:nil];
    }

    if (customLongitude != 0) {
        [[ATSDKGlobalSetting sharedManager] setLocationLongitude:customLongitude dimension:customLatitude];
    }


    ATFLog(@"setAdSourcePrivacyPolicy parsed networkFirmIds=%@ agreePrivacyStrategy=%d isCanUseAppList=%d isCanUseGeneralData=%d isCanUseWifiState=%d isCanUseMacAddress=%d isCanUseWriteExternal=%d isCanUsePermissionRecordAudio=%d isCanUseAndroidId=%d isCanUseOaid=%d isCanUseLocation=%d isCanUsePhoneState=%d isCanUseIp=%d isCanPersonalRecommend=%d isCanShake=%d forbidSensor=%d isAllowHardDiskSizeKBytes=%d idAllSwitch=%d isCanUseIdfa=%d customAndroidId=%@ customIMEI=%@ customOaid=%@ customMacAddress=%@ customIp=%@ customIDFA=%@ customLatitude=%f customLongitude=%f shakeAcceleration=%f shakeAngle=%f shakeTime=%ld installedPackageNames=%@",
          networkFirmIds, agreePrivacyStrategy, isCanUseAppList, isCanUseGeneralData, isCanUseWifiState, isCanUseMacAddress, isCanUseWriteExternal, isCanUsePermissionRecordAudio, isCanUseAndroidId, isCanUseOaid, isCanUseLocation, isCanUsePhoneState, isCanUseIp, isCanPersonalRecommend, isCanShake, forbidSensor, isAllowHardDiskSizeKBytes, idAllSwitch, isCanUseIdfa, customAndroidId, customIMEI, customOaid, customMacAddress, customIp, customIDFA, customLatitude, customLongitude, shakeAcceleration, shakeAngle, (long)shakeTime, installedPackageNames);

    /// TODO: 将解析后的策略应用到各已接入的广告源 CustomController（iOS adapters）。
    #pragma unused(networkFirmIds, agreePrivacyStrategy, isCanUseAppList, isCanUseGeneralData, isCanUseWifiState, isCanUseMacAddress, isCanUseWriteExternal, isCanUsePermissionRecordAudio, isCanUseAndroidId, isCanUseOaid, isCanUseLocation, isCanUsePhoneState, isCanUseIp, isCanPersonalRecommend, isCanShake, forbidSensor, isAllowHardDiskSizeKBytes, idAllSwitch, isCanUseIdfa, customAndroidId, customIMEI, customOaid, customMacAddress, customIp, customIDFA, customLatitude, customLongitude, shakeAcceleration, shakeAngle, shakeTime, installedPackageNames)
}

/// 显示DebugUI
+ (void)showDebuggerUI:(NSString *)debugKey {
    // 此处用反射方式调用，发布时可以不用导入AnyThinkDebuggerUISDK库
    ATFLog(@"ATFInitManger::showDebuggerUI with key: %@", debugKey);
    NSString *classStr = @"ATDebuggerAPI";
    Class debuggerAPIClass = NSClassFromString(classStr);
    if (!debuggerAPIClass) {
        ATFLog(@"ATFInitManger::showDebuggerUI- NO %@", classStr);
        return;
    } else {
        id debuger = [debuggerAPIClass performSelector:@selector(sharedInstance)];
        NSString *fuctionStr = @"showDebuggerInViewController:showType:debugkey:";
        SEL sel = NSSelectorFromString(fuctionStr);
        if (!debuger || ![debuger respondsToSelector:sel]) {
            ATFLog(@"ATFInitManger::showDebuggerUI- NO %@", fuctionStr);
            return;
        } else {
            UIViewController * targetVC = [ATFCommonTool getRootViewController];
            NSInteger showType = 1;
            // 使用 NSInvocation 来调用带有多个参数的方法
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[debuger methodSignatureForSelector:sel]];
            [invocation setTarget:debuger];
            [invocation setSelector:sel];
            
            [invocation setArgument:&targetVC atIndex:2];
            [invocation setArgument:&showType atIndex:3];
            [invocation setArgument:&debugKey atIndex:4];

            [invocation invoke];
        }
    }
}

#pragma mark - private
+ (void)sendInitUserLocation:(NSString *)location consentSet:(NSString *)consentSetStr{
    
    [SendEventManger sendMethod: InitCallName arguments:@{@"location":location,@"consentSet":consentSetStr} result:^(id reslut) {}];
}

+ (void)startSDK:(NSString *)appIdStr appKeyStr:(NSString *)appKeyStr
    requestError: (RequestErrorBlock) requestErrorBlock{

    NSError *error;

    [[ATAPI sharedInstance] startWithAppID:appIdStr appKey:appKeyStr error:&error];
    requestErrorBlock(error);
}

+ (void)setPresetPlacementConfigPath:(NSString *)pathStr {
    ATFLog(@"setPresetPlacementConfigPath: pathStr=%@", pathStr);
    if (pathStr.length == 0) {
        return;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:pathStr ofType:@""];
    if (path.length == 0) {
        path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Data/Raw/%@", pathStr] ofType:@""];
    }
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    if (bundle == nil) {
        ATFLog(@"setPresetPlacementConfigPath - bundle is nil for pathStr=%@", pathStr);
        return;
    }
    [[ATSDKGlobalSetting sharedManager] setPresetPlacementConfigPathBundle:bundle];
}

///  设置共享广告位配置（参考 Unity ATUnityManager::setSharedPlacementConfig）
+ (void)setSharedPlacementConfig:(NSDictionary *)configDict {
    ATFLog(@"setSharedPlacementConfig: configDict=%@", configDict);
    if (![configDict isKindOfClass:[NSDictionary class]] || configDict.count == 0) {
        return;
    }

    NSDictionary *splashLoadExtra = [configDict[@"splashLocalExtra"] isKindOfClass:[NSDictionary class]] ? configDict[@"splashLocalExtra"] : @{};
    NSDictionary *interstitialLoadExtra = [configDict[@"interstitialLocalExtra"] isKindOfClass:[NSDictionary class]] ? configDict[@"interstitialLocalExtra"] : @{};
    NSDictionary *rewardedVideoLoadExtra = [configDict[@"rewardVideoLocalExtra"] isKindOfClass:[NSDictionary class]] ? configDict[@"rewardVideoLocalExtra"] : @{};
    NSDictionary *bannerLoadExtra = [configDict[@"bannerLocalExtra"] isKindOfClass:[NSDictionary class]] ? configDict[@"bannerLocalExtra"] : @{};
    NSDictionary *nativeLoadExtra = [configDict[@"nativeLocalExtra"] isKindOfClass:[NSDictionary class]] ? configDict[@"nativeLocalExtra"] : @{};

    ATSharePlacementConfig *sharePlacementConfig = [[ATSharePlacementConfig alloc] init];
    sharePlacementConfig.splashLoadExtra = splashLoadExtra;
    sharePlacementConfig.interstitialLoadExtra = interstitialLoadExtra;
    sharePlacementConfig.rewardedVideoLoadExtra = rewardedVideoLoadExtra;
    sharePlacementConfig.bannerLoadExtra = bannerLoadExtra;
    sharePlacementConfig.nativeLoadExtra = nativeLoadExtra;
    [ATSDKGlobalSetting sharedManager].sharePlacementConfig = sharePlacementConfig;
}

#pragma mark - Waterfall filter (参考 Unity ATUnityManager)

///  注册瀑布流过滤器（filterJson 根键 groups；组内 AND、组间 OR）
+ (void)putFilter:(NSString *)placementId filterJson:(NSString *)filterJson {
    ATFLog(@"putFilter: placementId=%@ filterJson=%@", placementId, filterJson);
    if (placementId.length == 0 || filterJson.length == 0) {
        return;
    }
    NSDictionary *filterDict = [NSJSONSerialization JSONObjectWithData:[filterJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    if (![filterDict isKindOfClass:[NSDictionary class]]) {
        ATFLog(@"putFilter: invalid filterDict");
        return;
    }
    NSArray *groups = [filterDict[@"groups"] isKindOfClass:[NSArray class]] ? filterDict[@"groups"] : @[];

    ATAdCustomFilter *filter = [[ATAdCustomFilter alloc] init];
    [groups enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSDictionary class]]) { return; }

        NSMutableArray *networkFirmIDs = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *biddingTypes = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *networkPlacementIds = [NSMutableArray arrayWithCapacity:0];

        NSArray *networkId = [obj[@"networkId"] isKindOfClass:[NSArray class]] ? obj[@"networkId"] : @[];
        NSArray *biddingType = [obj[@"biddingType"] isKindOfClass:[NSArray class]] ? obj[@"biddingType"] : @[];
        NSArray *networkPlacementId = [obj[@"networkPlacementId"] isKindOfClass:[NSArray class]] ? obj[@"networkPlacementId"] : @[];
        [networkPlacementIds addObjectsFromArray:networkPlacementId];

        // e_cpm 的价格/币种用 at_policyString 兼容 NSNumber/NSString（Flutter 传数字时为 NSNumber）
        NSDictionary *e_cpm = [obj[@"e_cpm"] isKindOfClass:[NSDictionary class]] ? obj[@"e_cpm"] : @{};
        NSString *currency = at_policyString(e_cpm, @"currency");
        NSString *moreThanPrice = at_policyString(e_cpm, @"moreThanPrice");
        NSString *lessThanPrice = at_policyString(e_cpm, @"lessThanPrice");
        ATBiddingCurrencyType currencyType = ATBiddingCurrencyTypeCNYCents;
        if ([[currency lowercaseString] containsString:@"cny"]) {
            currencyType = ATBiddingCurrencyTypeCNY;
        } else if ([[currency lowercaseString] containsString:@"us"]) {
            currencyType = ATBiddingCurrencyTypeUS;
        }

        if ([biddingType containsObject:@"NORMAL"] || [biddingType containsObject:@"normal"]) {
            [biddingTypes addObject:@(ATAdCustomFilterBiddingModeNormal)];
        }
        if ([biddingType containsObject:@"s2s"] || [biddingType containsObject:@"S2S"]) {
            [biddingTypes addObject:@(ATAdCustomFilterBiddingModeS2S)];
        }
        if ([biddingType containsObject:@"c2s"] || [biddingType containsObject:@"C2S"]) {
            [biddingTypes addObject:@(ATAdCustomFilterBiddingModeC2S)];
        }

        if (moreThanPrice.length > 0) {
            ATAdCustomFilterEcpmItem *ecpmItem = [[ATAdCustomFilterEcpmItem alloc] initWithMoreThenPrice:moreThanPrice lessThenPrice:lessThanPrice currency:currencyType];
            filter.ecpmItem(ecpmItem);
        }

        [networkId enumerateObjectsUsingBlock:^(id  _Nonnull nObj, NSUInteger nIdx, BOOL * _Nonnull nStop) {
            [networkFirmIDs addObject:@([nObj integerValue])];
        }];

        // 过滤 广告源
        if (networkFirmIDs.count > 0) {
            filter.networkFirmIDs(networkFirmIDs);
        }
        if (biddingTypes.count > 0) {
            filter.biddingModes(biddingTypes);
        }
        if (networkPlacementIds.count > 0) {
            filter.networkSlotIDs(networkPlacementIds);
        }
        if (idx != groups.count - 1) {
            filter.orFilter();
        }
    }];
    // 设置到全局
    [[ATSDKGlobalSetting sharedManager] addFilter:filter forPlacementID:placementId];
}

///  移除指定广告位的过滤器
+ (void)removeFilterWithPlacementId:(NSString *)placementId {
    ATFLog(@"removeFilterWithPlacementId: placementId=%@", placementId);
    if (placementId.length > 0) {
        [[ATSDKGlobalSetting sharedManager] removeFilterWithPlacementIDs:@[placementId]];
    }
}

///  移除所有过滤器
+ (void)removeFilters {
    ATFLog(@"removeFilters");
    [[ATSDKGlobalSetting sharedManager] removeAllFilters];
}

+ (NSString*)getSDKVersionName {
    NSString *version = [[ATAPI sharedInstance] version];
    ATFLog(@"getSDKVersionName version=%@", version);
    return version;
}


@end
