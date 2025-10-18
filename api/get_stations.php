<?php
/**
 * 全駅リスト取得API
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/db_functions.php';

try {
    $stations = getAllStations();

    echo json_encode([
        'success' => true,
        'stations' => $stations
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to fetch stations: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
