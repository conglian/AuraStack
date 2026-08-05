//
//  ATFInterstitialManger.m
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/28.
//

#import "ATFInterstitialManger.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import "ATFCommonTool.h"
#import "ATFInterstitialDelegate.h"
#import "ATFConfiguration.h"

#define UseRewardedVideoAsInterstitialKey @"UseRewardedVideoAsInterstitialKey"
#define ATFInterstitialExtraAdSizeKey @"size"

@interface ATFInterstitialManger()

@property(nonatomic, strong) ATFInterstitialDelegate *interstitialDelegate;
@property(nonatomic, strong) NSMutableSet<NSString *> *autoLoadPlacementIDs;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *autoLoadLocalExtras;
 
@end

@implementation ATFInterstitialManger

#pragma mark - public
/// 加载插屏广告
- (void)loadInterstitialAd:(NSString *)placementID extraDic:(NSDictionary *)extraDic {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:extraDic];
    
    // 激励视频当做插屏使用（调用Sigmob的激励视频API）
    if ([extraDic.allKeys containsObject:UseRewardedVideoAsInterstitialKey]) {
        [dic removeObjectForKey:UseRewardedVideoAsInterstitialKey];
        dic[kATInterstitialExtraUsesRewardedVideo] = extraDic[UseRewardedVideoAsInterstitialKey];
    }
    
    // 可通过以下代码设置穿山甲平台的插屏图片广告的尺寸
    if ([extraDic.allKeys containsObject:ATFInterstitialExtraAdSizeKey]) {
        
        [dic removeObjectForKey:ATFInterstitialExtraAdSizeKey];
        
        NSDictionary *tempDic = extraDic[ATFInterstitialExtraAdSizeKey];
        
        NSNumber *widthNumeber = tempDic[@"width"];
        NSNumber *heightNumeber = tempDic[@"height"];
        
        CGSize tempSize = CGSizeMake([widthNumeber doubleValue], [heightNumeber doubleValue]);
        
        dic[kATInterstitialExtraAdSizeKey] = [NSValue valueWithCGSize:tempSize];
    }
    [ATFCommonTool applyAtAdRequestAndRemove:dic];
    [[ATAdManager sharedManager] setMultipleLoadingDelegate:self.interstitialDelegate placementId:placementID];
    [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:dic delegate:self.interstitialDelegate];
}

/// 插屏广告是否准备好
- (BOOL)hasInterstitialAdReady:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return NO;
    }
    
    BOOL isReady = [[ATAdManager sharedManager] interstitialReadyForPlacementID:placementID];
    return  isReady;
}

/// 全自动加载插屏广告是否准备好
- (BOOL)hasAutoLoadInterstitialAdReady:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return NO;
    }
    
    BOOL isReady = [[ATInterstitialAutoAdManager sharedInstance] autoLoadInterstitialReadyForPlacementID:placementID];
    ATFLog(@"auto load inter hasAutoLoadInterstitialAdReady: %@ --- isReady:%d", placementID, isReady);
    return isReady;
}

/// 获取当前广告位下所有可用广告的信息
- (NSString *)getInterstitialValidAds:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return @"";
    }
    
    NSArray *array = [[ATAdManager sharedManager] getInterstitialValidAdsForPlacementID:placementID];
    
    NSString *str = [ATFCommonTool toReadableJSONString:array];
    
    return str;
}

/// 获取全自动加载广告位下所有可用广告的信息
- (NSString *)getAutoLoadInterstitialValidAds:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return @"";
    }
    
    NSArray *array = [[ATInterstitialAutoAdManager sharedInstance] checkValidAdCachesWithPlacementID:placementID];
    
    NSString *str = [ATFCommonTool toReadableJSONString:array];
    
    return str;
}

/// 获取广告位的状态
- (NSDictionary *)checkInterstitialLoadStatus:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return [NSDictionary dictionary];
    }
    
    ATCheckLoadModel *checkLoadModel = [[ATAdManager sharedManager] checkInterstitialLoadStatusForPlacementID:placementID];
    
    NSDictionary *dic = [ATFCommonTool objectToJSONString:checkLoadModel];
    return  dic;
}

/// 获取全自动加载广告位的状态
- (NSDictionary *)checkAutoLoadInterstitialLoadStatus:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return [NSDictionary dictionary];
    }
    
    ATCheckLoadModel *checkLoadModel = [[ATInterstitialAutoAdManager sharedInstance] checkInterstitialLoadStatusForPlacementID:placementID];
    
    if (!checkLoadModel) {
        return [NSDictionary dictionary];
    }
    
    NSDictionary *dic = [ATFCommonTool objectToJSONString:checkLoadModel];
    return dic;
}
/// 展示插屏广告
- (void)showInterstitialAd:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    [[ATAdManager sharedManager] showInterstitialWithPlacementID:placementID inViewController:[ATFCommonTool currentViewController] delegate:self.interstitialDelegate];
}

/// 展示场景插屏广告
- (void)showInterstitialAd:(NSString *)placementID sceneID:(NSString *)sceneID{
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:sceneID];
    
    [[ATAdManager sharedManager] showInterstitialWithPlacementID:placementID scene:sceneID inViewController:[ATFCommonTool currentViewController] delegate:self.interstitialDelegate];
}

