<?php
/**
 * 駅コード修正実行スクリプト（安全版）
 * yagusa → yakusa に統一
 * 外部キー制約を一時的に無効にして実行
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/config/database.php';

try {
    $pdo = getDbConnection();

    // 外部キー制約を一時的に無効化
    $pdo->exec("SET FOREIGN_KEY_CHECKS=0");

    // トランザクション開始
    $pdo->beginTransaction();

    // 1. linimo_timetable を先に更新（親テーブルではなく子テーブルから）
    $sql1 = "UPDATE linimo_timetable SET station_code = 'yakusa' WHERE station_code = 'yagusa'";
    $result1 = $pdo->exec($sql1);

    // 2. rail_timetable も更新（もし yagusa が含まれていれば）
    $sql_rail = "UPDATE rail_timetable SET station_code = 'yakusa' WHERE station_code = 'yagusa'";
    $result_rail = $pdo->exec($sql_rail);

    // 3. stations テーブルで yagusa を yakusa に変更
    $sql2 = "UPDATE stations SET station_code = 'yakusa' WHERE station_code = 'yagusa'";
    $result2 = $pdo->exec($sql2);

    // トランザクションコミット
    $pdo->commit();

    // 外部キー制約を再度有効化
    $pdo->exec("SET FOREIGN_KEY_CHECKS=1");

    // 確認
    $check_sql = "SELECT COUNT(*) as yakusa_count FROM stations WHERE station_code = 'yakusa'";
    $check_result = $pdo->query($check_sql)->fetch();

    echo json_encode([
        'status' => 'success',
        'message' => '駅コード修正が完了しました（安全版）',
        'updated_linimo' => $result1,
        'updated_rail' => $result_rail,
        'updated_stations' => $result2,
        'verification' => $check_result
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

} catch (Exception $e) {
    // ロールバック
    if (isset($pdo)) {
        $pdo->rollBack();
        $pdo->exec("SET FOREIGN_KEY_CHECKS=1");
    }

    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
}
?>
