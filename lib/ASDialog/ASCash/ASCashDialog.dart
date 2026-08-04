import 'package:aurastack/ASTool/as_LocalProvider.dart';
import 'package:aurastack/ASTool/as_extension_help.dart';
import 'package:aurastack/ASTool/as_img.dart';
import 'package:aurastack/ASTool/as_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../ASTool/as_spine_tool.dart';
import '../../ASTool/as_stroke_text.dart';

// 余额不足
class ASCashOutDialog extends StatefulWidget {
  const ASCashOutDialog({super.key});

  @override
  State<ASCashOutDialog> createState() => ASCashOutDialogState();
}

class ASCashOutDialogState extends State<ASCashOutDialog>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Row(
              children: [
                Spacer(),
                ParticleButton(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: ASImg(name: 'as_close_w', width: 18, height: 18),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, 0);
                  },
                ),
                SizedBox(width: 32.w),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: 347,
              height: 342,
              decoration: BoxDecoration(image: ASDImg('as_tx_fa_bg')),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ASText(
                    text: 'Account Security Restriction',
                    size: 20,
                    color: '#FFFFFF'.color(),
                    weight: FontWeight.w700,
                  ),
                  SizedBox(height: 31),
                  SizedBox(
                    width: 168,
                    height: 168,
                    child: Center(child: ASImg(name: 'as_not_cash_icon')),
                  ),
                  SizedBox(
                    width: 248,
                    height: 40,
                    child: Center(
                      child: ASText(
                        text: 'for security, the minimum Withdrawal is \$1000',
                        size: 18,
                        color: '#4A474B'.color(),
                        weight: FontWeight.w600,
                        maxLines: 2,
                        align: .center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 27.h),
            ParticleButton(
              onTap: () {
                Navigator.pop(context, 0);
              },
              child: Container(
                width: 287,
                height: 55,
                decoration: BoxDecoration(image: ASDImg('as_yellow_btn_bg')),
                child: Center(
                  child: ASText(
                    text: 'Making Money',
                    size: 24,
                    color: '#5C300E'.color(),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 88.h),
          ],
        ),
      ],
    );
  }
}

// 发起体现
class ASTXSubmitDialog extends StatefulWidget {
  const ASTXSubmitDialog({super.key});

  @override
  State<ASTXSubmitDialog> createState() => ASTXSubmitDialogState();
}

