-- ===================================
-- Aichi Kanjo（愛知環状線）駅データ追加
-- stations テーブルに23駅を登録
-- ===================================

USE ait_transport;

-- 既存の Linimo 駅の order_index の最大値を確認してから追加
INSERT INTO stations (station_code, station_name, line_code, travel_time_from_yagusa, order_index) VALUES
-- 愛知環状線駅（23駅）
('okazaki', '岡崎', 'aichi_kanjo', 35, 100),
('mutsuna', '武豊', 'aichi_kanjo', 32, 101),
('naka_okazaki', '中岡崎', 'aichi_kanjo', 28, 102),
('kita_okazaki', '北岡崎', 'aichi_kanjo', 24, 103),
('daimon', '大門', 'aichi_kanjo', 20, 104),
('kitano_masuzuka', '北野増塚', 'aichi_kanjo', 18, 105),
('mikawa_kamigo', '三河上郷', 'aichi_kanjo', 16, 106),
('ekaku', '江角', 'aichi_kanjo', 14, 107),
('suenohara', '末野原', 'aichi_kanjo', 12, 108),
('mikawa_toyota', '三河豊田', 'aichi_kanjo', 10, 109),
('shin_uwagoromo', '新上ゴ衣', 'aichi_kanjo', 8, 110),
('shin_toyota', '新豊田', 'aichi_kanjo', 6, 111),
('aikan_umetsubo', '愛環梅坪', 'aichi_kanjo', 4, 112),
('shigo', '塩後', 'aichi_kanjo', 5, 113),
('kaizu', '海津', 'aichi_kanjo', 8, 114),
('homi', '豊見', 'aichi_kanjo', 12, 115),
('sasabara', '笹原', 'aichi_kanjo', 16, 116),
('yamaguchi', '山口', 'aichi_kanjo', 20, 117),
('setoguchi', '瀬戸口', 'aichi_kanjo', 24, 118),
('setoshi', '瀬戸市', 'aichi_kanjo', 28, 119),
('nakamizuno', '中水野', 'aichi_kanjo', 32, 120),
('kozoji', '幸次', 'aichi_kanjo', 35, 121);

-- 確認
SELECT COUNT(*) as aichi_kanjo_count FROM stations WHERE line_code = 'aichi_kanjo';
SELECT COUNT(*) as total_count FROM stations;

COMMIT;
