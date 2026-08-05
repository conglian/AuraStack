//
//  ATFNativePlatformView.m
//  anythink_sdk
//
//  Created by GUO PENG on 2021/7/12.
//

#import "ATFNativePlatformView.h"
#import "ATFNativeTool.h"
#import "ATFCommonTool.h"
#import "ATFNativeDelegate.h"
#import "ATFNativeTool.h"
#import "ATFNativeSelfRenderView.h"
#import "ATFConfiguration.h"
#import "ATFDisposeDataTool.h"

#define ATFkScreenW ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown ? UIScreen.mainScreen.bounds.size.width : UIScreen.mainScreen.bounds.size.height)

#define ATFkNavigationBarHeight ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown ? ([[UIApplication sharedApplication]statusBarFrame].size.height + 44) : ([[UIApplication sharedApplication]statusBarFrame].size.height - 4))

#define ATFkScreenH ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown ? UIScreen.mainScreen.bounds.size.height : UIScreen.mainScreen.bounds.size.width)

@interface ATFNativePlatformView()

@property(nonatomic, assign)  int64_t viewId;;

@property(nonatomic, strong) id args;

@property(nonatomic, strong) NSObject<FlutterBinaryMessenger> *messenger;

@property(nonatomic, assign) CGRect frame;

@property(nonatomic, strong) ATFNativeDelegate *nativeDelegate;

@property(nonatomic, strong) ATFNativeSelfRenderView *nativeSelfRenderView;

@end

@implementation ATFNativePlatformView

static NSMapTable<NSString *, ATNativeADView *> *ATFPlatformNativeViewMap = nil;
static NSMapTable<NSString *, ATFNativePlatformView *> *ATFPlatformNativeOwnerMap = nil;

+ (void)initialize {
    if (self == [ATFNativePlatformView class]) {
        ATFPlatformNativeViewMap = [NSMapTable strongToWeakObjectsMapTable];
        ATFPlatformNativeOwnerMap = [NSMapTable strongToWeakObjectsMapTable];
    }
}

+ (void)destroyNativeAdViewIfNeeded:(ATNativeADView *)adView {
    if (adView == nil) {
        return;
    }
    SEL destroySelector = NSSelectorFromString(@"destroyNative");
    if ([adView respondsToSelector:destroySelector]) {
        IMP imp = [adView methodForSelector:destroySelector];
        void (*func)(id, SEL) = (void *)imp;
        func(adView, destroySelector);
    }
}

+ (void)removePlatformNativeViewWithPlacementID:(NSString *)placementID {
    if (![placementID isKindOfClass:[NSString class]] || placementID.length == 0) {
        return;
    }
    ATNativeADView *adView = [ATFPlatformNativeViewMap objectForKey:placementID];
    [self destroyNativeAdViewIfNeeded:adView];
    if (adView) {
        [adView removeFromSuperview];
    }
    ATFNativePlatformView *owner = [ATFPlatformNativeOwnerMap objectForKey:placementID];
    if (owner) {
        owner.nativeSelfRenderView = nil;
    }
    [ATFPlatformNativeViewMap removeObjectForKey:placementID];
    [ATFPlatformNativeOwnerMap removeObjectForKey:placementID];
}

- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    
    if (self = [super init]){
        
        self.frame = frame;
        self.viewId = viewId;
        self.args = args;
        self.messenger = messenger;
    }
    return  self;
}

