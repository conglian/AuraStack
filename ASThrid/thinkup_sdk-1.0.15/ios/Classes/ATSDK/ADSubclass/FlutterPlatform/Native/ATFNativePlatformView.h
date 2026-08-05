//
//  ATFNativePlatformView.h
//  anythink_sdk
//
//  Created by GUO PENG on 2021/7/12.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATFNativePlatformView : NSObject<FlutterPlatformView>
- (instancetype)initWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger;


- (UIView*)view;

/// Remove cached PlatformView native ad view by placementID.
+ (void)removePlatformNativeViewWithPlacementID:(NSString *)placementID;

@end

NS_ASSUME_NONNULL_END
