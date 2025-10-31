#!/bin/bash

# ===================================
# 愛知環状線統合 - DB完全セットアップスクリプト
# 実行順序：setup → linimo_*.sql → migration → aichi_kanjo
# ===================================

set -e  # エラーで停止

echo "======================================"
echo "愛知環状線統合 DBセットアップ開始"
echo "======================================"
echo ""
echo "📋 実行順序："
echo "  1. 初期スキーマ作成"
echo "  2. 既存リニモデータ読込（4ファイル）"
echo "  3. オプションBへのマイグレーション"
echo "  4. 愛知環状線駅情報追加"
echo "  5. 愛知環状線時刻表追加"
echo ""

# ユーザー確認
read -p "MySQLのrootパスワードを入力してください: " MYSQL_PASSWORD
echo ""

# データベース接続確認
echo "✓ データベース接続を確認中..."
mysql -u root -p"$MYSQL_PASSWORD" -e "SELECT 1" > /dev/null 2>&1 || {
    echo "✗ エラー：MySQLに接続できません。パスワードを確認してください。"
    exit 1
}
echo "✓ 接続成功"
echo ""

# スクリプトディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# ===================================
# ステップ1：初期スキーマ作成
# ===================================
if [ -f "setup.sql" ]; then
    echo "ステップ1️⃣  初期スキーマを作成中..."
    mysql -u root -p"$MYSQL_PASSWORD" < setup.sql
    echo "✓ 初期スキーマ作成完了"
    echo ""
else
    echo "✗ エラー：setup.sql が見つかりません。"
    exit 1
fi

# ===================================
# ステップ2：既存リニモデータ読込（重要：マイグレーション前に実行）
# ===================================
echo "ステップ2️⃣  既存リニモデータを読み込み中..."
LINIMO_COUNT=0

if [ -f "linimo_weekday_to_fujigaoka.sql" ]; then
    echo "  📥 リニモ（平日→藤が丘）"
    mysql -u root -p"$MYSQL_PASSWORD" ait_transport < linimo_weekday_to_fujigaoka.sql
    ((LINIMO_COUNT++))
fi

if [ -f "linimo_weekday_to_yagusa.sql" ]; then
    echo "  📥 リニモ（平日→八草）"
    mysql -u root -p"$MYSQL_PASSWORD" ait_transport < linimo_weekday_to_yagusa.sql
    ((LINIMO_COUNT++))
fi

if [ -f "linimo_holiday_to_fujigaoka.sql" ]; then
    echo "  📥 リニモ（休日→藤が丘）"
    mysql -u root -p"$MYSQL_PASSWORD" ait_transport < linimo_holiday_to_fujigaoka.sql
    ((LINIMO_COUNT++))
fi

if [ -f "linimo_holiday_to_yagusa.sql" ]; then
    echo "  📥 リニモ（休日→八草）"
    mysql -u root -p"$MYSQL_PASSWORD" ait_transport < linimo_holiday_to_yagusa.sql
    ((LINIMO_COUNT++))
fi

if [ $LINIMO_COUNT -eq 4 ]; then
    echo "✓ リニモデータ読込完了（4ファイル）"
else
    echo "⚠️  警告：4つのリニモファイルのうち $LINIMO_COUNT 個のみ見つかりました"
fi
echo ""

# ===================================
# ステップ3：オプションBマイグレーション
# ===================================
echo "ステップ3️⃣  オプションBマイグレーション実行中..."
if [ -f "migration_to_option_b.sql" ]; then
    mysql -u root -p"$MYSQL_PASSWORD" ait_transport < migration_to_option_b.sql
    echo "✓ マイグレーション完了"
    echo ""
else
    echo "✗ エラー：migration_to_option_b.sql が見つかりません。"
    exit 1
fi

# ===================================
# ステップ4：愛知環状線駅情報追加
# ===================================
echo "ステップ4️⃣  愛知環状線駅情報を追加中..."
if [ -f "aichi_kanjo_stations.sql" ]; then
    mysql -u root -p"$MYSQL_PASSWORD" ait_transport < aichi_kanjo_stations.sql
    echo "✓ 駅情報追加完了"
    echo ""
