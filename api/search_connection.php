<?php
/**
 * 乗り継ぎ検索API
 *
 * 指定された出発地・目的地の乗り継ぎルートを検索してJSON形式で返す
 */

require_once __DIR__ . '/../config/settings.php';
require_once __DIR__ . '/../includes/functions.php';
require_once __DIR__ . '/../includes/db_functions.php';

// CORSヘッダー（必要に応じて）
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=utf-8');

try {
    // パラメータ取得
    $direction = $_GET['direction'] ?? 'to_station'; // to_station or to_university
    $from = $_GET['from'] ?? '';
    $to = $_GET['to'] ?? '';
    $time = $_GET['time'] ?? getCurrentTime();
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : (int)getSetting('result_limit', RESULT_LIMIT);

    // バリデーション
    if (empty($from) || empty($to)) {
        jsonResponse(false, null, '出発地と目的地を指定してください');
    }

    if (!isValidTime($time)) {
        jsonResponse(false, null, '無効な時刻形式です');
    }

    $routes = [];

    if ($direction === 'to_station' && $from === 'university') {
        // 大学→リニモ各駅
        if (!isValidStationCode($to)) {
            jsonResponse(false, null, '無効な目的地コードです');
        }
        $routes = calculateUniversityToStation($to, $time, $limit);
        $fromName = '愛知工業大学';
        $toName = getStationName($to);

    } elseif ($direction === 'to_university' && $to === 'university') {
        // リニモ各駅→大学
        if (!isValidStationCode($from)) {
            jsonResponse(false, null, '無効な出発地コードです');
        }
        $routes = calculateStationToUniversity($from, $time, $limit);
        $fromName = getStationName($from);
        $toName = '愛知工業大学';

    } else {
        jsonResponse(false, null, '現在、この区間の検索には対応していません');
    }

    // レスポンス
    jsonResponse(true, [
        'current_time' => formatTime($time),
        'direction' => $direction,
        'from' => $fromName,
        'to' => $toName,
        'connections' => $routes
    ]);

} catch (Exception $e) {
    logError('API Error in search_connection.php', $e);
    jsonResponse(false, null, 'サーバーエラーが発生しました');
}
