//
//  ATFRewardedVideoManger.m
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/26.
//

#import "ATFRewardedVideoManger.h"
//#import <AnyThinkSDK/AnyThinkSDK.h>
#import <AnyThinkSDK/AnyThinkSDK.h>
#import "ATFCommonTool.h"
#import "ATFRewardedVideoDelegate.h"
#import "ATFConfiguration.h"

#define kATAdLoadingExtraUserData  @"kATAdLoadingExtraMediaExtraKey"
#define kATAdLoadingExtraUserDataKeywordKey  @"kATAdLoadingExtraUserDataKeywordKey"
#define kATAdLoadingExtraUserID  @"kATAdLoadingExtraUserIDKey"

@interface ATFRewardedVideoManger()

@property(nonatomic, strong) ATFRewardedVideoDelegate *rewardedVideoDelegate;
@property(nonatomic, strong) NSMutableSet<NSString *> *autoLoadPlacementIDs;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *autoLoadLocalExtras;



@end


@implementation ATFRewardedVideoManger

#pragma mark - public
/// 加载激励视频
- (void)loadRewardedVideo:(NSString *)placementID extraDic:(NSDictionary *)extraDic {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:extraDic];
    
    if ([extraDic.allKeys containsObject:kATAdLoadingExtraUserDataKeywordKey]) {
        [dic removeObjectForKey:kATAdLoadingExtraUserDataKeywordKey];
        dic[kATAdLoadingExtraMediaExtraKey] = extraDic[kATAdLoadingExtraUserDataKeywordKey];
    }
    if ([extraDic.allKeys containsObject:kATAdLoadingExtraUserID]) {
        [dic removeObjectForKey:kATAdLoadingExtraUserID];
        dic[kATAdLoadingExtraUserIDKey] = extraDic[kATAdLoadingExtraUserID];
    }
    [ATFCommonTool applyAtAdRequestAndRemove:dic];
    [[ATAdManager sharedManager] setMultipleLoadingDelegate:self.rewardedVideoDelegate placementId:placementID];
    
    [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:dic delegate:self.rewardedVideoDelegate];
}


/// 展示激励视频广告
- (void)showRewardedVideo:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    [[ATAdManager sharedManager] showRewardedVideoWithPlacementID:placementID inViewController:[ATFCommonTool currentViewController] delegate:self.rewardedVideoDelegate];
}

///  展示场景激励视频广告
- (void)showRewardedVideo:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:sceneID];
    
    [[ATAdManager sharedManager] showRewardedVideoWithPlacementID:placementID scene:sceneID inViewController:[ATFCommonTool currentViewController] delegate:self.rewardedVideoDelegate];
}

///  展示激励视频广告通过config
- (void)showRewardedVideoWithShowConfig:(NSString *)placementID sceneID:(NSString *)sceneID showCustomExt:(NSString *)showCustomExt {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:sceneID];
    showCustomExt = [ATFCommonTool checkStrParamsEmptyAndReturn:showCustomExt];
    ATShowConfig *config = [self createShowConfigWithsceneID:sceneID showCustomExt:showCustomExt];
    [[ATAdManager sharedManager] showRewardedVideoWithPlacementID:placementID config:config inViewController:[ATFCommonTool currentViewController] delegate:self.rewardedVideoDelegate];
}


/// 是否有广告缓存
- (BOOL)rewardedVideoReady:(NSString *)placementID{
    
    if (kATFStringIsEmpty(placementID)) {
        return NO;
    }
    
    BOOL isReady = [[ATAdManager sharedManager] rewardedVideoReadyForPlacementID:placementID];
    return  isReady;
}

/// 全自动加载激励视频广告是否准备好
- (BOOL)autoLoadRewardedVideoReady:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return NO;
    }
    
    BOOL isReady = [[ATRewardedVideoAutoAdManager sharedInstance] autoLoadRewardedVideoReadyForPlacementID:placementID];
    ATFLog(@"auto load video autoLoadRewardedVideoReady: %@ --- isReady:%d", placementID, isReady);
    return isReady;
}

