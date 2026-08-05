//
//  ATFPlatfromNativeManger.m
//  anythink_sdk
//
//  Created by GUO PENG on 2021/7/12.
//

#import "ATFPlatfromNativeManger.h"
#import "ATFNativeDelegate.h"
#import "ATFDisposeDataTool.h"
#import "ATFCommonTool.h"
#import "ATFConfiguration.h"


@interface ATFPlatfromNativeManger()

@property(nonatomic, strong) ATFNativeDelegate *nativeDelegate;


@end


@implementation ATFPlatfromNativeManger


/// 加载原生广告
- (void)loadNativeWith:(NSString *)placementID extraDic:(NSDictionary *)extraDic{
    [[ATAdManager sharedManager] setMultipleLoadingDelegate:self.nativeDelegate placementId:placementID];

    ATFNativeAttributeMode *parentMode = [ATFDisposeDataTool disposeNativeData:extraDic keyStr:NativeSize];
    BOOL isAdaptiveHeight = NO;
    if ([extraDic[IsAdaptiveHeight] respondsToSelector:@selector(boolValue)]) {
        isAdaptiveHeight = [extraDic[IsAdaptiveHeight] boolValue];
    }
    NSDictionary *mediaViewFrameDic = [extraDic[MediaViewFrame] isKindOfClass:[NSDictionary class]] ? extraDic[MediaViewFrame] : nil;
    ATFLog(@"原生广告--加载的大小-2--%@",NSStringFromCGSize(CGSizeMake(parentMode.width, parentMode.height)));
    NSMutableDictionary *loadExtra = [@{
        kATExtraInfoNativeAdSizeKey:[NSValue valueWithCGSize:CGSizeMake(parentMode.width, parentMode.height)],
        kATNativeAdSizeToFitKey:@(isAdaptiveHeight),
    } mutableCopy];
    if (mediaViewFrameDic.count > 0) {
        ATFNativeAttributeMode *mediaViewFrameMode = [ATFDisposeDataTool disposeNativeData:extraDic keyStr:MediaViewFrame];
        loadExtra[kATExtraInfoMediaViewFrameKey] = [NSValue valueWithCGRect:CGRectMake(mediaViewFrameMode.x, mediaViewFrameMode.y, mediaViewFrameMode.width, mediaViewFrameMode.height)];
    }
    [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:loadExtra delegate:self.nativeDelegate];
}


#pragma mark - lazy
- (ATFNativeDelegate *)nativeDelegate {

    if (_nativeDelegate) return _nativeDelegate;

    ATFNativeDelegate *nativeDelegate = [ATFNativeDelegate new];

    return _nativeDelegate = nativeDelegate;
}

@end
