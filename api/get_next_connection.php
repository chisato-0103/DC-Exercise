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
    $direction = $_GET['direction'] ?? 'to_station'; // to_station or to_university
    $destination = $_GET['destination'] ?? getSetting('default_destination', DEFAULT_DESTINATION);
    $origin = $_GET['origin'] ?? getSetting('default_destination', DEFAULT_DESTINATION);
    $time = $_GET['time'] ?? getCurrentTime();
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : (int)getSetting('result_limit', RESULT_LIMIT);

    // バリデーション
    if (!isValidTime($time)) {
        jsonResponse(false, null, '無効な時刻形式です');
    }

    // 現在時刻
    $currentTime = getCurrentTime();
    $diaType = getCurrentDiaType();
    $dayType = getCurrentDayType();

    // 乗り継ぎルートを計算
    $routes = [];
    $fromName = '';
    $toName = '';
    $serviceInfo = null;

    if ($direction === 'to_station' && isValidStationCode($destination)) {
        // 大学 → リニモ各駅
        $routes = calculateUniversityToStation($destination, $time, $limit);
        $fromName = '愛知工業大学';
        $toName = getStationName($destination);
    } elseif ($direction === 'to_university') {
        // リニモ各駅または八草駅 → 大学
        if ($origin === 'yagusa') {
            // 八草駅 → 大学
            $routes = calculateYagusaToUniversity($time, $limit);
            $fromName = '八草駅';
            $toName = '愛知工業大学';
        } elseif (isValidStationCode($origin)) {
            // リニモ駅 → 大学
            $routes = calculateStationToUniversity($origin, $time, $limit);
            $fromName = getStationName($origin);
            $toName = '愛知工業大学';
        }
    }

    // ルートがない場合、最終便・初便情報を取得
    if (empty($routes)) {
        $currentHour = (int)date('H');

        if ($direction === 'to_station') {
            // 大学→駅の場合、シャトルバスの情報を取得
            $lastBus = getLastShuttleBus('to_yagusa', $diaType);
            $firstBus = getFirstShuttleBus('to_yagusa', $diaType);

            $serviceInfo = [
                'type' => 'shuttle',
                'direction_text' => '八草駅行き',
                'last' => $lastBus ? formatTime($lastBus['departure_time']) : null,
                'first' => $firstBus ? formatTime($firstBus['departure_time']) : null,
                'is_before_service' => $currentHour < 8,
                'is_after_service' => $currentHour >= 22
            ];
        } elseif ($direction === 'to_university') {
            // 駅→大学またはして八草駅→大学の場合、シャトルバスの情報を取得
            $lastBus = getLastShuttleBus('to_university', $diaType);
            $firstBus = getFirstShuttleBus('to_university', $diaType);

            $serviceInfo = [
                'type' => 'shuttle',
                'direction_text' => '大学行き',
                'last' => $lastBus ? formatTime($lastBus['departure_time']) : null,
                'first' => $firstBus ? formatTime($firstBus['departure_time']) : null,
                'is_before_service' => $currentHour < 8,
                'is_after_service' => $currentHour >= 22
            ];
        }
    }

    // ダイヤ情報
    global $DIA_TYPE_DESCRIPTIONS, $DAY_TYPE_DESCRIPTIONS;
    $diaDescription = $DIA_TYPE_DESCRIPTIONS[$diaType] ?? "ダイヤ{$diaType}";
    $dayDescription = $DAY_TYPE_DESCRIPTIONS[$dayType] ?? '';

    // レスポンス
    jsonResponse(true, [
        'current_time' => $currentTime,
        'dia_type' => $diaType,
        'dia_description' => $diaDescription,
        'day_type' => $dayType,
        'day_description' => $dayDescription,
        'direction' => $direction,
        'from_name' => $fromName,
        'to_name' => $toName,
        'routes' => $routes,
        'service_info' => $serviceInfo
    ]);

} catch (Exception $e) {
    logError('API Error in get_next_connection.php', $e);
    jsonResponse(false, null, 'サーバーエラーが発生しました');
}