#pragma mark - FlutterPlatformView
- (UIView*)view {
    
    NSDictionary *extraDic;
    if ([self.args isKindOfClass:[NSDictionary class]]) {
        extraDic = (NSDictionary *)self.args;
    }
    
    BOOL isAdaptiveHeight = [extraDic[@"isAdaptiveHeight"] boolValue];
    NSString *placementID = extraDic[@"placementID"];
    NSDictionary *dic = extraDic[@"extraMap"];
    
    NSString *showCustomExt = [ATFCommonTool checkStrParamsEmptyAndReturn:dic[@"showCustomExt"]];
    NSString *sceneID = [ATFCommonTool checkStrParamsEmptyAndReturn:extraDic[@"sceneID"]];
    ATShowConfig *showConfig = [[ATShowConfig alloc] initWithScene:sceneID showCustomExt:showCustomExt];
    
    ATNativeAdOffer *offer = [[ATAdManager sharedManager] getNativeAdOfferWithPlacementID:placementID showConfig:showConfig];
    if (offer == nil) {
        UILabel *label = [[UILabel alloc]init];
        label.text = @"Ad offer is empty";
        return label;
    }
    
    ATNativeADConfiguration *config = [ATFNativeTool getATNativeADConfiguration:dic isAdaptiveHeight:isAdaptiveHeight];
    config.delegate = self.nativeDelegate;
    ATFLog(@"原生广告--是否为模板广告:%d-平台:%ld-size宽:%f 高:%f",offer.nativeAd.isExpressAd,offer.networkFirmID,offer.nativeAd.nativeExpressAdViewWidth,offer.nativeAd.nativeExpressAdViewHeight);

    BOOL isExpressAd = offer.nativeAd.isExpressAd;
    ATFNativeSelfRenderView *selfRenderView = nil;
    if (!isExpressAd) {
        selfRenderView = [self getSelfRenderViewOffer:offer];
        [selfRenderView setUIWidget:dic];
    }

    ATNativeADView *adView = [self getNativeADView:config offer:offer selfRenderView:selfRenderView withPlacementId:placementID extraDic:dic];
    if (!isExpressAd) {
        [self prepareWithNativePrepareInfo:selfRenderView nativeADView:adView];
    }
    [offer rendererWithConfiguration:config selfRenderView:(isExpressAd ? nil : selfRenderView) nativeADView:adView];
    if (!isExpressAd) {
        adView.logoImageView.hidden = selfRenderView.isHiddenLogo;
    }
    
    
    if (adView != nil) {
        [ATFPlatformNativeViewMap setObject:adView forKey:placementID];
        [ATFPlatformNativeOwnerMap setObject:self forKey:placementID];
        return adView;
    }else{
        UILabel *label = [[UILabel alloc]init];
        label.text = @"Ad view failed to load";
        return label;
    }
}

- (ATFNativeSelfRenderView *)getSelfRenderViewOffer:(ATNativeAdOffer *)offer{
    ATFNativeSelfRenderView *selfRenderView = [[ATFNativeSelfRenderView alloc]initWithOffer:offer];
    self.nativeSelfRenderView = selfRenderView;
    return selfRenderView;
}

