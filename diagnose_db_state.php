<?php
/**
 * データベースの現在の状態を診断
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/config/database.php';

try {
    $pdo = getDbConnection();

    // 1. stations テーブルの yakusa と aichi_kanjo 状況
    $stations_check = $pdo->query(
        "SELECT station_code, COUNT(*) as count
         FROM stations
         WHERE station_code IN ('yakusa', 'yagusa')
         GROUP BY station_code"
    )->fetchAll();

    $aichi_count = $pdo->query(
        "SELECT COUNT(*) as count FROM stations WHERE line_type = 'aichi_kanjo'"
    )->fetch();

    $total_stations = $pdo->query(
        "SELECT COUNT(*) as count FROM stations"
    )->fetch();

    // 2. linimo_timetable の station_code 状況
    $linimo_yagusa = $pdo->query(
        "SELECT COUNT(*) as count FROM linimo_timetable WHERE station_code = 'yagusa'"
    )->fetch();

    $linimo_yakusa = $pdo->query(
        "SELECT COUNT(*) as count FROM linimo_timetable WHERE station_code = 'yakusa'"
    )->fetch();

    // 3. rail_timetable の day_type 値
    $rail_day_types = $pdo->query(
        "SELECT day_type, COUNT(*) as count FROM rail_timetable GROUP BY day_type"
    )->fetchAll();

    // 4. rail_timetable の ENUM定義
    $rail_schema = $pdo->query("DESCRIBE rail_timetable")->fetchAll();
    $rail_day_type_col = null;
    foreach ($rail_schema as $col) {
        if ($col['Field'] === 'day_type') {
            $rail_day_type_col = $col;
            break;
        }
    }

    // 5. rail_timetable の yagusa データ確認
    $rail_yagusa = $pdo->query(
        "SELECT COUNT(*) as count FROM rail_timetable WHERE station_code = 'yagusa'"
    )->fetch();

    $rail_yakusa = $pdo->query(
        "SELECT COUNT(*) as count FROM rail_timetable WHERE station_code = 'yakusa'"
    )->fetch();

    echo json_encode([
        'stations_yakusa_yagusa' => $stations_check,
        'stations_aichi_kanjo_count' => $aichi_count,
        'stations_total' => $total_stations,
        'linimo_timetable_yagusa_count' => $linimo_yagusa,
        'linimo_timetable_yakusa_count' => $linimo_yakusa,
        'rail_timetable_day_types' => $rail_day_types,
        'rail_timetable_day_type_enum' => $rail_day_type_col,
        'rail_timetable_yagusa_count' => $rail_yagusa,
        'rail_timetable_yakusa_count' => $rail_yakusa
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
}
?>
