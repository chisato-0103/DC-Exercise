# 愛知環状線統合 - DB実行ガイド

愛知工業大学交通情報システムに愛知環状線を統合するためのデータベース実行手順です。

## 📋 実行手順

### ステップ1：既存のDBをクリア（初回実行の場合）

既存のデータベースを使用したい場合はこのステップをスキップしてください。

```bash
# MySQLにログイン
mysql -u root -p

# データベースを削除（⚠️ 注意：既存データが削除されます）
DROP DATABASE IF EXISTS ait_transport;

# ログアウト
exit
```

### ステップ2：初期スキーマを作成（新規の場合）

既存のDBがない場合は、初期スキーマを実行してください：

```bash
cd /Applications/MAMP/htdocs/DC-Exercise/sql/
mysql -u root -p ait_transport < setup.sql
```

### ステップ3：オプションBへのマイグレーション実行

これにより、`transport_lines`と`rail_timetable`テーブルが作成され、
既存のリニモデータが自動的に`rail_timetable`に移行されます。

```bash
mysql -u root -p ait_transport < migration_to_option_b.sql
```

**実行内容：**
- ✅ `transport_lines` テーブル作成（路線マスタ）
- ✅ `rail_timetable` テーブル作成（汎用時刻表）
- ✅ 既存の `linimo_timetable` データを `rail_timetable` に移行
- ✅ シャトルバス、リニモ、愛知環状線の路線情報を登録

### ステップ4：愛知環状線駅情報を追加

21の愛知環状線駅を駅マスタテーブルに追加します。

```bash
mysql -u root -p ait_transport < aichi_kanjo_stations.sql
```

**追加される駅（21駅）：**
```
八草（yakusa） - 中心駅（リニモと共有）
山口、瀬戸口、瀬戸市、中水野、幸田
笹原、北身、海津、塩、愛環梅坪、新豊田、新上ゴロモ、
三河豊田、末野原、榎、三河上郷、大門北野増束、中岡崎、むつな、岡崎
```

### ステップ5：愛知環状線時刻表を追加（推奨：完全版）

⭐ **推奨：完全版を使用してください**

完全版には、朝7時から夜21時45分までの充実した時刻表が含まれています。

```bash
mysql -u root -p ait_transport < aichi_kanjo_timetable_complete.sql
```

**時刻表仕様：**
- 平日：15分間隔の運行（1時間に4本）
- 休日：30分間隔の運行
- 朝7時～21時45分（全時間帯カバー）
- 方向：to_okazaki（八草→岡崎方面）と to_kozoji（岡崎→八草方面）

### ステップ6：既存データの更新（オプション）

既存のリニモ・シャトルバスデータが必要な場合は、
以下のスクリプトを実行してください：

```bash
# シャトルバス（Aダイヤ）
mysql -u root -p ait_transport < complete_shuttle_a.sql

# シャトルバス（B/Cダイヤ）
mysql -u root -p ait_transport < complete_shuttle_bc.sql

# リニモ時刻表
mysql -u root -p ait_transport < linimo_weekday_to_fujigaoka.sql
mysql -u root -p ait_transport < linimo_weekday_to_yagusa.sql
mysql -u root -p ait_transport < linimo_holiday_to_fujigaoka.sql
mysql -u root -p ait_transport < linimo_holiday_to_yagusa.sql

# シャトルバス運行日程（FY2025）
mysql -u root -p ait_transport < shuttle_schedule_fy2025.sql
```

---

## 📊 実行結果の確認

すべてのスクリプト実行後、以下のコマンドでデータを確認できます：

### 路線マスタの確認
```sql
SELECT * FROM transport_lines;
```

**期待結果：**
```
id | line_code    | line_name      | transfer_hub | typical_duration
1  | shuttle      | シャトルバス    | yagusa       | 5
2  | linimo       | リニモ         | yagusa       | 2
3  | aichi_kanjo  | 愛知環状線     | yagusa       | 4
```

### 駅情報の確認
```sql
SELECT COUNT(*) AS total_stations FROM stations;
```

**期待結果：** `total_stations: 30` (リニモ9駅 + 愛知環状線21駅)

### 時刻表データの確認
```sql
SELECT line_code, day_type, COUNT(*) AS count
FROM rail_timetable
GROUP BY line_code, day_type;
```

**期待結果：**
```
line_code    | day_type | count
linimo       | weekday  | (リニモ平日データ数)
linimo       | holiday  | (リニモ休日データ数)
aichi_kanjo  | weekday  | 188（八草発+岡崎発+山口駅分）
aichi_kanjo  | holiday  | 60（30分間隔×2方向）
```

---

## 🌐 ブラウザでの確認

すべてのDB実行完了後、ブラウザでテストできます：

### URL
```
http://localhost:8888/DC-Exercise/
```

### テスト項目

1. **リニモ経由ルート（既存機能の確認）**
   - 「🏫 大学 → 🚃 リニモ駅」を選択
   - 駅を選択して検索
   - ✅ ルートが表示されることを確認

2. **愛知環状線経由ルート（新機能）**
   - 「🏫 大学 → 🚆 愛知環状線駅」を選択
   - 岡崎・山口などの駅を選択
   - ✅ シャトルバス→愛知環状線の乗り継ぎが表示されることを確認

3. **逆方向テスト**
   - 「🚃 リニモ駅 → 🏫 大学」を選択
   - 「🚆 愛知環状線駅 → 🏫 大学」を選択
   - ✅ 両方向のルートが表示されることを確認

---

## 🐛 トラブルシューティング

### エラー：「Access denied for user 'root'」
パスワードが間違っている、またはMySQLが起動していない可能性があります。

```bash
# MAMPのMySQLが起動しているか確認
/Applications/MAMP/Library/bin/mysqld --version

# MAMP管理画面から起動することも推奨
```

### エラー：「Unknown database 'ait_transport'」
`setup.sql` をまず実行してから、マイグレーション手順を実行してください。

### データが表示されない
以下を確認してください：
1. すべてのSQLスクリプトが正常に実行されたか
2. ブラウザのキャッシュをクリアしたか（Cmd+Shift+R）
3. PHPエラーログを確認したか（/Applications/MAMP/logs/php_error.log）

---

## 📁 ファイル一覧

| ファイル | 説明 |
|---------|------|
| `migration_to_option_b.sql` | 汎用化マイグレーション（★重要） |
| `aichi_kanjo_stations.sql` | 愛知環状線21駅情報 |
| `aichi_kanjo_timetable_complete.sql` | 愛知環状線完全時刻表（推奨） |
| `aichi_kanjo_timetable_sample.sql` | 愛知環状線サンプル時刻表（参考） |

---

## 📝 注記

- このガイドは、オプションB（統一トランスポートテーブル）実装版です
- 既存のリニモ・シャトルバス機能は影響を受けません
- 時刻表データはサンプルベースです。実際の時刻表はPDF資料を参照して更新してください

---

**実装日**: 2025-10-30
**バージョン**: 1.0（愛知環状線統合版）
