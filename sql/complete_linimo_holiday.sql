-- リニモ休日時刻表完全版（八草駅発→藤が丘方面）
-- 赤時刻: 土休日+8月・9月・2月・3月の平日（学校休業期間）
USE ait_transport;

-- 既存の休日データを削除
DELETE FROM linimo_timetable WHERE station_code = 'yagusa' AND direction = 'to_fujigaoka' AND day_type = 'holiday_red';

-- 八草駅発 → 藤が丘方面（休日・赤時刻）
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
-- 5時台
('yagusa', '八草', 'to_fujigaoka', '05:44:00', 'holiday_red'),
-- 6時台
('yagusa', '八草', 'to_fujigaoka', '06:02:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '06:17:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '06:32:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '06:43:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '06:51:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '06:59:00', 'holiday_red'),
-- 7時台
('yagusa', '八草', 'to_fujigaoka', '07:07:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '07:15:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '07:23:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '07:31:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '07:39:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '07:46:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '07:53:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '07:59:00', 'holiday_red'),
-- 8時台
('yagusa', '八草', 'to_fujigaoka', '08:05:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '08:13:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '08:21:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '08:29:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '08:36:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '08:43:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '08:51:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '08:59:00', 'holiday_red'),
-- 9時台
('yagusa', '八草', 'to_fujigaoka', '09:07:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '09:15:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '09:23:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '09:31:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '09:39:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '09:47:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '09:55:00', 'holiday_red'),
-- 10時台
('yagusa', '八草', 'to_fujigaoka', '10:03:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '10:11:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '10:19:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '10:27:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '10:35:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '10:43:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '10:51:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '10:59:00', 'holiday_red'),
-- 11時台
('yagusa', '八草', 'to_fujigaoka', '11:07:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '11:15:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '11:23:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '11:31:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '11:39:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '11:47:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '11:55:00', 'holiday_red'),
-- 12時台
('yagusa', '八草', 'to_fujigaoka', '12:03:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '12:11:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '12:19:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '12:27:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '12:35:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '12:43:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '12:51:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '12:59:00', 'holiday_red'),
-- 13時台
('yagusa', '八草', 'to_fujigaoka', '13:07:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '13:15:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '13:23:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '13:31:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '13:39:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '13:47:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '13:55:00', 'holiday_red'),
-- 14時台
('yagusa', '八草', 'to_fujigaoka', '14:03:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '14:11:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '14:19:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '14:27:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '14:35:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '14:43:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '14:51:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '14:59:00', 'holiday_red'),
-- 15時台
('yagusa', '八草', 'to_fujigaoka', '15:07:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '15:15:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '15:23:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '15:31:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '15:39:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '15:47:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '15:55:00', 'holiday_red'),
-- 16時台
('yagusa', '八草', 'to_fujigaoka', '16:03:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '16:11:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '16:19:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '16:27:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '16:35:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '16:43:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '16:51:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '16:59:00', 'holiday_red'),
-- 17時台
('yagusa', '八草', 'to_fujigaoka', '17:07:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '17:15:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '17:23:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '17:31:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '17:39:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '17:47:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '17:55:00', 'holiday_red'),
-- 18時台
('yagusa', '八草', 'to_fujigaoka', '18:03:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '18:11:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '18:19:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '18:27:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '18:35:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '18:43:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '18:51:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '18:59:00', 'holiday_red'),
-- 19時台
('yagusa', '八草', 'to_fujigaoka', '19:07:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '19:15:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '19:23:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '19:31:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '19:39:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '19:47:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '19:55:00', 'holiday_red'),
-- 20時台
('yagusa', '八草', 'to_fujigaoka', '20:03:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '20:11:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '20:19:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '20:27:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '20:35:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '20:43:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '20:51:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '20:59:00', 'holiday_red'),
-- 21時台
('yagusa', '八草', 'to_fujigaoka', '21:07:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '21:15:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '21:23:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '21:31:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '21:39:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '21:48:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '21:57:00', 'holiday_red'),
-- 22時台
('yagusa', '八草', 'to_fujigaoka', '22:07:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '22:18:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '22:29:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '22:40:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '22:51:00', 'holiday_red'),
-- 23時台
('yagusa', '八草', 'to_fujigaoka', '23:02:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '23:15:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '23:29:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '23:44:00', 'holiday_red'),
('yagusa', '八草', 'to_fujigaoka', '23:59:00', 'holiday_red');

SELECT 'リニモ休日時刻表（赤時刻）の完全データを投入しました' AS message;
SELECT CONCAT('リニモ休日時刻数: ', COUNT(*), '件') AS count FROM linimo_timetable WHERE station_code='yagusa' AND day_type='holiday_red';
SELECT CONCAT('リニモ全時刻数: ', COUNT(*), '件') AS total_count FROM linimo_timetable WHERE station_code='yagusa';