/// 检查广告状态
- (NSDictionary *)checkRewardedVideoLoadStatus:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return [NSDictionary dictionary];
    }
    
    ATCheckLoadModel *checkLoadModel = [[ATAdManager sharedManager] checkRewardedVideoLoadStatusForPlacementID:placementID];
    
    NSDictionary *dic = [ATFCommonTool objectToJSONString:checkLoadModel];
    return  dic;
}

/// 检查全自动加载激励视频广告状态
- (NSDictionary *)checkAutoLoadRewardedVideoLoadStatus:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return [NSDictionary dictionary];
    }
    
    ATCheckLoadModel *checkLoadModel = [[ATRewardedVideoAutoAdManager sharedInstance] checkRewardedVideoLoadStatusForPlacementID:placementID];
    
    if (!checkLoadModel) {
        return [NSDictionary dictionary];
    }
    
    NSDictionary *dic = [ATFCommonTool objectToJSONString:checkLoadModel];
    return dic;
}

///  获取当前广告位下所有可用广告的信息，v5.7.53及以上版本支持
- (NSString *)getRewardedVideoValidAds:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return @"";
    }
    
    NSArray *array = [[ATAdManager sharedManager] getRewardedVideoValidAdsForPlacementID:placementID];
    
    NSString *str = [ATFCommonTool toReadableJSONString:array];
    
    return str;
}

/// 获取全自动加载广告位下所有可用广告的信息
- (NSString *)getAutoLoadRewardedVideoValidAds:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return @"";
    }
    
    NSArray *array = [[ATRewardedVideoAutoAdManager sharedInstance] checkValidAdCachesWithPlacementID:placementID];
    
    NSString *str = [ATFCommonTool toReadableJSONString:array];
    
    return str;
}

/// 统计场景到达率
- (void)entryScenarioWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    ATFLog(@"entryRewardedVideoScenarioWithPlacementID: %@ --- sceneID:%@",placementID,sceneID);
    
    [[ATAdManager sharedManager] entryRewardedVideoScenarioWithPlacementID:placementID scene:sceneID];
}

/// 统计全自动加载场景到达率
- (void)entryAutoLoadScenarioWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:sceneID];
    
    ATFLog(@"entryAutoLoadRewardedVideoScenarioWithPlacementID: %@ --- sceneID:%@",placementID,sceneID);
    
    [[ATRewardedVideoAutoAdManager sharedInstance] entryAdScenarioWithPlacementID:placementID scenarioID:sceneID];
}

- (BOOL)containsAutoLoadPlacementID:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return NO;
    }
    
    return [self.autoLoadPlacementIDs containsObject:placementID];
}

/// 设置全自动加载激励视频广告
- (void)autoLoadRewardedVideo:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    [ATRewardedVideoAutoAdManager sharedInstance].delegate = self.rewardedVideoDelegate;
    
    NSArray<NSString *> *placementIDs = [self placementIDArrayWithString:placementID];
    [self.autoLoadPlacementIDs unionSet:[NSSet setWithArray:placementIDs]];
    
    [[ATRewardedVideoAutoAdManager sharedInstance] addAutoLoadAdPlacementIDArray:placementIDs];
}

/// 取消全自动加载激励视频广告
- (void)cancelAutoLoadRewardedVideo:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSArray<NSString *> *placementIDs = [self placementIDArrayWithString:placementID];
    [self.autoLoadPlacementIDs minusSet:[NSSet setWithArray:placementIDs]];
    [self.autoLoadLocalExtras removeObjectsForKeys:placementIDs];
    
    [[ATRewardedVideoAutoAdManager sharedInstance] removeAutoLoadAdPlacementIDArray:placementIDs];
}

/// 展示全自动加载激励视频广告
- (void)showAutoLoadRewardedVideoAD:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    [self showAutoLoadRewardedVideoAD:placementID sceneID:sceneID showCustomExt:@""];
}

