-- リニモ平日時刻表完全版（全駅：八草→藤が丘方面）
-- 緑時刻: 4月～7月・10月～1月の平日
USE ait_transport;

-- 既存データ削除
DELETE FROM linimo_timetable WHERE direction = 'to_fujigaoka' AND day_type = 'weekday_green';

-- ========================================
-- はなみずき通駅 → 藤が丘方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '05:43:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '06:02:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '06:17:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '06:27:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '06:36:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '06:45:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '06:53:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '07:01:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '07:09:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '07:17:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '07:25:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '07:33:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '07:41:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '07:49:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '07:57:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '08:05:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '08:13:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '08:21:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '08:29:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '08:37:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '08:45:00', 'weekday_green'),
('hanamizuki', 'はなみずき通', 'to_fujigaoka', '08:53:00', 'weekday_green');

-- ========================================
-- 杁ヶ池公園駅 → 藤が丘方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '05:41:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '06:00:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '06:15:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '06:25:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '06:34:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '06:43:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '06:51:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '06:59:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '07:07:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '07:15:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '07:23:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '07:31:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '07:39:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '07:47:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '07:55:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '08:03:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '08:11:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '08:19:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '08:27:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '08:35:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '08:43:00', 'weekday_green'),
('irigaike', '杁ヶ池公園', 'to_fujigaoka', '08:51:00', 'weekday_green');

-- ========================================
-- 長久手古戦場駅 → 藤が丘方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('nagakute', '長久手古戦場', 'to_fujigaoka', '05:39:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '05:57:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '06:13:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '06:23:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '06:32:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '06:41:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '06:49:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '06:57:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '07:05:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '07:13:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '07:21:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '07:29:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '07:37:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '07:45:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '07:53:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '08:01:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '08:09:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '08:17:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '08:25:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '08:33:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '08:41:00', 'weekday_green'),
('nagakute', '長久手古戦場', 'to_fujigaoka', '08:49:00', 'weekday_green');

-- ========================================
-- 芸大通駅 → 藤が丘方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('geidai', '芸大通', 'to_fujigaoka', '05:37:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '05:55:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '06:11:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '06:21:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '06:30:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '06:39:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '06:47:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '06:55:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '07:03:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '07:11:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '07:19:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '07:27:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '07:35:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '07:43:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '07:51:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '07:59:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '08:07:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '08:15:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '08:23:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '08:31:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '08:39:00', 'weekday_green'),
('geidai', '芸大通', 'to_fujigaoka', '08:47:00', 'weekday_green');

-- ========================================
-- 公園西駅 → 藤が丘方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('koennishi', '公園西', 'to_fujigaoka', '05:35:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '05:53:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '06:09:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '06:19:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '06:28:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '06:37:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '06:45:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '06:53:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '07:01:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '07:09:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '07:17:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '07:25:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '07:33:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '07:41:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '07:49:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '07:57:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '08:05:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '08:13:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '08:21:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '08:29:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '08:37:00', 'weekday_green'),
('koennishi', '公園西', 'to_fujigaoka', '08:45:00', 'weekday_green');

-- ========================================
-- 愛・地球博記念公園駅 → 藤が丘方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '05:33:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '05:51:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '06:07:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '06:17:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '06:26:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '06:35:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '06:43:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '06:51:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '06:59:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '07:07:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '07:15:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '07:23:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '07:31:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '07:39:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '07:47:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '07:55:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '08:03:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '08:11:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '08:19:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '08:27:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '08:35:00', 'weekday_green'),
('aichi_expo', '愛・地球博記念公園', 'to_fujigaoka', '08:43:00', 'weekday_green');

-- ========================================
-- 陶磁資料館南駅 → 藤が丘方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('toji', '陶磁資料館南', 'to_fujigaoka', '05:31:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '05:49:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '06:05:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '06:15:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '06:24:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '06:33:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '06:41:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '06:49:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '06:57:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '07:05:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '07:13:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '07:21:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '07:29:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '07:37:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '07:45:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '07:53:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '08:01:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '08:09:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '08:17:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '08:25:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '08:33:00', 'weekday_green'),
('toji', '陶磁資料館南', 'to_fujigaoka', '08:41:00', 'weekday_green');

-- ========================================
-- 八草駅 → 藤が丘方面（平日・緑時刻）
-- ========================================
INSERT INTO linimo_timetable (station_code, station_name, direction, departure_time, day_type) VALUES
('yagusa', '八草', 'to_fujigaoka', '05:30:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '05:48:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '06:03:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '06:13:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '06:22:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '06:31:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '06:39:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '06:47:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '06:55:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:03:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:11:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:19:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:27:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:35:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:43:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:51:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '07:59:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:07:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:15:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:23:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:31:00', 'weekday_green'),
('yagusa', '八草', 'to_fujigaoka', '08:39:00', 'weekday_green');
