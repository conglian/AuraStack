//
//  ATFInitManger.h
//  Pods-Runner
//
//  Created by GUO PENG on 2021/6/26.
//

#import <Foundation/Foundation.h>
#import <AnyThinkSDK/AnyThinkSDK.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^RequestErrorBlock)(NSError*);

@interface ATFInitManger : NSObject


/// 日志开关,默认为开
+ (void)setLogEnabled:(BOOL)logEnabled;

/// 设置渠道
+ (void)setChannelStr:(NSString *)channelStr;

/// 设置子渠道
+ (void)setSubchannelStr:(NSString *)subchannelStr;

/// 设置自定义规则
+ (void)setCustomDataDic:(NSDictionary *)customDataDic;

/// 设置排除交叉推广APP列表
+ (void)setExludeAppleIdArray:(NSArray *)exludeAppleIdArray;

/// 设置placementid规则
+ (void)setPlacementCustomData:(NSDictionary *)customDataDic placementIDStr:(NSString *)placementIDStr;

///  获取GDPR等级
+ (NSString *)getGDPRLevel;

///  获取用户位置
+ (void)getUserLocation;

///  展示GDPR授权界面
+ (void)showGDPRAuth;

///  展示GDPR+UMP授权界面（兼容不带appId的旧调用）
+ (void)showGDPRConsentDialog;
+ (void)showGDPRConsentDialogWithAppId:(nullable NSString *)appId;

///  展示GDPR+UMP二次确认界面（appId可空，兼容不带appId）
+ (void)showGDPRConsentSecondDialogWithAppId:(nullable NSString *)appId;

///  检查是否为欧盟流量（appId可空，异步回调返回结果）
+ (void)checkIsEuTrafficWithAppId:(nullable NSString *)appId completion:(void (^)(BOOL isEuTraffic))completion;

///  设置GDPR等级
+ (void)setDataConsentSet:(NSString *)gdprLevel;

///  限制这些隐私数据上报
+ (void)setDeniedUploadInfoArray:(NSArray *)infoArray;

///  设置广告源隐私合规策略
+ (void)setAdSourcePrivacyPolicy:(nullable NSString *)policyJson;

///  注册瀑布流过滤器（filterJson 根键 groups；组内 AND、组间 OR；）
+ (void)putFilter:(nullable NSString *)placementId filterJson:(nullable NSString *)filterJson;

///  移除指定广告位的过滤器
+ (void)removeFilterWithPlacementId:(nullable NSString *)placementId;

///  移除所有过滤器
+ (void)removeFilters;

/// 初始化SDK
+ (void)initSDKAppID:(NSString *)appIdStr appKeyStr:(NSString *)appKeyStr requestError:(RequestErrorBlock) requestErrorBlock;

/// 设置预置策略路径
+ (void)setPresetPlacementConfigPath:(NSString *)pathStr;

/// 设置共享广告位配置
+ (void)setSharedPlacementConfig:(NSDictionary *)configDict;

/// 显示debugUI
+ (void)showDebuggerUI:(NSString *)debugKey;

/// 获取sdk版本号
+ (NSString*)getSDKVersionName;

@end

NS_ASSUME_NONNULL_END