class ASTXSubmitDialogState extends State<ASTXSubmitDialog>
    with SingleTickerProviderStateMixin {
  int seletcd_row = 0;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Row(
              children: [
                Spacer(),
                ParticleButton(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: ASImg(name: 'as_close_w', width: 18, height: 18),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, 0);
                  },
                ),
                SizedBox(width: 32.w),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: 347,
              height: 374,
              decoration: BoxDecoration(image: ASDImg('as_tx_fa_bg')),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ASText(
                    text: 'Payment Information',
                    size: 20,
                    color: '#FFFFFF'.color(),
                    weight: FontWeight.w700,
                  ),
                  SizedBox(height: 25),
                  ParticleButton(
                    child: ASImg(
                      name: 'as_act_0_${seletcd_row == 0 ? 's' : 'n'}',
                      width: 253,
                      height: 60,
                    ),
                    onTap: () async {
                      setState(() {
                        seletcd_row = 0;
                      });
                      await ASLocalProvider.instance.updateint(
                        ASLocalProvider.instance.as_tx_ing_accountName,
                        0,
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  ParticleButton(
                    child: ASImg(
                      name: 'as_act_1_${seletcd_row == 1 ? 's' : 'n'}',
                      width: 253,
                      height: 60,
                    ),
                    onTap: () async {
                      setState(() {
                        seletcd_row = 1;
                      });
                      await ASLocalProvider.instance.updateint(
                        ASLocalProvider.instance.as_tx_ing_accountName,
                        1,
                      );
                    },
                  ),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      SizedBox(width: 32.w),
                      ASText(
                        text: 'Account/Phone',
                        size: 14,
                        color: '#000000'.color(),
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 287,
                    height: 48,
                    decoration: BoxDecoration(
                      color: '#E3E3E3'.color(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Please Input Your Account ID', // 占位符文案
                        hintStyle: TextStyle(
                          color: '#ACACAC'.color(), // 占位符文案颜色
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none, // 移除默认边框
                      ),
                      style: TextStyle(
                        color: Color(0xFF000000), // 输入文字颜色
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 17),
                  Row(
                    children: [
                      SizedBox(width: 32.w),
                      ASText(
                        text: 'Direct to Your paypal  Instant Payment',
                        size: 12,
                        color: '#4A474B'.color(),
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 27.h),
            ParticleButton(
              onTap: () {
                Navigator.pop(context, 0);
              },
              child: Container(
                width: 287,
                height: 55,
                decoration: BoxDecoration(image: ASDImg('as_yellow_btn_bg')),
                child: Center(
                  child: ASText(
                    text: 'Submit',
                    size: 24,
                    color: '#5C300E'.color(),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 88.h),
          ],
        ),
      ],
    );
  }
}

// Human Verrification
class ASTXHumanDialog extends StatefulWidget {
  const ASTXHumanDialog({super.key});

  @override
  State<ASTXHumanDialog> createState() => ASTXHumanDialogState();
}

class ASTXHumanDialogState extends State<ASTXHumanDialog>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Row(
              children: [
                Spacer(),
                ParticleButton(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: ASImg(name: 'as_close_w', width: 18, height: 18),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, 0);
                  },
                ),
                SizedBox(width: 32.w),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: 347,
              height: 260,
              decoration: BoxDecoration(image: ASDImg('cs_hum_bg')),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ASText(
                    text: 'Human Verification',
                    size: 20,
                    color: '#FFFFFF'.color(),
                    weight: FontWeight.w700,
                  ),
                  SizedBox(height: 42),
                  Row(
                    children: [
                      SizedBox(width: 32.w),
                      SizedBox(
                        width: 264,
                        height: 40,
                        child: ASText(
                          text:
                              'Please complete human verification before withdrawing.',
                          size: 16,
                          color: '#4A474B'.color(),
                          weight: FontWeight.w600,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 22),
                  Container(
                    width: 287,
                    height: 54,
                    decoration: BoxDecoration(
                      color: '#EFEFEF'.color(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 6.w),
                        ASImg(name: 'as_tx_box_icon', width: 46, height: 46),
                        SizedBox(width: 8.w),
                        ASText(
                          text: 'Chests：0/10 Treasure Chests',
                          size: 14,
                          color: '#000000'.color(),
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 27.h),
            ParticleButton(
              onTap: () {
                Navigator.pop(context, 0);
              },
              child: Container(
                width: 287,
                height: 55,
                decoration: BoxDecoration(image: ASDImg('as_yellow_btn_bg')),
                child: Center(
                  child: ASText(
                    text: 'Confirm',
                    size: 24,
                    color: '#5C300E'.color(),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 88.h),
          ],
        ),
      ],
    );
  }
}

// 安全提示
class ASTXAccountsecurityDialog extends StatefulWidget {
  const ASTXAccountsecurityDialog({super.key});

  @override
  State<ASTXAccountsecurityDialog> createState() =>
      ASTXAccountsecurityDialogState();
}

class ASTXAccountsecurityDialogState extends State<ASTXAccountsecurityDialog>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Row(
              children: [
                Spacer(),
                ParticleButton(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: ASImg(name: 'as_close_w', width: 18, height: 18),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, 0);
                  },
                ),
                SizedBox(width: 32.w),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: 339,
              height: 300,
              decoration: BoxDecoration(image: ASDImg('as_an_bg')),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ASText(
                    text: 'Account Security Restrictions',
                    size: 20,
                    color: '#FFFFFF'.color(),
                    weight: FontWeight.w700,
                  ),
                  SizedBox(height: 35),
                  ASImg(name: 'as_an_icon', width: 99, height: 121),
                  SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: text_fontName,
                        color: '#4A474B'.color(),
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'For Security,\nThe Minimum Withdrawal is  ',
                        ),
                        TextSpan(
                          text: '\$1000',
                          style: TextStyle(
                            color: '#1C7931'.color(),
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 27.h),
            ParticleButton(
              onTap: () {
                Navigator.pop(context, 0);
              },
              child: Container(
                width: 287,
                height: 55,
                decoration: BoxDecoration(image: ASDImg('as_yellow_btn_bg')),
                child: Center(
                  child: ASText(
                    text: 'Making Money',
                    size: 24,
                    color: '#5C300E'.color(),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 88.h),
          ],
        ),
      ],
    );
  }
}

// 任务完成
class ASTXATaskEndDialog extends StatefulWidget {
  const ASTXATaskEndDialog({super.key});

  @override
  State<ASTXATaskEndDialog> createState() => ASTXATaskEndDialogState();
}

class ASTXATaskEndDialogState extends State<ASTXATaskEndDialog>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Row(
              children: [
                Spacer(),
                ParticleButton(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: ASImg(name: 'as_close_w', width: 18, height: 18),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, 0);
                  },
                ),
                SizedBox(width: 32.w),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: 339,
              height: 334,
              decoration: BoxDecoration(image: ASDImg('as_taskEnd_bg')),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ASText(
                    text: 'Application Successful',
                    size: 20,
                    color: '#FFFFFF'.color(),
                    weight: FontWeight.w700,
                  ),
                  SizedBox(height: 29),
                  ASImg(name: 'as_task_end_icon', width: 122, height: 130),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(width: 28.w),
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: text_fontName,
                            color: '#4A474B'.color(),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  '· 7-14 working days after application.\n· A 1% fee applies per withdrawal.\n· Keep growing your wealth while\nyou wait.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 27.h),
            ParticleButton(
              onTap: () {
                Navigator.pop(context, 0);
              },
              child: Container(
                width: 287,
                height: 55,
                decoration: BoxDecoration(image: ASDImg('as_yellow_btn_bg')),
                child: Center(
                  child: ASText(
                    text: 'Play More',
                    size: 24,
                    color: '#5C300E'.color(),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 88.h),
          ],
        ),
      ],
    );
  }
}

/// 提现提醒
class ASTXTipsDialog extends StatefulWidget {
  const ASTXTipsDialog({super.key});

  @override
  State<ASTXTipsDialog> createState() => ASTXTipsDialogState();
}

class ASTXTipsDialogState extends State<ASTXTipsDialog>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          width: 0.width(context),
          height: 0.height(context),
          child: ASSpine(path: 'caidai'.spinepaths()),
        ),
        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            ASImg(name: 'as_tx_tip_top', width: 298, height: 36),
            SizedBox(height: 38.h),
            ASImg(name: 'as_tx_tip_icon', width: 177, height: 177),
            SizedBox(
              width: 318,
              height: 78,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w900,
                    fontFamily: text_fontName,
                    color: '#FFFFFF'.color(),
                  ),
                  children: <TextSpan>[
                    TextSpan(text: "Your effort has paid off! You've earned "),
                    TextSpan(
                      text: '\$1000 ',
                      style: TextStyle(color: '#FFE100'.color()),
                    ),
                    TextSpan(text: 'and are ready to withdraw.'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 36.h),
            ParticleButton(
              onTap: () {
                Navigator.pop(context, 1);
              },
              child: Container(
                width: 339,
                height: 55,
                decoration: BoxDecoration(image: ASDImg('as_yellow_btn_bg')),
                child: Center(
                  child: ASText(
                    text: 'Claim My Reward',
                    size: 24,
                    color: '#5C300E'.color(),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            ASUnderlineTextButton(
              text: 'Later On',
              fontSize: 16,
              textColor: '#CEC4D5'.color(),
              underlineColor: '#CEC4D5'.color(),
              onPressed: () {
                Navigator.pop(context, 0);
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// 提现信息
class ASTXInfoDialog extends StatefulWidget {
  const ASTXInfoDialog({super.key});

  @override
  State<ASTXInfoDialog> createState() => ASTXInfoDialogState();
}

class ASTXInfoDialogState extends State<ASTXInfoDialog>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Row(
              children: [
                Spacer(),
                ParticleButton(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: ASImg(name: 'as_close_w', width: 18, height: 18),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, 0);
                  },
                ),
                SizedBox(width: 32.w),
              ],
            ),
            SizedBox(height: 12.h),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w900,
                  fontFamily: text_fontName,
                  color: '#FFFFFF'.color(),
                ),
                children: <TextSpan>[
                  TextSpan(text: "Please Verify Your "),
                  TextSpan(
                    text: 'Payout Account!',
                    style: TextStyle(color: '#FFEA00'.color()),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              width: 313.w,
              height: 506.h,
              decoration: BoxDecoration(image: ASDImg('as_txinfo_bg')),
              child: Column(
                children: [
                  SizedBox(height: 72.h),
                  Row(
                    children: [
                      SizedBox(width: 37.w),
                      ASText(
                        text: '\$1000',
                        size: 48,
                        color: '#FFFFFF'.color(),
                        weight: FontWeight.w700,
                      ),
                    ],
                  ),
                  SizedBox(height: 60.h),
                  Row(
                    children: [
                      SizedBox(width: 22.w),
                      ASText(
                        text: 'Payout Platform',
                        size: 14.spMax,
                        color: '#63636F'.color(),
                        weight: FontWeight.w400,
                      ),
                      Spacer(),
                      ASText(
                        text: 'AuraStack',
                        size: 14.spMax,
                        color: '#191B3F'.color(),
                        weight: FontWeight.w400,
                      ),
                      SizedBox(width: 22.w),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      SizedBox(width: 22.w),
                      ASText(
                        text: 'Payout Instructions',
                        size: 14.spMax,
                        color: '#63636F'.color(),
                        weight: FontWeight.w400,
                      ),
                      Spacer(),
                      ASText(
                        text: 'Game Rewards',
                        size: 14.spMax,
                        color: '#191B3F'.color(),
                        weight: FontWeight.w400,
                      ),
                      SizedBox(width: 22.w),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      SizedBox(width: 22.w),
                      ASText(
                        text: 'Creation Time',
                        size: 14.spMax,
                        color: '#63636F'.color(),
                        weight: FontWeight.w400,
                      ),
                      Spacer(),
                      ASText(
                        text: formatNow(),
                        size: 14.spMax,
                        color: '#191B3F'.color(),
                        weight: FontWeight.w400,
                      ),
                      SizedBox(width: 22.w),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      SizedBox(width: 22.w),
                      ASText(
                        text: 'Account Information',
                        size: 14.spMax,
                        color: '#63636F'.color(),
                        weight: FontWeight.w400,
                      ),
                      Spacer(),
                      ASText(
                        text: ASLocalProvider.instance.as_account_id.isEmpty
                            ? 'Submit later'
                            : ASLocalProvider.instance.as_account_id,
                        size: 14.spMax,
                        color: '#191B3F'.color(),
                        weight: FontWeight.w400,
                      ),
                      SizedBox(width: 22.w),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      SizedBox(width: 22.w),
                      ASText(
                        text: 'Frequency',
                        size: 14.spMax,
                        color: '#63636F'.color(),
                        weight: FontWeight.w400,
                      ),
                      Spacer(),
                      ASText(
                        text: 'One Time',
                        size: 14.spMax,
                        color: '#191B3F'.color(),
                        weight: FontWeight.w400,
                      ),
                      SizedBox(width: 22.w),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      SizedBox(width: 22.w),
                      ASText(
                        text: 'Payment Method',
                        size: 14.spMax,
                        color: '#63636F'.color(),
                        weight: FontWeight.w400,
                      ),
                      Spacer(),
                      ASImg(
                        name:
                            'as_txinfo_${ASLocalProvider.instance.as_tx_ing_account}',
                        width: 77.w,
                        height: 22.h,
                      ),
                      SizedBox(width: 22.w),
                    ],
                  ),
                  SizedBox(height: 28.h),
                  Container(
                    width: 288,
                    height: 55,
                    decoration: BoxDecoration(image: ASDImg('as_zis_bg')),
                    child: ParticleButton(
                      child: Center(
                        child: ASText(
                          text: 'Confirm',
                          size: 24,
                          color: '#FFFFFF'.color(),
                          weight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, 1);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String formatNow() {
    final now = DateTime.now();

    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return "$year.$month.$day $hour:$minute";
  }
}
