import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'ASTBAEventTool.dart';
import 'as_extension_help.dart';


class ASLocalProvider extends ChangeNotifier {
  // 1. 私有构造函数（禁止外部直接创建实例）
  ASLocalProvider._();

  // 2. 静态单例实例
  static final ASLocalProvider _instance = ASLocalProvider._();

  // 3. 提供全局访问点
  static ASLocalProvider get instance => _instance;

  String as_account_id = '';
  String as_tx_list = "";
  String as_ratio_str = "90";

  bool as_bg_music = true; // 存储的本地值
  bool as_sound_music = true; // 存储的本地值
  bool as_login_status = false; // 存储的本地值
  bool as_scratch_status_0 = true;
  bool as_scratch_status_1 = true;
  bool as_scratch_status_2 = true;
  bool as_scratch_status_3 = true;
  bool as_scratch_status_4 = true;
  bool as_scratch_status_5 = true;
  bool as_scratch_status_6 = true;
  bool as_scratch_status_7 = true;
  bool as_scratch_status_8 = true;
  bool as_scratch_guide = true;
  bool as_old_guide = true;
  bool as_new_guide = false;
  bool is_end_Scratch = true;
  bool as_show_dolas_ani = false;
  bool as_show_bubble = false;
  bool as_show_box_guide = false;
  bool as_cloak_status = false;
  bool as_fk_number_status = false;
  bool as_fk_decvice_status = false;
  bool as_fk_ip_status = false;
  bool as_fk_ad_short_show = false;
  bool as_fk_ad_short_close = false;
  bool as_dolas_800 = false;
  bool as_dolas_1000 = false;
  bool as_yunying_3 = false;
  bool as_yunying_1 = false;
  bool as_100_timer_star = false;
  bool as_txing_status = false;
  bool as_tx_first_status = false;
  bool as_tx_last_status = false;
  bool as_show_box_tips = false;
  bool as_first_box_tips = false;
  bool as_first_show_cash = false;
  bool as_first_show_rank = false;
  bool as_open_tx = false;
  bool as_tx_task2_tips = false;
  bool as_last_tx_end = false;
  bool as_show_box = false;
  bool as_tx_task3_tips = false;
  bool as_tx_task4_tips = false;
  bool as_tx_end_status = false;
  bool as_afSwitch = true;
  bool as_set_root = false;
  bool as_af_status = false;
  bool as_newA_guide = false;
  bool as_good_review_status = false;
  bool as_show_80_pop = false;
  bool as_show_rank = false;
  bool as_tx_ing_status = false;
  bool as_install_status = false;
  bool as_dolas_80_end = false;

  int as_scrach_all_count = 0; // 存储的本地值

  int as_scrach_unlock_index_0 = 0; // 存储的本地值
  int as_scrach_unlock_index_1 = 0; // 存储的本地值
  int as_ad_all_number = 0;
  double as_dollar_number = 0.00;
  double as_dolas_old_number = 0.0;
  double add_olduser_point = 3.0;
  int as_ad_reawrd_all_number = 0;
  int as_ad_short_show_number = 0;
  int as_ad_short_close_number = 0;
  int as_ad_show_index = 0;
  int as_ad_show_number = 0;
  int as_key_number = 0;
  int as_account_seled_index = 0;
  int as_tx_ing_account = 0;
  int as_tx_ing_number = 0;
  int as_tx_task_index = 0;
  int as_current_ranking = 99;
  int as_all_ranking = 388;
  int as_rank_ad_count = 0;
  int as_tx_card_index = 0;
  int as_tx_wheel_index = 0;
  int as_tx_bubble_index = 0;
  int as_box_index = 0;
  int as_card_number = 0;
  int as_Level_number = 1; // 存储的本地值
  int as_Level_inedx = 1; // 存储的本地值
  int as_dice_number = 0;
  int as_card_a_number = 0;
  int as_scrach_end_number_0 = 0; // 存储的本地值
  int as_scrach_end_number_1 = 0; // 存储的本地值
  int as_scrach_end_number_2 = 0; // 存储的本地值
  int as_scrach_end_number_3 = 0; // 存储的本地值
  int as_scrach_end_number_4 = 0; // 存储的本地值
  int as_scrach_end_number_5 = 0; // 存储的本地值
  int as_currentNumberIndex = 0;
  int as_domand_number = 0;
  int as_tx_card_first = 0;
  int as_tx_dice_index = 0;
  int as_quiz_task_index = 0;
  int new_ad_console = 1;
  int as_zhuan_number = 0;
  int as_quiz_tap_index = 0;
  int as_tx_box_index = 0;

