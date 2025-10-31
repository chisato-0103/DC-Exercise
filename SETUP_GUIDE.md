# 🚀 セットアップクイックスタートガイド

## 概要

このガイドは、愛知環状線統合（Option B）の完全なDBセットアップを簡単に実行するためのステップバイステップです。

---

## ⚠️ 重要：実行順序

Option B統合では、**データマイグレーションの順序が重要**です。以下の順序で必ず実行してください：

1. **setup.sql** - 初期スキーマ作成
2. **linimo_*.sql（4つのファイル）** - リニモ実データ読込
3. **migration_to_option_b.sql** - 新テーブル構造へ移行
4. **aichi_kanjo_stations.sql** - 愛知環状線駅情報追加
5. **aichi_kanjo_timetable_full.sql** - 愛知環状線時刻表追加

⚠️ **注意**: 順序を間違えるとデータが失われます！

---

## 📋 方法A：自動スクリプト（推奨）

最も簡単な方法です。1コマンドで全てセットアップできます。

### ステップ1：スクリプトに実行権限を付与

```bash
cd /Applications/MAMP/htdocs/DC-Exercise/sql
chmod +x run_all_migrations.sh
```

### ステップ2：スクリプト実行

```bash
./run_all_migrations.sh
```

### ステップ3：プロンプト対応

```
MySQLのrootパスワードを入力してください: [パスワード入力]
```

スクリプトが以下の順序で自動実行されます：

```
1️⃣  初期スキーマ作成
    → setup.sql

2️⃣  既存リニモデータ読込
    → linimo_weekday_to_fujigaoka.sql
    → linimo_weekday_to_yagusa.sql
    → linimo_holiday_to_fujigaoka.sql
    → linimo_holiday_to_yagusa.sql

3️⃣  オプションBマイグレーション
    → migration_to_option_b.sql

4️⃣  愛知環状線駅情報追加
    → aichi_kanjo_stations.sql

5️⃣  愛知環状線時刻表追加
    → aichi_kanjo_timetable_full.sql

6️⃣  （オプション）運行日程更新
    → shuttle_schedule_fy2025.sql
```

### ステップ4：動作確認

スクリプト完了時に以下が表示されます：

```
📊 データベース統計情報：

  総駅数: 30
  シャトルバス時刻表記録数: 850

  linimo: 5290 記録
  aichi_kanjo: 3948 記録

  登録路線数: 3

✅ セットアップ完了 - ブラウザでテスト
🌐 http://localhost:8888/DC-Exercise/
```

---

## 📋 方法B：手動実行

より細かい制御が必要な場合は、以下のコマンドを順に実行してください。

### ステップ1：初期スキーマ作成

```bash
mysql -u root -p ait_transport < setup.sql
```

### ステップ2：リニモデータ読込（重要：この順序）

```bash
mysql -u root -p ait_transport < linimo_weekday_to_fujigaoka.sql
mysql -u root -p ait_transport < linimo_weekday_to_yagusa.sql
mysql -u root -p ait_transport < linimo_holiday_to_fujigaoka.sql
mysql -u root -p ait_transport < linimo_holiday_to_yagusa.sql
```

### ステップ3：マイグレーション実行

```bash
mysql -u root -p ait_transport < migration_to_option_b.sql
```

### ステップ4：愛知環状線駅追加

```bash
mysql -u root -p ait_transport < aichi_kanjo_stations.sql
```

### ステップ5：愛知環状線時刻表追加

```bash
mysql -u root -p ait_transport < aichi_kanjo_timetable_full.sql
```

### ステップ6（オプション）：運行日程追加

```bash
mysql -u root -p ait_transport < shuttle_schedule_fy2025.sql
```

---

## ✅ データ完全性の確認

セットアップ後、以下のスクリプトでデータが完全に読込まれたか確認できます：

```bash
mysql -u root -p ait_transport < verify_data_integrity.sql
```

### 期待される結果：

```
✅ リニモデータ完全
✅ 愛知環状線データ完全
✅ リニモ駅情報完全
✅ 愛知環状線駅情報完全
```

---

## 📊 各ファイルの役割と データ量

### 各SQLファイルの詳細

