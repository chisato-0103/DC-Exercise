-- ========================================
-- データ完全性確認スクリプト
-- Option B統合後のすべてのデータを検証
-- ========================================

USE ait_transport;

-- ========================================
-- 1. 駅情報の確認
-- ========================================
SELECT '=========================================' AS '';
SELECT '📍 駅情報の確認' AS section;
SELECT '=========================================' AS '';

SELECT
  COUNT(*) AS 総駅数,
  SUM(CASE WHEN line_type = 'linimo' THEN 1 ELSE 0 END) AS 'リニモ駅数',
  SUM(CASE WHEN line_type = 'aichi_kanjo' THEN 1 ELSE 0 END) AS '愛知環状線駅数'
FROM stations;

SELECT '' AS '';
SELECT 'リニモ駅一覧:' AS '';
SELECT station_code, station_name, line_type, order_index
FROM stations
WHERE line_type = 'linimo'
ORDER BY order_index;

SELECT '' AS '';
SELECT '愛知環状線駅一覧（最初の10駅）:' AS '';
SELECT station_code, station_name, line_type, order_index
FROM stations
WHERE line_type = 'aichi_kanjo'
ORDER BY order_index
LIMIT 10;

-- ========================================
-- 2. シャトルバス時刻表の確認
-- ========================================
SELECT '' AS '';
SELECT '=========================================' AS '';
SELECT '🚌 シャトルバス時刻表の確認' AS section;
SELECT '=========================================' AS '';

SELECT
  COUNT(*) AS 総レコード数,
  COUNT(DISTINCT direction) AS '方向数',
  COUNT(DISTINCT dia_type) AS 'ダイヤ種別数'
FROM shuttle_bus_timetable;

SELECT '' AS '';
SELECT 'ダイヤ別レコード数:' AS '';
SELECT
  dia_type,
  COUNT(*) AS 件数
FROM shuttle_bus_timetable
GROUP BY dia_type
ORDER BY dia_type;

SELECT '' AS '';
SELECT '方向別レコード数:' AS '';
SELECT
  direction,
  COUNT(*) AS 件数
FROM shuttle_bus_timetable
GROUP BY direction;

-- ========================================
-- 3. リニモ時刻表の確認
-- ========================================
SELECT '' AS '';
SELECT '=========================================' AS '';
SELECT '🚃 リニモ時刻表の確認（rail_timetable）' AS section;
SELECT '=========================================' AS '';

SELECT
  COUNT(*) AS 総レコード数,
  COUNT(DISTINCT station_code) AS '駅数',
  COUNT(DISTINCT direction) AS '方向数',
  COUNT(DISTINCT day_type) AS '曜日種別数'
FROM rail_timetable
WHERE line_code = 'linimo';

SELECT '' AS '';
SELECT '曜日別レコード数:' AS '';
SELECT
  day_type,
  COUNT(*) AS 件数,
  COUNT(DISTINCT departure_time) AS '列車本数（平日基準）'
FROM rail_timetable
WHERE line_code = 'linimo'
GROUP BY day_type;

SELECT '' AS '';
SELECT '方向別レコード数:' AS '';
SELECT
  direction,
  COUNT(*) AS 件数
FROM rail_timetable
WHERE line_code = 'linimo'
GROUP BY direction;

SELECT '' AS '';
SELECT 'リニモ駅別レコード数（最初の5駅）:' AS '';
SELECT
  station_name,
  COUNT(*) AS 件数
FROM rail_timetable
WHERE line_code = 'linimo'
GROUP BY station_code, station_name
LIMIT 5;

-- ========================================
-- 4. 愛知環状線時刻表の確認
-- ========================================
SELECT '' AS '';
SELECT '=========================================' AS '';
SELECT '🚆 愛知環状線時刻表の確認（rail_timetable）' AS section;
SELECT '=========================================' AS '';

SELECT
  COUNT(*) AS 総レコード数,
  COUNT(DISTINCT station_code) AS '駅数',
  COUNT(DISTINCT direction) AS '方向数',
  COUNT(DISTINCT day_type) AS '曜日種別数'
FROM rail_timetable
WHERE line_code = 'aichi_kanjo';

SELECT '' AS '';
SELECT '曜日別レコード数:' AS '';
SELECT
  day_type,
  COUNT(*) AS 件数,
  COUNT(DISTINCT departure_time) AS '列車本数（平日基準）'
FROM rail_timetable
WHERE line_code = 'aichi_kanjo'
GROUP BY day_type;

SELECT '' AS '';
SELECT '方向別レコード数:' AS '';
SELECT
  direction,
  COUNT(*) AS 件数
