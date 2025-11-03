<?php
/**
 * 汎用レール路線操作関数（オプションB）
 *
 * リニモと愛知環状線の両方に対応した汎用関数
 * 既存のlinimo専用関数と並行で使用可能
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/settings.php';
require_once __DIR__ . '/functions.php';

/**
 * 次の列車を取得（汎用版）
 *
 * @param string $lineCode 路線コード（'linimo', 'aichi_kanjo'など）
 * @param string $stationCode 駅コード
 * @param string $direction 方向
 * @param string $currentTime 現在時刻（HH:MM:SS）
 * @param string $dayType 曜日種別（'weekday', 'holiday'）
 * @param int $limit 取得件数
 * @return array 列車情報の配列
 */
function getNextRailTrains($lineCode, $stationCode, $direction, $currentTime, $dayType, $limit = 5) {
    try {
        $pdo = getDbConnection();

        $sql = "SELECT * FROM rail_timetable
                WHERE line_code = :line_code
                AND station_code = :station_code
                AND direction = :direction
                AND departure_time >= :current_time
                AND day_type = :day_type
                AND is_active = 1
                ORDER BY departure_time ASC
                LIMIT :limit";

        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':line_code', $lineCode, PDO::PARAM_STR);
        $stmt->bindValue(':station_code', $stationCode, PDO::PARAM_STR);
        $stmt->bindValue(':direction', $direction, PDO::PARAM_STR);
        $stmt->bindValue(':current_time', $currentTime, PDO::PARAM_STR);
        $stmt->bindValue(':day_type', $dayType, PDO::PARAM_STR);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll();

    } catch (PDOException $e) {
        logError('Failed to get next rail trains', $e);
        return [];
    }
}

/**
 * 大学 → 指定路線駅への乗り継ぎを計算（汎用版）
 *
 * @param string $lineCode 路線コード（'linimo', 'aichi_kanjo'など）
 * @param string $destinationCode 目的地駅コード
 * @param string $currentTime 現在時刻（HH:MM:SS）
 * @param int $limit 取得件数
 * @param string $dayType 曜日種別（'weekday_green' or 'holiday_red'、指定されない場合は自動判定）
 * @return array 乗り継ぎルートの配列
 */
