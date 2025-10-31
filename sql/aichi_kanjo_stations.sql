-- ===================================
-- 愛知環状線 駅マスタデータ（完全版 23駅）
-- ===================================

USE ait_transport;

-- 愛知環状線の正確な全23駅を stations テーブルに追加
-- 岡崎駅中心に、時計回りで距離と所要時間を推定
-- 駅間所要時間：約4分（1周 = 23駅 × 4分 ≈ 92分）

INSERT INTO stations (station_code, station_name, station_name_en, order_index, travel_time_from_yagusa, line_type) VALUES
-- 岡崎から八草方向（時計回り）
('okazaki', '岡崎', 'Okazaki', 100, 0, 'aichi_kanjo'),
('mutsuna', '六名', 'Mutsuna', 101, 4, 'aichi_kanjo'),
('naka_okazaki', '中岡崎', 'Naka-Okazaki', 102, 8, 'aichi_kanjo'),
('kita_okazaki', '北岡崎', 'Kita-Okazaki', 103, 12, 'aichi_kanjo'),
('daimon', '大門', 'Daimon', 104, 16, 'aichi_kanjo'),
('kitano_masuzuka', '北野桝塚', 'Kitanomasuzuka', 105, 20, 'aichi_kanjo'),
('mikawa_kamigo', '三河上郷', 'Mikawa-Kamigo', 106, 24, 'aichi_kanjo'),
('ekaku', '永覚', 'Ekaku', 107, 28, 'aichi_kanjo'),
('suenohara', '末野原', 'Suenohara', 108, 32, 'aichi_kanjo'),
('mikawa_toyota', '三河豊田', 'Mikawa-Toyota', 109, 36, 'aichi_kanjo'),
('shin_uwagoromo', '新上挙母', 'Shin-Uwagoromo', 110, 40, 'aichi_kanjo'),
('shin_toyota', '新豊田', 'Shin-Toyota', 111, 44, 'aichi_kanjo'),
('aikan_umetsubo', '愛環梅坪', 'Aikan-Umetsubo', 112, 48, 'aichi_kanjo'),
('shigo', '四郷', 'Shigo', 113, 52, 'aichi_kanjo'),
('kaizu', '貝津', 'Kaizu', 114, 56, 'aichi_kanjo'),
('homi', '保見', 'Homi', 115, 60, 'aichi_kanjo'),
('sasabara', '篠原', 'Sasabara', 116, 64, 'aichi_kanjo'),
('yakusa', '八草', 'Yakusa', 117, 68, 'aichi_kanjo'),

-- 八草から高蔵寺方向（時計回り続き）
('yamaguchi', '山口', 'Yamaguchi', 118, 72, 'aichi_kanjo'),
('setoguchi', '瀬戸口', 'Setoguchi', 119, 76, 'aichi_kanjo'),
('setoshi', '瀬戸市', 'Setoshi', 120, 80, 'aichi_kanjo'),
('nakamizuno', '中水野', 'Nakamizuno', 121, 84, 'aichi_kanjo'),
('kozoji', '高蔵寺', 'Kozoji', 122, 88, 'aichi_kanjo');

-- ===================================
-- 検証
-- ===================================
SELECT '✅ 愛知環状線駅情報を追加しました（全23駅）' AS status;
SELECT CONCAT('総駅数: ', COUNT(*)) AS total_count FROM stations;
SELECT CONCAT('愛知環状線駅数: ', COUNT(*)) AS aichi_kanjo_count FROM stations WHERE line_type = 'aichi_kanjo';
