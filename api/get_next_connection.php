<?php
/**
 * 次の便取得API
 *
 * 現在時刻から次に乗れる便を取得し、JSON形式で返す
 */

require_once __DIR__ . '/../config/settings.php';
require_once __DIR__ . '/../includes/functions.php';
require_once __DIR__ . '/../includes/db_functions.php';
require_once __DIR__ . '/../includes/db_functions_generic.php';

// CORSヘッダー
// ⚠️ 本番環境では '*' ではなく、特定のドメインに制限することを推奨
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=utf-8');

try {
    // パラメータ取得
    $direction = $_GET['direction'] ?? 'to_station'; // to_station or to_university
    $lineCode = $_GET['line_code'] ?? 'linimo'; // linimo or aichi_kanjo
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : (int)getSetting('result_limit', RESULT_LIMIT);

    // 方向に応じてパラメータを取得
    if ($direction === 'to_station') {
        $destination = $_GET['destination'] ?? getSetting('default_destination', DEFAULT_DESTINATION);
        $origin = null;
    } else {
        $origin = $_GET['origin'] ?? getSetting('default_destination', DEFAULT_DESTINATION);
        $destination = null;
    }

    // テスト用パラメータ（デバッグモードのみ）
    $testDate = null;
    $testHour = null;
    if (DEBUG_MODE && isset($_GET['test_date'])) {
        $testDate = $_GET['test_date'];
    }

    if (DEBUG_MODE && isset($_GET['test_time'])) {
        $time = $_GET['test_time'];
        $testHour = (int)explode(':', $time)[0];  // test_time から時を抽出
    } else {
        $time = getCurrentTime();
    }

    // バリデーション
    if (!isValidTime($time)) {
        jsonResponse(false, null, '無効な時刻形式です');
    }

    // 現在時刻（テスト時刻またはリアルタイム時刻）
    $currentTime = $time;
    $diaType = getCurrentDiaType($testDate);

    // テスト用日付がある場合はその日付で day_type を計算
    if ($testDate) {
        // テスト日付の曜日を計算
        $timestamp = strtotime($testDate);
        $month = (int)date('n', $timestamp);
        $dayOfWeek = (int)date('w', $timestamp);

        if ($dayOfWeek === 0 || $dayOfWeek === 6) {
            $dayType = 'holiday_red';
        } elseif (in_array($month, [2, 3, 8, 9])) {
            $dayType = 'holiday_red';
        } else {
            $dayType = 'weekday_green';
        }
    } else {
        $dayType = getCurrentDayType();
    }

    // 乗り継ぎルートを計算
    $routes = [];
    $fromName = '';
    $toName = '';
    $serviceInfo = null;

    if ($direction === 'to_station' && isValidStationCode($destination)) {
        // 大学 → 路線駅
        if ($lineCode === 'linimo') {
            // リニモ駅へ
            $routes = calculateUniversityToStation($destination, $time, $limit);
        } elseif ($lineCode === 'aichi_kanjo') {
            // 愛知環状線駅へ
            $routes = calculateUniversityToRail($lineCode, $destination, $time, $limit, $dayType);
        }
        $fromName = '愛知工業大学';
        $toName = getStationName($destination);
    } elseif ($direction === 'to_university') {
        // 路線駅または八草駅 → 大学
        if ($origin === 'yakusa') {
            // 八草駅 → 大学
            $routes = calculateYagusaToUniversity($time, $limit);
            $fromName = '八草駅';
            $toName = '愛知工業大学';
        } elseif (isValidStationCode($origin)) {
            // 路線駅 → 大学
            if ($lineCode === 'linimo') {
                // リニモ駅から
                $routes = calculateStationToUniversity($origin, $time, $limit);
            } elseif ($lineCode === 'aichi_kanjo') {
                // 愛知環状線駅から
                $routes = calculateRailToUniversity($lineCode, $origin, $time, $limit, $dayType);
            }
            $fromName = getStationName($origin);
            $toName = '愛知工業大学';
        }
    }

    // ルートがない場合、最終便・初便情報を取得
    if (empty($routes)) {
        // デバッグ用：test_hourがセットされている場合はそれを使用
        $currentHour = $testHour !== null ? $testHour : (int)date('H');
        // 注: $currentTime は既に line 58 で $time に設定されているため、ここでは上書きしない

        if ($direction === 'to_station') {
            // 大学→駅の場合、シャトルバスの情報を取得
            $lastBus = getLastShuttleBus('to_yagusa', $diaType);
            $firstBus = getFirstShuttleBus('to_yagusa', $diaType);

            // 次の日のダイヤを取得（翌日のダイヤが異なる場合に対応）
            $nextDayDiaType = getNextDayDiaType();
            $nextDayFirstBus = getFirstShuttleBus('to_yagusa', $nextDayDiaType);

            // 翌日のダイヤ説明を取得
            $nextDayDiaDescription = $DIA_TYPE_DESCRIPTIONS[$nextDayDiaType] ?? "ダイヤ{$nextDayDiaType}";

            // 最終便の時刻を参照して運行終了を判定
            $isAfterService = false;
            if ($lastBus && $lastBus['departure_time']) {
                // 最終便時刻と現在時刻を比較
                $lastBusTime = strtotime($lastBus['departure_time']);
                $currentTimeObj = strtotime($currentTime);
                $isAfterService = $currentTimeObj > $lastBusTime;
            } elseif ($currentHour >= 22) {
                // 最終便が取得できない場合は22:00で判定
                $isAfterService = true;
            }

            $serviceInfo = [
                'type' => 'shuttle',
                'direction_text' => '八草駅行き',
                'last' => $lastBus ? formatTime($lastBus['departure_time']) : null,
                'first' => $firstBus ? formatTime($firstBus['departure_time']) : null,
                'next_day_first' => $nextDayFirstBus ? formatTime($nextDayFirstBus['departure_time']) : null,
                'next_day_dia_type' => $nextDayDiaType,
                'next_day_dia_description' => $nextDayDiaDescription,
                'is_before_service' => $currentHour < 8,
                'is_after_service' => $isAfterService,
                'bg_color' => $isAfterService ? '#1e3a5f' : '#0052a3',
                'text_color' => '#ffffff'
            ];
        } elseif ($direction === 'to_university') {
            // 駅→大学またはして八草駅→大学の場合、シャトルバスの情報を取得
            $lastBus = getLastShuttleBus('to_university', $diaType);
            $firstBus = getFirstShuttleBus('to_university', $diaType);

            // 次の日のダイヤを取得
            $nextDayDiaType = getNextDayDiaType();
            $nextDayFirstBus = getFirstShuttleBus('to_university', $nextDayDiaType);

            // 翌日のダイヤ説明を取得
            $nextDayDiaDescription = $DIA_TYPE_DESCRIPTIONS[$nextDayDiaType] ?? "ダイヤ{$nextDayDiaType}";

            // 最終便の時刻を参照して運行終了を判定
            $isAfterService = false;
            if ($lastBus && $lastBus['departure_time']) {
                // 最終便時刻と現在時刻を比較
                $lastBusTime = strtotime($lastBus['departure_time']);
                $currentTimeObj = strtotime($currentTime);
                $isAfterService = $currentTimeObj > $lastBusTime;
            } elseif ($currentHour >= 22) {
                // 最終便が取得できない場合は22:00で判定
                $isAfterService = true;
            }

            $serviceInfo = [
                'type' => 'shuttle',
                'direction_text' => '大学行き',
                'last' => $lastBus ? formatTime($lastBus['departure_time']) : null,
                'first' => $firstBus ? formatTime($firstBus['departure_time']) : null,
                'next_day_first' => $nextDayFirstBus ? formatTime($nextDayFirstBus['departure_time']) : null,
                'next_day_dia_type' => $nextDayDiaType,
                'next_day_dia_description' => $nextDayDiaDescription,
                'is_before_service' => $currentHour < 8,
                'is_after_service' => $isAfterService,
                'bg_color' => $isAfterService ? '#1e3a5f' : '#0052a3',
                'text_color' => '#ffffff'
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
        'line_code' => $lineCode,
        'from_name' => $fromName,
        'to_name' => $toName,
        'routes' => $routes,
        'service_info' => $serviceInfo
    ]);

} catch (Exception $e) {
    http_response_code(500);
    logError('API Error in get_next_connection.php', $e);

    // 本番環境では例外詳細を隠す
    $errorMessage = DEBUG_MODE
        ? $e->getMessage()
        : 'サーバーエラーが発生しました';

    jsonResponse(false, null, $errorMessage);
}