- (void)showAutoLoadRewardedVideoAD:(NSString *)placementID sceneID:(NSString *)sceneID showCustomExt:(NSString *)showCustomExt {
    NSDictionary *extraDic = self.autoLoadLocalExtras[placementID];
    NSString *showConfigExt = [ATFCommonTool checkStrParamsEmptyAndReturn:showCustomExt];
    if (showConfigExt.length == 0 && [extraDic isKindOfClass:[NSDictionary class]]) {
        showConfigExt = [ATFCommonTool checkStrParamsEmptyAndReturn:extraDic[@"kATAdShowCustomExtKey"]];
    }
    
    ATShowConfig *config = [self createShowConfigWithsceneID:sceneID showCustomExt:showConfigExt atCustomContentResult:extraDic[@"atCustomContentResult"]];
    [[ATRewardedVideoAutoAdManager sharedInstance] showAutoLoadRewardedVideoWithPlacementID:placementID showConfig:config inViewController:[ATFCommonTool currentViewController] delegate:self.rewardedVideoDelegate];
}

- (ATShowConfig *)createShowConfigWithsceneID:(NSString *)sceneID showCustomExt:(NSString *)extraJsonString {
    return [self createShowConfigWithsceneID:sceneID showCustomExt:extraJsonString atCustomContentResult:nil];
}

- (ATShowConfig *)createShowConfigWithsceneID:(NSString *)sceneID showCustomExt:(NSString *)extraJsonString atCustomContentResult:(id)atCustomContentResult {
    NSDictionary *showCongifDict = ([extraJsonString isKindOfClass:[NSString class]] && [extraJsonString dataUsingEncoding:NSUTF8StringEncoding] != nil) ? [NSJSONSerialization JSONObjectWithData:[extraJsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil] : nil;
    NSString *scenarioId = showCongifDict[@"tkExtraJson"] ? : sceneID;
    if (scenarioId.length == 0) {
        scenarioId = showCongifDict[@"Scenario"] ? : @"";
    }
    ATShowConfig *config;
    if (showCongifDict) {
        NSString *showCustomExt = showCongifDict[@"showCustomExt"] ? : @"";
        
        NSDictionary *contentResultDict = showCongifDict[@"atCustomContentResult"] ? : @{};
        NSArray *customContentResult = contentResultDict[@"items"] ? : @[];
        
        NSMutableArray *contentInfoArray = [NSMutableArray arrayWithCapacity:0];
        [customContentResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *customContentString = obj[@"customContentString"] ? : @"";
            double customContentDouble = [obj[@"customContentDouble"] doubleValue];
            
            NSDictionary *customContentObject = obj[@"customContentObject"] ? : @{};
            if (customContentString.length > 0) {
                ATCustomContentInfo *info = [[ATCustomContentInfo alloc] initInfoWithContentString:customContentString contentObject:customContentObject];
                [contentInfoArray addObject:info];
            } else {
                ATCustomContentInfo *info = [[ATCustomContentInfo alloc] initInfoWithContentDouble:customContentDouble contentObject:customContentObject];
                [contentInfoArray addObject:info];
            }
        }];
        
        ATCustomContentResult *contentResult = [[ATCustomContentResult alloc] initContentResultWithInfoArray:contentInfoArray];
        if (showCustomExt.length > 0 && contentInfoArray.count == 0) {
            config = [[ATShowConfig alloc] initWithScene:scenarioId showCustomExt:showCustomExt];
        } else if (showCustomExt.length > 0 && contentInfoArray.count > 0) {
            config = [[ATShowConfig alloc] initWithScene:scenarioId showCustomExt:showCustomExt customContentResult:contentResult];
        } else {
            config = [[ATShowConfig alloc] initWithScene:scenarioId showCustomExt:extraJsonString];
        }
    } else { 
        if (atCustomContentResult) {
            ATCustomContentResult *contentResult = [self customContentResultWithObject:atCustomContentResult];
            config = [[ATShowConfig alloc] initWithScene:scenarioId showCustomExt:extraJsonString customContentResult:contentResult];
        } else {
            config = [[ATShowConfig alloc] initWithScene:scenarioId showCustomExt:extraJsonString];
        }
    }
    return config;
}

