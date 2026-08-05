//
//  ATFSplashAdManger.m
//  anythink_sdk
//
//  Created by GUO PENG on 2023/9/7.
//

#import "ATFSplashAdManger.h"
#import "ATFSplashDelegate.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import "ATFCommonTool.h"
#import "ATFConfiguration.h"

@interface ATFSplashAdManger()

@property(nonatomic, strong) ATFSplashDelegate *splashAdDelegate;

@end


@implementation ATFSplashAdManger

/// 加载开屏
- (void)loadSplashAd:(NSString *)placementID extraDic:(NSDictionary *)extraDic {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:extraDic];
    NSString *keyString = @"tolerateTimeout";
    if ([extraDic.allKeys containsObject:keyString]) {
        [dic removeObjectForKey:keyString];
        dic[kATSplashExtraTolerateTimeoutKey] = @([extraDic[keyString] floatValue] * 0.001);
    }
    [ATFCommonTool applyAtAdRequestAndRemove:dic];
    [[ATAdManager sharedManager] setMultipleLoadingDelegate:self.splashAdDelegate placementId:placementID];
    NSString *bottomTemplateValue = extraDic[BottomTemplate];
    UIView *bottomContainView;
    if (bottomTemplateValue.length > 0) {
        bottomContainView = [[NSClassFromString(bottomTemplateValue) alloc] init];
    }
    if (bottomContainView) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        
        CGFloat bottomRatioValue = 0;
        CGFloat bottomHeightValue = 0;
        CGFloat width = window.frame.size.width;
        CGFloat height = 0;
        
        id ratioObj = extraDic[BottomRatio];
        if (ratioObj != nil) {
            bottomRatioValue = [ratioObj doubleValue];
        }
         
        id heightObj = extraDic[BottomHeight];
        if (heightObj != nil) {
            bottomHeightValue = [heightObj doubleValue];
        }
        
        if (bottomRatioValue > 0) {
            height = window.frame.size.height * bottomRatioValue;
        } else if (bottomHeightValue > 0) {
            height = bottomHeightValue;
        }    
        
        bottomContainView.frame =CGRectMake(0, 0, width, height);
        [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:dic delegate:self.splashAdDelegate containerView:bottomContainView];
        
    } else {
        [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:dic delegate:self.splashAdDelegate];
    }
    
}

/// 是否有广告缓存
- (BOOL)splashAdReady:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return NO;
    }
    
    BOOL isReady = [[ATAdManager sharedManager] splashReadyForPlacementID:placementID];
    return  isReady;
}

/// 检查广告状态
- (NSDictionary *)checkSplashAdLoadStatus:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return [NSDictionary dictionary];
    }
    
    ATCheckLoadModel *checkLoadModel = [[ATAdManager sharedManager] checkSplashLoadStatusForPlacementID:placementID];
    NSDictionary *dic = [ATFCommonTool objectToJSONString:checkLoadModel];
    return  dic;
}

/// 获取当前广告位下所有可用广告的信息，v5.7.53及以上版本支持
- (NSString *)getSplashAdValidAds:(NSString *)placementID {

    if (kATFStringIsEmpty(placementID)) {
        return @"";
    }
    
    NSArray *array = [[ATAdManager sharedManager] getSplashValidAdsForPlacementID:placementID];
    NSString *str = [ATFCommonTool toReadableJSONString:array];
    return str;
}

/// 展示开屏广告
- (void)showSplashAd:(NSString *)placementID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    ATShowConfig * showConfig = [ATShowConfig new];
    [[ATAdManager sharedManager] showSplashWithPlacementID:placementID config:showConfig window:window inViewController:[ATFCommonTool getRootViewController] extra:nil delegate:self.splashAdDelegate];
}

///  展示场景开屏广告
- (void)showSplashAd:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
     
    sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:sceneID];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    ATShowConfig * showConfig = [self createShowConfigWithsceneID:sceneID showCustomExt:@""];
    [[ATAdManager sharedManager] showSplashWithPlacementID:placementID config:showConfig window:window inViewController:[ATFCommonTool getRootViewController] extra:nil delegate:self.splashAdDelegate];
}

///  展示开屏广告通过config
- (void)showSplashAdWithShowConfig:(NSString *)placementID sceneID:(NSString *)sceneID showCustomExt:(NSString *)showCustomExt {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
     
    sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:sceneID];
    showCustomExt = [ATFCommonTool checkStrParamsEmptyAndReturn:showCustomExt];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    ATShowConfig * showConfig = [self createShowConfigWithsceneID:sceneID showCustomExt:showCustomExt];
    [[ATAdManager sharedManager] showSplashWithPlacementID:placementID config:showConfig window:window inViewController:[ATFCommonTool getRootViewController] extra:nil delegate:self.splashAdDelegate];
}

/// 统计场景到达率
- (void)entryScenarioWithPlacementID:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    if (kATFStringIsEmpty(placementID)) {
        return;
    }
    
    ATFLog(@"entrySplashScenarioWithPlacementID: %@ --- sceneID:%@",placementID,sceneID);

    [[ATAdManager sharedManager] entrySplashScenarioWithPlacementID:placementID scene:sceneID];
}

- (ATShowConfig *)createShowConfigWithsceneID:(NSString *)sceneID showCustomExt:(NSString *)extraJsonString {
    NSDictionary *showCongifDict = ([extraJsonString isKindOfClass:[NSString class]] && [extraJsonString dataUsingEncoding:NSUTF8StringEncoding] != nil) ? [NSJSONSerialization JSONObjectWithData:[extraJsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil] : nil;
    NSString *scenarioId = showCongifDict[@"tkExtraJson"] ? : sceneID;
    if (scenarioId.length == 0) {
        scenarioId = showCongifDict[@"Scenario"] ? : @"";
    }
    ATShowConfig *config;
    if (showCongifDict) {
        NSString *showCustomExt = showCongifDict[@"showCustomExt"] ? : @"";
        
        NSDictionary *atCustomContentResult = showCongifDict[@"atCustomContentResult"] ? : @{};
        NSArray *customContentResult = atCustomContentResult[@"items"] ? : @[];
        
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
        config = [[ATShowConfig alloc] initWithScene:scenarioId showCustomExt:extraJsonString];
    }
    return config;
}

#pragma mark - lazy
- (ATFSplashDelegate *)splashAdDelegate {
    if (_splashAdDelegate) return _splashAdDelegate;
    ATFSplashDelegate *splashDelegate = [ATFSplashDelegate new];
    return _splashAdDelegate = splashDelegate;
}

 
@end