else
    echo "✗ エラー：aichi_kanjo_stations.sql が見つかりません。"
    exit 1
fi

# ===================================
# ステップ5：愛知環状線時刻表追加（実PDF基づくデータ）
# ===================================
echo "ステップ5️⃣  愛知環状線時刻表を追加中（実PDF基づくデータ）..."
if [ -f "aichi_kanjo_timetable_actual.sql" ]; then
    mysql -u root -p"$MYSQL_PASSWORD" ait_transport < aichi_kanjo_timetable_actual.sql
    echo "✓ 実PDF時刻表追加完了（2,806レコード - 61列車 × 23駅 × 2方向）"
    echo ""
else
    echo "⚠️  警告：aichi_kanjo_timetable_actual.sql が見つかりません。"
    if [ -f "aichi_kanjo_timetable_full.sql" ]; then
        echo "  代替案として full版を使用します..."
        mysql -u root -p"$MYSQL_PASSWORD" ait_transport < aichi_kanjo_timetable_full.sql
        echo "✓ 時刻表追加完了"
        echo ""
    else
        echo "✗ エラー：時刻表ファイルが見つかりません。"
        exit 1
    fi
fi

# ===================================
# ステップ6（オプション）：運行日程データ
# ===================================
echo "シャトルバス運行日程を更新しますか？ (y/n)"
read -p "選択: " UPDATE_SCHEDULE

if [ "$UPDATE_SCHEDULE" = "y" ]; then
    echo ""
    echo "ステップ6️⃣  運行日程を更新中..."

    if [ -f "shuttle_schedule_fy2025.sql" ]; then
        echo "  📅 シャトルバス運行日程（FY2025）"
        mysql -u root -p"$MYSQL_PASSWORD" ait_transport < shuttle_schedule_fy2025.sql
        echo "✓ 運行日程更新完了"
    else
        echo "⚠️  shuttle_schedule_fy2025.sql が見つかりません。スキップします。"
    fi
    echo ""
fi

# ===================================
# 最終確認
# ===================================
echo "======================================"
echo "✓ DBセットアップ完了！"
echo "======================================"
echo ""

# データ確認
echo "📊 データベース統計情報："
mysql -u root -p"$MYSQL_PASSWORD" ait_transport << EOF
SELECT '📍 駅情報' AS category;
SELECT CONCAT('  総駅数: ', COUNT(*)) FROM stations;

SELECT '' AS blank1;
SELECT '🚌 シャトルバス' AS category;
SELECT CONCAT('  時刻表記録数: ', COUNT(*)) FROM shuttle_bus_timetable;

SELECT '' AS blank2;
SELECT '🚃 リニモ・愛知環状線 (rail_timetable)' AS category;
SELECT CONCAT('  ', line_code, ': ', COUNT(*), ' 記録')
FROM rail_timetable
GROUP BY line_code
ORDER BY line_code;

SELECT '' AS blank3;
SELECT '🛣️ 路線マスタ' AS category;
SELECT CONCAT('  登録路線数: ', COUNT(*)) FROM transport_lines;

SELECT '' AS blank4;
SELECT '📈 総データ概要' AS category;
SELECT CONCAT('  総レコード数（rail_timetable）: ', COUNT(*)) FROM rail_timetable;
EOF

echo ""
echo "======================================"
echo "✅ セットアップ完了 - ブラウザでテスト"
echo "======================================"
echo "🌐 http://localhost:8888/DC-Exercise/"
echo ""
echo "📝 実行されたファイル順序："
echo "  1. setup.sql"
echo "  2. linimo_weekday_to_fujigaoka.sql"
echo "  3. linimo_weekday_to_yagusa.sql"
echo "  4. linimo_holiday_to_fujigaoka.sql"
echo "  5. linimo_holiday_to_yagusa.sql"
echo "  6. migration_to_option_b.sql"
echo "  7. aichi_kanjo_stations.sql"
echo "  8. aichi_kanjo_timetable_actual.sql（実PDF基づくデータ）"
echo "======================================"
