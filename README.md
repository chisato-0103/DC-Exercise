# 愛知工業大学 交通情報システム

愛知工業大学のシャトルバスとリニモの時刻表・乗り継ぎ情報を一目でわかりやすく表示するWebアプリケーションです。

## 概要

このシステムは、愛知工業大学の学生・教職員・来訪者が、シャトルバスとリニモの乗り継ぎ情報を簡単に検索できるように設計されています。現在時刻から最適な乗り継ぎルートを自動で表示し、待ち時間を最小化します。

## 主な機能

- **次の便表示**: 現在時刻から次に乗れる便を自動表示
- **乗り継ぎ最適化**: 待ち時間が最小となるルートを計算
- **双方向検索**: 大学→リニモ各駅 / リニモ各駅→大学
- **ダイヤ自動判定**: A/B/CダイヤをDB照会で自動判定（運行日程マスタ管理）
- **運行終了時の表示**: 22:00以降に運行終了メッセージと翌日始発情報を自動表示
- **運行情報**: 運休・遅延情報の表示（手動更新）
- **お問い合わせ機能**: ユーザーからのお問い合わせを受け付け
- **レスポンシブUI**: スマホ・タブレット・PC対応

## 対象範囲（Phase 1）

- **シャトルバス**: 八草駅 ⇔ 愛知工業大学
- **リニモ**: 八草駅 〜 藤が丘駅間の各駅

## 技術スタック

| 項目 | 技術 | バージョン |
|------|------|-----------|
| フロントエンド | HTML5, CSS3, JavaScript (Vanilla) | ES6+ |
| バックエンド | PHP | 7.4以上 |
| データベース | MySQL | 5.7以上 |
| サーバー | Apache + MAMP | - |
| バージョン管理 | Git | - |

## ディレクトリ構成

```
/DC-Exercise/
├── index.html             # トップページ（SPA）
├── contact.html           # お問い合わせページ
├── api/                   # バックエンドAPI
│   ├── get_next_connection.php    # 次の便取得
│   ├── search_connection.php      # 乗り継ぎ検索
│   ├── get_stations.php           # 駅リスト取得
│   ├── get_notices.php            # お知らせ取得
│   └── contact_submit.php         # お問い合わせ送信処理
├── config/
│   ├── database.php       # DB接続設定
│   └── settings.php       # システム設定（ダイヤ自動判定など）
├── includes/
│   ├── functions.php      # 共通関数（時刻計算、DB照会ダイヤ判定など）
│   └── db_functions.php   # DB操作関数（検索、乗り継ぎ計算など）
├── assets/
│   ├── css/
│   │   └── style.css      # スタイルシート
│   └── js/
│       ├── api.js         # API通信モジュール
│       ├── app.js         # 共通処理（折りたたみ、カウントダウン）
│       └── index.js       # トップページ用ロジック
└── sql/                   # DB初期化・データ投入スクリプト
    ├── setup.sql                  # テーブル作成
    ├── complete_shuttle_a.sql     # シャトルバスAダイヤ
    ├── complete_shuttle_bc.sql    # シャトルバスB/Cダイヤ
    ├── shuttle_schedule_fy2025.sql # 運行日程マスタ（FY2025）
    ├── linimo_weekday_to_fujigaoka.sql
    ├── linimo_weekday_to_yagusa.sql
    ├── linimo_holiday_to_fujigaoka.sql
    ├── linimo_holiday_to_yagusa.sql
    └── create_contacts_table.sql  # お問い合わせテーブル
```

### アーキテクチャ

- **フロントエンド**: 静的HTML + Vanilla JavaScript（フレームワークレス）
- **バックエンド**: PHP REST API
- **データ取得**: JavaScriptからAPIを非同期呼び出し
- **セキュリティ**: フロント/バックエンド分離、プリペアドステートメント、XSS対策

## セットアップ

### 1. 環境要件

- PHP 7.4以上
- MySQL 5.7以上
- Apache Webサーバー
- MAMP（推奨）

### 2. データベースのセットアップ

```bash
# MySQLにログイン
mysql -u root -p

# データベースの作成
CREATE DATABASE ait_transport;

# SQLファイルの実行（実行順序は重要）
mysql -u root -p ait_transport < sql/setup.sql
mysql -u root -p ait_transport < sql/complete_shuttle_a.sql
mysql -u root -p ait_transport < sql/complete_shuttle_bc.sql
mysql -u root -p ait_transport < sql/shuttle_schedule_fy2025.sql
mysql -u root -p ait_transport < sql/linimo_weekday_to_fujigaoka.sql
mysql -u root -p ait_transport < sql/linimo_weekday_to_yagusa.sql
mysql -u root -p ait_transport < sql/linimo_holiday_to_fujigaoka.sql
mysql -u root -p ait_transport < sql/linimo_holiday_to_yagusa.sql
mysql -u root -p ait_transport < sql/create_contacts_table.sql
```

### 3. 設定ファイルの編集

**ローカル開発環境（MAMP）の場合:**

