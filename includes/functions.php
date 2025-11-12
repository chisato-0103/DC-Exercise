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
    // HH:MM:SS形式の時刻に分を加算
    $timeParts = explode(':', $time);
    $hours = (int)$timeParts[0];
    $mins = (int)$timeParts[1];
    $secs = isset($timeParts[2]) ? (int)$timeParts[2] : 0;

    // 分を加算
    $totalMinutes = $hours * 60 + $mins + $minutes;
    $totalSeconds = $totalMinutes * 60 + $secs;

    // 24時間を超えた場合の処理
    $totalSeconds = $totalSeconds % (24 * 60 * 60);

    $newHours = (int)($totalSeconds / 3600);
    $newMins = (int)(($totalSeconds % 3600) / 60);
    $newSecs = $totalSeconds % 60;

    return sprintf('%02d:%02d:%02d', $newHours, $newMins, $newSecs);
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
        // リニモ駅
        'yakusa',
        'tojishiryokannminami',
        'aichikyuhakukinenkoen',
        'koennishi',
        'geidaidori',
        'nagakutekosenjo',
        'irigaikekoen',
        'hanamizukidori',
        'fujigaoka',
        // 愛知環状線駅（23駅） - Database format (with underscores)
        'okazaki',
        'mutsuna',
        'nakaokazaki',
        'kitaokazaki',
        'kitanomasuzuka',
        'mikawakamigo',
        'ekaku',
        'suenohara',
        'mikawa_toyota',
        'shinuwagoromo',
        'shintoyota',
        'aikan_umetsubo',
        'shigo',
        'kaizu',
        'homi',
        'sasabara',
        'yamaguchi',
        'setoguchi',
        'setoshi',
        'nakamizuno',
        'kozoji',
        // Alternative formats (without underscores) for backward compatibility
        'kitaokazaki',
        'kitanomasuzuka',
        'mikawakamigo',
        'mikawatoyota',
        'shinuwagoromo',
        'shintoyota',
        'aikanumetubo',
        'aikanumetsubo',
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
        // リニモ駅
        'yakusa' => '八草',
        'tojishiryokan_minami' => '陶磁資料館南',
        'aichikyuhaku_kinen_koen' => '愛・地球博記念公園',
        'koennishi' => '公園西',
        'geidaidori' => '芸大通',
        'nagakutekosenjo' => '長久手古戦場',
        'irigaikekoen' => '杁ヶ池公園',
        'hanamizukidori' => 'はなみずき通',
        'fujigaoka' => '藤が丘',
        // 愛知環状線駅（23駅） - Database format with underscores
        'okazaki' => '岡崎',
        'mutsuna' => '武豊',
        'nakaokazaki' => '中岡崎',
        'kita_okazaki' => '北岡崎',
        'kitano_masuzuka' => '北野増塚',
        'mikawa_kamigo' => '三河上郷',
        'ekaku' => '江角',
        'suenohara' => '末野原',
        'mikawa_toyota' => '三河豊田',
        'shin_uwagoromo' => '新上挙母',
        'shin_toyota' => '新豊田',
        'aikan_umetsubo' => '愛環梅坪',
        'shigo' => '塩後',
        'kaizu' => '海津',
        'homi' => '豊見',
        'sasabara' => '笹原',
        'yamaguchi' => '山口',
        'setoguchi' => '瀬戸口',
        'setoshi' => '瀬戸市',
        'nakamizuno' => '中水野',
        'kozoji' => '幸次',
        // Alternative formats (without underscores) for backward compatibility
        'kitaokazaki' => '北岡崎',
        'kitanomasuzuka' => '北野増塚',
        'mikawakamigo' => '三河上郷',
        'mikawatoyota' => '三河豊田',
        'shinuwagoromo' => '新上挙母',
        'shintoyota' => '新豊田',
        'aikanumetubo' => '愛環梅坪',
        'aikanumetsubo' => '愛環梅坪',
    ];
    return $stationNames[$stationCode] ?? $stationCode;
}

/**
 * 翌日のダイヤ種別を判定（DB照会）
 *
 * @return string 翌日のダイヤ種別（A/B/C）、運休の場合は'holiday'
 */
function getNextDayDiaType() {
    // 翌日の日付を計算
    $tomorrow = date('Y-m-d', time() + (24 * 60 * 60));

    try {
        require_once __DIR__ . '/../config/database.php';
        $pdo = getDbConnection();

        // shuttle_scheduleテーブルから翌日のダイヤを照会
        $sql = "SELECT dia_type FROM shuttle_schedule WHERE operation_date = :date LIMIT 1";
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':date', $tomorrow, PDO::PARAM_STR);
        $stmt->execute();

        $result = $stmt->fetch();
        if ($result) {
            return $result['dia_type'];
        }

        // データがない場合はAダイヤにフォールバック
        return 'A';

    } catch (Exception $e) {
        error_log('Error getting next day diagram type from database: ' . $e->getMessage());
        // エラーが発生した場合はAダイヤにフォールバック
        return 'A';
    }
}
