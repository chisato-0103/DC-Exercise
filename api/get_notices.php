<?php
/**
 * お知らせ取得API
 */

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../includes/db_functions.php';

try {
    $type = $_GET['type'] ?? 'all'; // all, shuttle, linimo

    $notices = getActiveNotices($type);

    echo json_encode([
        'success' => true,
        'notices' => $notices
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to fetch notices: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
