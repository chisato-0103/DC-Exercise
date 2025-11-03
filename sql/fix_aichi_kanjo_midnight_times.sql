-- ===================================
-- Fix: Remove invalid midnight times from aichi_kanjo
-- ===================================
-- Issue: Times like 00:03, 00:06, 00:09 etc. don't exist in official timetables
-- These appear to be calculation artifacts
--
-- Solution: Delete all records with times between 00:00 and 06:00
-- The actual first departure is around 6:14 (Okazaki)
--
-- Date: 2025-11-03

DELETE FROM rail_timetable 
WHERE line_code = 'aichi_kanjo' 
  AND departure_time >= '00:00:00' 
  AND departure_time < '06:00:00';

-- Verification
SELECT 
  station_code,
  MIN(departure_time) as earliest_departure,
  MAX(departure_time) as latest_departure,
  COUNT(*) as record_count
FROM rail_timetable 
WHERE line_code = 'aichi_kanjo'
GROUP BY station_code
ORDER BY MIN(departure_time);