  int as_scratch_box_index = 0;

  int as_scratch_gua_index = 0;

  int card_push_number = 8;

  int as_scratch_not_award_number = 0;

  // 主题类型
  int as_quiz_model_index = 0;

  int as_scratch_num_row = 0;

  int as_scratch_num_index = 0;

  // 当前第几题
  int as_quiz_num_index = 0;
  int as_quzi_row = 0;
  int as_wheel_number = 0;
  int as_pig_level = 0;
  double as_pig_level_index = 0.0;
  int as_quiz_all_num = 0;
  int quiz_console = 5;
  int as_dice_index = 0;


  String as_scrach_end_time_0 = ''; // 存储的本地值
  String as_scrach_end_time_1 = ''; // 存储的本地值
  String as_scrach_end_time_2 = ''; // 存储的本地值
  String as_scrach_end_time_3 = ''; // 存储的本地值
  String as_scrach_end_time_4 = ''; // 存储的本地值
  String as_scrach_end_time_5 = ''; // 存储的本地值

  // 加速卡
  double as_card_quicken_num = 0.0;

  bool as_card_quicken_30 = false;

  bool as_card_quicken_50 = false;

  bool as_card_quicken_80 = false;

  bool as_card_quicken_90 = false;

  bool as_card_quicken_1 = false;

  bool as_card_quicken_01 = false;

  bool as_first_show_home = false;

  bool as_new_guide_end = false;

  int as_qunm_ad_index = 0;

  String get as_currentNumberIndexName => 'as_currentNumberIndex';

  String get as_dice_numberName => 'as_dice_number';

  String get as_domand_numberName => 'as_domand_number';

  String get as_sound_musicName => 'as_sound_music';

  String get as_bg_musicName => 'as_bg_music';

  String get as_Level_numberName => 'as_Level_number';

  String get as_Level_inedxName => 'as_Level_inedx';

  String get as_fk_number_statusName => 'as_fk_number_status';

  String get as_fk_ip_statusName => 'as_fk_ip_status';

  String get as_fk_decvice_statusName => 'as_fk_decvice_status';

  String get as_ad_show_numberName => 'as_ad_show_number';

  String get as_ad_all_numberName => 'as_ad_all_number';

  String get as_ad_show_indexName => 'as_ad_show_index';

  String get as_ad_reawrd_all_numberName => 'as_ad_reawrd_all_number';

  String get as_ad_short_show_numberName => 'as_ad_short_show_number';

  String get as_fk_ad_short_showName => 'as_fk_ad_short_show';

  String get as_ad_short_close_numberName => 'as_ad_short_close_number';

  String get as_fk_ad_short_closeName => 'as_fk_ad_short_close';

  String get as_new_guideName => 'as_new_guide';

  String get as_ratio_strName => 'as_ratio_str';

  String get as_dolas_1000Name => 'as_dolas_1000';

  String get as_dolas_800Name => 'as_dolas_800';

  String get as_100_timer_starName => 'as_100_timer_star';

  String get as_dollar_numberName => 'as_dollar_number';

  String get as_card_numberName => 'as_card_number';

  String get as_show_dolas_aniName => 'as_show_dolas_ani';

