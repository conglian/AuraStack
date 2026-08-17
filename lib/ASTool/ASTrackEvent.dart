abstract final class ASTrackEvent {
  /// 新增
  static const install = 'install';

  /// 前台日活
  static const session = 'session';

  /// 启动页展示
  static const launchPage = 'launch_page';

  /// app启动来源；types：app、noti
  static const launchFrom = 'launch_from';

  /// adjust请求
  static const adjustRequest = 'adjust_req';

  /// adjust成功回调次数；adjust_user：「0」黑名单用户，「1」自然量用户
  static const adjustSuccess = 'adjust_suc';

  /// 首页游戏列表
  static const homePage = 'home_page';

  /// 每日宝箱弹窗展示
  static const dailyBox = 'daily_box';

  /// 每日宝箱点击
  static const dailyBoxClick = 'daily_box_c';

  /// 气泡点击
  static const bubbleClick = 'bubble_c';

  /// 张数获取弹窗展示
  static const sheetNumberPopup = 'sheet_num_pop';

  /// 张数获取弹窗点击get
  static const sheetNumberClick = 'sheet_num_c';

  /// 宝箱弹窗展示
  static const boxPopup = 'box_pop';

  /// 宝箱奖励翻倍点击
  static const boxPopupDoubleClick = 'box_pop_2x';

  /// 宝箱单倍点击
  static const boxPopupSingleClick = 'box_pop_1x';

  /// 刮卡游戏页面上报
  static const scratchPage = 'scratch_page';

  /// 刮卡完成后的行为上报（刮卡次数上报）；types：user、aut
  static const scratchCard = 'scratch_card';

  /// 刮卡弹窗展示；types：scratch、dice、spin；style：uwin、superwin、jacktot
  static const moneyPopup = 'money_pop';

  /// 刮卡弹窗点击翻倍；types：scratch、dice、spin；style：uwin、superwin、jacktot
  static const moneyPopupDoubleClick = 'money_pop_2c';

  /// 刮卡弹窗点击单倍；types：scratch、dice、spin；style：uwin、superwin、jacktot
  static const moneyPopupSingleClick = 'money_pop_1c';

  /// 骰子玩法展示
  static const dicePage = 'dice_page';

  /// 投掷骰子
  static const diceThrow = 'dice_page_throw';

  /// 转盘功能展示
  static const spinPage = 'spin_page';

  /// 猪猪任务页展示
  static const pigTaskPage = 'pig_task_page';

  /// 猪猪任务完成点击领取
  static const pigTaskEndClick = 'pig_task_endc';

  /// 提现页曝光
  static const cashPage = 'cash_page';

  /// 提现页提现按钮点击
  static const cashPageClick = 'cash_page_c';

  /// 提现不足弹窗
  static const cashNotEnoughPopup = 'cash_not_pop';

  /// 提现信息填写
  static const withdrawalInformation = 'withdrawal_information';

  /// 提现任务弹窗
  static const cashTaskPopup = 'cash_task_pop';

  /// 额度提醒弹窗
  static const remindPopup = 'remind_pop';

  /// 额度提醒弹窗点击
  static const remindPopupClick = 'remind_pop_c';

  /// 提现提醒弹窗
  static const meetWithdraw = 'meet_withdraw';

  /// 提现提醒弹窗点击
  static const meetWithdrawClick = 'meet_withdraw_c';

  /// 提现信息确认弹窗
  static const cashConfirmation = 'cash_confirmation';

  /// 翻卡弹窗展示
  static const withdrawalCard = 'withdrawal_card';

  /// 打款申请弹窗
  static const paymentApplication = 'payment_application';

  /// 打款申请弹窗点击按钮
  static const paymentApplicationClick = 'payment_application_c';

  /// 任务完成后的恭喜弹窗
  static const congratulationShow = 'congratulation_s';

  /// 提现排队上报；进入该流程就上报
  static const cashQueue = 'cash_queue';

  /// 排队加速按钮点击
  static const cutIn = 'cut_in';

  /// 排队结束上报，到达100%
  static const cutInEnd = 'cut_inend';

  /// 广告重试弹窗展示
  static const adRetry = 'ad_retry';

  /// 广告重试弹窗点击
  static const adRetryClick = 'ad_retry_c';

  /// 无网络弹窗展示
  static const networkNo = 'network_no';

  /// 无网络弹窗点击
  static const networkNoClick = 'network_no_c';

  /// 通知二次弹窗展示
  static const notificationConfirmPopup = 'noti_confirm_pop';

  /// 通知二次弹窗关闭
  static const notificationConfirmSkip = 'noti_confirm_pop_skip';

  /// 通知二次开启页面允许
  static const notificationConfirmAllow = 'noti_confirm_pop_allow';

  /// 通知二次开启页面成功打开
  static const notificationConfirmSuccess = 'noti_confirm_pop_suc';

  /// 通知二次开启页面打开失败
  static const notificationConfirmFail = 'noti_confirm_pop_fail';

  /// 通知触发；types：noti1、noti2、noti3、unlock、fcm、fixed、media
  static const allNotificationTrigger = 'all_noti_t';

  /// 通知点击；types：noti1、noti2、noti3、unlock、fcm、fixed、media
  static const allNotificationClick = 'all_noti_c';

  /// 终生累计cash到达对应参数值的时候，就打一次；money：100至1000
  static const cashLifetime = 'cash_dall';

  /// 终生累计广告数每隔5上报，上不封顶
  static const adLifetime = 'pv_dall';

  /// 退出弹窗展示
  static const exitPopup = 'exit_pop';

  /// 退出弹窗点击；types：exit、keep
  static const exitPopupClick = 'exit_pop_c';

  /// 安装（自定义）
  static const sessionCustom = 'session_custom';

  /// 判断为异常用户
  static const riskChance = 'risk_chance';

  /// 广告展示次数过多明日再来弹窗
  static const seeYouTomorrow = 'see_you_tommorow';

  /// 广告SDK初始化成功
  static const adInitSuccess = 'ad_initsuc';

  /// 广告发起请求时上报
  static const adRequest = 'ad_request';

  /// 广告成功返回上报
  static const adReturn = 'ad_return';

  /// 广告填充失败时上报
  static const adReturnFail = 'ad_return_fail';

  /// 广告真正展示，每展示一次上报一次
  static const adImpression = 'ad_impression';

  /// 场景即将展示广告，即将展示一次上报一次
  static const adChance = 'ad_chance';

  /// 广告展示失败
  static const adImpressionFail = 'ad_impression_fail';

  /// 广告关闭
  static const adClose = 'ad_close';

  /// 冷启动开屏
  static const launchColdInterstitial = 'olstk_launch_coid_int';

  /// 热启动开屏
  static const launchHotInterstitial = 'olstk_launch_hot_int';

  /// 刮卡获得弹窗点击出激励广告
  static const getCardRewarded = 'olstk_getcard_rv';

  /// 刮卡奖励弹窗点击双倍出激励
  static const cardRewarded = 'olstk_card_rv';

  /// 刮卡奖励弹窗点击单倍概率出插屏
  static const cardInterstitial = 'olstk_card_int';

  /// 宝箱点击claim all出激励广告
  static const boxRewarded = 'olstk_box_rv';

  /// 宝箱点击单个概率出插屏
  static const boxInterstitial = 'olstk_box_int';

  /// 骰子奖励点击2x出激励广告
  static const diceRewarded = 'olstk_dice_rv';

  /// 骰子奖励领取单倍，展示概率插屏广告
  static const diceInterstitial = 'olstk_dice_int';

  /// 转盘奖励点击2x出激励广告
  static const wheelRewarded = 'olstk_wheel_rv';

  /// 转盘奖励领取单倍，展示概率插屏广告
  static const wheelInterstitial = 'olstk_wheel_int';

  /// 点击气泡出激励广告
  static const bubbleRewarded = 'olstk_bubble_rv';

  /// 任务领取概率出插屏
  static const taskInterstitial = 'olstk_task_int';

  /// 提现排队按钮「cut in」点击走激励广告
  static const withdrawalCutInRewarded = 'olstk_wdcut_rv';

  /// 申请请求按钮点击走激励广告
  static const withdrawalApplyRewarded = 'olstk_wdapply_rv';
}
