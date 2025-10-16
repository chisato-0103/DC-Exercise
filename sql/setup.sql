-- 愛知工業大学 交通情報システム データベース初期化スクリプト
-- 作成日: 2025-10-15

-- データベースの作成
CREATE DATABASE IF NOT EXISTS ait_transport DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ait_transport;

-- 既存テーブルの削除（開発時のみ）
DROP TABLE IF EXISTS notices;
DROP TABLE IF EXISTS linimo_timetable;
DROP TABLE IF EXISTS shuttle_bus_timetable;
DROP TABLE IF EXISTS stations;
DROP TABLE IF EXISTS system_settings;

-- ===================================
-- 1. 駅マスタテーブル
-- ===================================
CREATE TABLE stations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    station_code VARCHAR(50) UNIQUE NOT NULL,
    station_name VARCHAR(50) NOT NULL,
    station_name_en VARCHAR(100),
    order_index INT NOT NULL,
    travel_time_from_yagusa INT NOT NULL COMMENT '八草駅からの所要時間（分）',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_station_code (station_code),
    INDEX idx_order_index (order_index)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 駅マスタ初期データ
INSERT INTO stations (station_code, station_name, station_name_en, order_index, travel_time_from_yagusa) VALUES
('yagusa', '八草', 'Yagusa', 1, 0),
('tojishiryokan_minami', '陶磁資料館南', 'Tojishiryokan Minami', 2, 2),
('ai_chikyuhaku_kinen_koen', '愛・地球博記念公園', 'Ai･Chikyuhaku Kinen Koen', 3, 4),
('koen_nishi', '公園西', 'Koen Nishi', 4, 6),
('geidai_dori', '芸大通', 'Geidai-dori', 5, 8),
('nagakute_kosenjo', '長久手古戦場', 'Nagakute Kosenjo', 6, 10),
('irigaike_koen', '杁ヶ池公園', 'Irigaike Koen', 7, 12),
('hanamizuki_dori', 'はなみずき通', 'Hanamizuki-dori', 8, 14),
('fujigaoka', '藤が丘', 'Fujigaoka', 9, 17);