function calculateUniversityToRail($lineCode, $destinationCode, $currentTime, $limit = 3, $dayType = null) {
    try {
        $diaType = getCurrentDiaType();
        if ($dayType === null) {
            $dayType = getCurrentDayType();
        }
        $transferTime = (int)getSetting('transfer_time_minutes', TRANSFER_TIME_MINUTES);

        // 目的地の情報を取得
        $destinationInfo = getStationInfo($destinationCode);
        if (!$destinationInfo) {
            return [];
        }

        // 八草駅が目的地の場合はシャトルバスのみ
        if ($destinationCode === 'yakusa') {
            $shuttleBuses = getNextShuttleBuses('to_yagusa', $currentTime, $diaType, $limit);

            $routes = [];
            foreach ($shuttleBuses as $shuttle) {
                $departure = $shuttle['departure_time'];
                $arrival = $shuttle['arrival_time'];
                $travelTime = calculateDuration($departure, $arrival);
                $waitingTime = calculateDuration($currentTime, $departure);

                $routes[] = [
                    'shuttle_departure' => formatTime($departure),
                    'shuttle_arrival' => formatTime($arrival),
                    'rail_departure' => null,
                    'destination_arrival' => formatTime($arrival),
                    'transfer_time' => 0,
                    'total_time' => $travelTime,
                    'waiting_time' => $waitingTime,
                    'destination_name' => $destinationInfo['station_name'],
                    'line_code' => $lineCode
                ];
            }

            return $routes;
        }

        // 路線駅が目的地の場合はシャトルバス + 路線で計算
        $railTravelTime = (int)$destinationInfo['travel_time_from_yagusa'];
        $shuttleBuses = getNextShuttleBuses('to_yagusa', $currentTime, $diaType, 10);
        $routes = [];

        foreach ($shuttleBuses as $shuttle) {
            $yagusaArrivalTime = $shuttle['arrival_time'];
            $minRailTime = addMinutes($yagusaArrivalTime, $transferTime);

            // 接続可能な列車を取得（八草駅から）
            // リニモの場合は'to_fujigaoka'、愛知環状線の場合は'to_okazaki'など
            $railDirection = ($lineCode === 'linimo') ? 'to_fujigaoka' : 'to_okazaki';

            $railTrains = getNextRailTrains($lineCode, 'yakusa', $railDirection, $minRailTime, $dayType, 3);

            if (empty($railTrains)) {
                continue;
            }

            $rail = $railTrains[0];
            $yagusaDepartureTime = $rail['departure_time'];
            $estimatedArrivalTime = addMinutes($yagusaDepartureTime, $railTravelTime);
            $destinationArrivalTime = $estimatedArrivalTime;

            // 実際の乗り換え時間を計算
            $actualTransferTime = calculateDuration($yagusaArrivalTime, $yagusaDepartureTime);

            // 総所要時間と待ち時間を計算
            $totalTime = calculateDuration($currentTime, $destinationArrivalTime);
            $waitingTime = calculateDuration($currentTime, $shuttle['departure_time']);

            // 路線選択肢を生成（複数本）
            $railOptions = [];
            foreach ($railTrains as $option) {
                $optionDepartureTime = $option['departure_time'];
                $optionArrivalTime = addMinutes($optionDepartureTime, $railTravelTime);
                $optionTransferTime = calculateDuration($yagusaArrivalTime, $optionDepartureTime);
                $optionTotalTime = calculateDuration($currentTime, $optionArrivalTime);

                $railOptions[] = [
                    'rail_departure' => formatTime($optionDepartureTime),
                    'destination_arrival' => formatTime($optionArrivalTime),
                    'transfer_time' => $optionTransferTime,
                    'total_time' => $optionTotalTime,
                    'rail_time' => $railTravelTime
                ];
            }

            $routes[] = [
                'shuttle_departure' => formatTime($shuttle['departure_time']),
                'shuttle_arrival' => formatTime($yagusaArrivalTime),
                'rail_departure' => formatTime($rail['departure_time']),
                'destination_arrival' => formatTime($destinationArrivalTime),
                'transfer_time' => $actualTransferTime,
                'total_time' => $totalTime,
                'waiting_time' => $waitingTime,
                'destination_name' => $destinationInfo['station_name'],
                'rail_options' => $railOptions,
                'line_code' => $lineCode
            ];

            if (count($routes) >= $limit) {
                break;
            }
        }

        return $routes;

    } catch (Exception $e) {
        logError('Failed to calculate university to rail route', $e);
        return [];
    }
}

/**
 * 指定路線駅 → 大学への乗り継ぎを計算（汎用版）
 *
 * @param string $lineCode 路線コード（'linimo', 'aichi_kanjo'など）
 * @param string $originCode 出発駅コード
 * @param string $currentTime 現在時刻（HH:MM:SS）
 * @param int $limit 取得件数
 * @param string $dayType 曜日種別（'weekday_green' or 'holiday_red'、指定されない場合は自動判定）
 * @return array 乗り継ぎルートの配列
 */
