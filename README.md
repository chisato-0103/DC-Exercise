# 愛知工業大学 交通情報システム

愛知工業大学のシャトルバスとリニモの時刻表・乗り継ぎ情報を一目でわかりやすく表示するWebアプリケーションです。

## 概要

このシステムは、愛知工業大学の学生・教職員・来訪者が、シャトルバスとリニモの乗り継ぎ情報を簡単に検索できるように設計されています。現在時刻から最適な乗り継ぎルートを自動で表示し、待ち時間を最小化します。

## 主な機能

- **次の便表示**: 現在時刻から次に乗れる便を自動表示
- **乗り継ぎ最適化**: 待ち時間が最小となるルートを計算
- **双方向検索**: 大学→リニモ各駅 / リニモ各駅→大学
- **ダイヤ自動判定**: A/B/Cダイヤを日付・曜日から自動判定
- **運行情報**: 運休・遅延情報の表示（手動更新）
- **レスポンシブUI**: スマホ・タブレット・PC対応

## 対象範囲（Phase 1）

- **シャトルバス**: 八草駅 ⇔ 愛知工業大学
- **リニモ**: 八草駅 〜 藤が丘駅間の各駅

## 技術スタック

- **フロントエンド**: HTML5, CSS3, JavaScript (Vanilla)
- **バックエンド**: PHP 7.4以上
- **データベース**: MySQL 5.7以上
- **開発環境**: MAMP (Mac, Apache, MySQL, PHP)
- **バージョン管理**: Git

## ディレクトリ構成

```
/DC-Exercise/
├── index.html             # トップページ（SPA）
├── api/                   # バックエンドAPI
│   ├── get_next_connection.php    # 次の便取得
│   ├── search_connection.php      # 乗り継ぎ検索
│   ├── get_stations.php           # 駅リスト取得
│   └── get_notices.php            # お知らせ取得
├── config/
│   ├── database.php       # DB接続設定
│   └── settings.php       # システム設定（ダイヤ自動判定含む）
├── includes/
│   ├── functions.php      # 共通関数
│   └── db_functions.php   # DB操作関数
├── assets/
│   ├── css/
│   │   └── style.css      # スタイルシート
│   └── js/
│       ├── api.js         # API通信モジュール
│       ├── app.js         # 共通処理（折りたたみ、カウントダウンなど）
│       └── index.js       # トップページ用ロジック
└── sql/                   # DB初期化・データ投入スクリプト
    ├── setup.sql
    ├── complete_shuttle_a.sql
    ├── complete_shuttle_bc.sql
    └── complete_linimo_*.sql
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

# SQLファイルの実行
mysql -u root -p ait_transport < sql/setup.sql
```

### 3. 設定ファイルの編集

`config/database.php` を編集し、データベース接続情報を設定してください。

```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'ait_transport');
define('DB_USER', 'your_username');
define('DB_PASS', 'your_password');
```

### 4. サーバーの起動

MAMPを使用する場合は、MAMPを起動し、プロジェクトフォルダをドキュメントルートに設定してください。

## 使い方

1. ブラウザで `http://localhost:8888/DC-Exercise/index.html` にアクセス
2. トップ画面で次の便の情報が自動表示されます
3. 「ルート検索」セクションで目的地を選択して検索可能
4. ダイヤは日付・曜日から自動判定されます

## 開発ロードマップ

### Phase 1（完了）✅
- ✅ シャトルバス（八草⇔大学）
- ✅ リニモ（八草〜藤が丘、全9駅）
- ✅ 双方向乗り継ぎ検索
- ✅ 次の便自動表示
- ✅ ダイヤ自動判定（A/B/C）
- ✅ お知らせ表示機能
- ✅ フロント/バックエンド分離
- ✅ モバイルファーストUI

### Phase 2（将来実装予定）
- 管理画面（お知らせ・設定管理）
- 愛知環状線の追加

## 詳細設計

詳細な設計については [CLAUDE.md](CLAUDE.md) を参照してください。

## デプロイ方法

### ローカル環境（開発）
```
http://localhost:8888/DC-Exercise/index.html
```

### 本番環境へのデプロイ

#### オプション1: レンタルサーバー（推奨）

**無料PHPホスティング:**
- **InfinityFree**: https://infinityfree.net/
- **000webhost**: https://www.000webhost.com/

**手順:**
1. FTPクライアント（FileZilla等）でファイルをアップロード
2. phpMyAdminでデータベースをセットアップ
3. `config/database.php` を本番環境用に編集

#### オプション2: VPS/クラウド

**推奨サービス:**
- さくらのVPS（月額1,000円〜）
- AWS EC2（無料枠あり）
- Google Cloud Platform

**必要な設定:**
```bash
# Apache + PHP + MySQLのインストール
sudo apt update
sudo apt install apache2 php mysql-server

# プロジェクトのデプロイ
cd /var/www/html
git clone [your-repo-url]

# データベースのセットアップ
mysql -u root -p < sql/setup.sql
mysql -u root -p < sql/complete_shuttle_a.sql
mysql -u root -p < sql/complete_shuttle_bc.sql
mysql -u root -p < sql/complete_linimo_all_stations_*.sql
```

#### オプション3: Dockerコンテナ（高度）

```dockerfile
# Dockerfile例
FROM php:8.1-apache
RUN docker-php-ext-install pdo pdo_mysql
COPY . /var/www/html/
```

## 著作権・免責事項

### データソースについて

本システムで使用している時刻表データは以下の公開情報を参考にしています：
- リニモ（愛知高速交通）公式サイト
- 愛知工業大学シャトルバス時刻表

### 法的な位置づけ

1. **教育目的の非営利利用**
   - 本システムは愛知工業大学の学生向け通学支援を目的とした非営利サービスです
   - 時刻データ自体は事実情報であり、著作権の対象外です（判例: 昭和6年7月24日）

2. **データの取り扱い**
   - 時刻データは手動で転記・入力しています（自動スクレイピングは行っていません）
   - データの正確性は保証できません。公式サイトで最新情報をご確認ください

3. **免責事項**
   - 本システムの利用により生じた損害について、開発者は一切の責任を負いません
   - 時刻表は予告なく変更される場合があります
   - 遅延・運休等のリアルタイム情報は反映されません

### 連絡先

時刻表データの利用に関するお問い合わせ：
- **リニモ**: 愛知高速交通株式会社（TEL: 0561-61-4781）
- **シャトルバス**: 愛知工業大学 学生課

## ライセンス

このプロジェクトは愛知工業大学の学内利用を目的としています。

商業利用、再配布、改変については開発者にご相談ください。

## 参考資料

- [リニモ公式サイト](https://www.linimo.jp/)
- [愛知工業大学公式サイト](https://www.ait.ac.jp/)

## 謝辞

本システムの開発にあたり、公共交通機関の時刻表情報を参考にさせていただきました。
学生の通学支援という公益目的のため、ご理解いただけますと幸いです。
