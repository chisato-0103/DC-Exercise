-- リニモ平日時刻表完全版（全駅：藤が丘→八草方面）
-- 緑時刻: 4月～7月・10月～1月の平日
USE ait_transport;

-- 既存データ削除
DELETE FROM linimo_timetable WHERE direction = 'to_yagusa' AND day_type = 'weekday_green';

-- ========================================
-- 藤が丘駅 → 八草方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('fujigaoka', '藤が丘', 'to_yagusa', '05:52:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '06:09:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '06:23:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '06:33:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '06:42:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '06:51:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '06:59:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '07:07:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '07:15:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '07:23:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '07:31:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '07:39:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '07:47:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '07:55:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '08:03:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '08:11:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '08:19:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '08:27:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '08:35:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '08:43:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '08:51:00', 'weekday_green'),
('fujigaoka', '藤が丘', 'to_yagusa', '08:59:00', 'weekday_green');

-- ========================================
-- はなみずき通駅 → 八草方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('hanamizuki', 'はなみずき通', 'to_yagusa', '05:55:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '06:12:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '06:26:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '06:36:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '06:45:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '06:54:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '07:02:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '07:10:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '07:18:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '07:26:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '07:34:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '07:42:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '07:50:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '07:58:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '08:06:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '08:14:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '08:22:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '08:30:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '08:38:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '08:46:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '08:54:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_yagusa', '09:02:00', 'weekday_green');

-- ========================================
-- 杁ヶ池公園駅 → 八草方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('irigaike', '杁ヶ池公園', 'to_yagusa', '05:57:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '06:14:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '06:28:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '06:38:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '06:47:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '06:56:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '07:04:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '07:12:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '07:20:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '07:28:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '07:36:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '07:44:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '07:52:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '08:00:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '08:08:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '08:16:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '08:24:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '08:32:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '08:40:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '08:48:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '08:56:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_yagusa', '09:04:00', 'weekday_green');

-- ========================================
-- 長久手古戦場駅 → 八草方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('nagakute', '長久手古戦場', 'to_yagusa', '05:59:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '06:15:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '06:29:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '06:39:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '06:48:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '06:57:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '07:05:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '07:13:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '07:21:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '07:29:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '07:37:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '07:45:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '07:53:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '08:01:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '08:09:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '08:17:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '08:25:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '08:33:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '08:41:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '08:49:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '08:57:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_yagusa', '09:05:00', 'weekday_green');

-- ========================================
-- 芸大通駅 → 八草方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('geidai', '芸大通', 'to_yagusa', '06:05:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '06:21:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '06:35:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '06:45:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '06:54:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '07:03:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '07:11:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '07:19:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '07:27:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '07:35:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '07:43:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '07:51:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '07:59:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '08:07:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '08:15:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '08:23:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '08:31:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '08:39:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '08:47:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '08:55:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '09:03:00', 'weekday_green'),
('geidai', '芸大通', 'to_yagusa', '09:11:00', 'weekday_green');

-- ========================================
-- 公園西駅 → 八草方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('koennishi', '公園西', 'to_yagusa', '06:07:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '06:23:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '06:37:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '06:47:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '06:56:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '07:05:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '07:13:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '07:21:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '07:29:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '07:37:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '07:45:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '07:53:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '08:01:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '08:09:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '08:17:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '08:25:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '08:33:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '08:41:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '08:49:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '08:57:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '09:05:00', 'weekday_green'),
('koennishi', '公園西', 'to_yagusa', '09:13:00', 'weekday_green');

-- ========================================
-- 愛・地球博記念公園駅 → 八草方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '06:09:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '06:25:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '06:39:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '06:49:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '06:58:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '07:07:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '07:15:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '07:23:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '07:31:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '07:39:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '07:47:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '07:55:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '08:03:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '08:11:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '08:19:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '08:27:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '08:35:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '08:43:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '08:51:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '08:59:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '09:07:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_yagusa', '09:15:00', 'weekday_green');

-- ========================================
-- 陶磁資料館南駅 → 八草方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('toji', '陶磁資料館南', 'to_yagusa', '06:11:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '06:27:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '06:41:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '06:51:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '07:00:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '07:09:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '07:17:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '07:25:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '07:33:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '07:41:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '07:49:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '07:57:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '08:05:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '08:13:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '08:21:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '08:29:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '08:37:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '08:45:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '08:53:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '09:01:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '09:09:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_yagusa', '09:17:00', 'weekday_green');
