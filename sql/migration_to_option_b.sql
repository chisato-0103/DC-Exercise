-- ===================================
-- オプションB化マイグレーションスクリプト
-- 統一トランスポートテーブルへの移行
-- ===================================

USE ait_transport;

-- ===================================
-- 0. 既存テーブルの拡張
-- ===================================
-- stations テーブルに line_type カラムを追加（存在しない場合）
ALTER TABLE stations ADD COLUMN line_type VARCHAR(50) DEFAULT 'linimo' COMMENT '路線タイプ';
ALTER TABLE stations ADD INDEX idx_line_type (line_type);

-- ===================================
-- 1. 路線マスタテーブル作成
-- ===================================
CREATE TABLE IF NOT EXISTS transport_lines (
    id INT PRIMARY KEY AUTO_INCREMENT,
    line_code VARCHAR(50) UNIQUE NOT NULL COMMENT '路線コード',
    line_name VARCHAR(100) NOT NULL COMMENT '路線名',
    line_name_en VARCHAR(100) COMMENT '路線名（英語）',
    transfer_hub VARCHAR(50) NOT NULL COMMENT '乗換ハブ駅コード（通常は yagusa）',
    typical_duration INT COMMENT '駅間平均所要時間（分）',
    remarks VARCHAR(255) COMMENT '備考',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_line_code (line_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 路線マスタデータ
INSERT INTO transport_lines (line_code, line_name, line_name_en, transfer_hub, typical_duration, remarks) VALUES
('shuttle', 'シャトルバス', 'Shuttle Bus', 'yagusa', 5, 'AIT Campus ↔ Yagusa Station'),
('linimo', 'リニモ', 'Linimo', 'yagusa', 2, 'Yagusa → Fujigaoka (9 stations)'),
('aichi_kanjo', '愛知環状線', 'Aichi Kanjo Line', 'yagusa', 4, 'Okazaki ↔ Kozoji (23 stations)');

-- ===================================
-- 2. 汎用レール時刻表テーブル作成
-- ===================================
CREATE TABLE IF NOT EXISTS rail_timetable (
    id INT PRIMARY KEY AUTO_INCREMENT,
    line_code VARCHAR(50) NOT NULL COMMENT '路線コード',
    station_code VARCHAR(50) NOT NULL COMMENT '駅コード',
    station_name VARCHAR(50) NOT NULL COMMENT '駅名',
    direction VARCHAR(50) NOT NULL COMMENT '方向',
    departure_time TIME NOT NULL COMMENT '発車時刻',
    day_type ENUM('weekday_green', 'holiday_red') NOT NULL DEFAULT 'weekday_green' COMMENT '曜日種別',
    is_active BOOLEAN DEFAULT TRUE COMMENT '運行中フラグ',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (line_code) REFERENCES transport_lines(line_code),
    FOREIGN KEY (station_code) REFERENCES stations(station_code),
    INDEX idx_line_station_direction (line_code, station_code, direction, departure_time),
    INDEX idx_day_type (day_type),
    INDEX idx_line_active (line_code, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================
-- 3. 既存のリニモデータを rail_timetable に移行
-- ===================================
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, is_active)
SELECT
    'linimo' AS line_code,
    station_code,
    station_name,
    direction,
    departure_time,
    day_type,
    is_active
FROM linimo_timetable;

-- ===================================
-- 4. shuttle_schedule テーブルの確認（存在する場合）
-- ===================================
-- 注: shuttle_schedule テーブルが存在する場合は、そのままにしておきます
-- 必要に応じて後で shuttle_schedule をベースにしたダイヤ判定に変更できます

-- ===================================
-- 5. マイグレーション検証
-- ===================================
SELECT 'マイグレーション完了: 以下のテーブルが作成/更新されました' AS status;
SELECT COUNT(*) AS transport_lines_count FROM transport_lines;
SELECT COUNT(*) AS rail_timetable_count FROM rail_timetable;
SELECT line_code, COUNT(*) AS record_count FROM rail_timetable GROUP BY line_code;