///  展示场景插屏广告通过config
- (void)showInterstitialAdWithShowConfig:(NSString *)placementID sceneID:(NSString *)sceneID showCustomExt:(NSString *)showCustomExt {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    placementID = [ATFCommonTool checkStrParamsEmptyAndReturn:placementID];
    sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:sceneID];
    showCustomExt = [ATFCommonTool checkStrParamsEmptyAndReturn:showCustomExt];
    
    ATShowConfig * showConfig = [self createShowConfigWithsceneID:sceneID showCustomExt:showCustomExt];
    [[ATAdManager sharedManager] showInterstitialWithPlacementID:placementID showConfig:showConfig inViewController:[ATFCommonTool getRootViewController] delegate:self.interstitialDelegate nativeMixViewBlock:^(ATNativeMixInterstitialView * _Nonnull selfRenderingMixInterstitialView) {
        
    }];
}

/// 统计场景到达率
- (void)entryScenarioWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    ATFLog(@"entryInterScenarioWithPlacementID: %@ --- sceneID:%@",placementID,sceneID);
    
    [[ATAdManager sharedManager] entryInterstitialScenarioWithPlacementID:placementID scene:sceneID];
}

/// 统计全自动加载场景到达率
- (void)entryAutoLoadScenarioWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:sceneID];
    
    ATFLog(@"entryAutoLoadInterScenarioWithPlacementID: %@ --- sceneID:%@",placementID,sceneID);
    
    [[ATInterstitialAutoAdManager sharedInstance] entryAdScenarioWithPlacementID:placementID scenarioID:sceneID];
}

- (BOOL)containsAutoLoadPlacementID:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return NO;
    }
    
    return [self.autoLoadPlacementIDs containsObject:placementID];
}

/// 设置全自动加载
- (void)autoLoadInterstitialAD:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    [ATInterstitialAutoAdManager sharedInstance].delegate = self.interstitialDelegate;

    NSArray<NSString *> *placementIDs = [self placementIDArrayWithString:placementID];
    [self.autoLoadPlacementIDs unionSet:[NSSet setWithArray:placementIDs]];
    
    [[ATInterstitialAutoAdManager sharedInstance] addAutoLoadAdPlacementIDArray:placementIDs];
}

/// 取消全自动加载插屏
- (void)cancelAutoLoadInterstitialAD:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSArray<NSString *> *placementIDs = [self placementIDArrayWithString:placementID];
    [self.autoLoadPlacementIDs minusSet:[NSSet setWithArray:placementIDs]];
    [self.autoLoadLocalExtras removeObjectsForKeys:placementIDs];
    
    [[ATInterstitialAutoAdManager sharedInstance] removeAutoLoadAdPlacementIDArray:placementIDs];
}

/// 展示全自动加载插屏
- (void)showAutoLoadInterstitialADWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    placementID = [ATFCommonTool checkStrParamsEmptyAndReturn:placementID];
    [self showAutoLoadInterstitialADWithPlacementID:placementID sceneID:sceneID showCustomExt:@""];
}

- (void)showAutoLoadInterstitialADWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID showCustomExt:(NSString *)showCustomExt {
    NSDictionary *extraDic = self.autoLoadLocalExtras[placementID];
    NSString *showConfigExt = [ATFCommonTool checkStrParamsEmptyAndReturn:showCustomExt];
    if (showConfigExt.length == 0 && [extraDic isKindOfClass:[NSDictionary class]]) {
        showConfigExt = [ATFCommonTool checkStrParamsEmptyAndReturn:extraDic[@"kATAdShowCustomExtKey"]];
    }
    
    ATShowConfig *showConfig = [self createShowConfigWithsceneID:sceneID showCustomExt:showConfigExt atCustomContentResult:extraDic[@"atCustomContentResult"]];
    [[ATInterstitialAutoAdManager sharedInstance] showAutoLoadInterstitialWithPlacementID:placementID showConfig:showConfig inViewController:[ATFCommonTool currentViewController] delegate:self.interstitialDelegate]; 
}

/// 设置自动加载插屏广告回传参数，没传入extra内容可以用于清空
- (void)autoLoadInterstitialADSetLocalExtra:(NSString *)placementID extraDic:(NSDictionary *)extraDic {

    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:extraDic];
  
    // 激励视频当做插屏使用（调用Sigmob的激励视频API）
    if ([extraDic.allKeys containsObject:UseRewardedVideoAsInterstitialKey]) {
        [dic removeObjectForKey:UseRewardedVideoAsInterstitialKey];
        dic[kATInterstitialExtraUsesRewardedVideo] = extraDic[UseRewardedVideoAsInterstitialKey];
    }
    
    // 可通过以下代码设置穿山甲平台的插屏图片广告的尺寸
    if ([extraDic.allKeys containsObject:ATFInterstitialExtraAdSizeKey]) {
        
        [dic removeObjectForKey:ATFInterstitialExtraAdSizeKey];

        NSDictionary *tempDic = extraDic[ATFInterstitialExtraAdSizeKey];

        NSNumber *widthNumeber = tempDic[@"width"];
        NSNumber *heightNumeber = tempDic[@"height"];

        CGSize tempSize = CGSizeMake([widthNumeber doubleValue], [heightNumeber doubleValue]);

        dic[kATInterstitialExtraAdSizeKey] = [NSValue valueWithCGSize:tempSize];
    }
    
    [[ATInterstitialAutoAdManager sharedInstance] setLocalExtra:dic placementID:placementID];
    self.autoLoadLocalExtras[placementID] = [dic copy];
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
- (ATFInterstitialDelegate *)interstitialDelegate {

    if (_interstitialDelegate) return _interstitialDelegate;

    ATFInterstitialDelegate *interstitialDelegate = [ATFInterstitialDelegate new];

    return _interstitialDelegate = interstitialDelegate;
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
