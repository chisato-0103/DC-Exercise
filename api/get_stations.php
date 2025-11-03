<?php
/**
 * 全駅リスト取得API
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/settings.php';
require_once __DIR__ . '/../includes/functions.php';
require_once __DIR__ . '/../includes/db_functions.php';

try {
    $stations = getAllStations();

    jsonResponse(true, ['stations' => $stations]);

} catch (Exception $e) {
    http_response_code(500);
    logError('Failed to get stations', $e);

    // 本番環境では例外詳細を隠す
    $errorMessage = DEBUG_MODE
        ? 'Failed to fetch stations: ' . $e->getMessage()
        : '駅リストの取得に失敗しました';

    jsonResponse(false, null, $errorMessage);
}