function calculateRailToUniversity($lineCode, $originCode, $currentTime, $limit = 3, $dayType = null) {
    try {
        $diaType = getCurrentDiaType();
        if ($dayType === null) {
            $dayType = getCurrentDayType();
        }
        $transferTime = (int)getSetting('transfer_time_minutes', TRANSFER_TIME_MINUTES);

        // 出発駅の情報を取得
        $originInfo = getStationInfo($originCode);
        if (!$originInfo) {
            return [];
        }

        $railTravelTime = (int)$originInfo['travel_time_from_yagusa'];

        // 次の列車（出発駅→八草駅）を取得
        // リニモの場合は'to_yagusa'、愛知環状線の場合は'to_kozoji'など
        $railDirection = ($lineCode === 'linimo') ? 'to_yagusa' : 'to_kozoji';

        $railTrains = getNextRailTrains($lineCode, $originCode, $railDirection, $currentTime, $dayType, 30);

        // 時刻表データがない場合は、八草発の逆方向から逆算
        $useReverseCalculation = empty($railTrains);
        if ($useReverseCalculation) {
            $reverseDirection = ($lineCode === 'linimo') ? 'to_fujigaoka' : 'to_okazaki';
            $railTrains = getNextRailTrains($lineCode, 'yakusa', $reverseDirection, $currentTime, $dayType, 30);
        }

        $routes = [];

        foreach ($railTrains as $rail) {
            if ($useReverseCalculation) {
                // 八草駅発車時刻から出発駅の発車時刻を逆算
                $yagusaDepartureTime = $rail['departure_time'];
                $originDepartureTime = addMinutes($yagusaDepartureTime, -$railTravelTime);

                // 現在時刻より前なら除外
                if (compareTime($originDepartureTime, $currentTime) < 0) {
                    continue;
                }

                // 八草駅到着時刻
                $yagusaArrivalTime = addMinutes($yagusaDepartureTime, 2);
            } else {
                // 実際の時刻表データを使用
                $originDepartureTime = $rail['departure_time'];

                // 八草駅到着時刻を計算
                $yagusaArrivalTime = addMinutes($originDepartureTime, $railTravelTime);
            }

            // 乗り換え時間を加算
            $minShuttleTime = addMinutes($yagusaArrivalTime, $transferTime);

            // 接続可能なシャトルバスを複数本取得
            $shuttleBuses = getNextShuttleBuses('to_university', $minShuttleTime, $diaType, 3);

            if (empty($shuttleBuses)) {
                continue;
            }

            $shuttle = $shuttleBuses[0];

            // 総所要時間と待ち時間を計算
            $totalTime = calculateDuration($originDepartureTime, $shuttle['arrival_time']);
            $waitingTime = calculateDuration($currentTime, $originDepartureTime);

            // 実際の乗り換え時間を計算（八草駅到着 → シャトルバス出発）
            $actualTransferTime = calculateDuration($yagusaArrivalTime, $shuttle['departure_time']);

            // シャトルバス選択肢を生成（複数本）
            $shuttleOptions = [];
            foreach ($shuttleBuses as $option) {
                $optionDepartureTime = $option['departure_time'];
                $optionArrivalTime = $option['arrival_time'];
                $optionTransferTime = calculateDuration($yagusaArrivalTime, $optionDepartureTime);
                $optionTotalTime = calculateDuration($currentTime, $optionArrivalTime);

                $shuttleOptions[] = [
                    'shuttle_departure' => formatTime($optionDepartureTime),
                    'shuttle_arrival' => formatTime($optionArrivalTime),
                    'transfer_time' => $optionTransferTime,
                    'total_time' => $optionTotalTime
                ];
            }

            $routes[] = [
                'rail_departure' => formatTime($originDepartureTime),
                'rail_arrival' => formatTime($yagusaArrivalTime),
                'shuttle_departure' => formatTime($shuttle['departure_time']),
                'shuttle_arrival' => formatTime($shuttle['arrival_time']),
                'transfer_time' => $actualTransferTime,
                'total_time' => $totalTime,
                'waiting_time' => $waitingTime,
                'rail_time' => $railTravelTime,
                'origin_name' => $originInfo['station_name'],
                'shuttle_options' => $shuttleOptions,
                'line_code' => $lineCode
            ];

            if (count($routes) >= $limit) {
                break;
            }
        }

        return $routes;

    } catch (Exception $e) {
        logError('Failed to calculate rail to university route', $e);
        return [];
    }
}
