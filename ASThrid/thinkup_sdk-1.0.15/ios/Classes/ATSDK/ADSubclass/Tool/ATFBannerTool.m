//
//  ATFBannerTool.m
//  anythink_sdk
//
//  Created by GUO PENG on 2021/7/12.
//

#import "ATFBannerTool.h"
#import "ATFCommonTool.h"
#import <AnyThinkSDK/AnyThinkSDK.h>

#define ATFBannerAdLoadingExtraBannerAdSizeStruct  @"size"

@implementation ATFBannerTool
/// 解析flutter端参数,获取bannerView的rect
+ (CGRect)getSizeFromExtraDic:(NSDictionary *)extraDic{
    
    NSNumber *widthNumeber = [NSNumber numberWithDouble:[ATFCommonTool getRootViewController].view.frame.size.width];
    NSNumber *heightNumeber = [NSNumber numberWithDouble:250.f];
    
    NSNumber *x = [NSNumber numberWithDouble:0.0f];
    
    NSNumber *y = [NSNumber numberWithDouble:0.0f];

    if ([extraDic.allKeys containsObject:ATFBannerAdLoadingExtraBannerAdSizeStruct] &&extraDic[ATFBannerAdLoadingExtraBannerAdSizeStruct][@"width"] != nil ) {
        
        x = extraDic[ATFBannerAdLoadingExtraBannerAdSizeStruct][@"x"];
        y = extraDic[ATFBannerAdLoadingExtraBannerAdSizeStruct][@"y"];
        widthNumeber = extraDic[ATFBannerAdLoadingExtraBannerAdSizeStruct][@"width"];
        heightNumeber = extraDic[ATFBannerAdLoadingExtraBannerAdSizeStruct][@"height"];
    }
    
    return  CGRectMake([x doubleValue], [y doubleValue], [widthNumeber doubleValue], [heightNumeber doubleValue]);
}


/// 获取BannerView
+ (ATBannerView *)getBannerViewAdRect:(CGRect)rect placementID:(NSString *)placementID sceneID:(NSString * _Nullable)sceneID showCustomExt:(NSString * _Nullable)showCustomExt {
    
    if (kATFStringIsEmpty(placementID)) {
        return nil;
    }
    
    if (kATFStringIsEmpty(sceneID)) {
        sceneID = @"";
    }
    
    if (kATFStringIsEmpty(showCustomExt)) {
        showCustomExt = @"";
    }
    
    ATShowConfig *showConfig;
    ATBannerView *bannerView;
    
    NSDictionary *showCongifDict = ([showCustomExt isKindOfClass:[NSString class]] && [showCustomExt dataUsingEncoding:NSUTF8StringEncoding] != nil) ? [NSJSONSerialization JSONObjectWithData:[showCustomExt dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil] : nil;
    if (showCongifDict) {
        NSString *scenarioId = showCongifDict[@"tkExtraJson"] ? : sceneID;
        if (scenarioId.length == 0) {
            scenarioId = showCongifDict[@"Scenario"] ? : sceneID;
        }
        NSString *showCustomExt_inDict = showCongifDict[@"showCustomExt"] ? : @"";
        NSDictionary *atCustomContentResult = showCongifDict[@"atCustomContentResult"] ? : @{};
        NSArray *customContentResult = atCustomContentResult[@"items"] ? : @[];
          
        if (customContentResult > 0) {
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
            showConfig = [[ATShowConfig alloc] initWithScene:scenarioId showCustomExt:showCustomExt_inDict customContentResult:contentResult];
        } else {
            showConfig = [[ATShowConfig alloc] initWithScene:scenarioId showCustomExt:showCustomExt_inDict];
        }
    } else {
        if (showCustomExt.length > 0) {
            showConfig = [[ATShowConfig alloc] initWithScene:sceneID showCustomExt:showCustomExt];
        }
    }
    if (showConfig) {
        bannerView = [[ATAdManager sharedManager] retrieveBannerViewForPlacementID:placementID config:showConfig];
    } else {
        bannerView = [[ATAdManager sharedManager] retrieveBannerViewForPlacementID:placementID scene:sceneID];
    } 
  
    bannerView.frame = rect;
    
    return bannerView;
    
}


/// 横幅广告是否准备好
+ (BOOL)bannerAdReady:(NSString *)placementID{
    
    BOOL isReady =[[ATAdManager sharedManager] bannerAdReadyForPlacementID:placementID];
    return  isReady;
}

/// 获取当前广告位下所有可用广告的信息
+ (NSString *)getBannerValidAds:(NSString *)placementID{
    
    NSArray *array = [[ATAdManager sharedManager] getBannerValidAdsForPlacementID:placementID];
      NSString *str = [ATFCommonTool toReadableJSONString:array];
      return str;
}


/// 获取广告位的状态
+ (NSDictionary *)checkBannerLoadStatus:(NSString *)placementID{
    
    ATCheckLoadModel *model = [[ATAdManager sharedManager] checkBannerLoadStatusForPlacementID:placementID];
    
    NSDictionary *dic = [ATFCommonTool objectToJSONString:model];
    return  dic;
}



@end