  String get as_box_indexName => 'as_box_index';

  String get as_txing_statusName => 'as_txing_status';

  String get as_tx_ing_numberName => 'as_tx_ing_number';

  String get as_account_seled_indexName => 'as_account_seled_index';

  String get as_tx_ing_accountName => 'as_tx_ing_account';

  String get as_tx_bubble_indexName => 'as_tx_bubble_index';

  String get as_tx_card_indexName => 'as_tx_card_index';

  String get as_tx_wheel_indexName => 'as_tx_wheel_index';

  String get as_tx_task_indexName => 'as_tx_task_index';

  String get as_tx_card_firstName => 'as_tx_card_first';

  String get as_account_idName => 'as_account_id';

  String get as_tx_dice_indexName => 'as_tx_dice_index';

  String get as_tx_first_statusName => 'as_tx_first_status';

  String get as_tx_last_statusName => 'as_tx_last_status';

  String get as_current_rankingName => 'as_current_ranking';

  String get as_all_rankingName => 'as_all_ranking';

  String get as_old_guideName => 'as_old_guide';

  String get as_scratch_not_award_numberName => 'as_scratch_not_award_number';

  String get as_cloak_statusName => 'as_cloak_status';

  String get as_show_box_tipsName => 'as_show_box_tips';

  String get as_first_box_tipsName => 'as_first_box_tips';

  String get as_first_show_cashName => 'as_first_show_cash';

  String get as_scratch_guideName => 'as_scratch_guide';

  String get as_open_txName => 'as_open_tx';

  String get as_tx_task2_tipsName => 'as_tx_task2_tips';

  String get as_last_tx_endName => 'as_last_tx_end';

  String get is_end_ScratchName => 'is_end_Scratch';

  String get as_yunying_1Name => 'as_yunying_1';

  String get as_yunying_3Name => 'as_yunying_3';

  String get as_show_boxName => 'as_show_box';

  String get as_tx_task3_tipsName => 'as_tx_task3_tips';

  String get as_tx_task4_tipsName => 'as_tx_task4_tips';

  String get as_tx_end_statusName => 'as_tx_end_status';

  String get as_dolas_old_numberName => 'as_dolas_old_number';

  String get as_afSwitchName => 'as_afSwitch';

  String get as_set_rootName => 'as_set_root';

  String get as_login_statusName => 'as_login_status';

  String get as_af_statusName => 'as_af_status';

  String get as_newA_guideName => 'as_newA_guide';

  String get as_good_review_statusName => 'as_good_review_status';

  String get as_card_a_numberName => 'as_card_a_number';

  String get as_quiz_model_indexName => 'as_quiz_model_index';

  String get as_quiz_num_indexName => 'as_quiz_num_index';

  String get as_quzi_rowName => 'as_quzi_row';

  String get as_wheel_numberName => 'as_wheel_number';

  String get as_pig_levelName => 'as_pig_level';

  String get as_pig_level_indexName => 'as_pig_level_index';

  String get as_quiz_task_indexName => 'as_quiz_task_index';

  String get new_ad_consoleName => 'new_ad_console';

  String get as_zhuan_numberName => 'as_zhuan_number';

  String get as_quiz_all_numName => 'as_quiz_all_num';

  String get as_quiz_tap_indexName => 'as_quiz_tap_index';

  String get as_show_80_popName => 'as_show_80_pop';

  String get as_show_rankName => 'as_show_rank';

  String get as_tx_ing_statusName => 'as_tx_ing_status';

  String get add_olduser_pointName => 'add_olduser_point';

  String get as_install_statusName => 'as_install_status';

  String get quiz_consoleName => 'quiz_console';

  String get as_tx_box_indexName => 'as_tx_box_index';

  String get as_scrach_end_number_0Name => 'as_scrach_end_number_0';

  String get as_scrach_end_number_1Name => 'as_scrach_end_number_1';