| ファイル | 目的 | データ量 | 実行時間 |
|---------|------|---------|---------|
| **setup.sql** | DB/テーブル初期化 | 基本スキーマ | 秒単位 |
| **linimo_weekday_to_fujigaoka.sql** | リニモ平日→藤が丘 | 1,325行 | 秒単位 |
| **linimo_weekday_to_yagusa.sql** | リニモ平日→八草 | 1,325行 | 秒単位 |
| **linimo_holiday_to_fujigaoka.sql** | リニモ休日→藤が丘 | 1,315行 | 秒単位 |
| **linimo_holiday_to_yagusa.sql** | リニモ休日→八草 | 1,315行 | 秒単位 |
| **migration_to_option_b.sql** | Option B移行 | 新テーブル作成 | 秒単位 |
| **aichi_kanjo_stations.sql** | 愛知環状線駅追加 | 21駅情報 | 秒単位 |
| **aichi_kanjo_timetable_full.sql** | 愛知環状線時刻表 | 3,948行 | 数秒 |
| **shuttle_schedule_fy2025.sql** | 運行日程 | 365日分 | 秒単位 |

**合計実行時間**: 約15〜30秒

---

## 🔍 トラブルシューティング

### エラー1：「setup.sql が見つかりません」

```
✗ エラー：setup.sql が見つかりません。
```

**解決方法:**
```bash
cd /Applications/MAMP/htdocs/DC-Exercise/sql
ls -la setup.sql
```

ファイルが存在するか確認してください。

### エラー2：「MySQLに接続できません」

```
✗ エラー：MySQLに接続できません。パスワードを確認してください。
```

**解決方法:**
1. MAMPでMySQLが起動しているか確認
2. MySQLのrootパスワードを確認
3. `mysql -u root -p` で直接接続テスト

### エラー3：「migration_to_option_b.sql が見つかりません」

**解決方法:**
前のセットアップが完了していない可能性があります。

```bash
cd /Applications/MAMP/htdocs/DC-Exercise/sql
ls -la migration_to_option_b.sql
```

### エラー4：データが少ない（5,290件ではなく0件など）

**原因:** linimo_*.sql ファイルが実行されていない

**解決方法:**
1. マイグレーションスクリプトを削除
2. リセット（setup.sqlで初期化）
3. linimo_*.sql（4つ）を最初に実行
4. migration_to_option_b.sql を実行

```bash
# リセット
mysql -u root -p -e "DROP DATABASE ait_transport;"

# 正しい順序で実行
mysql -u root -p < setup.sql
mysql -u root -p ait_transport < linimo_weekday_to_fujigaoka.sql
# ... 他の3つ ...
mysql -u root -p ait_transport < migration_to_option_b.sql
```

---

## 📚 追加資料

- **DATA_SOURCES.md** - すべてのデータの出所と詳細説明
- **AICHI_KANJO_INTEGRATION.md** - 技術的な実装詳細
- **CLAUDE.md** - プロジェクト全体の概要

---

## 🌐 動作確認

セットアップ完了後、以下でテストしてください：

1. **ブラウザで開く**
   ```
   http://localhost:8888/DC-Exercise/
   ```

2. **ラジオボタンで路線選択**
   - 🏫 大学 → 🚃 リニモ駅
   - 🚃 リニモ駅 → 🏫 大学
   - 🏫 大学 → 🚆 愛知環状線駅
   - 🚆 愛知環状線駅 → 🏫 大学

3. **出発地/目的地を選択して検索**

4. **結果が表示されることを確認**

---

## 💡 よくある質問

### Q1：再度セットアップ（リセット）する場合は？

```bash
mysql -u root -p -e "DROP DATABASE ait_transport;"
./run_all_migrations.sh
```

### Q2：データを追加/更新したい場合は？

新しいSQLファイルを作成して実行:
```bash
mysql -u root -p ait_transport < new_data.sql
```

### Q3：特定の路線だけセットアップしたい場合は？

手動実行（方法B）を使用して、必要なファイルのみ実行してください。

### Q4：linimo_*.sql ファイルが見つからない場合は？

これらのファイルは必須です。Git リポジトリから取得してください：
```bash
git pull origin main
ls -la sql/linimo_*.sql
```

---

**セットアップ完了後**, ブラウザで動作確認を行ってください！

🎉 **Happy Path を楽しんでね!**

---

**最終更新**: 2025年10月30日
**バージョン**: 1.0
