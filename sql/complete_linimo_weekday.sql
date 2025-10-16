-- リニモ平日時刻表完全版（八草駅発→藤が丘方面）
-- 緑時刻: 4月～7月・10月～1月の平日
USE ait_transport;

-- 既存の平日データを削除
DELETE FROM linimo_timetable WHERE station_code = 'yagusa' AND direction = 'to_fujigaoka' AND day_type = 'weekday_green';

-- 八草駅発 → 藤が丘方面（平日・緑時刻）
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
-- 5時台
('yagusa', '八草', 'to_fujigaoka', '05:52:00', 'weekday_green'),
-- 6時台
('yagusa', '八草', 'to_fujigaoka', '06:09:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '06:23:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '06:33:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '06:42:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '06:51:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '06:59:00', 'weekday_green'),
-- 7時台
('yagusa', '八草', 'to_fujigaoka', '07:07:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:15:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:22:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:29:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:37:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:45:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:52:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:59:00', 'weekday_green'),
-- 8時台
('yagusa', '八草', 'to_fujigaoka', '08:07:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:15:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:23:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:31:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:39:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:47:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:55:00', 'weekday_green'),
-- 9時台
('yagusa', '八草', 'to_fujigaoka', '09:03:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '09:11:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '09:19:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '09:27:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '09:35:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '09:43:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '09:51:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '09:59:00', 'weekday_green'),
-- 10時台
('yagusa', '八草', 'to_fujigaoka', '10:07:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '10:15:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '10:23:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '10:31:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '10:39:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '10:47:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '10:55:00', 'weekday_green'),
-- 11時台
('yagusa', '八草', 'to_fujigaoka', '11:03:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '11:11:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '11:19:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '11:27:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '11:35:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '11:43:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '11:51:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '11:59:00', 'weekday_green'),
-- 12時台
('yagusa', '八草', 'to_fujigaoka', '12:07:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '12:15:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '12:23:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '12:31:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '12:39:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '12:47:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '12:55:00', 'weekday_green'),
-- 13時台
('yagusa', '八草', 'to_fujigaoka', '13:03:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '13:11:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '13:19:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '13:27:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '13:35:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '13:43:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '13:51:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '13:59:00', 'weekday_green'),
-- 14時台
('yagusa', '八草', 'to_fujigaoka', '14:07:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '14:15:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '14:23:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '14:31:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '14:39:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '14:47:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '14:55:00', 'weekday_green'),
-- 15時台
('yagusa', '八草', 'to_fujigaoka', '15:03:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '15:11:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '15:19:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '15:27:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '15:35:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '15:43:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '15:51:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '15:59:00', 'weekday_green'),
-- 16時台
('yagusa', '八草', 'to_fujigaoka', '16:07:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '16:15:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '16:23:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '16:31:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '16:39:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '16:47:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '16:55:00', 'weekday_green'),
-- 17時台
('yagusa', '八草', 'to_fujigaoka', '17:03:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '17:11:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '17:19:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '17:27:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '17:35:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '17:43:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '17:51:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '17:59:00', 'weekday_green'),
-- 18時台
('yagusa', '八草', 'to_fujigaoka', '18:07:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '18:15:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '18:23:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '18:31:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '18:39:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '18:47:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '18:55:00', 'weekday_green'),
-- 19時台
('yagusa', '八草', 'to_fujigaoka', '19:03:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '19:11:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '19:19:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '19:27:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '19:35:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '19:43:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '19:51:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '19:59:00', 'weekday_green'),
-- 20時台
('yagusa', '八草', 'to_fujigaoka', '20:07:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '20:15:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '20:23:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '20:31:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '20:39:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '20:47:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '20:55:00', 'weekday_green'),
-- 21時台
('yagusa', '八草', 'to_fujigaoka', '21:03:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '21:11:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '21:19:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '21:27:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '21:35:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '21:43:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '21:52:00', 'weekday_green'),
-- 22時台
('yagusa', '八草', 'to_fujigaoka', '22:01:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '22:11:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '22:22:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '22:33:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '22:44:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '22:55:00', 'weekday_green'),
-- 23時台
('yagusa', '八草', 'to_fujigaoka', '23:06:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '23:17:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '23:28:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '23:40:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '23:55:00', 'weekday_green'),
-- 0時台
('yagusa', '八草', 'to_fujigaoka', '00:10:00', 'weekday_green');

SELECT 'リニモ平日時刻表（緑時刻）の完全データを投入しました' AS message;
SELECT CONCAT('リニモ時刻数: ', COUNT(*), '件') AS count FROM linimo_timetable WHERE station_code='yagusa' AND day_type='weekday_green';
