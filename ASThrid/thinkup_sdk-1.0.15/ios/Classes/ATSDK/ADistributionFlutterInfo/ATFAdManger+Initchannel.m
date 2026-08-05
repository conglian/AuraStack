//
//  ATFAdManger+Initchannel.m
//  Pods-Runner
//
//  Created by GUO PENG on 2021/6/26.
//

#import "ATFAdManger+Initchannel.h"
#import "ATFInitManger.h"
#import "ATFCoconfigurManger.h"
#import "ATFConfiguration.h"
#import "ATFDisposeDataTool.h"

@implementation ATFAdManger (Initchannel)

- (void)initFlutterInformation:(FlutterMethodCall*)call result:(FlutterResult)result{

    // 设置日志开关
    if ([SetLogEnabled isEqualToString:call.method]) {
        [ATFInitManger setLogEnabled:ATFCoconfigurMode.isLogEnabled];
        result(@(ATFCoconfigurMode.isLogEnabled));
    }
    // 设置渠道
    else if ([SetChannelStr isEqualToString:call.method]) {
        [ATFInitManger setChannelStr:ATFCoconfigurMode.channelStr];
        result(ATFCoconfigurMode.channelStr);
    }
    // 设置子渠道
    else if ([SetSubchannelStr isEqualToString:call.method]) {
        [ATFInitManger setSubchannelStr:ATFCoconfigurMode.subchannelStr];
        result(ATFCoconfigurMode.subchannelStr);
    }
    
    // 设置自定义规则
    else if ([SetCustomDataDic isEqualToString:call.method]) {
        [ATFInitManger setCustomDataDic:ATFCoconfigurMode.customDataDic];
        result(ATFCoconfigurMode.customDataDic);
    }

    // 设置排除交叉推广APP列表
    else if ([SetExludeBundleIDArray isEqualToString:call.method]) {
        [ATFInitManger setExludeAppleIdArray:ATFCoconfigurMode.exludeBundleIDArray];
        result(ATFCoconfigurMode.exludeBundleIDArray);
    }
    
    // 设置placementid规则
    else if ([SetPlacementCustomData isEqualToString:call.method]) {
        [ATFInitManger setPlacementCustomData:ATFCoconfigurMode.placementCustomDataDic placementIDStr:ATFCoconfigurMode.placementIDStr];
        result(ATFCoconfigurMode.placementIDStr);
    }
    
    // 获取GDPR等级
    else if ([GetGDPRLevel isEqualToString:call.method]) {
        NSString *level = [ATFInitManger getGDPRLevel];
        result(level);
    }
    
    // 获取用户位置
    else if ([GetUserLocation isEqualToString:call.method]) {
        [ATFInitManger getUserLocation];
        result(@"succeed");
    }
    // 设置GDPR等级
    else if ([SetDataConsentSet isEqualToString:call.method]) {
        [ATFInitManger setDataConsentSet:ATFCoconfigurMode.gdprLevel];
        result(@"succeed");
    }
    // 限制隐私数据上报
    else if ([SetDeniedUploadInfoArray isEqualToString:call.method]) {
        [ATFInitManger setDeniedUploadInfoArray:ATFCoconfigurMode.deniedUploadInfoArray];
        result(ATFCoconfigurMode.deniedUploadInfoArray ?: @[]);
    }
    // 初始化SDK
    else if ([InitSDK isEqualToString:call.method]) {
        [self starToponSDK:call result:result];
    }
    // 设置预置策略路径
    else if ([SetPresetPlacementConfigPath isEqualToString:call.method]) {
        NSString *pathStr = call.arguments[@"pathStr"];
        [ATFInitManger setPresetPlacementConfigPath:pathStr];
        result(@"succeed");
    }
    // 显示GDPR旧
    else if ([ShowGDPRAuth isEqualToString:call.method]) {
        [ATFInitManger showGDPRAuth];
        result(@"succeed");
    }
    // 显示GDPR新（兼容带/不带 appId）
    else if ([ShowGDPRConsentDialog isEqualToString:call.method]) {
        NSString *appId = [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments[@"appId"] : nil;
        [ATFInitManger showGDPRConsentDialogWithAppId:appId];
        result(@{
            @"infoMsg": @"",
            @"dismissType": @"104",
        });
        ATFLog(@"showGDPRConsentDialog: %@", appId);
    }
    // 显示GDPR二次确认界面（兼容带/不带 appId）
    else if ([ShowGDPRConsentSecondDialog isEqualToString:call.method]) {
        NSString *appId = [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments[@"appId"] : nil;
        [ATFInitManger showGDPRConsentSecondDialogWithAppId:appId];
        result(@{
            @"infoMsg": @"",
            @"dismissType": @"104",
        });
        ATFLog(@"ShowGDPRConsentSecondDialog: %@", appId);
    }
    // 检查是否为欧盟流量（异步回调，兼容带/不带 appId）
    else if ([CheckIsEuTraffic isEqualToString:call.method]) {
        NSString *appId = [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments[@"appId"] : nil;
        [ATFInitManger checkIsEuTrafficWithAppId:appId completion:^(BOOL isEuTraffic) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(@(isEuTraffic));
            });
        }];
        ATFLog(@"CheckIsEuTraffic: %@", appId);
    }
    // Stub: SDK version not wired on iOS yet.
    else if ([GetSDKVersionName isEqualToString:call.method]) {
        NSString *version = [ATFInitManger getSDKVersionName];
        result(version);
        ATFLog(@"GetSDKVersionName: %@", version);
    }
    // Stub: native start not wired on iOS yet.
    else if ([StartSDK isEqualToString:call.method]) {
        result(@"succeed");
    }
    // 设置广告源隐私合规策略（policyJson）
    else if ([SetAdSourcePrivacyPolicy isEqualToString:call.method]) {
        NSString *policyJson = [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments[@"policyJson"] : nil;
        [ATFInitManger setAdSourcePrivacyPolicy:policyJson];
        result(@"succeed");
    }
    // putFilter（extraDic 为 Map，序列化为 JSON 后按 Unity 逻辑解析）
    else if ([PutFilter isEqualToString:call.method]) {
        NSString *placementId = [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments[@"placementID"] : nil;
        id extra = [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments[@"extraDic"] : nil;
        NSString *filterJson = nil;
        if ([extra isKindOfClass:[NSString class]]) {
            filterJson = extra;
        } else if ([NSJSONSerialization isValidJSONObject:extra]) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:extra options:0 error:nil];
            filterJson = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        }
        [ATFInitManger putFilter:placementId filterJson:filterJson];
        result(@"succeed");
    }
    // removeFilters
    else if ([RemoveFilters isEqualToString:call.method]) {
        [ATFInitManger removeFilters];
        result(@"succeed");
    }
    // removeFilterWithPlacementId
    else if ([RemoveFilterWithPlacementId isEqualToString:call.method]) {
        NSString *placementId = [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments[@"placementID"] : nil;
        [ATFInitManger removeFilterWithPlacementId:placementId];
        result(@"succeed");
    }
    // 设置共享广告位配置（extraDic 为 Map，参考 Unity ATUnityManager::setSharedPlacementConfig）
    else if ([SetSharedPlacementConfig isEqualToString:call.method]) {
        id extra = [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments[@"extraDic"] : nil;
        if ([extra isKindOfClass:[NSDictionary class]]) {
            [ATFInitManger setSharedPlacementConfig:extra];
        }
        result(@"succeed");
    }
    // 显示DebugUI
    else if ([ShowDebugUI isEqualToString:call.method]) {
        [ATFInitManger showDebuggerUI:ATFCoconfigurMode.debugKey];
        result(@"succeed");
    }
}


#pragma mark - private
// 初始化SDK
- (void)starToponSDK:(FlutterMethodCall *)call result:(FlutterResult)result{
    
    [ATFInitManger initSDKAppID:ATFCoconfigurMode.appIdStr appKeyStr:ATFCoconfigurMode.appKeyStr requestError:^(NSError * resultError) {
        
        if (resultError == nil) {
            result(@"succeed");
        }else{
            NSString *codeStr = [NSString stringWithFormat:@"%ld---error:%@",(long)resultError.code,resultError.domain];
            result(codeStr);
        }
    }];
}
@end
