// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ja';

  static m0(email, logPath) => "エラーページのスクリーンショットとログファイルをこのメールボックスに送信してください：\n${email}\nログファイルパス：${logPath}";

  static m1(curVersion, newVersion, releaseNote) => "現在のバージョン：${curVersion} \n最新のバージョン：${newVersion}\n詳細:\n${releaseNote}";

  static m2(name) => "ソース${name}";

  static m3(n) => "最大${n}ボックス";

  static m4(n) => "聖杯は伝承結晶に置き換える${n}個";

  static m5(error) => "インポートに失敗しました、エラー:\n${error}";

  static m6(name) => "${name}はすでに存在します";

  static m7(site) => "${site}にジャンプ";

  static m8(first) => "${Intl.select(first, {'true': '最初のもの', 'false': '最後のもの', 'other': '最後のもの', })}";

  static m9(index) => "プラン${index}";

  static m10(total) => "合計：${total}";

  static m11(total, hidden) => "合計：${total} (非表示: ${hidden})";

  static m12(a, b) => "${a}${b}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "about_app" : MessageLookupByLibrary.simpleMessage("ついて"),
    "about_app_declaration_text" : MessageLookupByLibrary.simpleMessage("　このアプリケーションで使用されるデータは、ゲームおよび次のサイトからのものです。ゲーム画像およびその他のテキストの著作権はTYPE MOON / FGO PROJECTに帰属します。\n　プログラムの機能と設計はWeChatアプリ「素材规划」とiOSアプリのGudaを参照しています。\n"),
    "about_appstore_rating" : MessageLookupByLibrary.simpleMessage("App Storeに評価"),
    "about_data_source" : MessageLookupByLibrary.simpleMessage("データソース"),
    "about_data_source_footer" : MessageLookupByLibrary.simpleMessage("マークされていないソースまたは侵害がある場合はお知らせください"),
    "about_email_dialog" : m0,
    "about_email_subtitle" : MessageLookupByLibrary.simpleMessage("エラーページのスクリーンショットとログファイルを添付してください"),
    "about_feedback" : MessageLookupByLibrary.simpleMessage("フィードバック"),
    "about_update_app" : MessageLookupByLibrary.simpleMessage("アプリを更新"),
    "about_update_app_alert_ios_mac" : MessageLookupByLibrary.simpleMessage("App Storeでアップデートを確認してください"),
    "about_update_app_detail" : m1,
    "active_skill" : MessageLookupByLibrary.simpleMessage("保有スキル"),
    "add_to_blacklist" : MessageLookupByLibrary.simpleMessage("ブラックリストに追加"),
    "ap" : MessageLookupByLibrary.simpleMessage("AP"),
    "ap_calc_page_joke" : MessageLookupByLibrary.simpleMessage("口算不及格的咕朗台.jpg"),
    "ap_calc_title" : MessageLookupByLibrary.simpleMessage("AP計算"),
    "ap_efficiency" : MessageLookupByLibrary.simpleMessage("AP効率"),
    "ap_overflow_time" : MessageLookupByLibrary.simpleMessage("APフル時間"),
    "ascension" : MessageLookupByLibrary.simpleMessage("霊基"),
    "ascension_short" : MessageLookupByLibrary.simpleMessage("霊基"),
    "ascension_up" : MessageLookupByLibrary.simpleMessage("霊基再臨"),
    "backup" : MessageLookupByLibrary.simpleMessage("バックアップ"),
    "backup_success" : MessageLookupByLibrary.simpleMessage("バックアップは成功しました"),
    "blacklist" : MessageLookupByLibrary.simpleMessage("ブラックリスト"),
    "bond_craft" : MessageLookupByLibrary.simpleMessage("絆礼装"),
    "calc_weight" : MessageLookupByLibrary.simpleMessage("重み"),
    "calculate" : MessageLookupByLibrary.simpleMessage("計算する"),
    "calculator" : MessageLookupByLibrary.simpleMessage("電卓"),
    "cancel" : MessageLookupByLibrary.simpleMessage("キャセル"),
    "card_description" : MessageLookupByLibrary.simpleMessage("解説"),
    "card_info" : MessageLookupByLibrary.simpleMessage("資料"),
    "check_update" : MessageLookupByLibrary.simpleMessage("更新の確認"),
    "clear" : MessageLookupByLibrary.simpleMessage("クリア"),
    "clear_cache" : MessageLookupByLibrary.simpleMessage("キャッシュを消去"),
    "clear_cache_finish" : MessageLookupByLibrary.simpleMessage("キャッシュがクリアされました"),
    "clear_cache_hint" : MessageLookupByLibrary.simpleMessage("イラスト、ボイスなど"),
    "clear_userdata" : MessageLookupByLibrary.simpleMessage("ユーザーデータをクリア"),
    "cmd_code_title" : MessageLookupByLibrary.simpleMessage("指令紋章"),
    "command_code" : MessageLookupByLibrary.simpleMessage("指令紋章"),
    "confirm" : MessageLookupByLibrary.simpleMessage("確認"),
    "copper" : MessageLookupByLibrary.simpleMessage("銅"),
    "copy" : MessageLookupByLibrary.simpleMessage("コピー"),
    "copy_plan_menu" : MessageLookupByLibrary.simpleMessage("他のプランからコピー"),
    "counts" : MessageLookupByLibrary.simpleMessage("カウント"),
    "craft_essence" : MessageLookupByLibrary.simpleMessage("概念礼装"),
    "craft_essence_title" : MessageLookupByLibrary.simpleMessage("概念礼装"),
    "cur_account" : MessageLookupByLibrary.simpleMessage("アカウント"),
    "cur_ap" : MessageLookupByLibrary.simpleMessage("既存のAP"),
    "current_" : MessageLookupByLibrary.simpleMessage("現在"),
    "dataset_goto_download_page" : MessageLookupByLibrary.simpleMessage("ダウンロードページに移動"),
    "dataset_goto_download_page_hint" : MessageLookupByLibrary.simpleMessage("ダウンロード後に手動でインポート"),
    "dataset_management" : MessageLookupByLibrary.simpleMessage("データベース"),
    "dataset_type_entire" : MessageLookupByLibrary.simpleMessage("完全なデータパッケージ"),
    "dataset_type_entire_hint" : MessageLookupByLibrary.simpleMessage("テキストと画像を含める、約25M"),
    "dataset_type_text" : MessageLookupByLibrary.simpleMessage("テキストデータパッケージ"),
    "dataset_type_text_hint" : MessageLookupByLibrary.simpleMessage("テキストのみ、約5M"),
    "delete" : MessageLookupByLibrary.simpleMessage("削除"),
    "delete_all_data" : MessageLookupByLibrary.simpleMessage("すべてのデータを削除"),
    "delete_all_data_hint" : MessageLookupByLibrary.simpleMessage("ユーザーデータ、ゲームデータ、画像リソースを含め、デフォルトのリソースを読み込む"),
    "download" : MessageLookupByLibrary.simpleMessage("ダウンロード"),
    "download_complete" : MessageLookupByLibrary.simpleMessage("ダウンロード完了"),
    "download_latest_gamedata" : MessageLookupByLibrary.simpleMessage("最新のデータをダウンロード"),
    "download_source" : MessageLookupByLibrary.simpleMessage("ダウンロードソース"),
    "download_source_hint" : MessageLookupByLibrary.simpleMessage("ゲームデータとアプリケーションの更新"),
    "download_source_of" : m2,
    "downloaded" : MessageLookupByLibrary.simpleMessage("ダウンロード済み"),
    "downloading" : MessageLookupByLibrary.simpleMessage("ダウンロード"),
    "dress" : MessageLookupByLibrary.simpleMessage("霊衣"),
    "dress_up" : MessageLookupByLibrary.simpleMessage("霊衣開放"),
    "drop_calc_empty_hint" : MessageLookupByLibrary.simpleMessage("＋をクリックしてアイテムを追加"),
    "drop_calc_help_text" : MessageLookupByLibrary.simpleMessage("计算结果仅供参考\n>>>最低AP：\n过滤AP较低的free, 但保证每个素材至少有一个关卡\n>>>选择国服则未实装的素材将被移除\n>>>优化：最低总次数或最低总AP\n"),
    "drop_calc_min_ap" : MessageLookupByLibrary.simpleMessage("最低AP"),
    "drop_calc_optimize" : MessageLookupByLibrary.simpleMessage("最適化"),
    "drop_calc_solve" : MessageLookupByLibrary.simpleMessage("解決する"),
    "drop_calculator" : MessageLookupByLibrary.simpleMessage("ドロップ"),
    "drop_calculator_short" : MessageLookupByLibrary.simpleMessage("ドロップ"),
    "drop_rate" : MessageLookupByLibrary.simpleMessage("ドロップ率"),
    "edit" : MessageLookupByLibrary.simpleMessage("編集"),
    "efficiency" : MessageLookupByLibrary.simpleMessage("効率"),
    "efficiency_type" : MessageLookupByLibrary.simpleMessage("効率タイプ"),
    "efficiency_type_ap" : MessageLookupByLibrary.simpleMessage("20AP効率"),
    "efficiency_type_drop" : MessageLookupByLibrary.simpleMessage("ドロップ率"),
    "enhance" : MessageLookupByLibrary.simpleMessage("強化"),
    "enhance_warning" : MessageLookupByLibrary.simpleMessage("強化すると、次の資アイテムが差し引かれます"),
    "event_collect_item_confirm" : MessageLookupByLibrary.simpleMessage("すべてのアイテムを倉庫に追加し、プランからイベントを削除します"),
    "event_collect_items" : MessageLookupByLibrary.simpleMessage("アイテムの収集"),
    "event_item_default" : MessageLookupByLibrary.simpleMessage("ショップ/タスク/ポイント/ドロップ報酬"),
    "event_item_extra" : MessageLookupByLibrary.simpleMessage("その他"),
    "event_lottery_limit_hint" : m3,
    "event_lottery_limited" : MessageLookupByLibrary.simpleMessage("ボックスガチャ"),
    "event_lottery_unit" : MessageLookupByLibrary.simpleMessage(""),
    "event_lottery_unlimited" : MessageLookupByLibrary.simpleMessage("ボックスガチャ"),
    "event_not_planned" : MessageLookupByLibrary.simpleMessage("イベントはプランされていません"),
    "event_rerun_replace_grail" : m4,
    "event_title" : MessageLookupByLibrary.simpleMessage("イベント"),
    "exchange_ticket" : MessageLookupByLibrary.simpleMessage("アイテム交換券"),
    "exchange_ticket_short" : MessageLookupByLibrary.simpleMessage("交換券"),
    "favorite" : MessageLookupByLibrary.simpleMessage("フォロー"),
    "fgo_domus_aurea" : MessageLookupByLibrary.simpleMessage("FGOアイテム効率劇場"),
    "filename" : MessageLookupByLibrary.simpleMessage("ファイル名"),
    "filter" : MessageLookupByLibrary.simpleMessage("フィルター"),
    "filter_atk_hp_type" : MessageLookupByLibrary.simpleMessage("属性"),
    "filter_attribute" : MessageLookupByLibrary.simpleMessage("相性"),
    "filter_category" : MessageLookupByLibrary.simpleMessage("分類"),
    "filter_gender" : MessageLookupByLibrary.simpleMessage("性别"),
    "filter_obtain" : MessageLookupByLibrary.simpleMessage("入手方法"),
    "filter_plan_not_reached" : MessageLookupByLibrary.simpleMessage("未完成"),
    "filter_plan_reached" : MessageLookupByLibrary.simpleMessage("達成"),
    "filter_shown_type" : MessageLookupByLibrary.simpleMessage("表示"),
    "filter_skill_lv" : MessageLookupByLibrary.simpleMessage("スキルレベル"),
    "filter_sort" : MessageLookupByLibrary.simpleMessage("ソート"),
    "filter_sort_class" : MessageLookupByLibrary.simpleMessage("クラス"),
    "filter_sort_number" : MessageLookupByLibrary.simpleMessage("番号"),
    "filter_sort_rarity" : MessageLookupByLibrary.simpleMessage("スター"),
    "filter_special_trait" : MessageLookupByLibrary.simpleMessage("特殊特性"),
    "free_efficiency" : MessageLookupByLibrary.simpleMessage("フリー効率"),
    "free_progress" : MessageLookupByLibrary.simpleMessage("クエスト"),
    "free_progress_newest" : MessageLookupByLibrary.simpleMessage("最新"),
    "free_quest" : MessageLookupByLibrary.simpleMessage("フリークエスト"),
    "gallery_tab_name" : MessageLookupByLibrary.simpleMessage("ホーム"),
    "game_drop" : MessageLookupByLibrary.simpleMessage("ドロップ"),
    "game_experience" : MessageLookupByLibrary.simpleMessage("EXP"),
    "game_kizuna" : MessageLookupByLibrary.simpleMessage("絆"),
    "game_rewards" : MessageLookupByLibrary.simpleMessage("クリア報酬"),
    "gamedata" : MessageLookupByLibrary.simpleMessage("ゲームデータ"),
    "gold" : MessageLookupByLibrary.simpleMessage("金"),
    "grail" : MessageLookupByLibrary.simpleMessage("聖杯"),
    "grail_level" : MessageLookupByLibrary.simpleMessage("聖杯レベル"),
    "grail_up" : MessageLookupByLibrary.simpleMessage("聖杯転臨"),
    "guda_item_data" : MessageLookupByLibrary.simpleMessage("Gudaアイテムデータ"),
    "guda_servant_data" : MessageLookupByLibrary.simpleMessage("Gudaサーヴァントデータ"),
    "hello" : MessageLookupByLibrary.simpleMessage("こんにちは、マスタ。"),
    "help" : MessageLookupByLibrary.simpleMessage("ヘルプ"),
    "hint_no_bond_craft" : MessageLookupByLibrary.simpleMessage("絆礼装なし"),
    "hint_no_valentine_craft" : MessageLookupByLibrary.simpleMessage("チョコ礼装なし"),
    "ignore" : MessageLookupByLibrary.simpleMessage("無視"),
    "illustration" : MessageLookupByLibrary.simpleMessage("イラスト"),
    "illustrator" : MessageLookupByLibrary.simpleMessage("イラストレーター"),
    "import_data" : MessageLookupByLibrary.simpleMessage("インポート"),
    "import_data_error" : m5,
    "import_data_success" : MessageLookupByLibrary.simpleMessage("インポートは成功しました"),
    "import_guda_data" : MessageLookupByLibrary.simpleMessage("Gudaデータをインポート"),
    "import_guda_hint" : MessageLookupByLibrary.simpleMessage("更新：保留本地数据并用导入的数据更新(推荐)\n覆盖：清楚本地数据再导入数据"),
    "import_guda_items" : MessageLookupByLibrary.simpleMessage("Gudaアイテムデータをインポート"),
    "import_guda_servants" : MessageLookupByLibrary.simpleMessage("Gudaサーヴァントデータをインポート"),
    "info_agility" : MessageLookupByLibrary.simpleMessage("敏捷"),
    "info_alignment" : MessageLookupByLibrary.simpleMessage("属性"),
    "info_bond_points" : MessageLookupByLibrary.simpleMessage("絆ポイント"),
    "info_bond_points_single" : MessageLookupByLibrary.simpleMessage("ポイント"),
    "info_bond_points_sum" : MessageLookupByLibrary.simpleMessage("累計"),
    "info_cards" : MessageLookupByLibrary.simpleMessage("カード"),
    "info_critical_rate" : MessageLookupByLibrary.simpleMessage("スター集中度"),
    "info_cv" : MessageLookupByLibrary.simpleMessage("CV"),
    "info_death_rate" : MessageLookupByLibrary.simpleMessage("即死率"),
    "info_endurance" : MessageLookupByLibrary.simpleMessage("耐久"),
    "info_gender" : MessageLookupByLibrary.simpleMessage("性别"),
    "info_height" : MessageLookupByLibrary.simpleMessage("身長"),
    "info_human" : MessageLookupByLibrary.simpleMessage("人型"),
    "info_luck" : MessageLookupByLibrary.simpleMessage("幸運"),
    "info_mana" : MessageLookupByLibrary.simpleMessage("魔力"),
    "info_np" : MessageLookupByLibrary.simpleMessage("宝具"),
    "info_np_rate" : MessageLookupByLibrary.simpleMessage("NP率"),
    "info_star_rate" : MessageLookupByLibrary.simpleMessage("スター発生率"),
    "info_strength" : MessageLookupByLibrary.simpleMessage("筋力"),
    "info_trait" : MessageLookupByLibrary.simpleMessage("特性"),
    "info_value" : MessageLookupByLibrary.simpleMessage("数值"),
    "info_weak_to_ea" : MessageLookupByLibrary.simpleMessage("EAに特攻"),
    "info_weight" : MessageLookupByLibrary.simpleMessage("体重"),
    "input_invalid_hint" : MessageLookupByLibrary.simpleMessage("入力が無効です"),
    "interlude_and_rankup" : MessageLookupByLibrary.simpleMessage("幕間・強化"),
    "ios_app_path" : MessageLookupByLibrary.simpleMessage("\"ファイル\"アプリ/このiPhone内/Chaldea"),
    "item" : MessageLookupByLibrary.simpleMessage("アイテム"),
    "item_already_exist_hint" : m6,
    "item_category_ascension" : MessageLookupByLibrary.simpleMessage("霊基再臨用アイテム"),
    "item_category_copper" : MessageLookupByLibrary.simpleMessage("銅素材"),
    "item_category_event_svt_ascension" : MessageLookupByLibrary.simpleMessage("イベントサーバント霊基再臨用アイテム"),
    "item_category_gem" : MessageLookupByLibrary.simpleMessage("輝石"),
    "item_category_gems" : MessageLookupByLibrary.simpleMessage("スキル強化用アイテム"),
    "item_category_gold" : MessageLookupByLibrary.simpleMessage("金素材"),
    "item_category_magic_gem" : MessageLookupByLibrary.simpleMessage("魔石"),
    "item_category_monument" : MessageLookupByLibrary.simpleMessage("モニュメント"),
    "item_category_others" : MessageLookupByLibrary.simpleMessage("その他"),
    "item_category_piece" : MessageLookupByLibrary.simpleMessage("ピース"),
    "item_category_secret_gem" : MessageLookupByLibrary.simpleMessage("秘石"),
    "item_category_silver" : MessageLookupByLibrary.simpleMessage("銀素材"),
    "item_category_special" : MessageLookupByLibrary.simpleMessage("特殊素材"),
    "item_category_usual" : MessageLookupByLibrary.simpleMessage("共通素材"),
    "item_exceed" : MessageLookupByLibrary.simpleMessage("アイテムの余剰"),
    "item_left" : MessageLookupByLibrary.simpleMessage("残り"),
    "item_no_free_quests" : MessageLookupByLibrary.simpleMessage("フリークエストはありません"),
    "item_only_show_lack" : MessageLookupByLibrary.simpleMessage("不足しているのみ"),
    "item_own" : MessageLookupByLibrary.simpleMessage("持って"),
    "item_title" : MessageLookupByLibrary.simpleMessage("アイテム"),
    "item_total_demand" : MessageLookupByLibrary.simpleMessage("合計"),
    "join_beta" : MessageLookupByLibrary.simpleMessage("ベータ版に参加する"),
    "jump_to" : m7,
    "language" : MessageLookupByLibrary.simpleMessage("日本語"),
    "level" : MessageLookupByLibrary.simpleMessage("レベル"),
    "limited_event" : MessageLookupByLibrary.simpleMessage("期間限定イベント"),
    "link" : MessageLookupByLibrary.simpleMessage("リンク"),
    "list_end_hint" : m8,
    "main_record" : MessageLookupByLibrary.simpleMessage("シナリオ"),
    "main_record_bonus" : MessageLookupByLibrary.simpleMessage("報酬"),
    "main_record_bonus_short" : MessageLookupByLibrary.simpleMessage("報酬"),
    "main_record_chapter" : MessageLookupByLibrary.simpleMessage("タイトル"),
    "main_record_fixed_drop" : MessageLookupByLibrary.simpleMessage("ドロップ"),
    "main_record_fixed_drop_short" : MessageLookupByLibrary.simpleMessage("ドロップ"),
    "max_ap" : MessageLookupByLibrary.simpleMessage("最大のAP"),
    "more" : MessageLookupByLibrary.simpleMessage("もっと"),
    "mystic_code" : MessageLookupByLibrary.simpleMessage("魔術礼装"),
    "new_account" : MessageLookupByLibrary.simpleMessage("新しいアカウント"),
    "next_card" : MessageLookupByLibrary.simpleMessage("次のカード"),
    "nga" : MessageLookupByLibrary.simpleMessage("NGA"),
    "nga_fgo" : MessageLookupByLibrary.simpleMessage("NGA-FGO"),
    "no" : MessageLookupByLibrary.simpleMessage("いいえ"),
    "no_servant_quest_hint" : MessageLookupByLibrary.simpleMessage("幕間の物語や強化クエストはありません"),
    "no_servant_quest_hint_subtitle" : MessageLookupByLibrary.simpleMessage("♡をクリックして、すべてのクエストを表示します"),
    "nobel_phantasm" : MessageLookupByLibrary.simpleMessage("宝具"),
    "nobel_phantasm_level" : MessageLookupByLibrary.simpleMessage("宝具レベル"),
    "obtain_methods" : MessageLookupByLibrary.simpleMessage("入手方法"),
    "ok" : MessageLookupByLibrary.simpleMessage("OK"),
    "open" : MessageLookupByLibrary.simpleMessage("開く"),
    "overwrite" : MessageLookupByLibrary.simpleMessage("上書き"),
    "passive_skill" : MessageLookupByLibrary.simpleMessage("クラススキル"),
    "plan" : MessageLookupByLibrary.simpleMessage("プラン"),
    "plan_max10" : MessageLookupByLibrary.simpleMessage("プラン最大化する(310)"),
    "plan_max9" : MessageLookupByLibrary.simpleMessage("プラン最大化する(999)"),
    "plan_objective" : MessageLookupByLibrary.simpleMessage("プラン目標"),
    "plan_title" : MessageLookupByLibrary.simpleMessage("プラン"),
    "plan_x" : m9,
    "previous_card" : MessageLookupByLibrary.simpleMessage("前のカード"),
    "priority" : MessageLookupByLibrary.simpleMessage("優先順位"),
    "query_failed" : MessageLookupByLibrary.simpleMessage("クエリに失敗しました"),
    "quest" : MessageLookupByLibrary.simpleMessage("クエスト"),
    "quest_condition" : MessageLookupByLibrary.simpleMessage("開放条件"),
    "rarity" : MessageLookupByLibrary.simpleMessage("レアリティ"),
    "reload_data_success" : MessageLookupByLibrary.simpleMessage("インポートに成功しました"),
    "reload_default_gamedata" : MessageLookupByLibrary.simpleMessage("プリインストールされたバージョンをリロードします"),
    "reloading_data" : MessageLookupByLibrary.simpleMessage("インポート中"),
    "remove_from_blacklist" : MessageLookupByLibrary.simpleMessage("ブラックリストから削除"),
    "rename" : MessageLookupByLibrary.simpleMessage("名前変更"),
    "rerun_event" : MessageLookupByLibrary.simpleMessage("復刻イベント"),
    "reset" : MessageLookupByLibrary.simpleMessage("リセット"),
    "reset_success" : MessageLookupByLibrary.simpleMessage("リセットしました"),
    "reset_svt_enhance_state" : MessageLookupByLibrary.simpleMessage("サーヴァント強化状态をリセット"),
    "reset_svt_enhance_state_hint" : MessageLookupByLibrary.simpleMessage("宝具/スキル強化"),
    "restore" : MessageLookupByLibrary.simpleMessage("復元"),
    "search_result_count" : m10,
    "search_result_count_hide" : m11,
    "select_copy_plan_source" : MessageLookupByLibrary.simpleMessage("コピー元を選択"),
    "select_plan" : MessageLookupByLibrary.simpleMessage("プランを選択"),
    "servant" : MessageLookupByLibrary.simpleMessage("サーヴァント"),
    "servant_title" : MessageLookupByLibrary.simpleMessage("サーヴァント"),
    "server" : MessageLookupByLibrary.simpleMessage("サーバー"),
    "server_cn" : MessageLookupByLibrary.simpleMessage("CN"),
    "server_jp" : MessageLookupByLibrary.simpleMessage("JP"),
    "settings_data" : MessageLookupByLibrary.simpleMessage("データ"),
    "settings_data_management" : MessageLookupByLibrary.simpleMessage("データベース"),
    "settings_general" : MessageLookupByLibrary.simpleMessage("一般"),
    "settings_language" : MessageLookupByLibrary.simpleMessage("言語"),
    "settings_tab_name" : MessageLookupByLibrary.simpleMessage("設定"),
    "settings_tutorial" : MessageLookupByLibrary.simpleMessage("ヘルプ"),
    "settings_use_mobile_network" : MessageLookupByLibrary.simpleMessage("モバイルデータを使用"),
    "settings_userdata_footer" : MessageLookupByLibrary.simpleMessage("更新数据/版本/bug较多时，建议提前备份数据，卸载应用将导致内部备份丢失，及时转移到可靠的储存位置"),
    "share" : MessageLookupByLibrary.simpleMessage("共有"),
    "silver" : MessageLookupByLibrary.simpleMessage("銀"),
    "skill" : MessageLookupByLibrary.simpleMessage("スキル"),
    "skill_up" : MessageLookupByLibrary.simpleMessage("スキル強化"),
    "skilled_max10" : MessageLookupByLibrary.simpleMessage("スキルレベル最大化する(310)"),
    "statistics_include_checkbox" : MessageLookupByLibrary.simpleMessage("既存のアイテムを含める"),
    "statistics_title" : MessageLookupByLibrary.simpleMessage("統計"),
    "svt_info_tab_base" : MessageLookupByLibrary.simpleMessage("ステータス"),
    "svt_info_tab_bond_story" : MessageLookupByLibrary.simpleMessage("プロファイル"),
    "svt_not_planned" : MessageLookupByLibrary.simpleMessage("フォローされていません"),
    "svt_obtain_event" : MessageLookupByLibrary.simpleMessage("配布"),
    "svt_obtain_friend_point" : MessageLookupByLibrary.simpleMessage("フレポ"),
    "svt_obtain_initial" : MessageLookupByLibrary.simpleMessage("初期"),
    "svt_obtain_limited" : MessageLookupByLibrary.simpleMessage("限定"),
    "svt_obtain_permanent" : MessageLookupByLibrary.simpleMessage("恒常"),
    "svt_obtain_story" : MessageLookupByLibrary.simpleMessage("スト限"),
    "svt_obtain_unavailable" : MessageLookupByLibrary.simpleMessage("召喚不可"),
    "svt_plan_hidden" : MessageLookupByLibrary.simpleMessage("非表示"),
    "tooltip_refresh_sliders" : MessageLookupByLibrary.simpleMessage("ホームページを更新"),
    "total_ap" : MessageLookupByLibrary.simpleMessage("合計AP"),
    "total_counts" : MessageLookupByLibrary.simpleMessage("合計カウント"),
    "update" : MessageLookupByLibrary.simpleMessage("更新"),
    "userdata" : MessageLookupByLibrary.simpleMessage("ユーザーデータ"),
    "userdata_cleared" : MessageLookupByLibrary.simpleMessage("ユーザーデータがクリアされました"),
    "valentine_craft" : MessageLookupByLibrary.simpleMessage("チョコ礼装"),
    "version" : MessageLookupByLibrary.simpleMessage("バージョン"),
    "view_illustration" : MessageLookupByLibrary.simpleMessage("カードの画像を表示"),
    "voice" : MessageLookupByLibrary.simpleMessage("ボイス"),
    "words_separate" : m12,
    "yes" : MessageLookupByLibrary.simpleMessage("はい")
  };
}
