<?php
/**
 * 駅コード修正実行スクリプト
 * yagusa → yakusa に統一
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/config/database.php';

try {
    $pdo = getDbConnection();

    // トランザクション開始
    $pdo->beginTransaction();

    // 1. stations テーブルで yagusa を yakusa に変更
    $sql1 = "UPDATE stations SET station_code = 'yakusa' WHERE station_code = 'yagusa'";
    $result1 = $pdo->exec($sql1);

    // 2. linimo_timetable で yagusa を yakusa に変更
    $sql2 = "UPDATE linimo_timetable SET station_code = 'yakusa' WHERE station_code = 'yagusa'";
    $result2 = $pdo->exec($sql2);

    // 3. shuttle_bus_timetable に yagusa のままでいい（リニモではなくシャトルバス用）
    // ただし、乗り換えハブとしての yagusa 参照は確認が必要

    // トランザクションコミット
    $pdo->commit();

    // 確認
    $check_sql = "SELECT COUNT(*) as yakusa_count FROM stations WHERE station_code = 'yakusa'";
    $check_result = $pdo->query($check_sql)->fetch();

    echo json_encode([
        'status' => 'success',
        'message' => '駅コード修正が完了しました',
        'updated_stations' => $result1,
        'updated_linimo' => $result2,
        'verification' => $check_result
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

} catch (Exception $e) {
    // ロールバック
    if (isset($pdo)) {
        $pdo->rollBack();
    }

    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
}
?>
