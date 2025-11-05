# SQLデータセットアップガイド

## 概要
このディレクトリには、愛工大交通情報システムのデータベース初期化とデータ投入用のSQLファイルが含まれています。

## ファイル一覧

### 基本セットアップ
- **setup.sql** - データベース・テーブル作成とサンプルデータ

### シャトルバス時刻表
- **complete_shuttle_a.sql** - Aダイヤ（授業期間平日）完全版
- **complete_shuttle_bc.sql** - B/Cダイヤ（土曜・学校休業期間）完全版
- **shuttle_schedule_fy2025.sql** - 運行日程（ダイヤ自動判定用）

### リニモ（藤が丘線）時刻表
- **linimo_weekday_to_fujigaoka.sql** - 平日（全駅→藤が丘方面）完全版
- **linimo_weekday_to_yagusa.sql** - 平日（全駅→八草方面）完全版
- **linimo_holiday_to_fujigaoka.sql** - 土休日（全駅→藤が丘方面）完全版
- **linimo_holiday_to_yagusa.sql** - 土休日（全駅→八草方面）完全版

### 愛知環状線時刻表
- **rebuild_aichi_kanjo_rail_timetable.sql** - 完全版（23駅、2,558件） ✅ NEW

## セットアップ手順

### 1. 基本セットアップ
```bash
# MAMPのMySQLにログイン
mysql -u root -p

# setup.sqlを実行
source /Applications/MAMP/htdocs/DC-Exercise/sql/setup.sql
```

### 2. シャトルバス時刻表の投入
```sql
source /Applications/MAMP/htdocs/DC-Exercise/sql/complete_shuttle_a.sql;
source /Applications/MAMP/htdocs/DC-Exercise/sql/complete_shuttle_bc.sql;
```

### 3. リニモ時刻表の投入（全駅・全方向・完全版）

✅ **完全版**: PDFから抽出した全駅・全方向の正確なデータ

```sql
source /Applications/MAMP/htdocs/DC-Exercise/sql/linimo_weekday_to_fujigaoka.sql;
source /Applications/MAMP/htdocs/DC-Exercise/sql/linimo_weekday_to_yagusa.sql;
source /Applications/MAMP/htdocs/DC-Exercise/sql/linimo_holiday_to_fujigaoka.sql;
source /Applications/MAMP/htdocs/DC-Exercise/sql/linimo_holiday_to_yagusa.sql;
```

### 4. 愛知環状線時刻表の投入 ✅ NEW

```sql
source /Applications/MAMP/htdocs/DC-Exercise/sql/rebuild_aichi_kanjo_rail_timetable.sql;
```

#### データ状況（全て完全版）:
**平日（weekday_green）:**
- ✅ 全9駅 × 藤が丘方面: 完全版
- ✅ 全9駅 × 八草方面: 完全版

**土休日（holiday_red）:**
- ✅ 全9駅 × 藤が丘方面: 完全版
- ✅ 全9駅 × 八草方面: 完全版

#### 各駅の八草駅からの所要時間（参考）:
| 駅名 | station_code | travel_time_from_yagusa |
|------|--------------|-------------------------|
| 八草 | yagusa | 0分 |
| 陶磁資料館南 | tojishiryokan_minami | 2分 |
| 愛・地球博記念公園 | ai_chikyuhaku_kinen_koen | 4分 |
| 公園西 | koen_nishi | 6分 |
| 芸大通 | geidai_dori | 8分 |
| 長久手古戦場 | nagakute_kosenjo | 10分 |
| 杁ヶ池公園 | irigaike_koen | 12分 |
| はなみずき通 | hanamizuki_dori | 14分 |
| 藤が丘 | fujigaoka | 17分 |

## 現在の実装状況

### ✅ 完全対応
- 大学 → リニモ各駅（全駅・全方向の実時刻表を使用）
- リニモ各駅 → 大学（全駅・全方向の実時刻表を使用）

**Phase 1完成:**
- シャトルバス: Aダイヤ完全版、B/Cダイヤ完全版
- リニモ: 全9駅 × 2方向 × 2曜日種別 = 完全網羅

## データ確認クエリ

### シャトルバスデータの確認
```sql
-- Aダイヤの八草駅行き
SELECT direction, departure_time, arrival_time
FROM shuttle_bus_timetable
WHERE dia_type = 'A' AND direction = 'to_yagusa'
ORDER BY departure_time;

-- Aダイヤの大学行き
SELECT direction, departure_time, arrival_time
FROM shuttle_bus_timetable
WHERE dia_type = 'A' AND direction = 'to_university'
ORDER BY departure_time;
```

### リニモデータの確認
```sql
-- 八草発→藤が丘方面（平日）
SELECT station_name, direction, departure_time
FROM linimo_timetable
WHERE station_code = 'yagusa' AND direction = 'to_fujigaoka' AND day_type = 'weekday_green'
ORDER BY departure_time;

-- 各駅発→八草方面（平日）
SELECT station_name, direction, departure_time
FROM linimo_timetable
WHERE direction = 'to_yagusa' AND day_type = 'weekday_green'
ORDER BY station_code, departure_time;
```

### 逆方向データの有無確認
```sql
-- 駅別の時刻表データ件数
SELECT
    station_code,
    station_name,
    direction,
    COUNT(*) as count
FROM linimo_timetable
WHERE day_type = 'weekday_green'
GROUP BY station_code, station_name, direction
ORDER BY station_code, direction;
```

## トラブルシューティング

### Q1: 「各駅から大学」の検索で結果が表示されない
**A:** 以下を確認してください:
1. シャトルバスの大学行き（to_university）データが投入されているか
2. システム設定で正しいダイヤ種別が設定されているか
3. 現在時刻に対して、接続可能なシャトルバスが存在するか

### Q2: 時刻が正確でない気がする
**A:** 全駅の実時刻表データが投入済みです。不具合がある場合は以下を確認:
- システム設定で正しいダイヤ種別（current_dia_type）が設定されているか
- day_typeが正しく判定されているか（weekday_green / holiday_red）

### Q3: データを入れ直したい
```sql
-- 特定駅の逆方向データを削除
DELETE FROM linimo_timetable
WHERE station_code = 'fujigaoka' AND direction = 'to_yagusa';

-- 全逆方向データを削除
DELETE FROM linimo_timetable WHERE direction = 'to_yagusa';

-- 再度SQLファイルを実行
source /path/to/your/sql/file.sql;
```

## Phase 1完成チェックリスト
- ✅ シャトルバス: Aダイヤ完全版
- ✅ シャトルバス: B/Cダイヤ完全版
- ✅ リニモ: 全駅・全方向・平日完全版
- ✅ リニモ: 全駅・全方向・土休日完全版
- ✅ 愛知環状線: 23駅完全版（2025-11-03実装）

## 愛知環状線データ詳細
- **実装日**: 2025年11月3日
- **駅数**: 23駅
- **総レコード数**: 2,558件
- **方向**: to_kozoji（高蔵寺方面）、to_okazaki（岡崎方面）
- **データ形式**: PDFから正確に抽出した平日ダイヤ（weekday_green）
- **特徴**: 環状線のため全駅が両方向対応

## Phase 2以降の改善予定
- [ ] お気に入り機能の実装
- [ ] データ更新用の管理画面の実装
- [ ] 愛知環状線の休日ダイヤ追加
