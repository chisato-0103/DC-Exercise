# 愛知工業大学 交通情報システム

愛知工業大学のシャトルバスとリニモの時刻表・乗り継ぎ情報を一目でわかりやすく表示するWebアプリケーションです。

## 概要

このシステムは、愛知工業大学の学生・教職員・来訪者が、シャトルバスとリニモの乗り継ぎ情報を簡単に検索できるように設計されています。現在時刻から最適な乗り継ぎルートを自動で表示し、待ち時間を最小化します。

## 主な機能

- **次の便表示**: 現在時刻から次に乗れる便を自動表示
- **乗り継ぎ最適化**: 待ち時間が最小となるルートを計算
- **目的地選択**: リニモ各駅への乗り継ぎ検索
- **時刻表表示**: シャトルバス（A/B/Cダイヤ）とリニモの時刻表
- **運行情報**: 運休・遅延情報の表示

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
/project-root/
├── index.php              # トップページ（次の便表示）
├── timetable.php          # 時刻表表示
├── search.php             # 乗り継ぎ検索結果
├── api/
│   ├── get_next_connection.php    # 次の便取得API
│   ├── search_connection.php      # 乗り継ぎ検索API
│   └── get_timetable.php          # 時刻表取得API
├── config/
│   ├── database.php       # DB接続設定
│   └── settings.php       # システム設定
├── includes/
│   ├── functions.php      # 共通関数
│   └── db_functions.php   # DB操作関数
├── assets/
│   ├── css/
│   │   └── style.css      # スタイルシート
│   └── js/
│       └── app.js         # JavaScriptファイル
└── sql/
    └── setup.sql          # DB初期化スクリプト
```

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

1. ブラウザで `http://localhost/` にアクセス
2. トップ画面で次の便の情報が自動表示されます
3. 目的地を選択して検索することも可能
4. 時刻表を確認したい場合は「時刻表を見る」をクリック

## 開発ロードマップ

### Phase 1（現在）
- シャトルバス（八草⇔大学）
- リニモ（八草〜藤が丘）
- 基本的な乗り継ぎ検索
- 次の便表示
- 時刻表表示

### Phase 2（予定）
- 愛知環状線の追加
- より詳細な乗り継ぎ検索
- お気に入り機能
- 管理画面の実装

### Phase 3（予定）
- 遅延情報の自動取得
- リアルタイム運行情報
- プッシュ通知機能

## 詳細設計

詳細な設計については [design.md](design.md) を参照してください。

## ライセンス

このプロジェクトは愛知工業大学の学内利用を目的としています。

## 参考資料

- [リニモ公式サイト](https://www.linimo.jp/)
- [愛知工業大学公式サイト](https://www.ait.ac.jp/)
