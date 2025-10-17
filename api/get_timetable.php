<?php
/**
 * 時刻表取得API
 *
 * シャトルバスまたはリニモの時刻表をJSON形式で返す
 */

require_once __DIR__ . '/../config/settings.php';
require_once __DIR__ . '/../includes/functions.php';
require_once __DIR__ . '/../includes/db_functions.php';

// CORSヘッダー（必要に応じて）
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=utf-8');

try {
    // パラメータ取得
    $type = $_GET['type'] ?? 'shuttle'; // shuttle or linimo
    $direction = $_GET['direction'] ?? '';
    $diaType = $_GET['dia_type'] ?? '';
    $dayType = $_GET['day_type'] ?? '';
    $stationCode = $_GET['station_code'] ?? 'yagusa';

    $timetable = [];
    $metadata = [];

    if ($type === 'shuttle') {
        // シャトルバス時刻表
        if (empty($direction) || empty($diaType)) {
            jsonResponse(false, null, 'direction と dia_type パラメータが必要です');
        }

        if (!in_array($direction, ['to_university', 'to_yagusa'])) {
            jsonResponse(false, null, '無効な direction です');
        }

        if (!isValidDiaType($diaType)) {
            jsonResponse(false, null, '無効な dia_type です');
        }

        try {
            $pdo = getDbConnection();
            $sql = "SELECT departure_time, arrival_time, remarks
                    FROM shuttle_bus_timetable
                    WHERE direction = :direction
                    AND dia_type = :dia_type
                    AND is_active = 1
                    ORDER BY departure_time ASC";

            $stmt = $pdo->prepare($sql);
            $stmt->bindValue(':direction', $direction, PDO::PARAM_STR);
            $stmt->bindValue(':dia_type', $diaType, PDO::PARAM_STR);
            $stmt->execute();

            $results = $stmt->fetchAll();

            foreach ($results as $row) {
                $timetable[] = [
                    'departure_time' => formatTime($row['departure_time']),
                    'arrival_time' => formatTime($row['arrival_time']),
                    'remarks' => $row['remarks']
                ];
            }

            global $DIA_TYPE_DESCRIPTIONS;
            $metadata = [
                'type' => 'shuttle',
                'direction' => $direction,
                'direction_name' => $direction === 'to_university' ? '八草駅 → 愛知工業大学' : '愛知工業大学 → 八草駅',
                'dia_type' => $diaType,
                'dia_type_description' => $DIA_TYPE_DESCRIPTIONS[$diaType] ?? '',
                'count' => count($timetable)
            ];

        } catch (PDOException $e) {
            logError('Failed to get shuttle timetable', $e);
            jsonResponse(false, null, 'データベースエラーが発生しました');
        }

    } elseif ($type === 'linimo') {
        // リニモ時刻表
        if (empty($direction) || empty($dayType)) {
            jsonResponse(false, null, 'direction と day_type パラメータが必要です');
        }

        if (!in_array($direction, ['to_fujigaoka', 'to_yagusa'])) {
            jsonResponse(false, null, '無効な direction です');
        }

        if (!in_array($dayType, ['weekday_green', 'holiday_red'])) {
            jsonResponse(false, null, '無効な day_type です');
        }

        if (!isValidStationCode($stationCode)) {
            jsonResponse(false, null, '無効な station_code です');
        }

        try {
            $pdo = getDbConnection();
            $sql = "SELECT departure_time
                    FROM linimo_timetable
                    WHERE station_code = :station_code
                    AND direction = :direction
                    AND day_type = :day_type
                    AND is_active = 1
                    ORDER BY departure_time ASC";

            $stmt = $pdo->prepare($sql);
            $stmt->bindValue(':station_code', $stationCode, PDO::PARAM_STR);
            $stmt->bindValue(':direction', $direction, PDO::PARAM_STR);
            $stmt->bindValue(':day_type', $dayType, PDO::PARAM_STR);
            $stmt->execute();

            $results = $stmt->fetchAll();

            foreach ($results as $row) {
                $timetable[] = [
                    'departure_time' => formatTime($row['departure_time'])
                ];
            }

            global $DAY_TYPE_DESCRIPTIONS;
            $metadata = [
                'type' => 'linimo',
                'station_code' => $stationCode,
                'station_name' => getStationName($stationCode),
                'direction' => $direction,
                'direction_name' => $direction === 'to_fujigaoka' ? '藤が丘方面' : '八草方面',
                'day_type' => $dayType,
                'day_type_description' => $DAY_TYPE_DESCRIPTIONS[$dayType] ?? '',
                'count' => count($timetable)
            ];

        } catch (PDOException $e) {
            logError('Failed to get linimo timetable', $e);
            jsonResponse(false, null, 'データベースエラーが発生しました');
        }

    } else {
        jsonResponse(false, null, '無効な type です (shuttle または linimo を指定してください)');
    }

    // レスポンス
    jsonResponse(true, [
        'metadata' => $metadata,
        'timetable' => $timetable
    ]);

} catch (Exception $e) {
    logError('API Error in get_timetable.php', $e);
    jsonResponse(false, null, 'サーバーエラーが発生しました');
}
