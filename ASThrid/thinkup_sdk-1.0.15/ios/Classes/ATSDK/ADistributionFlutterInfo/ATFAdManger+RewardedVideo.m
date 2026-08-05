//
//  ATFAdManger+RewardedVideo.m
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/26.
//

#import "ATFAdManger+RewardedVideo.h"
#import "ATFConfiguration.h"
#import "ATFCommonTool.h"


@implementation ATFAdManger (RewardedVideo)

- (void)rewardedVideoFlutterInformation:(FlutterMethodCall*)call result:(FlutterResult)result{
    
    NSString *placementID = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"placementID"]];
    NSString *sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"sceneID"]];
    NSString *showCustomExt = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"showCustomExt"]];
    NSString *placementIDs = [ATFCommonTool checkStrParamsEmptyAndReturn:call.arguments[@"placementIDMulti"]];
    
    NSDictionary *extraDic = [call.arguments[@"extraDic"] isKindOfClass:[NSDictionary class]] ? call.arguments[@"extraDic"] : @{};
    ATFLog(@"Rewarded video ad slot:%@",placementID);

    // 加载视频
    if ([LoadRewardedVideo isEqualToString:call.method]) {
        [self.rewardedVideoManger loadRewardedVideo:placementID extraDic:extraDic];
        result(@"succeed");
    }
    // 是否有广告缓存
    else if ([RewardedVideoReady isEqualToString:call.method]) {
       BOOL isReady = [self.rewardedVideoManger containsAutoLoadPlacementID:placementID]
            ? [self.rewardedVideoManger autoLoadRewardedVideoReady:placementID]
            : [self.rewardedVideoManger rewardedVideoReady:placementID];
        ATFLog(@"RewardedVideo result method=%@ placementID=%@ isReady=%d", call.method, placementID, isReady);
        result(@(isReady));
    }
    // 检查视频状态
    else if ([CheckRewardedVideoLoadStatus isEqualToString:call.method]) {
        NSDictionary *dic = [self.rewardedVideoManger containsAutoLoadPlacementID:placementID]
            ? [self.rewardedVideoManger checkAutoLoadRewardedVideoLoadStatus:placementID]
            : [self.rewardedVideoManger checkRewardedVideoLoadStatus:placementID];
        ATFLog(@"RewardedVideo result method=%@ placementID=%@ loadStatus=%@", call.method, placementID, dic);
        result(dic);
    }
    // 展示激励视频
    else if ([ShowRewardedVideo isEqualToString:call.method]) {
         [self.rewardedVideoManger showRewardedVideo:placementID];
         result(@"succeed");
    }
    // 展示场景激励视频
    else if ([ShowSceneRewardedVideo isEqualToString:call.method]) {
        
        if (sceneID == nil || sceneID.length == 0) {
            [self.rewardedVideoManger showRewardedVideo:placementID];
        }else{
            [self.rewardedVideoManger showRewardedVideo:placementID sceneID:sceneID];
        }
        result(@"succeed");

    }
    // 获取当前广告位下所有可用广告的信息，v5.7.53及以上版本支持
    else if ([GetRewardedVideoValidAds isEqualToString:call.method]) {
        NSString *str = [self.rewardedVideoManger containsAutoLoadPlacementID:placementID]
            ? [self.rewardedVideoManger getAutoLoadRewardedVideoValidAds:placementID]
            : [self.rewardedVideoManger getRewardedVideoValidAds:placementID];
        ATFLog(@"RewardedVideo result method=%@ placementID=%@ validAds=%@", call.method, placementID, str);
        result(str);
    }
    // 展示广告带Config
    else if ([ShowRewardedVideoWithShowConfig isEqualToString:call.method]) {
        [self.rewardedVideoManger showRewardedVideoWithShowConfig:placementID sceneID:sceneID showCustomExt:showCustomExt];
        result(@"succeed");
    }
    //场景统计
    else if ([EntryRewardedVideoScenario isEqualToString:call.method]) {
        if ([self.rewardedVideoManger containsAutoLoadPlacementID:placementID]) {
            [self.rewardedVideoManger entryAutoLoadScenarioWithPlacementID:placementID sceneID:sceneID];
        } else {
            [self.rewardedVideoManger entryScenarioWithPlacementID:placementID sceneID:sceneID];
        }
        result(@"succeed");
    }
    //全自动加载相关
    else if ([AutoLoadRewardedVideo isEqualToString:call.method]) {
        [self.rewardedVideoManger autoLoadRewardedVideo:placementIDs];
        result(@"succeed");
    }
    else if ([CancelAutoLoadRewardedVideo isEqualToString:call.method]) {
        [self.rewardedVideoManger cancelAutoLoadRewardedVideo:placementIDs];
        result(@"succeed");
    }
    else if ([ShowAutoLoadRewardedVideoAD isEqualToString:call.method]) {
        [self.rewardedVideoManger showAutoLoadRewardedVideoAD:placementID sceneID:sceneID];
        result(@"succeed");
    }
    else if ([AutoLoadRewardedVideoSetLocalExtra isEqualToString:call.method]) {
        [self.rewardedVideoManger autoLoadRewardedVideoSetLocalExtra:placementIDs extraDic:extraDic];
        result(@"succeed");
    }
}

@end