- (ATCustomContentResult *)customContentResultWithObject:(id)object {
    
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSDictionary *contentResultDict = (NSDictionary *)object;
    NSArray *customContentInfoList = contentResultDict[@"customContentInfoList"] ? : contentResultDict[@"items"];
    if (![customContentInfoList isKindOfClass:[NSArray class]] || customContentInfoList.count == 0) {
        return nil;
    }
    
    NSMutableArray *contentInfoArray = [NSMutableArray arrayWithCapacity:customContentInfoList.count];
    [customContentInfoList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *contentInfoDict = (NSDictionary *)obj;
        NSString *customContentString = contentInfoDict[@"customContentString"] ? : @"";
        double customContentDouble = [contentInfoDict[@"customContentDouble"] doubleValue];
        NSDictionary *customContentObject = contentInfoDict[@"customContentObject"] ? : @{};
        if (customContentString.length > 0) {
            ATCustomContentInfo *info = [[ATCustomContentInfo alloc] initInfoWithContentString:customContentString contentObject:customContentObject];
            [contentInfoArray addObject:info];
        } else {
            ATCustomContentInfo *info = [[ATCustomContentInfo alloc] initInfoWithContentDouble:customContentDouble contentObject:customContentObject];
            [contentInfoArray addObject:info];
        }
    }];
    
    if (contentInfoArray.count == 0) {
        return nil;
    }
    
    return [[ATCustomContentResult alloc] initContentResultWithInfoArray:contentInfoArray];
}

/// 设置自动加载激励视频广告回传参数，没传入extra内容可以用于清空
- (void)autoLoadRewardedVideoSetLocalExtra:(NSString *)placementID extraDic:(NSDictionary *)extraDic {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
     
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:extraDic];

    if ([extraDic.allKeys containsObject:kATAdLoadingExtraUserDataKeywordKey]) {
        [dic removeObjectForKey:kATAdLoadingExtraUserDataKeywordKey];
        dic[kATAdLoadingExtraMediaExtraKey] = extraDic[kATAdLoadingExtraUserDataKeywordKey];
    }
    if ([extraDic.allKeys containsObject:kATAdLoadingExtraUserID]) {
        [dic removeObjectForKey:kATAdLoadingExtraUserID];
        dic[kATAdLoadingExtraUserIDKey] = extraDic[kATAdLoadingExtraUserID];
    }
     
    [[ATRewardedVideoAutoAdManager sharedInstance] setLocalExtra:dic placementID:placementID];
    self.autoLoadLocalExtras[placementID] = [dic copy];
}

- (NSArray<NSString *> *)placementIDArrayWithString:(NSString *)placementIDString {
    
    NSMutableArray<NSString *> *placementIDs = [NSMutableArray array];
    NSArray<NSString *> *components = [placementIDString componentsSeparatedByString:@","];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    for (NSString *placementID in components) {
        NSString *trimmedPlacementID = [placementID stringByTrimmingCharactersInSet:whitespace];
        if (!kATFStringIsEmpty(trimmedPlacementID)) {
            [placementIDs addObject:trimmedPlacementID];
        }
    }
    
    return placementIDs;
}
 
#pragma mark - lazy
- (ATFRewardedVideoDelegate *)rewardedVideoDelegate {

    if (_rewardedVideoDelegate) return _rewardedVideoDelegate;

    ATFRewardedVideoDelegate *rewardedVideoDelegate = [ATFRewardedVideoDelegate new];

    return _rewardedVideoDelegate = rewardedVideoDelegate;
}

- (NSMutableSet<NSString *> *)autoLoadPlacementIDs {
    
    if (_autoLoadPlacementIDs) return _autoLoadPlacementIDs;
    
    return _autoLoadPlacementIDs = [NSMutableSet set];
}

- (NSMutableDictionary<NSString *, NSDictionary *> *)autoLoadLocalExtras {
    
    if (_autoLoadLocalExtras) return _autoLoadLocalExtras;
    
    return _autoLoadLocalExtras = [NSMutableDictionary dictionary];
}

@end