- (ATNativeADView *)getNativeADView:(ATNativeADConfiguration *)config offer:(ATNativeAdOffer *)offer selfRenderView:(ATFNativeSelfRenderView *)selfRenderView withPlacementId:(NSString*)placementID extraDic:(NSDictionary *) extraDic {
    
    ATNativeADView *nativeADView = [[ATNativeADView alloc]initWithConfiguration:config currentOffer:offer placementID:placementID];
    if (selfRenderView == nil) {
        return nativeADView;
    }

    UIView *mediaView = [nativeADView getMediaView];

    NSMutableArray *array = [@[selfRenderView.iconImageView,selfRenderView.titleLabel,selfRenderView.textLabel,selfRenderView.ctaLabel,selfRenderView.mainImageView] mutableCopy];

    if (mediaView) {
        [array addObject:mediaView];
        selfRenderView.mediaView = mediaView;
        [selfRenderView addSubview:mediaView];
        // setUIWidget is called before mediaView is injected, so we must
        // re-apply layout here to keep mediaView aligned with mainImageView.
        [selfRenderView setUIWidget:extraDic];
        selfRenderView.mediaView.frame = selfRenderView.mainImageView.frame;
    }
    
    NSArray<ATFNativeAttributeMode *> *modes = [ATFDisposeDataTool disposeCustomViewNativeData:extraDic keyStr:@"customView"];
    [modes enumerateObjectsUsingBlock:^(ATFNativeAttributeMode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ATFNativeAttributeModeType type = (ATFNativeAttributeModeType)obj.type.integerValue;
        switch (type) {
            case ATFNativeAttributeModeTypeImage: {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:obj.imagePath]];
                if (obj.backgroundColorStr && ![obj.backgroundColorStr isEqualToString:@""]) {
                    imageView.backgroundColor = [ATFCommonTool colorWithHexString:obj.backgroundColorStr];
                }
                imageView.frame = CGRectMake(obj.x, obj.y, obj.width, obj.height);
                if (obj.cornerRadius > 0) {
                    imageView.layer.cornerRadius = obj.cornerRadius;
                    imageView.layer.masksToBounds = YES;
                }
                [selfRenderView addSubview:imageView];
                [selfRenderView.customViews addObject:imageView];
            }
                break;
            case ATFNativeAttributeModeTypeLabel: {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(obj.x, obj.y, obj.width, obj.height)];
                if (obj.backgroundColorStr && ![obj.backgroundColorStr isEqualToString:@""]) {
                    label.backgroundColor = [ATFCommonTool colorWithHexString:obj.backgroundColorStr];
                }
                label.text = obj.title;
                label.textColor = [ATFCommonTool colorWithHexString:obj.textColorStr];
                if (obj.cornerRadius > 0) {
                    label.layer.cornerRadius = obj.cornerRadius;
                    label.layer.masksToBounds = YES;
                }
                label.font = [UIFont systemFontOfSize:obj.textSize];
                if ([obj.textAlignmentStr isEqualToString:@"left"]) {
                    label.textAlignment = NSTextAlignmentLeft;
                }
                if ([obj.textAlignmentStr isEqualToString:@"center"]) {
                    label.textAlignment = NSTextAlignmentCenter;
                }
                if ([obj.textAlignmentStr isEqualToString:@"right"]) {
                    label.textAlignment = NSTextAlignmentRight;
                }
                [selfRenderView addSubview:label];
                [selfRenderView.customViews addObject:label];
            }
                break;
            case ATFNativeAttributeModeTypeView: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(obj.x, obj.y, obj.width, obj.height)];
                if (obj.backgroundColorStr && ![obj.backgroundColorStr isEqualToString:@""]) {
                    view.backgroundColor = [ATFCommonTool colorWithHexString:obj.backgroundColorStr];
                }
                
                if (obj.cornerRadius > 0) {
                    view.layer.cornerRadius = obj.cornerRadius;
                    view.layer.masksToBounds = YES;
                }
                
                [selfRenderView addSubview:view];
                [selfRenderView.customViews addObject:view];
            }
                break;
                
            default:
                break;
        }
    }];
    
    [array addObjectsFromArray:selfRenderView.customViews];
    
    
    [nativeADView registerClickableViewArray:array];
    return nativeADView;
}

- (void)prepareWithNativePrepareInfo:(ATFNativeSelfRenderView *)selfRenderView nativeADView:(ATNativeADView *)nativeADView{
    
    ATNativePrepareInfo *info = [ATNativePrepareInfo loadPrepareInfo:^(ATNativePrepareInfo * _Nonnull prepareInfo) {
        prepareInfo.textLabel = selfRenderView.textLabel;
        prepareInfo.advertiserLabel = selfRenderView.advertiserLabel;
        prepareInfo.titleLabel = selfRenderView.titleLabel;
        prepareInfo.ratingLabel = selfRenderView.ratingLabel;
        prepareInfo.iconImageView = selfRenderView.iconImageView;
        prepareInfo.mainImageView = selfRenderView.mainImageView;
//        prepareInfo.logoImageView = selfRenderView.logoImageView;
        prepareInfo.dislikeButton = selfRenderView.dislikeButton;
        prepareInfo.ctaLabel = selfRenderView.ctaLabel;
        prepareInfo.mediaView = selfRenderView.mediaView;
    }];
    [nativeADView prepareWithNativePrepareInfo:info];
}

#pragma mark - lazy
- (ATFNativeDelegate *)nativeDelegate {

    if (_nativeDelegate) return _nativeDelegate;

    ATFNativeDelegate *nativeDelegate = [ATFNativeDelegate new];

    return _nativeDelegate = nativeDelegate;
}
@end
