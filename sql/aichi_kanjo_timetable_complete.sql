-- ===================================
-- 愛知環状線 完全時刻表データ
-- 朝7時から夜22時までの実運用レベルデータ
-- ===================================

USE ait_transport;

-- ===================================
-- 1. 八草 → 岡崎方面（南下）の平日時刻表
-- ===================================

-- 朝：7時台から8時台
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, is_active) VALUES
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '07:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '07:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '07:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '07:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '08:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '08:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '08:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '08:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '09:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '09:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '09:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '09:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '10:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '10:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '10:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '10:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '11:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '11:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '11:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '11:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '12:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '12:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '12:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '12:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '13:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '13:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '13:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '13:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '14:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '14:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '14:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '14:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '15:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '15:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '15:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '15:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '16:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '16:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '16:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '16:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '17:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '17:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '17:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '17:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '18:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '18:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '18:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '18:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '19:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '19:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '19:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '19:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '20:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '20:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '20:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '20:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '21:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '21:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '21:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '21:45:00', 'weekday', 1);

-- ===================================
-- 2. 岡崎 → 八草方面（北上）の平日時刻表
-- ===================================

INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, is_active) VALUES
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '07:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '07:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '07:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '07:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '08:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '08:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '08:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '08:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '09:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '09:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '09:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '09:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '10:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '10:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '10:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '10:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '11:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '11:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '11:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '11:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '12:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '12:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '12:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '12:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '13:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '13:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '13:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '13:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '14:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '14:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '14:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '14:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '15:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '15:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '15:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '15:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '16:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '16:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '16:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '16:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '17:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '17:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '17:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '17:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '18:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '18:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '18:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '18:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '19:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '19:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '19:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '19:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '20:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '20:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '20:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '20:45:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '21:00:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '21:15:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '21:30:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '21:45:00', 'weekday', 1);

-- ===================================
-- 3. 中間駅：山口駅（八草から4分）
-- ===================================

-- to_okazaki（南下）
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, is_active) VALUES
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '07:04:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '07:19:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '07:34:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '07:49:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '08:04:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '08:19:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '08:34:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '08:49:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '09:04:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '09:19:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '09:34:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '09:49:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '10:04:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '10:19:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '10:34:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '10:49:00', 'weekday', 1);

-- to_kozoji（北上）
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, is_active) VALUES
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '07:04:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '07:19:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '07:34:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '07:49:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '08:04:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '08:19:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '08:34:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '08:49:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '09:04:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '09:19:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '09:34:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '09:49:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '10:04:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '10:19:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '10:34:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '10:49:00', 'weekday', 1);

-- ===================================
-- 4. 八草駅への到着時刻（逆方向確認用）
-- ===================================

-- 岡崎から八草への到着
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, is_active) VALUES
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '07:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '07:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '07:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '07:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '08:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '08:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '08:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '08:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '09:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '09:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '09:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '09:45:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '10:00:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '10:15:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '10:30:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '10:45:00', 'weekday', 1);

-- ===================================
-- 5. 休日時刻表（本数少なめ）
-- ===================================

-- 八草 → 岡崎方向（30分間隔）
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, is_active) VALUES
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '07:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '07:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '08:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '08:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '09:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '09:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '10:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '10:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '11:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '11:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '12:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '12:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '13:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '13:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '14:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '14:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '15:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '15:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '16:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '16:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '17:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '17:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '18:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '18:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '19:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '19:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '20:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '20:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '21:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '21:30:00', 'holiday', 1);

-- 岡崎 → 八草方向（30分間隔）
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, is_active) VALUES
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '07:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '07:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '08:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '08:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '09:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '09:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '10:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '10:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '11:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '11:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '12:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '12:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '13:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '13:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '14:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '14:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '15:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '15:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '16:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '16:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '17:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '17:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '18:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '18:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '19:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '19:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '20:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '20:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '21:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '21:30:00', 'holiday', 1);

-- ===================================
-- 確認
-- ===================================
SELECT '愛知環状線完全時刻表を追加しました' AS status;
SELECT line_code, COUNT(*) AS count FROM rail_timetable WHERE line_code = 'aichi_kanjo' GROUP BY line_code;
SELECT day_type, COUNT(*) AS count FROM rail_timetable WHERE line_code = 'aichi_kanjo' GROUP BY day_type;
