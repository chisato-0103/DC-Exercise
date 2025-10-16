<?php
/**
 * データベース操作関数
 *
 * データベースへのクエリ処理を行う関数を定義
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/settings.php';
require_once __DIR__ . '/functions.php';

/**
 * 次のシャトルバスを取得
 *
 * @param string $direction 方向（to_university / to_yagusa）
 * @param string $currentTime 現在時刻（HH:MM:SS）
 * @param string $diaType ダイヤ種別（A/B/C）
 * @param int $limit 取得件数
 * @return array シャトルバスの配列
 */
function getNextShuttleBuses($direction, $currentTime, $diaType, $limit = 5) {
    try {
        $pdo = getDbConnection();

        $sql = "SELECT * FROM shuttle_bus_timetable
                WHERE direction = :direction
                AND dia_type = :dia_type
                AND departure_time >= :current_time
                AND is_active = 1
                ORDER BY departure_time ASC
                LIMIT :limit";

        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':direction', $direction, PDO::PARAM_STR);
        $stmt->bindValue(':dia_type', $diaType, PDO::PARAM_STR);
        $stmt->bindValue(':current_time', $currentTime, PDO::PARAM_STR);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll();

    } catch (PDOException $e) {
        logError('Failed to get next shuttle buses', $e);
        return [];
    }
}

/**
 * 次のリニモを取得
 *
 * @param string $stationCode 駅コード
 * @param string $direction 方向（to_fujigaoka / to_yagusa）
 * @param string $currentTime 現在時刻（HH:MM:SS）
 * @param string $dayType 曜日種別（weekday_green / holiday_red）
 * @param int $limit 取得件数
 * @return array リニモの配列
 */
function getNextLinimoTrains($stationCode, $direction, $currentTime, $dayType, $limit = 5) {
    try {
        $pdo = getDbConnection();

        $sql = "SELECT * FROM linimo_timetable
                WHERE station_code = :station_code
                AND direction = :direction
                AND departure_time >= :current_time
                AND day_type = :day_type
                AND is_active = 1
                ORDER BY departure_time ASC
                LIMIT :limit";

        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':station_code', $stationCode, PDO::PARAM_STR);
        $stmt->bindValue(':direction', $direction, PDO::PARAM_STR);
        $stmt->bindValue(':current_time', $currentTime, PDO::PARAM_STR);
        $stmt->bindValue(':day_type', $dayType, PDO::PARAM_STR);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll();

    } catch (PDOException $e) {
        logError('Failed to get next Linimo trains', $e);
        return [];
    }
}

/**
 * 駅情報を取得
 *
 * @param string $stationCode 駅コード
 * @return array|null 駅情報
 */
function getStationInfo($stationCode) {
    try {
        $pdo = getDbConnection();

        $sql = "SELECT * FROM stations WHERE station_code = :station_code";
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':station_code', $stationCode, PDO::PARAM_STR);
        $stmt->execute();

        return $stmt->fetch();

    } catch (PDOException $e) {
        logError('Failed to get station info', $e);
        return null;
    }
}

/**
 * 全駅のリストを取得
 *
 * @return array 駅情報の配列
 */
function getAllStations() {
    try {
        $pdo = getDbConnection();

        $sql = "SELECT * FROM stations ORDER BY order_index ASC";
        $stmt = $pdo->query($sql);

        return $stmt->fetchAll();

    } catch (PDOException $e) {
        logError('Failed to get all stations', $e);
        return [];
    }
}

/**
 * アクティブなお知らせを取得
 *
 * @param string $target 対象（all / shuttle / linimo）
 * @return array お知らせの配列
 */
function getActiveNotices($target = 'all') {
    try {
        $pdo = getDbConnection();
        $currentDateTime = getCurrentDateTime();

        $sql = "SELECT * FROM notices
                WHERE is_active = 1
                AND start_date <= :current_datetime
                AND (end_date IS NULL OR end_date >= :current_datetime)
                AND (target = :target OR target = 'all')
                ORDER BY start_date DESC";

        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':current_datetime', $currentDateTime, PDO::PARAM_STR);
        $stmt->bindValue(':target', $target, PDO::PARAM_STR);
        $stmt->execute();

        return $stmt->fetchAll();

    } catch (PDOException $e) {
        logError('Failed to get active notices', $e);
        return [];
    }
}

/**
 * 最適な乗り継ぎルートを計算（大学→リニモ各駅）
 *
 * @param string $destinationCode 目的地駅コード
 * @param string $currentTime 現在時刻（HH:MM:SS）
 * @param int $limit 取得件数
 * @return array 乗り継ぎルートの配列
 */
function calculateUniversityToStation($destinationCode, $currentTime, $limit = 3) {
    try {
        // 現在のダイヤ種別と曜日種別を取得
        $diaType = getCurrentDiaType();
        $dayType = getCurrentDayType();

        // 乗り換え時間と所要時間を取得
        $transferTime = (int)getSetting('transfer_time_minutes', TRANSFER_TIME_MINUTES);

        // 目的地の情報を取得
        $destinationInfo = getStationInfo($destinationCode);
        if (!$destinationInfo) {
            return [];
        }

        $linimoTravelTime = (int)$destinationInfo['travel_time_from_yagusa'];

        // 次のシャトルバス（大学→八草駅）を取得
        $shuttleBuses = getNextShuttleBuses('to_yagusa', $currentTime, $diaType, 10);

        $routes = [];

        foreach ($shuttleBuses as $shuttle) {
            // 八草駅到着時刻 + 乗り換え時間
            $yagusaArrivalTime = $shuttle['arrival_time'];
            $minLinimoTime = addMinutes($yagusaArrivalTime, $transferTime);

            // 接続可能なリニモを取得
            $linimoTrains = getNextLinimoTrains('yagusa', 'to_fujigaoka', $minLinimoTime, $dayType, 1);

            if (empty($linimoTrains)) {
                continue;
            }

            $linimo = $linimoTrains[0];

            // 目的地到着時刻を計算
            $destinationArrivalTime = addMinutes($linimo['departure_time'], $linimoTravelTime);

            // 総所要時間と待ち時間を計算
            $totalTime = calculateDuration($currentTime, $destinationArrivalTime);
            $waitingTime = calculateDuration($currentTime, $shuttle['departure_time']);
            $actualTransferTime = calculateDuration($yagusaArrivalTime, $linimo['departure_time']);

            $routes[] = [
                'shuttle_departure' => formatTime($shuttle['departure_time']),
                'shuttle_arrival' => formatTime($yagusaArrivalTime),
                'linimo_departure' => formatTime($linimo['departure_time']),
                'destination_arrival' => formatTime($destinationArrivalTime),
                'transfer_time' => $actualTransferTime,
                'total_time' => $totalTime,
                'waiting_time' => $waitingTime,
                'destination_name' => $destinationInfo['station_name']
            ];

            if (count($routes) >= $limit) {
                break;
            }
        }

        return $routes;

    } catch (Exception $e) {
        logError('Failed to calculate university to station route', $e);
        return [];
    }
}

/**
 * システム設定を取得
 *
 * @param string $key 設定キー
 * @return string|null 設定値
 */
function getSystemSetting($key) {
    try {
        $pdo = getDbConnection();

        $sql = "SELECT setting_value FROM system_settings WHERE setting_key = :key";
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':key', $key, PDO::PARAM_STR);
        $stmt->execute();

        $result = $stmt->fetch();
        return $result ? $result['setting_value'] : null;

    } catch (PDOException $e) {
        logError('Failed to get system setting', $e);
        return null;
    }
}
