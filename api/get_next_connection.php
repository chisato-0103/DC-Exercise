<?php
/**
 * 次の便取得API
 *
 * 現在時刻から次に乗れる便を取得し、JSON形式で返す
 */

require_once __DIR__ . '/../config/settings.php';
require_once __DIR__ . '/../includes/functions.php';
require_once __DIR__ . '/../includes/db_functions.php';

// CORSヘッダー（必要に応じて）
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=utf-8');

try {
    // パラメータ取得
    $destination = $_GET['destination'] ?? getSetting('default_destination', DEFAULT_DESTINATION);
    $time = $_GET['time'] ?? getCurrentTime();
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : (int)getSetting('result_limit', RESULT_LIMIT);

    // バリデーション
    if (!isValidStationCode($destination)) {
        jsonResponse(false, null, '無効な目的地コードです');
    }

    if (!isValidTime($time)) {
        jsonResponse(false, null, '無効な時刻形式です');
    }

    // 乗り継ぎルートを計算
    $routes = calculateUniversityToStation($destination, $time, $limit);

    // レスポンス
    jsonResponse(true, [
        'current_time' => formatTime($time),
        'destination' => getStationName($destination),
        'destination_code' => $destination,
        'connections' => $routes
    ]);

} catch (Exception $e) {
    logError('API Error in get_next_connection.php', $e);
    jsonResponse(false, null, 'サーバーエラーが発生しました');
}
