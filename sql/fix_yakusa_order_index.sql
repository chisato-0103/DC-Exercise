-- ===================================
-- Fix: Yakusa Station Order Index in Aichi Kanjo Line
-- ===================================
-- Issue: Yakusa (八草) was not in correct position in aichi_kanjo station list
-- Root Cause: order_index was set to 1 (same as linimo order)
--
-- Solution: Set yakusa's order_index to 117
-- This positions it between Sasabara (篠原: 116) and Yamaguchi (山口: 118)
-- matching the actual Aichi Kanjo Line station order
--
-- Date: 2025-11-03

UPDATE stations SET order_index = 117 WHERE station_code = 'yakusa' AND line_type = 'aichi_kanjo';

-- Verification
SELECT station_code, station_name, order_index
FROM stations
WHERE line_type = 'aichi_kanjo'
ORDER BY order_index;