  String get as_scrach_end_number_2Name => 'as_scrach_end_number_2';

  String get as_scrach_end_number_3Name => 'as_scrach_end_number_3';

  String get as_scrach_end_number_4Name => 'as_scrach_end_number_4';

  String get as_scrach_end_number_5Name => 'as_scrach_end_number_5';

  String get as_scratch_box_indexName => 'as_scratch_box_index';

  String get card_push_numberName => 'card_push_number';

  String get as_scratch_gua_indexName => 'as_scratch_gua_index';

  String get as_dolas_80_endName => 'as_dolas_80_end';

  String get as_scratch_num_rowName => 'as_scratch_num_row';

  String get as_scratch_num_indexName => 'as_scratch_num_index';

  String get as_card_quicken_numName => 'as_card_quicken_nums';

  String get as_card_quicken_30Name => 'as_card_quicken_30';

  String get as_card_quicken_50Name => 'as_card_quicken_50';

  String get as_card_quicken_80Name => 'as_card_quicken_80';

  String get as_card_quicken_90Name => 'as_card_quicken_90';

  String get as_card_quicken_1Name => 'as_card_quicken_1';

  String get as_card_quicken_01Name => 'as_card_quicken_01';

  String get as_scrach_end_time_0Name => 'as_scrach_end_time_0';

  String get as_scrach_end_time_1Name => 'as_scrach_end_time_1';

  String get as_scrach_end_time_2Name => 'as_scrach_end_time_2';

  String get as_scrach_end_time_3Name => 'as_scrach_end_time_3';

  String get as_scrach_end_time_4Name => 'as_scrach_end_time_4';

  String get as_scrach_end_time_5Name => 'as_scrach_end_time_5';

  String get as_show_box_guideName => 'as_show_box_guide';

  String get as_qunm_ad_indexName => 'as_qunm_ad_index';

  String get as_first_show_rankName => 'as_first_show_rank';

  String get as_rank_ad_countName => 'as_rank_ad_count';

  String get as_first_show_homeName => 'as_first_show_home';

  String get as_new_guide_endName => 'as_new_guide_end';

  String get as_scrach_all_countName => 'as_scrach_all_count';

  String get as_dice_indexName => 'as_dice_index';


