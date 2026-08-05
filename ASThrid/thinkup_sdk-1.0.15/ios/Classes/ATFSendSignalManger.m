//
//  ATFSendSignalManger.m
//  topon_flutter_plugin
//
//  Created by GUO PENG on 2021/6/28.
//

#import "ATFSendSignalManger.h"
#import "ATFConfiguration.h"
#import <Foundation/Foundation.h>
#import "ATFCommonTool.h"

@interface ATFSendSignalManger ()

@end

@implementation ATFSendSignalManger
+(instancetype) sharedManager {
    static ATFSendSignalManger *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ATFSendSignalManger alloc] init];
    });
    return sharedManager;
}


- (void)sendMethod:(NSString *) methodName arguments:(id) arguments result: (ResultBlock) resultBlock{
    if ([arguments isKindOfClass:[NSDictionary class]]) {
        arguments = [ATFCommonTool dictionaryByRemovingUnsupportedValues:arguments];
    }
    if ([NSThread isMainThread]) {
        [self.methodChannel invokeMethod:methodName arguments:arguments result:resultBlock];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.methodChannel invokeMethod:methodName arguments:arguments result:resultBlock];
        });
    }
}



@end
