//
//  ATFAdManger+InterstitialAd.m
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/28.
//

#import "ATFAdManger+InterstitialAd.h"
#import "ATFConfiguration.h"
#import "ATFCommonTool.h"

@implementation ATFAdManger (InterstitialAd)

- (void)interstitialAdFlutterInformation:(FlutterMethodCall *)call result:(FlutterResult)result {

    NSString *placementID = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"placementID"]];
    NSDictionary *extraDic = [call.arguments[@"extraDic"] isKindOfClass:[NSDictionary class]] ? call.arguments[@"extraDic"] : @{};
    NSString *sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"sceneID"]];
    NSString *showCustomExt = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"showCustomExt"]];
    NSString *placementIDs = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"placementIDMulti"]];
    
    ATFLog(@"Interstitial ad slot:%@",placementID);

    // 加载插屏广告
    if ([LoadInterstitialAd isEqualToString:call.method]) {
        
        [self.interstitialManger loadInterstitialAd:placementID extraDic:extraDic];
        result(@"succeed");
    }
    // 插屏广告是否准备好
    else if ([HasInterstitialAdReady isEqualToString:call.method]) {
        BOOL isReady = [self.interstitialManger containsAutoLoadPlacementID:placementID]
            ? [self.interstitialManger hasAutoLoadInterstitialAdReady:placementID]
            : [self.interstitialManger hasInterstitialAdReady:placementID];
        ATFLog(@"Interstitial result method=%@ placementID=%@ isReady=%d", call.method, placementID, isReady);
        result(@(isReady));

    }
    // 获取当前广告位下所有可用广告的信息，v5.7.53及以上版本支持
    else if ([GetInterstitialValidAds isEqualToString:call.method]) {
        NSString *str = [self.interstitialManger containsAutoLoadPlacementID:placementID]
            ? [self.interstitialManger getAutoLoadInterstitialValidAds:placementID]
            : [self.interstitialManger getInterstitialValidAds:placementID];
        ATFLog(@"Interstitial result method=%@ placementID=%@ validAds=%@", call.method, placementID, str);
        result(str);
        
    }
    
    // 获取广告位的状态
    else if ([CheckInterstitialLoadStatus isEqualToString:call.method]) {
        NSDictionary *dic = [self.interstitialManger containsAutoLoadPlacementID:placementID]
            ? [self.interstitialManger checkAutoLoadInterstitialLoadStatus:placementID]
            : [self.interstitialManger checkInterstitialLoadStatus:placementID];
        ATFLog(@"Interstitial result method=%@ placementID=%@ loadStatus=%@", call.method, placementID, dic);
        result(dic);
    }
    
    // 展示插屏广告
    else if ([ShowInterstitialAd isEqualToString:call.method]) {
        [self.interstitialManger showInterstitialAd:placementID];
        result(@"succeed");
    }
    
    // 展示场景插屏广告
    else if ([ShowSceneInterstitialAd isEqualToString:call.method]) {
        if (kATFStringIsEmpty(sceneID)) {
            [self.interstitialManger showInterstitialAd:placementID];
        }else{
            [self.interstitialManger showInterstitialAd:placementID sceneID:sceneID];
        }
        result(@"succeed");
    }

    // 展示插屏广告带Config
    else if ([ShowInterstitialAdWithShowConfig isEqualToString:call.method]) {
        [self.interstitialManger showInterstitialAdWithShowConfig:placementID sceneID:sceneID showCustomExt:showCustomExt];
        result(@"succeed");
    }

    //场景到达统计
    else if ([EntryInterstitialScenario isEqualToString:call.method]) {
        if ([self.interstitialManger containsAutoLoadPlacementID:placementID]) {
            [self.interstitialManger entryAutoLoadScenarioWithPlacementID:placementID sceneID:sceneID];
        } else {
            [self.interstitialManger entryScenarioWithPlacementID:placementID sceneID:sceneID];
        }
        result(@(YES));
    }

    //全自动加载相关
    else if ([AutoLoadInterstitialAD isEqualToString:call.method]) {
        [self.interstitialManger autoLoadInterstitialAD:placementIDs];
        result(@"succeed");
    }
    else if ([CancelAutoLoadInterstitialAD isEqualToString:call.method]) {
        [self.interstitialManger cancelAutoLoadInterstitialAD:placementIDs];
        result(@"succeed");
    }
    else if ([ShowAutoLoadInterstitialADWithPlacementID isEqualToString:call.method]) {
        [self.interstitialManger showAutoLoadInterstitialADWithPlacementID:placementID sceneID:sceneID];
        result(@"succeed");
    }
    else if ([AutoLoadInterstitialADSetLocalExtra isEqualToString:call.method]) {
        [self.interstitialManger autoLoadInterstitialADSetLocalExtra:placementIDs extraDic:extraDic];
        result(@"succeed");
    }
}

@end
