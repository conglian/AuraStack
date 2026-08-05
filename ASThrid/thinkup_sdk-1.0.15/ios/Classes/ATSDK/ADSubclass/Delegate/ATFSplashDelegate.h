//
//  ATFSplashDelegate.h
//  anythink_sdk
//
//  Created by GUO PENG on 2023/9/7.
//

#import <Foundation/Foundation.h>
#import <AnyThinkSDK/AnyThinkSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATFSplashDelegate : NSObject<ATSplashDelegate, ATAdMultipleLoadingDelegate>

@property (nonatomic, copy, nullable) dispatch_block_t splashBottomDidShowBlock;
@property (nonatomic, copy, nullable) dispatch_block_t splashBottomDidHideBlock;

@end

NS_ASSUME_NONNULL_END
