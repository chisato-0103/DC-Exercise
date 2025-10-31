-- ===================================
-- 愛知環状線 時刻表サンプルデータ
-- 実際の運行時刻については愛知環状鉄道の公式時刻表を参照して更新してください
-- ===================================

USE ait_transport;

-- ===================================
-- 八草 → 岡崎方面（南下）の時刻表サンプル
-- ===================================
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, is_active) VALUES
-- 8時台
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '08:10:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '08:25:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '08:40:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '08:55:00', 'weekday', 1),
-- 9時台
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '09:10:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '09:25:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '09:40:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '09:55:00', 'weekday', 1),
-- 10時台
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '10:10:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '10:25:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '10:40:00', 'weekday', 1),
-- 16時台
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '16:10:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '16:25:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '16:40:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '16:55:00', 'weekday', 1);

-- ===================================
-- 八草 → 岡崎方面（南下）の駅別時刻（山口、瀬戸口など）
-- 八草からの所要時間を考慮
-- ===================================
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, is_active) VALUES
-- 山口駅（八草から4分）
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '08:14:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '08:29:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '08:44:00', 'weekday', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '08:59:00', 'weekday', 1),
-- 瀬戸口駅（八草から8分）
('aichi_kanjo', 'setoguchi', '瀬戸口', 'to_okazaki', '08:18:00', 'weekday', 1),
('aichi_kanjo', 'setoguchi', '瀬戸口', 'to_okazaki', '08:33:00', 'weekday', 1),
('aichi_kanjo', 'setoguchi', '瀬戸口', 'to_okazaki', '08:48:00', 'weekday', 1),
('aichi_kanjo', 'setoguchi', '瀬戸口', 'to_okazaki', '09:03:00', 'weekday', 1);

-- ===================================
-- 岡崎 → 八草方面（北上）の時刻表サンプル
-- ===================================
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, is_active) VALUES
-- 8時台
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '08:05:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '08:20:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '08:35:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '08:50:00', 'weekday', 1),
-- 9時台
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '09:05:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '09:20:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '09:35:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '09:50:00', 'weekday', 1),
-- 16時台
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '16:05:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '16:20:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '16:35:00', 'weekday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '16:50:00', 'weekday', 1);

-- ===================================
-- 八草駅への到着時刻（岡崎方面から）
-- ===================================
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, is_active) VALUES
-- 朝（八草への到着時刻で表示）
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '08:25:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '08:40:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '08:55:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '09:10:00', 'weekday', 1),
-- 16時台
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '16:25:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '16:40:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '16:55:00', 'weekday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_kozoji', '17:10:00', 'weekday', 1);

-- ===================================
-- 休日時刻表サンプル（平日より本数減）
-- ===================================
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, is_active) VALUES
-- 休日：八草 → 岡崎方面
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '08:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '09:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '10:00:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '16:30:00', 'holiday', 1),
('aichi_kanjo', 'yakusa', '八草', 'to_okazaki', '17:00:00', 'holiday', 1),
-- 休日：岡崎 → 八草方面
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '08:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '09:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '10:00:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '16:30:00', 'holiday', 1),
('aichi_kanjo', 'okazaki', '岡崎', 'to_kozoji', '17:00:00', 'holiday', 1);

-- ===================================
-- 検証
-- ===================================
SELECT '愛知環状線時刻表サンプルデータを追加しました' AS status;
SELECT COUNT(*) AS total_records FROM rail_timetable WHERE line_code = 'aichi_kanjo';
SELECT day_type, COUNT(*) AS count FROM rail_timetable WHERE line_code = 'aichi_kanjo' GROUP BY day_type;
