//
//  ATFAdManger+NativeAd.m
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/29.
//

#import "ATFAdManger+NativeAd.h"
#import "ATFConfiguration.h"
#import "ATFNativeTool.h"
#import "ATFCommonTool.h"
#import "ATFNativePlatformView.h"

@implementation ATFAdManger (NativeAd)

- (void)nativeAdFlutterInformation:(FlutterMethodCall*)call result:(FlutterResult)result{
    
    NSString *placementID = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"placementID"]];
    NSDictionary *extraDic = [call.arguments[@"extraDic"] isKindOfClass:[NSDictionary class]] ? call.arguments[@"extraDic"] : @{};
    
    NSString *sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"sceneID"]];
    NSString *showCustomExt = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"showCustomExt"]];
    id atCustomContentResult = call.arguments[@"atCustomContentResult"];
    BOOL isAdaptiveHeight = [call.arguments[IsAdaptiveHeight] boolValue];

    BOOL isNativeShowType = YES;

    if ([extraDic.allKeys containsObject:@"isNativeShowType"] && [extraDic[@"isNativeShowType"] boolValue] == NO) {
        isNativeShowType = NO;
    }
    
    ATFLog(@"Native ad slot:%@",placementID);

    // 加载原生广告
    if ([LoadNativeAd isEqualToString:call.method]) {
        if (isNativeShowType == NO) {
            [self.platfromNativeManger loadNativeWith:placementID extraDic:extraDic];
        } else {
            [self.nativeManger loadNativeWith:placementID extraDic:extraDic];
        }
        result(@"succeed");
    }
    
    // 原生广告是否准备好
    else if ([NativeAdReady isEqualToString:call.method]) {
        BOOL isReady = [ATFNativeTool nativeAdReady:placementID];
        ATFLog(@"Native result method=%@ placementID=%@ isReady=%d", call.method, placementID, isReady);
        result(@(isReady));
    }
    
    // 获取广告位的状态
    else if ([CheckNativeAdLoadStatus isEqualToString:call.method]) {
        NSDictionary *dic = [ATFNativeTool checkNativeLoadStatus:placementID];
        ATFLog(@"Native result method=%@ placementID=%@ loadStatus=%@", call.method, placementID, dic);
        result(dic);
    }
    
    // 获取当前广告位下所有可用广告的信息，v5.7.53及以上版本支持
    else if ([GetNativeValidAds isEqualToString:call.method]) {
        NSString *str = [ATFNativeTool getNativeValidAds:placementID];
        ATFLog(@"Native result method=%@ placementID=%@ validAds=%@", call.method, placementID, str);
        result(str);
    }
    
    // 展示原生广告
    else if ([ShowNativeAd isEqualToString:call.method]) {
        [self.nativeManger showNative:placementID isAdaptiveHeight:isAdaptiveHeight extraDic:extraDic];
        result(@"succeed");
    }
    
    // 展示场景原生广告
    else if ([ShowSceneNativeAd isEqualToString:call.method]) {
        if (sceneID == nil || sceneID.length == 0) {
            [self.nativeManger showNative:placementID isAdaptiveHeight:isAdaptiveHeight extraDic:extraDic];
        }else{
            [self.nativeManger showNative:placementID sceneID:sceneID isAdaptiveHeight:isAdaptiveHeight extraDic:extraDic];
        }
        result(@"succeed");
    }
    
    // 移除原生广告
    else if ([RemoveNativeAd isEqualToString:call.method]) {
        [ATFNativePlatformView removePlatformNativeViewWithPlacementID:placementID];
        [self.nativeManger removeNative:placementID];
        result(@(YES));
    }

    else if ([EntryNativeScenario isEqualToString:call.method]) {
        [self.nativeManger entryScenarioWithPlacementID:placementID sceneID:sceneID];
        result(@(YES));
    }

    else if ([ShowSceneNativeAdWithCustomExt isEqualToString:call.method]) {
        [self.nativeManger showNative:placementID sceneID:sceneID showCustomExt:showCustomExt isAdaptiveHeight:isAdaptiveHeight extraDic:extraDic atCustomContentResult:atCustomContentResult];
        result(@"succeed");
    }
}

@end
