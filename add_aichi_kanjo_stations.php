<?php
/**
 * Aichi Kanjo駅データ追加実行スクリプト
 * stations テーブルに23駅を登録
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/config/database.php';

try {
    $pdo = getDbConnection();

    // トランザクション開始
    $pdo->beginTransaction();

    // Aichi Kanjo駅データ
    $aichi_kanjo_stations = [
        ['okazaki', '岡崎', 35, 100],
        ['mutsuna', '武豊', 32, 101],
        ['naka_okazaki', '中岡崎', 28, 102],
        ['kita_okazaki', '北岡崎', 24, 103],
        ['daimon', '大門', 20, 104],
        ['kitano_masuzuka', '北野増塚', 18, 105],
        ['mikawa_kamigo', '三河上郷', 16, 106],
        ['ekaku', '江角', 14, 107],
        ['suenohara', '末野原', 12, 108],
        ['mikawa_toyota', '三河豊田', 10, 109],
        ['shin_uwagoromo', '新上ゴ衣', 8, 110],
        ['shin_toyota', '新豊田', 6, 111],
        ['aikan_umetsubo', '愛環梅坪', 4, 112],
        ['shigo', '塩後', 5, 113],
        ['kaizu', '海津', 8, 114],
        ['homi', '豊見', 12, 115],
        ['sasabara', '笹原', 16, 116],
        ['yamaguchi', '山口', 20, 117],
        ['setoguchi', '瀬戸口', 24, 118],
        ['setoshi', '瀬戸市', 28, 119],
        ['nakamizuno', '中水野', 32, 120],
        ['kozoji', '幸次', 35, 121]
    ];

    $inserted = 0;
    $sql = "INSERT INTO stations (station_code, station_name, line_type, travel_time_from_yagusa, order_index)
            VALUES (:code, :name, 'aichi_kanjo', :travel_time, :order_index)";
    $stmt = $pdo->prepare($sql);

    foreach ($aichi_kanjo_stations as $station) {
        $stmt->bindValue(':code', $station[0], PDO::PARAM_STR);
        $stmt->bindValue(':name', $station[1], PDO::PARAM_STR);
        $stmt->bindValue(':travel_time', $station[2], PDO::PARAM_INT);
        $stmt->bindValue(':order_index', $station[3], PDO::PARAM_INT);
        $stmt->execute();
        $inserted++;
    }

    // トランザクションコミット
    $pdo->commit();

    // 確認
    $check_sql = "SELECT COUNT(*) as count FROM stations WHERE line_type = 'aichi_kanjo'";
    $count = $pdo->query($check_sql)->fetch()['count'];

    echo json_encode([
        'status' => 'success',
        'message' => 'Aichi Kanjo駅データ追加が完了しました',
        'inserted_count' => $inserted,
        'verification' => [
            'aichi_kanjo_stations' => $count
        ]
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

} catch (Exception $e) {
    // ロールバック
    if (isset($pdo)) {
        $pdo->rollBack();
    }

    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
}
?>
