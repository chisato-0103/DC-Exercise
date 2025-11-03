-- ===================================
-- 駅コード修正スクリプト
-- yagusa → yakusa に統一
-- ===================================

USE ait_transport;

-- stations テーブルで yagusa を yakusa に変更
UPDATE stations SET station_code = 'yakusa' WHERE station_code = 'yagusa';

-- linimo_timetable で yagusa を yakusa に変更
UPDATE linimo_timetable SET station_code = 'yakusa' WHERE station_code = 'yagusa';

-- 確認：修正前後で確認
SELECT COUNT(*) as stations_count FROM stations WHERE station_code = 'yakusa';
SELECT COUNT(*) as linimo_count FROM linimo_timetable WHERE station_code = 'yakusa';

COMMIT;
