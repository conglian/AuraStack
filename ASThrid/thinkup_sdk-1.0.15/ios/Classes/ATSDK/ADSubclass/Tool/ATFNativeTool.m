//
//  ATFNativeTool.m
//  anythink_sdk
//
//  Created by GUO PENG on 2021/7/12.
//

#import "ATFNativeTool.h"
#import "ATFConfiguration.h"
#import "ATFCommonTool.h"
#import "ATFNativeAttributeMode.h"


@implementation ATFNativeTool

+ (ATNativeADConfiguration *)getATNativeADConfiguration:(NSDictionary *)extraDic{
    return [self getATNativeADConfiguration:extraDic isAdaptiveHeight:NO];
}

+ (ATFNativeAttributeMode *)nativeModeFromExtraDic:(NSDictionary *)extraDic key:(NSString *)key {
    ATFNativeAttributeMode *nativeAttributeMode = [[ATFNativeAttributeMode alloc] init];
    if (![extraDic isKindOfClass:[NSDictionary class]]) {
        return nativeAttributeMode;
    }
    id value = extraDic[key];
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nativeAttributeMode;
    }
    [nativeAttributeMode setValuesForKeysWithDictionary:(NSDictionary *)value];
    return nativeAttributeMode;
}

+ (ATNativeADConfiguration *)getATNativeADConfiguration:(NSDictionary *)extraDic isAdaptiveHeight:(BOOL)isAdaptiveHeight{
    
    ATFNativeAttributeMode *parentMode = [self nativeModeFromExtraDic:extraDic key:Parent];
    ATFNativeAttributeMode *mainImageMode = [self nativeModeFromExtraDic:extraDic key:MainImage];
    ATFNativeAttributeMode *adLogoMode = [self nativeModeFromExtraDic:extraDic key:AdLogo];
    
    UIViewController *tempController = [ATFCommonTool getRootViewController];
    
    ATNativeADConfiguration *config = [[ATNativeADConfiguration alloc] init];
    config.ADFrame = CGRectMake(parentMode.x, parentMode.y, parentMode.width, parentMode.height);
    ATFLog(@"原生广告--Config-WidgetShow-frame:%@",NSStringFromCGRect(config.ADFrame));
    config.mediaViewFrame = CGRectMake(mainImageMode.x, mainImageMode.y, mainImageMode.width, mainImageMode.height);
    config.rootViewController = tempController;
    config.logoViewFrame = CGRectMake(adLogoMode.x, adLogoMode.y, adLogoMode.width, adLogoMode.height);
    config.sizeToFit = isAdaptiveHeight;
    return  config;
}


/// 原生广告是否准备好
+ (BOOL)nativeAdReady:(NSString *)placementID{

    BOOL isReady = [[ATAdManager sharedManager] nativeAdReadyForPlacementID:placementID];
    return  isReady;
}

/// 获取当前广告位下所有可用广告的信息，v5.7.53及以上版本支持
+ (NSString *)getNativeValidAds:(NSString *)placementID{

    NSArray *array = [[ATAdManager sharedManager] getNativeValidAdsForPlacementID:placementID];
      NSString *str = [ATFCommonTool toReadableJSONString:array];
      return str;
}


/// 获取原生广告位的状态
+ (NSDictionary *)checkNativeLoadStatus:(NSString *)placementID{
    
    ATCheckLoadModel *model = [[ATAdManager sharedManager] checkNativeLoadStatusForPlacementID:placementID];
    NSDictionary *dic = [ATFCommonTool objectToJSONString:model];
    return  dic;
}

@end
