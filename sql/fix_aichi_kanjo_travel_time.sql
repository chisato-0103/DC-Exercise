-- ===================================
-- Fix: Aichi Kanjo Station Travel Times
-- ===================================
-- Issue: Travel times were inconsistent and reversed
-- Root Cause: Manual data entry errors
--
-- Solution: Set travel times with 4-minute intervals from Yakusa
-- Okazaki: 11 min, then +4 min for each subsequent station
--
-- Date: 2025-11-03

UPDATE stations SET travel_time_from_yagusa = 11 WHERE station_code = 'okazaki';
UPDATE stations SET travel_time_from_yagusa = 15 WHERE station_code = 'mutsuna';
UPDATE stations SET travel_time_from_yagusa = 19 WHERE station_code = 'naka_okazaki';
UPDATE stations SET travel_time_from_yagusa = 23 WHERE station_code = 'kita_okazaki';
UPDATE stations SET travel_time_from_yagusa = 27 WHERE station_code = 'daimon';
UPDATE stations SET travel_time_from_yagusa = 31 WHERE station_code = 'kitano_masuzuka';
UPDATE stations SET travel_time_from_yagusa = 35 WHERE station_code = 'mikawa_kamigo';
UPDATE stations SET travel_time_from_yagusa = 39 WHERE station_code = 'ekaku';
UPDATE stations SET travel_time_from_yagusa = 43 WHERE station_code = 'suenohara';
UPDATE stations SET travel_time_from_yagusa = 47 WHERE station_code = 'mikawa_toyota';
UPDATE stations SET travel_time_from_yagusa = 51 WHERE station_code = 'shin_uwagoromo';
UPDATE stations SET travel_time_from_yagusa = 55 WHERE station_code = 'shin_toyota';
UPDATE stations SET travel_time_from_yagusa = 59 WHERE station_code = 'aikan_umetsubo';
UPDATE stations SET travel_time_from_yagusa = 63 WHERE station_code = 'shigo';
UPDATE stations SET travel_time_from_yagusa = 67 WHERE station_code = 'kaizu';
UPDATE stations SET travel_time_from_yagusa = 71 WHERE station_code = 'homi';
UPDATE stations SET travel_time_from_yagusa = 75 WHERE station_code = 'sasabara';
UPDATE stations SET travel_time_from_yagusa = 79 WHERE station_code = 'yakusa';
UPDATE stations SET travel_time_from_yagusa = 83 WHERE station_code = 'yamaguchi';
UPDATE stations SET travel_time_from_yagusa = 87 WHERE station_code = 'setoguchi';
UPDATE stations SET travel_time_from_yagusa = 91 WHERE station_code = 'setoshi';
UPDATE stations SET travel_time_from_yagusa = 95 WHERE station_code = 'nakamizuno';
UPDATE stations SET travel_time_from_yagusa = 99 WHERE station_code = 'kozoji';

-- Verification
SELECT station_code, station_name, travel_time_from_yagusa
FROM stations
WHERE line_type = 'aichi_kanjo'
ORDER BY travel_time_from_yagusa;
