<?php
/**
 * お知らせ取得API
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/settings.php';
require_once __DIR__ . '/../includes/functions.php';
require_once __DIR__ . '/../includes/db_functions.php';

try {
    $type = $_GET['type'] ?? 'all'; // all, shuttle, linimo

    $notices = getActiveNotices($type);

    jsonResponse(true, ['notices' => $notices]);

} catch (Exception $e) {
    http_response_code(500);
    logError('Failed to get notices', $e);

    // 本番環境では例外詳細を隠す
    $errorMessage = DEBUG_MODE
        ? 'Failed to fetch notices: ' . $e->getMessage()
        : 'お知らせの取得に失敗しました';

    jsonResponse(false, null, $errorMessage);
}
