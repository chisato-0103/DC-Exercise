-- ===================================
-- Fix: Aichi Kanjo Okazaki Station Travel Time
-- ===================================
-- Issue: Okazaki station had travel_time_from_yagusa = 0
-- which caused empty routes for University → Okazaki searches
--
-- Root Cause: The calculateUniversityToRail function uses this value
-- to calculate estimated arrival time. With 0 minutes, the matching
-- algorithm couldn't find connecting trains at Okazaki.
--
-- Solution: Updated travel_time_from_yagusa to 11 minutes
-- (calculated from actual timetable data analysis)
--
-- Date: 2025-11-02

UPDATE stations SET travel_time_from_yagusa = 11 WHERE station_code = 'okazaki';

-- Verification
SELECT station_code, station_name, travel_time_from_yagusa
FROM stations
WHERE station_code = 'okazaki';
