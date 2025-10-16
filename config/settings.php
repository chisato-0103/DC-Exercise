<?php
/**
 * システム設定ファイル
 *
 * このファイルでシステム全体の設定を管理します
 */

// タイムゾーン設定
date_default_timezone_set('Asia/Tokyo');

// デバッグモード（本番環境では必ずfalseにしてください）
define('DEBUG_MODE', true);

// エラー表示設定
if (DEBUG_MODE) {
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
} else {
    ini_set('display_errors', 0);
    error_reporting(0);
}

// システム設定（デフォルト値）
// ※ データベースのsystem_settingsテーブルの値が優先されます
define('TRANSFER_TIME_MINUTES', 10);  // 乗り換え時間（分）
define('SHUTTLE_TRAVEL_TIME', 5);     // シャトルバス所要時間（分）
define('DEFAULT_DESTINATION', 'fujigaoka');  // デフォルト目的地
define('RESULT_LIMIT', 3);            // 表示する乗り継ぎ候補数
define('CURRENT_DIA_TYPE', 'A');      // 現在のダイヤ種別

// リニモ各駅の八草駅からの所要時間（分）
// ※ stationsテーブルから動的に取得することを推奨
$LINIMO_TRAVEL_TIMES = [
    'yagusa' => 0,
    'tojishiryokan_minami' => 2,
    'ai_chikyuhaku_kinen_koen' => 4,
    'koen_nishi' => 6,
    'geidai_dori' => 8,
    'nagakute_kosenjo' => 10,
    'irigaike_koen' => 12,
    'hanamizuki_dori' => 14,
    'fujigaoka' => 17
];

// ダイヤ種別の説明
$DIA_TYPE_DESCRIPTIONS = [
    'A' => '授業期間平日（4月〜7月、10月〜1月）',
    'B' => '土曜日',
    'C' => '学校休業期間（8月、9月、2月、3月の平日）'
];

// 曜日種別の説明
$DAY_TYPE_DESCRIPTIONS = [
    'weekday_green' => '平日（4月〜7月、10月〜1月）',
    'holiday_red' => '土休日・学校休業期間（8月、9月、2月、3月）'
];

// APIレスポンスヘッダー
define('API_CONTENT_TYPE', 'application/json; charset=utf-8');

/**
 * データベースからシステム設定を読み込む
 *
 * @return array システム設定の連想配列
 */
function loadSystemSettings() {
    try {
        require_once __DIR__ . '/database.php';
        $pdo = getDbConnection();

        $stmt = $pdo->query("SELECT setting_key, setting_value FROM system_settings");
        $settings = [];

        while ($row = $stmt->fetch()) {
            $settings[$row['setting_key']] = $row['setting_value'];
        }

        return $settings;
    } catch (Exception $e) {
        error_log('Failed to load system settings: ' . $e->getMessage());
        return [];
    }
}

/**
 * 設定値を取得（データベース優先、フォールバックは定数）
 *
 * @param string $key 設定キー
 * @param mixed $default デフォルト値
 * @return mixed 設定値
 */
function getSetting($key, $default = null) {
    static $settings = null;

    if ($settings === null) {
        $settings = loadSystemSettings();
    }

    return $settings[$key] ?? $default;
}

/**
 * 現在のダイヤ種別を判定
 *
 * @return string ダイヤ種別（A/B/C）
 */
function getCurrentDiaType() {
    // 実際の実装では、現在の日付と運行カレンダーから判定
    // プロトタイプではsystem_settingsから取得
    return getSetting('current_dia_type', CURRENT_DIA_TYPE);
}

/**
 * リニモの曜日種別を判定
 *
 * @return string 曜日種別（weekday_green/holiday_red）
 */
function getCurrentDayType() {
    // 実際の実装では、現在の日付と月から判定
    // プロトタイプでは簡易判定
    $month = (int)date('n');
    $dayOfWeek = (int)date('w');

    // 土日の場合
    if ($dayOfWeek === 0 || $dayOfWeek === 6) {
        return 'holiday_red';
    }

    // 8月、9月、2月、3月は赤時刻
    if (in_array($month, [2, 3, 8, 9])) {
        return 'holiday_red';
    }

    return 'weekday_green';
}