-- ===================================
-- 2. シャトルバス時刻表テーブル
-- ===================================
CREATE TABLE shuttle_bus_timetable (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dia_type ENUM('A', 'B', 'C') NOT NULL COMMENT 'ダイヤ種別: A=授業期間平日, B=土曜日, C=学校休業期間',
    direction ENUM('to_university', 'to_yagusa') NOT NULL COMMENT '方向: to_university=大学行き, to_yagusa=八草駅行き',
    departure_time TIME NOT NULL COMMENT '発車時刻',
    arrival_time TIME NOT NULL COMMENT '到着時刻',
    is_active BOOLEAN DEFAULT TRUE COMMENT '運行中フラグ',
    remarks VARCHAR(255) COMMENT '備考',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_dia_direction_time (dia_type, direction, departure_time),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- シャトルバス時刻表データ（Aダイヤ: 八草駅→大学）
INSERT INTO shuttle_bus_timetable (dia_type, direction, departure_time, arrival_time) VALUES
-- 8時台
('A', 'to_university', '08:00:00', '08:05:00'),
('A', 'to_university', '08:05:00', '08:10:00'),
('A', 'to_university', '08:10:00', '08:15:00'),
('A', 'to_university', '08:15:00', '08:20:00'),
('A', 'to_university', '08:20:00', '08:25:00'),
('A', 'to_university', '08:25:00', '08:30:00'),
('A', 'to_university', '08:30:00', '08:35:00'),
('A', 'to_university', '08:35:00', '08:40:00'),
('A', 'to_university', '08:40:00', '08:45:00'),
('A', 'to_university', '08:45:00', '08:50:00'),
('A', 'to_university', '08:50:00', '08:55:00'),
('A', 'to_university', '08:55:00', '09:00:00'),
-- 9時台
('A', 'to_university', '09:00:00', '09:05:00'),
('A', 'to_university', '09:05:00', '09:10:00'),
('A', 'to_university', '09:10:00', '09:15:00'),
('A', 'to_university', '09:15:00', '09:20:00'),
('A', 'to_university', '09:20:00', '09:25:00'),
('A', 'to_university', '09:25:00', '09:30:00'),
('A', 'to_university', '09:30:00', '09:35:00'),
('A', 'to_university', '09:35:00', '09:40:00'),
('A', 'to_university', '09:40:00', '09:45:00'),
('A', 'to_university', '09:50:00', '09:55:00'),
('A', 'to_university', '09:55:00', '10:00:00');

-- シャトルバス時刻表データ（Aダイヤ: 大学→八草駅）
INSERT INTO shuttle_bus_timetable (dia_type, direction, departure_time, arrival_time) VALUES
-- 8時台
('A', 'to_yagusa', '08:20:00', '08:25:00'),
('A', 'to_yagusa', '08:50:00', '08:55:00'),
-- 9時台
('A', 'to_yagusa', '09:20:00', '09:25:00'),
('A', 'to_yagusa', '09:50:00', '09:55:00'),
-- 10時台
('A', 'to_yagusa', '10:20:00', '10:25:00'),
('A', 'to_yagusa', '10:50:00', '10:55:00'),
-- 16時台（一部のみサンプル）
('A', 'to_yagusa', '16:00:00', '16:05:00'),
('A', 'to_yagusa', '16:05:00', '16:10:00'),
('A', 'to_yagusa', '16:10:00', '16:15:00'),
('A', 'to_yagusa', '16:15:00', '16:20:00'),
('A', 'to_yagusa', '16:25:00', '16:30:00'),
('A', 'to_yagusa', '16:30:00', '16:35:00');

-- ===================================
-- 3. リニモ時刻表テーブル
-- ===================================
CREATE TABLE linimo_timetable (
    id INT PRIMARY KEY AUTO_INCREMENT,
    station_code VARCHAR(50) NOT NULL,
    station_name VARCHAR(50) NOT NULL,
    direction ENUM('to_fujigaoka', 'to_yagusa') NOT NULL COMMENT '方向: to_fujigaoka=藤が丘方面, to_yagusa=八草方面',
    departure_time TIME NOT NULL COMMENT '発車時刻',
    day_type ENUM('weekday_green', 'holiday_red') NOT NULL COMMENT '曜日種別: weekday_green=平日(4-7,10-1月), holiday_red=土休日+学校休業期間(8,9,2,3月)',
    is_active BOOLEAN DEFAULT TRUE COMMENT '運行中フラグ',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_station_direction_time (station_code, direction, departure_time),
    INDEX idx_day_type (day_type),
    FOREIGN KEY (station_code) REFERENCES stations(station_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- リニモ時刻表データ（八草駅発→藤が丘方面、平日）サンプルデータ
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
-- 8時台
('yagusa', '八草', 'to_fujigaoka', '08:02:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:10:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:18:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:26:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:33:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:40:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:48:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:56:00', 'weekday_green'),
-- 9時台
('yagusa', '八草', 'to_fujigaoka', '09:04:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '09:12:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '09:20:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '09:28:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '09:36:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '09:44:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '09:52:00', 'weekday_green'),
-- 10時台
('yagusa', '八草', 'to_fujigaoka', '10:00:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '10:08:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '10:16:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '10:24:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '10:32:00', 'weekday_green');

-- ===================================
-- 4. 運行情報・お知らせテーブル
-- ===================================
CREATE TABLE notices (
    id INT PRIMARY KEY AUTO_INCREMENT,
    notice_type ENUM('delay', 'suspension', 'info') NOT NULL COMMENT '通知種別: delay=遅延, suspension=運休, info=お知らせ',
    target ENUM('shuttle', 'linimo', 'all') NOT NULL COMMENT '対象: shuttle=シャトルバス, linimo=リニモ, all=全体',
    title VARCHAR(100) NOT NULL COMMENT 'タイトル',
    content TEXT NOT NULL COMMENT '内容',
    start_date DATETIME NOT NULL COMMENT '表示開始日時',
    end_date DATETIME COMMENT '表示終了日時',
    is_active BOOLEAN DEFAULT TRUE COMMENT '表示フラグ',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_active_dates (is_active, start_date, end_date),
    INDEX idx_target (target)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- サンプル通知データ
INSERT INTO notices (notice_type, target, title, content, start_date, end_date, is_active) VALUES
('info', 'all', 'システム公開のお知らせ', '愛知工業大学交通情報システムを公開しました。シャトルバスとリニモの乗り継ぎ情報をご確認いただけます。', '2025-10-15 00:00:00', NULL, TRUE);

-- ===================================
-- 5. システム設定テーブル
-- ===================================
CREATE TABLE system_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(50) UNIQUE NOT NULL COMMENT '設定キー',
    setting_value VARCHAR(255) NOT NULL COMMENT '設定値',
    description TEXT COMMENT '説明',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_setting_key (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- システム設定初期値
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('transfer_time_minutes', '10', '乗り換え時間（分）'),
('current_dia_type', 'A', '現在のシャトルバスダイヤ種別（A/B/C）'),
('default_destination', 'fujigaoka', 'デフォルト目的地駅コード'),
('result_limit', '3', '表示する乗り継ぎ候補数'),
('shuttle_travel_time', '5', 'シャトルバス所要時間（分）');

-- ===================================
-- インデックスとパフォーマンス最適化
-- ===================================

-- 各テーブルの統計情報を更新
ANALYZE TABLE stations;
ANALYZE TABLE shuttle_bus_timetable;
ANALYZE TABLE linimo_timetable;
ANALYZE TABLE notices;
ANALYZE TABLE system_settings;

-- セットアップ完了メッセージ
SELECT 'データベースのセットアップが完了しました。' AS message;
SELECT CONCAT('駅数: ', COUNT(*), '駅') AS stations_count FROM stations;
SELECT CONCAT('シャトルバス時刻数: ', COUNT(*), '件') AS shuttle_count FROM shuttle_bus_timetable;
SELECT CONCAT('リニモ時刻数: ', COUNT(*), '件') AS linimo_count FROM linimo_timetable;
