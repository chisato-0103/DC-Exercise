-- お問い合わせテーブルの作成

CREATE TABLE IF NOT EXISTS `contacts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '送信者名',
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'メールアドレス',
  `subject` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '件名',
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'メッセージ内容',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci COMMENT 'IPアドレス',
  `status` enum('new','read','replied') COLLATE utf8mb4_unicode_ci DEFAULT 'new' COMMENT 'ステータス: new=未読, read=既読, replied=返信済み',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '送信日時',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日時',
  PRIMARY KEY (`id`),
  KEY `idx_email` (`email`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
