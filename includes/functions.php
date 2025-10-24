<?php
/**
 * 共通関数ファイル
 *
 * システム全体で使用する汎用関数を定義
 */

/**
 * HTMLエスケープ
 *
 * @param string $str エスケープする文字列
 * @return string エスケープ後の文字列
 */
function h($str) {
    return htmlspecialchars($str, ENT_QUOTES, 'UTF-8');
}

/**
 * JSON形式でレスポンスを返す
 *
 * @param bool $success 成功フラグ
 * @param mixed $data データ
 * @param string $error エラーメッセージ
 */
function jsonResponse($success, $data = null, $error = null) {
    header('Content-Type: application/json; charset=utf-8');

    $response = [
        'success' => $success,
    ];

    if ($data !== null) {
        $response['data'] = $data;
    }

    if ($error !== null) {
        $response['error'] = $error;
    }

    echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

/**
 * 時刻を「HH:MM」形式にフォーマット
 *
 * @param string $time 時刻文字列
 * @return string フォーマット済み時刻
 */
function formatTime($time) {
    return date('H:i', strtotime($time));
}

/**
 * 時刻を「HH:MM:SS」形式にフォーマット
 *
 * @param string $time 時刻文字列
 * @return string フォーマット済み時刻
 */
function formatTimeWithSeconds($time) {
    return date('H:i:s', strtotime($time));
}

/**
 * 所要時間を計算（分単位）
 *
 * @param string $startTime 開始時刻
 * @param string $endTime 終了時刻
 * @return int 所要時間（分）
 */
function calculateDuration($startTime, $endTime) {
    $start = strtotime($startTime);
    $end = strtotime($endTime);
    return (int)(($end - $start) / 60);
}

/**
 * 時刻に分を加算
 *
 * @param string $time 基準時刻
 * @param int $minutes 加算する分
 * @return string 加算後の時刻（HH:MM:SS形式）
 */
function addMinutes($time, $minutes) {
    $timestamp = strtotime($time) + ($minutes * 60);
    return date('H:i:s', $timestamp);
}

/**
 * 現在時刻を取得（HH:MM:SS形式）
 *
 * @return string 現在時刻
 */
function getCurrentTime() {
    return date('H:i:s');
}

/**
 * 現在日時を取得（YYYY-MM-DD HH:MM:SS形式）
 *
 * @return string 現在日時
 */
function getCurrentDateTime() {
    return date('Y-m-d H:i:s');
}

/**
 * 時刻の比較
 *
 * @param string $time1 時刻1
 * @param string $time2 時刻2
 * @return int time1 < time2なら負、time1 > time2なら正、同じなら0
 */
function compareTime($time1, $time2) {
    return strtotime($time1) - strtotime($time2);
}

/**
 * デバッグログ出力
 *
 * @param mixed $data ログ出力するデータ
 * @param string $label ラベル
 */
function debugLog($data, $label = 'DEBUG') {
    if (defined('DEBUG_MODE') && DEBUG_MODE) {
        error_log(sprintf('[%s] %s', $label, print_r($data, true)));
    }
}

/**
 * エラーログ出力
 *
 * @param string $message エラーメッセージ
 * @param Exception $exception 例外オブジェクト（オプション）
 */
function logError($message, $exception = null) {
    $logMessage = '[ERROR] ' . $message;

    if ($exception) {
        $logMessage .= ' | Exception: ' . $exception->getMessage();
        $logMessage .= ' | File: ' . $exception->getFile();
        $logMessage .= ' | Line: ' . $exception->getLine();
    }

    error_log($logMessage);
}

/**
 * バリデーション: 時刻形式チェック
 *
 * @param string $time 時刻文字列
 * @return bool 有効な時刻形式ならtrue
 */
function isValidTime($time) {
    return preg_match('/^([01][0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$/', $time) === 1;
}

/**
 * バリデーション: 駅コードチェック
 *
 * @param string $stationCode 駅コード
 * @return bool 有効な駅コードならtrue
 */
function isValidStationCode($stationCode) {
    $validCodes = [
        'yagusa',
        'tojishiryokan_minami',
        'ai_chikyuhaku_kinen_koen',
        'koen_nishi',
        'geidai_dori',
        'nagakute_kosenjo',
        'irigaike_koen',
        'hanamizuki_dori',
        'fujigaoka'
    ];
    return in_array($stationCode, $validCodes, true);
}

/**
 * バリデーション: ダイヤ種別チェック
 *
 * @param string $diaType ダイヤ種別
 * @return bool 有効なダイヤ種別ならtrue
 */
function isValidDiaType($diaType) {
    return in_array($diaType, ['A', 'B', 'C'], true);
}

/**
 * 駅名を取得
 *
 * @param string $stationCode 駅コード
 * @return string 駅名
 */
function getStationName($stationCode) {
    $stationNames = [
        'yagusa' => '八草',
        'tojishiryokan_minami' => '陶磁資料館南',
        'ai_chikyuhaku_kinen_koen' => '愛・地球博記念公園',
        'koen_nishi' => '公園西',
        'geidai_dori' => '芸大通',
        'nagakute_kosenjo' => '長久手古戦場',
        'irigaike_koen' => '杁ヶ池公園',
        'hanamizuki_dori' => 'はなみずき通',
        'fujigaoka' => '藤が丘'
    ];
    return $stationNames[$stationCode] ?? $stationCode;
}

/**
 * 翌日のダイヤ種別を判定
 *
 * @return string 翌日のダイヤ種別（A/B/C）
 */
function getNextDayDiaType() {
    // 現在の時刻に24時間を加算
    $tomorrowTimestamp = time() + (24 * 60 * 60);
    $month = (int)date('n', $tomorrowTimestamp);
    $dayOfWeek = (int)date('w', $tomorrowTimestamp);

    // 土曜日は常にBダイヤ
    if ($dayOfWeek === 6) {
        return 'B';
    }

    // 日曜日は運行なし（念のためCダイヤ扱い）
    if ($dayOfWeek === 0) {
        return 'C';
    }

    // 平日の判定
    // 8月、9月、2月、3月 → Cダイヤ（学校休業期間）
    if (in_array($month, [2, 3, 8, 9])) {
        return 'C';
    }

    // 4-7月、10-1月の平日 → Aダイヤ（授業期間）
    if (in_array($month, [4, 5, 6, 7, 10, 11, 12, 1])) {
        return 'A';
    }

    // それ以外（念のため）
    return 'A';
}
