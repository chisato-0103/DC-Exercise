<?php
/**
 * データベース接続設定
 *
 * 使用前に、以下の定数を環境に合わせて変更してください
 */

// データベース接続情報
// 環境変数があればそれを使用、なければローカル開発用のデフォルト値
define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_PORT', getenv('DB_PORT') ?: '8889'); // MAMPのデフォルトポート
define('DB_NAME', getenv('DB_NAME') ?: 'ait_transport');
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') ?: 'root'); // MAMPのデフォルト
define('DB_CHARSET', 'utf8mb4');

// エラーハンドリング設定
define('DB_ERROR_MODE', PDO::ERRMODE_EXCEPTION);

/**
 * データベース接続を取得
 *
 * @return PDO データベース接続オブジェクト
 * @throws PDOException 接続に失敗した場合
 */
function getDbConnection() {
    static $pdo = null;

    if ($pdo === null) {
        try {
            $dsn = sprintf(
                'mysql:host=%s;port=%s;dbname=%s;charset=%s',
                DB_HOST,
                DB_PORT,
                DB_NAME,
                DB_CHARSET
            );

            $options = [
                PDO::ATTR_ERRMODE => DB_ERROR_MODE,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ];

            $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);

        } catch (PDOException $e) {
            error_log('Database connection failed: ' . $e->getMessage());
            throw new PDOException('データベース接続に失敗しました');
        }
    }

    return $pdo;
}
