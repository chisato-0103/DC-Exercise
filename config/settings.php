<?php
/**
 * システム設定ファイル
 *
 * このファイルでシステム全体の設定を管理します
 */

// .env ファイルから環境変数を読み込む（settings.phpが最初に呼び出されるため、ここで読み込む）
if (file_exists(__DIR__ . '/../.env')) {
    $envFile = file(__DIR__ . '/../.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($envFile as $line) {
        // コメント行をスキップ
        if (strpos(trim($line), '#') === 0) {
            continue;
        }
        // KEY=VALUE 形式をパース
        if (strpos($line, '=') !== false) {
            [$key, $value] = explode('=', $line, 2);
            $key = trim($key);
            $value = trim($value);
            // 環境変数に設定
            if (!getenv($key)) {
                putenv($key . '=' . $value);
            }
        }
    }
}

// タイムゾーン設定
date_default_timezone_set('Asia/Tokyo');

// デバッグモード（環境変数で制御、デフォルトはfalse）
define('DEBUG_MODE', (getenv('DEBUG_MODE') === 'true' || getenv('APP_ENV') === 'development'));

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
 * 現在のダイヤ種別を判定（DB照会）
 *
 * @param string $date 判定対象日付（YYYY-MM-DD形式、省略時は本日）
 * @return string ダイヤ種別（A/B/C）、運休の場合は'holiday'
 *
 * ダイヤ種別の判定ロジック:
 * - shuttle_scheduleテーブルから指定日付のダイヤを照会
 * - データがない場合はAダイヤにフォールバック
 * - 運休日は'holiday'を返す
 */
function getCurrentDiaType($date = null) {
    // 日付を指定されていない場合は本日を使用
    if ($date === null) {
        $date = date('Y-m-d');
    }

    try {
        require_once __DIR__ . '/database.php';
        $pdo = getDbConnection();

        // shuttle_scheduleテーブルから指定日のダイヤを照会
        $sql = "SELECT dia_type FROM shuttle_schedule WHERE operation_date = :date LIMIT 1";
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':date', $date, PDO::PARAM_STR);
        $stmt->execute();

        $result = $stmt->fetch();
        if ($result) {
            return $result['dia_type'];
        }

        // データがない場合はAダイヤにフォールバック
        return getSetting('current_dia_type', CURRENT_DIA_TYPE);

    } catch (Exception $e) {
        error_log('Error getting diagram type from database: ' . $e->getMessage());
        // エラーが発生した場合はAダイヤにフォールバック
        return getSetting('current_dia_type', CURRENT_DIA_TYPE);
    }
}

/**
 * 曜日種別を判定（rail_timetableで使用）
 *
 * @return string 曜日種別（weekday_green または holiday_red）
 *
 * ロジック:
 * - weekday_green: 4月〜7月、10月〜1月の平日
 * - holiday_red: 土休日、8月、9月、2月、3月（平日含む）
 */
function getCurrentDayType() {
    $month = (int)date('n');
    $dayOfWeek = (int)date('w');

    // 土日の場合
    if ($dayOfWeek === 0 || $dayOfWeek === 6) {
        return 'holiday_red';
    }

    // 8月、9月、2月、3月は休日扱い（平日でも）
    if (in_array($month, [2, 3, 8, 9])) {
        return 'holiday_red';
    }

    // 4月〜7月、10月〜1月の平日
    return 'weekday_green';
}
