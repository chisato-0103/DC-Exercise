-- ===================================
-- 愛知環状線 day_type修正スクリプト
-- 'weekday' → 'weekday_green', 'holiday' → 'holiday_red' に統一
-- ===================================

USE ait_transport;

-- ===================================
-- 1. day_type値の統一
-- ===================================

-- weekday → weekday_green に変更（愛知環状線のみ）
UPDATE rail_timetable
SET day_type = 'weekday_green'
WHERE line_code = 'aichi_kanjo' AND day_type = 'weekday';

-- holiday → holiday_red に変更（愛知環状線のみ）
UPDATE rail_timetable
SET day_type = 'holiday_red'
WHERE line_code = 'aichi_kanjo' AND day_type = 'holiday';

-- ===================================
-- 2. 修正確認
-- ===================================
SELECT 'Aichi Kanjo day_type分布' AS status;
SELECT day_type, COUNT(*) as count
FROM rail_timetable
WHERE line_code = 'aichi_kanjo'
GROUP BY day_type;

SELECT 'Linimo day_type分布' AS status;
SELECT day_type, COUNT(*) as count
FROM rail_timetable
WHERE line_code = 'linimo'
GROUP BY day_type;

SELECT 'すべてのrail_timetable day_type分布' AS status;
SELECT day_type, COUNT(*) as count
FROM rail_timetable
GROUP BY day_type;

-- ===================================
-- 3. 検証：古い値が残っていないか確認
-- ===================================
SELECT 'データベース検証：古い値の確認' AS status;
SELECT COUNT(*) as old_values_found
FROM rail_timetable
WHERE day_type IN ('weekday', 'holiday');

COMMIT;
