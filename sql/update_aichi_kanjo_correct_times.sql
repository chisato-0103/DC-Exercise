-- ==================================
-- 愛知環状線 正確な所要時間更新（八草基準・累積時間）
-- ==================================
-- このスクリプトは、実測データから得た八草駅からの正確な累積所要時間を反映するため、
-- stations テーブルの travel_time_from_yakusa を更新します。

-- 高蔵寺方面（to_kozouji）の駅
UPDATE stations SET travel_time_from_yakusa = 4 WHERE station_code = 'yamaguchi';      -- 山口
UPDATE stations SET travel_time_from_yakusa = 7 WHERE station_code = 'setoguchi';      -- 瀬戸口
UPDATE stations SET travel_time_from_yakusa = 10 WHERE station_code = 'setoshi';       -- 瀬戸市
UPDATE stations SET travel_time_from_yakusa = 13 WHERE station_code = 'nakamizuno';    -- 中水野
UPDATE stations SET travel_time_from_yakusa = 17 WHERE station_code = 'kozoji';        -- 高蔵寺

-- 岡崎方面（to_okazaki）の駅
UPDATE stations SET travel_time_from_yakusa = 4 WHERE station_code = 'sasabara';       -- 篠原
UPDATE stations SET travel_time_from_yakusa = 7 WHERE station_code = 'homi';           -- 保見
UPDATE stations SET travel_time_from_yakusa = 9 WHERE station_code = 'kaizu';          -- 貝津
UPDATE stations SET travel_time_from_yakusa = 12 WHERE station_code = 'shigo';         -- 四郷
UPDATE stations SET travel_time_from_yakusa = 15 WHERE station_code = 'aikan_umetsubo'; -- 愛環梅坪
UPDATE stations SET travel_time_from_yakusa = 18 WHERE station_code = 'shin_toyota';   -- 新豊田
UPDATE stations SET travel_time_from_yakusa = 21 WHERE station_code = 'shin_uwagoromo'; -- 新上挙母
UPDATE stations SET travel_time_from_yakusa = 24 WHERE station_code = 'mikawa_toyota';  -- 三河豊田
UPDATE stations SET travel_time_from_yakusa = 27 WHERE station_code = 'suenohara';     -- 末野原
UPDATE stations SET travel_time_from_yakusa = 30 WHERE station_code = 'ekaku';         -- 永覚
UPDATE stations SET travel_time_from_yakusa = 33 WHERE station_code = 'mikawa_kamigo';  -- 三河上郷
UPDATE stations SET travel_time_from_yakusa = 36 WHERE station_code = 'kitano_masuzuka'; -- 北野桝塚
UPDATE stations SET travel_time_from_yakusa = 41 WHERE station_code = 'kita_okazaki';  -- 北岡崎
UPDATE stations SET travel_time_from_yakusa = 44 WHERE station_code = 'nakaokazaki';   -- 中岡崎
UPDATE stations SET travel_time_from_yakusa = 47 WHERE station_code = 'mutsuna';       -- 六名
UPDATE stations SET travel_time_from_yakusa = 50 WHERE station_code = 'okazaki';       -- 岡崎

-- 更新確認
SELECT '愛知環状線の所要時間を実測データで更新しました。' AS message;
SELECT station_code, station_name, travel_time_from_yakusa, line_type
FROM stations 
WHERE line_type = 'aichi_kanjo' 
ORDER BY order_index;
