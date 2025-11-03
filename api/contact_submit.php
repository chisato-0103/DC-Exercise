<?php
/**
 * お問い合わせ送信API
 *
 * お問い合わせフォームからのデータを受け取ってDBに保存
 */

header('Access-Control-Allow-Origin: *');

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/settings.php';
require_once __DIR__ . '/../includes/functions.php';

try {
    // POSTデータを取得
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);

    // バリデーション
    $name = trim($data['name'] ?? '');
    $email = trim($data['email'] ?? '');
    $subject = trim($data['subject'] ?? '');
    $message = trim($data['message'] ?? '');

    // エラーメッセージ配列
    $errors = [];

    // 名前のバリデーション
    if (empty($name)) {
        $errors['name'] = 'お名前を入力してください';
    } elseif (strlen($name) > 100) {
        $errors['name'] = 'お名前は100文字以内で入力してください';
    }

    // メールアドレスのバリデーション
    if (empty($email)) {
        $errors['email'] = 'メールアドレスを入力してください';
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors['email'] = '正しいメールアドレスを入力してください';
    } elseif (strlen($email) > 255) {
        $errors['email'] = 'メールアドレスは255文字以内で入力してください';
    }

    // 件名のバリデーション
    if (empty($subject)) {
        $errors['subject'] = '件名を入力してください';
    } elseif (strlen($subject) > 200) {
        $errors['subject'] = '件名は200文字以内で入力してください';
    }

    // メッセージのバリデーション
    if (empty($message)) {
        $errors['message'] = 'メッセージを入力してください';
    } elseif (strlen($message) > 5000) {
        $errors['message'] = 'メッセージは5000文字以内で入力してください';
    }

    // バリデーションエラーがあれば返す
    if (!empty($errors)) {
        http_response_code(400);
        jsonResponse(false, ['errors' => $errors]);
    }

    // IPアドレスを取得（スパム対策用）
    $ipAddress = $_SERVER['REMOTE_ADDR'] ?? null;

    // データベースに保存
    $pdo = getDbConnection();
    $sql = "INSERT INTO contacts (name, email, subject, message, ip_address, status)
            VALUES (:name, :email, :subject, :message, :ip_address, 'new')";

    $stmt = $pdo->prepare($sql);
    $stmt->bindValue(':name', $name, PDO::PARAM_STR);
    $stmt->bindValue(':email', $email, PDO::PARAM_STR);
    $stmt->bindValue(':subject', $subject, PDO::PARAM_STR);
    $stmt->bindValue(':message', $message, PDO::PARAM_STR);
    $stmt->bindValue(':ip_address', $ipAddress, PDO::PARAM_STR);

    if (!$stmt->execute()) {
        throw new Exception('データベースへの保存に失敗しました');
    }

    // 成功レスポンス
    http_response_code(200);
    jsonResponse(true, ['message' => 'お問い合わせを送信いただきありがとうございます。']);

} catch (Exception $e) {
    http_response_code(500);
    logError('Error in contact_submit.php', $e);

    // 本番環境では例外詳細を隠す
    $errorMessage = DEBUG_MODE
        ? $e->getMessage()
        : 'サーバーエラーが発生しました。しばらく経ってからお試しください。';

    jsonResponse(false, null, $errorMessage);
}