FROM rail_timetable
WHERE line_code = 'aichi_kanjo'
GROUP BY direction;

SELECT '' AS '';
SELECT '愛知環状線駅別レコード数（最初の5駅）:' AS '';
SELECT
  station_name,
  COUNT(*) AS 件数
FROM rail_timetable
WHERE line_code = 'aichi_kanjo'
GROUP BY station_code, station_name
ORDER BY station_name
LIMIT 5;

-- ========================================
-- 5. rail_timetable全体の確認
-- ========================================
SELECT '' AS '';
SELECT '=========================================' AS '';
SELECT '🚃🚆 rail_timetable（全路線統計）' AS section;
SELECT '=========================================' AS '';

SELECT
  line_code AS 路線,
  COUNT(*) AS レコード数
FROM rail_timetable
GROUP BY line_code
WITH ROLLUP;

-- ========================================
-- 6. 路線マスタの確認
-- ========================================
SELECT '' AS '';
SELECT '=========================================' AS '';
SELECT '🛣️ 路線マスタ（transport_lines）' AS section;
SELECT '=========================================' AS '';

SELECT
  line_code,
  line_name,
  line_name_en,
  transfer_hub,
  typical_duration
FROM transport_lines
ORDER BY line_code;

-- ========================================
-- 7. シャトルバス運行日程の確認
-- ========================================
SELECT '' AS '';
SELECT '=========================================' AS '';
SELECT '📅 シャトルバス運行日程の確認' AS section;
SELECT '=========================================' AS '';

SELECT
  COUNT(*) AS 総日数,
  COUNT(DISTINCT dia_type) AS 'ダイヤ種別数'
FROM shuttle_schedule;

SELECT '' AS '';
SELECT 'ダイヤ種別別日数:' AS '';
SELECT
  dia_type,
  COUNT(*) AS 日数
FROM shuttle_schedule
GROUP BY dia_type
ORDER BY dia_type;

SELECT '' AS '';
SELECT '最初の5日間:' AS '';
SELECT
  operation_date,
  dia_type,
  remarks
FROM shuttle_schedule
ORDER BY operation_date
LIMIT 5;

-- ========================================
-- 8. 総合統計
-- ========================================
SELECT '' AS '';
SELECT '=========================================' AS '';
SELECT '📊 全体統計サマリー' AS section;
SELECT '=========================================' AS '';

SELECT
  CONCAT('駅総数: ', (SELECT COUNT(*) FROM stations)) AS stat1,
  CONCAT('シャトルバス時刻表: ', (SELECT COUNT(*) FROM shuttle_bus_timetable), ' 件') AS stat2,
  CONCAT('rail_timetable（全路線）: ', (SELECT COUNT(*) FROM rail_timetable), ' 件') AS stat3,
  CONCAT('  - リニモ: ', (SELECT COUNT(*) FROM rail_timetable WHERE line_code = 'linimo'), ' 件') AS stat4,
  CONCAT('  - 愛知環状線: ', (SELECT COUNT(*) FROM rail_timetable WHERE line_code = 'aichi_kanjo'), ' 件') AS stat5;

-- ========================================
-- 9. データ完全性チェック
-- ========================================
SELECT '' AS '';
SELECT '=========================================' AS '';
SELECT '✅ データ完全性チェック' AS section;
SELECT '=========================================' AS '';

SELECT
  CASE
    WHEN (SELECT COUNT(*) FROM rail_timetable WHERE line_code = 'linimo') = 5290
    THEN '✅ リニモデータ完全'
    ELSE '⚠️ リニモデータ不完全'
  END AS 'リニモ検証',
  CASE
    WHEN (SELECT COUNT(*) FROM rail_timetable WHERE line_code = 'aichi_kanjo') = 3948
    THEN '✅ 愛知環状線データ完全'
    ELSE '⚠️ 愛知環状線データ不完全'
  END AS '愛知環状線検証',
  CASE
    WHEN (SELECT COUNT(*) FROM stations WHERE line_type = 'linimo') = 9
    THEN '✅ リニモ駅情報完全'
    ELSE '⚠️ リニモ駅情報不完全'
  END AS 'リニモ駅検証',
  CASE
    WHEN (SELECT COUNT(*) FROM stations WHERE line_type = 'aichi_kanjo') = 21
    THEN '✅ 愛知環状線駅情報完全'
    ELSE '⚠️ 愛知環状線駅情報不完全'
  END AS '愛知環状線駅検証';

SELECT '' AS '';
SELECT '=========================================' AS '';
SELECT '✅ データ完全性確認完了' AS result;
SELECT '=========================================' AS '';