  // 3. 初始化：从本地存储加载数据（组件初始化时调用）
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    // 从本地读取值（key自定义，需与存储时一致）
    as_tx_dice_index =  prefs.getInt('as_tx_dice_index') ?? 0;
    as_tx_card_first =  prefs.getInt('as_tx_card_first') ?? 0;
    as_domand_number =  prefs.getInt('as_domand_number') ?? 0;
    as_dice_index = prefs.getInt('as_dice_index') ?? 0;
    as_scrach_all_count = prefs.getInt('as_scrach_all_count') ?? 0;
    as_dice_number =  prefs.getInt('as_dice_number') ?? 0;
    as_card_number =  prefs.getInt('as_card_number') ?? 0;
    as_box_index =  prefs.getInt('as_box_index') ?? 0;
    as_tx_card_index =  prefs.getInt('as_tx_card_index') ?? 0;
    as_wheel_number =  prefs.getInt('as_wheel_number') ?? 0;
    as_pig_level =  prefs.getInt('as_pig_level') ?? 0;
    as_tx_box_index =  prefs.getInt('as_tx_box_index') ?? 0;
    as_pig_level_index =  prefs.getDouble('as_pig_level_index') ?? 0.0;
    add_olduser_point =  prefs.getDouble('add_olduser_point') ?? 3.0;
    as_tx_wheel_index =  prefs.getInt('as_tx_wheel_index') ?? 0;
    as_tx_bubble_index =  prefs.getInt('as_tx_bubble_index') ?? 0;
    as_current_ranking =  prefs.getInt('as_current_ranking') ?? 99;
    as_all_ranking =  prefs.getInt('as_all_ranking') ?? 388;
    as_rank_ad_count =  prefs.getInt('as_rank_ad_count') ?? 388;
    as_tx_task_index =  prefs.getInt('as_tx_task_index') ?? 0;
    as_quiz_task_index =  prefs.getInt('as_quiz_task_index') ?? 0;
    as_tx_ing_account =  prefs.getInt('as_tx_ing_account') ?? 0;
    as_tx_ing_number =  prefs.getInt('as_tx_ing_number') ?? 0;
    as_card_a_number =  prefs.getInt('as_card_a_number') ?? 0;
    as_quiz_model_index =  prefs.getInt('as_quiz_model_index') ?? 0;
    as_quiz_num_index =  prefs.getInt('as_quiz_num_index') ?? 0;
    as_zhuan_number =  prefs.getInt('as_zhuan_number') ?? 0;
    as_quiz_all_num =  prefs.getInt('as_quiz_all_num') ?? 0;
    as_quiz_tap_index =  prefs.getInt('as_quiz_tap_index') ?? 0;
    as_scratch_box_index =  prefs.getInt('as_scratch_box_index') ?? 0;
    as_qunm_ad_index = prefs.getInt('as_qunm_ad_index') ?? 0;
    as_scratch_not_award_number =
         prefs.getInt('as_scratch_not_award_number') ?? 0;
    as_account_seled_index =  prefs.getInt('as_account_seled_index') ?? 0;
    as_scrach_unlock_index_0 =  prefs.getInt('as_scrach_unlock_index_0') ?? 0;
    as_scrach_unlock_index_1 =  prefs.getInt('as_scrach_unlock_index_1') ?? 0;
    as_ad_short_show_number =  prefs.getInt('as_ad_short_show_number') ?? 0;
    as_ad_short_close_number =  prefs.getInt('as_ad_short_close_number') ?? 0;
    as_ad_show_number =  prefs.getInt('as_ad_show_number') ?? 0;
    as_key_number =  prefs.getInt('as_key_number') ?? 0;
    as_quzi_row =  prefs.getInt('as_quzi_row') ?? 0;
    as_wheel_number =  prefs.getInt('as_wheel_number') ?? 0;
    quiz_console =  prefs.getInt('quiz_console') ?? 5;
    new_ad_console =  prefs.getInt('new_ad_console') ?? 1;
    as_bg_music =  prefs.getBool('as_bg_music') ?? true;
    as_sound_music =  prefs.getBool('as_sound_music') ?? true;
    as_tx_task3_tips =  prefs.getBool('as_tx_task3_tips') ?? false;
    as_tx_task4_tips =  prefs.getBool('as_tx_task4_tips') ?? false;
    as_txing_status =  prefs.getBool('as_txing_status') ?? false;
    as_login_status =  prefs.getBool('as_login_status') ?? false;
    as_first_show_home = prefs.getBool('as_first_show_home') ?? false;
    as_good_review_status =  prefs.getBool('as_good_review_status') ?? false;
    as_open_tx =  prefs.getBool('as_open_tx') ?? false;
    as_new_guide_end = prefs.getBool('as_new_guide_end') ?? false;
    as_first_show_rank = prefs.getBool('as_first_show_rank') ?? false;
    as_install_status =  prefs.getBool('as_install_status') ?? false;
    as_show_box =  prefs.getBool('as_show_box') ?? false;
    as_afSwitch =  prefs.getBool('as_afSwitch') ?? true;
    as_set_root =  prefs.getBool('as_set_root') ?? false;
    as_show_rank =  prefs.getBool('as_show_rank') ?? false;
    as_af_status =  prefs.getBool('as_af_status') ?? false;
    is_end_Scratch =  prefs.getBool('is_end_Scratch') ?? true;
    as_cloak_status =  prefs.getBool('as_cloak_status') ?? false;
    as_show_box_tips =  prefs.getBool('as_show_box_tips') ?? false;
    as_first_box_tips =  prefs.getBool('as_first_box_tips') ?? false;
    as_fk_number_status =  prefs.getBool('as_fk_number_status') ?? false;
    as_fk_decvice_status =  prefs.getBool('as_fk_decvice_status') ?? false;
    as_fk_ad_short_show =  prefs.getBool('as_fk_ad_short_show') ?? false;
    as_fk_ad_short_close =  prefs.getBool('as_fk_ad_short_close') ?? false;
    as_fk_ip_status =  prefs.getBool('as_fk_ip_status') ?? false;
    as_newA_guide =  prefs.getBool('as_newA_guide') ?? false;
    as_scratch_guide =  prefs.getBool('as_scratch_guide') ?? true;
    as_old_guide =  prefs.getBool('as_old_guide') ?? true;
    as_new_guide =  prefs.getBool('as_new_guide') ?? false;
    as_show_bubble =  prefs.getBool('as_show_bubble') ?? false;
    as_show_dolas_ani =  prefs.getBool('as_show_dolas_ani') ?? false;
    as_show_box_guide =  prefs.getBool('as_show_box_guide') ?? false;
    as_dolas_800 =  prefs.getBool('as_dolas_800') ?? false;
    as_dolas_1000 =  prefs.getBool('as_dolas_1000') ?? false;
    as_100_timer_star =  prefs.getBool('as_100_timer_star') ?? false;
    as_tx_first_status =  prefs.getBool('as_tx_first_status') ?? false;
    as_tx_last_status =  prefs.getBool('as_tx_last_status') ?? false;
    as_first_show_cash =  prefs.getBool('as_first_show_cash') ?? false;
    as_tx_task2_tips =  prefs.getBool('as_tx_task2_tips') ?? false;
    as_last_tx_end =  prefs.getBool('as_last_tx_end') ?? false;
    as_yunying_3 =  prefs.getBool('as_yunying_3') ?? false;
    as_yunying_1 =  prefs.getBool('as_yunying_1') ?? false;
    as_tx_end_status =  prefs.getBool('as_tx_end_status') ?? false;
    as_show_80_pop =  prefs.getBool('as_show_80_pop') ?? false;
    as_tx_ing_status =  prefs.getBool('as_tx_ing_status') ?? false;
    as_ad_reawrd_all_number =  prefs.getInt('as_ad_reawrd_all_number') ?? 0;
    as_ad_all_number =  prefs.getInt('as_ad_all_number') ?? 0;
    as_dollar_number =  prefs.getDouble('as_dollar_number') ?? 0.00;
    as_dolas_old_number =  prefs.getDouble('as_dolas_old_number') ?? 0.0;
    as_ad_show_index =  prefs.getInt('as_ad_show_index') ?? 0;
    as_Level_number =  prefs.getInt('as_Level_number') ?? 1;
    as_Level_inedx =  prefs.getInt('as_Level_inedx') ?? 1;
    as_scrach_end_number_0 =  prefs.getInt('as_scrach_end_number_0') ?? 0;
    as_scrach_end_number_1 =  prefs.getInt('as_scrach_end_number_1') ?? 0;
    as_scrach_end_number_2 =  prefs.getInt('as_scrach_end_number_2') ?? 0;
    as_scrach_end_number_3 =  prefs.getInt('as_scrach_end_number_3') ?? 0;
    as_scrach_end_number_4 =  prefs.getInt('as_scrach_end_number_4') ?? 0;
    as_scrach_end_number_5 =  prefs.getInt('as_scrach_end_number_5') ?? 0;
    as_currentNumberIndex =  prefs.getInt('as_currentNumberIndex') ?? 0;
    as_scratch_status_0 =  prefs.getBool('as_scratch_status_0') ?? true;
    as_scratch_status_1 =  prefs.getBool('as_scratch_status_1') ?? true;
    as_scratch_status_2 =  prefs.getBool('as_scratch_status_2') ?? true;
    as_scratch_status_3 =  prefs.getBool('as_scratch_status_3') ?? true;
    as_scratch_status_4 =  prefs.getBool('as_scratch_status_4') ?? true;
    as_scratch_status_5 =  prefs.getBool('as_scratch_status_5') ?? true;
    as_scratch_status_6 =  prefs.getBool('as_scratch_status_6') ?? true;
    as_scratch_status_7 =  prefs.getBool('as_scratch_status_7') ?? true;
    as_scratch_status_8 =  prefs.getBool('as_scratch_status_8') ?? true;
    as_dolas_80_end =  prefs.getBool('as_dolas_80_end') ?? true;
    as_card_quicken_30 =  prefs.getBool('as_card_quicken_30') ?? false;
    as_card_quicken_50 =  prefs.getBool('as_card_quicken_50') ?? false;
    as_card_quicken_80 =  prefs.getBool('as_card_quicken_80') ?? false;
    as_card_quicken_90 =  prefs.getBool('as_card_quicken_90') ?? false;
    as_card_quicken_1 =  prefs.getBool('as_card_quicken_1') ?? false;
    as_card_quicken_01 =  prefs.getBool('as_card_quicken_01') ?? false;
    as_ratio_str = prefs.getString('as_ratio_str') ?? '90';
    as_account_id = prefs.getString('as_account_id') ?? '';
    as_tx_list = prefs.getString("as_tx_list") ?? "";
    as_scrach_end_time_0 = prefs.getString("as_scrach_end_time_0") ?? "";
    as_scrach_end_time_1 = prefs.getString("as_scrach_end_time_1") ?? "";
    as_scrach_end_time_2 = prefs.getString("as_scrach_end_time_2") ?? "";
    as_scrach_end_time_3 = prefs.getString("as_scrach_end_time_3") ?? "";
    as_scrach_end_time_4 = prefs.getString("as_scrach_end_time_4") ?? "";
    as_scrach_end_time_5 = prefs.getString("as_scrach_end_time_5") ?? "";
    card_push_number = prefs.getInt('card_push_number') ?? 8;
    as_scratch_gua_index = prefs.getInt('as_scratch_gua_index') ?? 0;
    as_scratch_num_row = prefs.getInt('as_scratch_num_row') ?? 0;
    as_scratch_num_index = prefs.getInt('as_scratch_num_index') ?? 0;
    as_card_quicken_num = prefs.getDouble('as_card_quicken_nums') ?? 0;
    Future.delayed(Duration(milliseconds: 100),(){
      'updateUI=${as_dollar_number}'.log();
      notifyListeners(); // 加载完成后通知UI更新
    });
  }

  // 通用bool
  Future<void> updateBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    bool reuslt = await prefs.setBool(key, value);
    init();
  }

  // 通用int
  Future<void> updateint(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    bool reuslt = await prefs.setInt(key, value);
    init();
  }

  // 通用double
  Future<void> updatedouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    if (key == ASLocalProvider.instance.as_dollar_numberName) {
        // CSNoticeHelp().startSJForegroundService();
    }
    print("value= $value");
    await prefs.setDouble(key, value);
    if (key == ASLocalProvider.instance.as_dollar_numberName && value > 0) {
      await prefs.setDouble(as_dolas_old_numberName,  as_dolas_old_number + value);
    }
    if (key == ASLocalProvider.instance.as_dollar_numberName && value > 0){
      trigger.check(ASLocalProvider.instance.as_dollar_number.toInt(), onTrigger: (level) {
        print("触发 → 达到 $level");
        as_event_fire('cash_money_detail', {'money' : level});
      });
      await prefs.setBool(as_show_dolas_aniName, true);
    }
    init();
  }

  // 通用String
  Future<void> updateString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    bool reuslt = await prefs.setString(key, value);
    init();
  }
}

final trigger = ASThresholdTrigger();

