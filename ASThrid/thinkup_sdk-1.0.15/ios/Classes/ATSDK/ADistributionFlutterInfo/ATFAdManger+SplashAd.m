//
//  ATFAdManger+SplashAd.m
//  anythink_sdk
//
//  Created by GUO PENG on 2023/9/7.
//

#import "ATFAdManger+SplashAd.h"
#import "ATFConfiguration.h"
#import "ATFCommonTool.h"


@implementation ATFAdManger (SplashAd)


- (void)splashAdFlutterInformation:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSString *placementID = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"placementID"]];
    NSString *sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"sceneID"]];
    NSDictionary *extraDic = [call.arguments[@"extraDic"] isKindOfClass:[NSDictionary class]] ? call.arguments[@"extraDic"] : @{};
    NSString *showCustomExt = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"showCustomExt"]];
    ATFLog(@"Rewarded video ad slot:%@",placementID);
    
    // 加载开屏
    if ([LoadSplashAd isEqualToString:call.method]) {
        [self.splashAdManger loadSplashAd:placementID extraDic:extraDic];
        result(@"succeed");
    }
    // 是否有广告缓存
    else if ([SplashAdReadyReady isEqualToString:call.method]) {
       BOOL isReady = [self.splashAdManger splashAdReady:placementID];
        ATFLog(@"Splash result method=%@ placementID=%@ isReady=%d", call.method, placementID, isReady);
        result(@(isReady));
    }
    // 检查开屏状态
    else if ([CheckSplashAdLoadStatus isEqualToString:call.method]) {
        NSDictionary *dic = [self.splashAdManger checkSplashAdLoadStatus:placementID];
        ATFLog(@"Splash result method=%@ placementID=%@ loadStatus=%@", call.method, placementID, dic);
        result(dic);
    }
    // 展示开屏
    else if ([ShowSplashAd isEqualToString:call.method]) {
         [self.splashAdManger showSplashAd:placementID];
         result(@"succeed");
    }
    // 展示场景开屏
    else if ([ShowSceneSplashAd isEqualToString:call.method]) {
        
        if (sceneID == nil || sceneID.length == 0) {
            [self.splashAdManger showSplashAd:placementID];
        }else{
            [self.splashAdManger showSplashAd:placementID sceneID:sceneID];
        }
        result(@"succeed");
    }
    // 获取当前广告位下所有可用广告的信息，v5.7.53及以上版本支持
    else if ([GetSplashAdValidAds isEqualToString:call.method]) {
        NSString *str = [self.splashAdManger getSplashAdValidAds:placementID];
        ATFLog(@"Splash result method=%@ placementID=%@ validAds=%@", call.method, placementID, str);
        result(str);
    }
    // 展示广告带Config
    else if ([ShowSplashAdWithShowConfig isEqualToString:call.method]) {
        [self.splashAdManger showSplashAdWithShowConfig:placementID sceneID:sceneID showCustomExt:showCustomExt];
        result(@"succeed");
    }
    else if ([EntrySplashScenario isEqualToString:call.method]) {
        [self.splashAdManger entryScenarioWithPlacementID:placementID sceneID:sceneID];
        result(@(YES));
    }
}

@end