`.env` ファイルを作成するか、環境変数を設定してください。`config/database.php` は自動的に環境変数またはデフォルト値を使用します。

```
DB_HOST=localhost
DB_PORT=8889
DB_NAME=ait_transport
DB_USER=root
DB_PASS=root
```

**本番環境（AWS EC2など）の場合:**

`.env` ファイルに実際の接続情報を設定してください。

```
DB_HOST=your_db_host
DB_PORT=3306
DB_NAME=ait_transport
DB_USER=your_username
DB_PASS=your_password
```

### 4. サーバーの起動

MAMPを使用する場合は、MAMPを起動し、プロジェクトフォルダをドキュメントルートに設定してください。

## アクセス方法

### ローカル開発環境
```
http://localhost:8888/DC-Exercise/index.html
```

### 本番環境（AWS EC2）
```
https://ait-traffic.ddns.net/
```

⚠️ **重要**: 本番環境のサーバーは AWS EC2 上で動作していますが、**常時起動していません**。
サーバーの起動が必要な場合は、開発者にお問い合わせください。

## 使い方

### 基本的な操作

1. **ブラウザでアクセス**
   - ローカル開発環境: `http://localhost:8888/DC-Exercise/index.html`
   - 本番環境: `https://ait-traffic.ddns.net/`

2. **トップ画面で次の便を確認**
   - 現在時刻から次に乗れるシャトルバスとリニモの情報が自動表示されます
   - 「次に乗るシャトルバス」「次に乗るリニモ」など、方向に応じた情報が表示されます
   - カウントダウンタイマーで待ち時間を表示

3. **ルート検索セクションを使用**
   - 「📍 ルート検索」セクションを展開（タップ/クリック）
   - 方向を選択（大学→リニモ各駅 / リニモ各駅→大学）
   - 目的地または出発地を選択
   - 「検索」ボタンをタップ

4. **運行時間外の表示**
   - **朝8時前**: 「⏰ 運行開始前」と本日の初便情報を表示
   - **夜22時以降**: 「🌙 本日の運行は終了しました」と翌日の始発情報を表示

### 自動判定される情報

- **ダイヤ種別（A/B/C）**: 日付・曜日から自動判定
- **翌日のダイヤ**: 運行終了時に翌日のダイヤ種別を自動判定
- **最適な乗り継ぎ**: 待ち時間が最小となるルートを自動計算

## 開発ロードマップ

### Phase 1（完了）✅
- ✅ シャトルバス（八草⇔大学、A/B/Cダイヤ）
- ✅ リニモ（八草〜藤が丘、全9駅、平日/休日）
- ✅ 双方向乗り継ぎ検索
- ✅ 次の便自動表示
- ✅ ダイヤ自動判定（DB照会方式、FY2025運行日程マスタ）
- ✅ 運行終了時の翌日始発表示
- ✅ お知らせ表示機能
- ✅ お問い合わせ機能
- ✅ フロント/バックエンド分離
- ✅ モバイルファーストUI

### Phase 2（将来実装予定）
- 管理画面（お知らせ・設定管理・お問い合わせ参照）
- 複数学年度の運行日程管理
- 愛知環状線の追加

## ドキュメント

### 開発者向け
- **[CLAUDE.md](CLAUDE.md)**: Claude Code用の技術ガイド（技術スタック、データベース設計、API設計）
- **[DESIGN.md](DESIGN.md)**: システム仕様書（実装詳細、アルゴリズム、UI/UX設計）
- **[DEPLOYMENT.md](DEPLOYMENT.md)**: 本番環境へのデプロイ手順

## 著作権・免責事項

### データソースについて

本システムで使用している時刻表データは以下の方法で収集しています：
- **参考情報**: リニモ（愛知高速交通）公式サイトと愛知工業大学シャトルバス時刻表
- **収集方法**: 参考情報を確認した上で、データベースに手動で入力しています（自動スクレイピングではなく）

### 法的な位置づけ

1. **教育目的の非営利利用**
   - 本システムは愛知工業大学の学生向け通学支援を目的とした非営利サービスです
   - 時刻データ自体は事実情報であり、著作権の対象外です（判例: 昭和6年7月24日）

2. **データの取り扱い**
   - 時刻データは参考情報を確認した上で、手動でデータベースに入力しています
   - 定期的な自動更新機能はありません。運行スケジュール変更時は手動でデータを更新する必要があります
   - データの正確性は保証できません。公式サイトで最新情報をご確認ください

3. **免責事項**
   - 本システムの利用により生じた損害について、開発者は一切の責任を負いません
   - 時刻表は予告なく変更される場合があります
   - 遅延・運休等のリアルタイム情報は反映されません

## 参考資料

- [リニモ公式サイト](https://www.linimo.jp/)
- [愛知工業大学公式サイト](https://www.ait.ac.jp/)

## 謝辞

本システムの開発にあたり、公共交通機関の時刻表情報を参考にさせていただきました。
学生の通学支援という公益目的のため、ご理解いただけますと幸いです。
