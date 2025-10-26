# 愛知工業大学 交通情報システム 設計書（最終版）

## 1. システム概要

### 1.1 目的
愛知工業大学のシャトルバスとリニモの時刻表・乗り継ぎ情報を一目でわかりやすく表示し、利用者の待ち時間を最小化するためのWebアプリケーション。

### 1.2 想定ユーザー
- 愛知工業大学を利用する全ての人（学生、教職員、来訪者など）

### 1.3 対象範囲（Phase 1完成版）
- **シャトルバス**: 八草駅 ⇔ 愛知工業大学
- **リニモ**: 八草駅 〜 藤が丘駅間の全9駅

---

## 2. 実装済み機能

### 2.1 主要機能

#### ✅ 2.1.1 トップ画面（次の便表示）
- 現在時刻から「次に乗れる便」を自動表示
- デフォルト目的地：藤が丘駅
- 表示内容：
  - 推奨される乗り継ぎパターン（最大3候補）
  - シャトルバス発車時刻
  - リニモ接続便の発車時刻
  - 到着予定時刻
  - 乗り換え時間
  - 待ち時間のカウントダウン表示

#### ✅ 2.1.2 双方向検索機能
- **大学 → リニモ各駅**
  - 全9駅：八草、陶磁資料館南、愛・地球博記念公園、公園西、芸大通、長久手古戦場、杁ヶ池公園、はなみずき通、藤が丘

- **リニモ各駅 → 大学**
  - 上記の逆方向

#### ✅ 2.1.3 乗り継ぎ最適化機能
- 待ち時間が最小となるシャトルバスとリニモの組み合わせを計算
- 乗り換え時間の考慮（デフォルト：10分）
- 複数の候補を表示（最適な上位3件）

#### ✅ 2.1.4 ダイヤ自動判定
- **Aダイヤ**: 授業期間平日（4-7月、10-1月）
- **Bダイヤ**: 土曜日（通年）
- **Cダイヤ**: 学校休業期間（8-9月、2-3月の平日）
- 日付と曜日から自動判定、画面に表示

#### ✅ 2.1.5 運行情報表示
- お知らせ・運休・遅延情報の表示
- 折りたたみ可能なUI
- 手動更新（DBのnoticesテーブルで管理）

#### ✅ 2.1.6 運行時間外メッセージ
- **運行開始前（8時前）**：
  - メッセージ：「⏰ 運行開始前 本日の運行はまだ開始していません」
  - 本日の初便時刻と方向
  - 本日のダイヤ種別（A/B/C）説明

- **運行終了後（22時以降）**：
  - メッセージ：「🌙 本日の運行は終了しました」
  - 本日の最終便時刻と方向
  - 本日のダイヤ種別（A/B/C）説明
  - 翌日の始発情報：
    - 翌日の始発時刻
    - 翌日の日付（YYYY年MM月DD日形式）
    - 翌日のダイヤ種別（A/B/C）説明
  - セッションカラー：時刻に応じて背景色が変更

### 2.2 非機能要件

#### ✅ 2.2.1 レスポンシブデザイン
- スマートフォン、タブレット、PC対応
- モバイルファーストのUI設計
- 折りたたみ可能なセクション

#### ✅ 2.2.2 パフォーマンス
- 静的HTMLで高速読み込み
- APIは非同期呼び出し
- 1分ごとの自動リロード

#### ✅ 2.2.3 保守性
- フロントエンド/バックエンド完全分離
- REST API設計
- 設定ファイルでパラメータ管理
- コードの可読性・保守性重視

#### ✅ 2.2.4 アクセシビリティ
- 誰でもアクセス可能（認証不要）
- シンプルで直感的なUI
- 大きなボタンとタップしやすいUI

---

## 3. システム構成

### 3.1 技術スタック

| 項目 | 技術 | 備考 |
|------|------|------|
| フロントエンド | HTML5, CSS3, Vanilla JavaScript | フレームワークレス |
| バックエンド | PHP 8.4 | REST API |
| データベース | MySQL 5.7以上 | |
| サーバー環境 | MAMP | Mac, Apache, MySQL, PHP |
| アーキテクチャ | SPA-like | 静的HTML + API呼び出し |

### 3.2 アーキテクチャ

```
[ブラウザ (index.html)]
    ↓ JavaScript (fetch API)
[PHP REST API]
    ↓
[MySQL データベース]
```

**特徴:**
- フロントエンド/バックエンド分離
- セキュリティ境界が明確
- APIの再利用性が高い
- 静的HTMLはキャッシュ可能

### 3.3 ディレクトリ構成

```
/DC-Exercise/
├── index.html             # トップページ（SPA）
├── api/                   # Backend REST APIs
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
│       ├── app.js         # 共通処理（折りたたみ、カウントダウン）
│       └── index.js       # トップページ用ロジック（24KB）
└── sql/                   # DB初期化・データ投入スクリプト
    ├── setup.sql          # テーブル作成
    ├── complete_shuttle_a.sql        # Aダイヤデータ
    ├── complete_shuttle_bc.sql       # B/Cダイヤデータ
    ├── complete_linimo_all_stations_weekday_to_fujigaoka.sql
    ├── complete_linimo_all_stations_weekday_to_yagusa.sql
    ├── complete_linimo_all_stations_holiday_to_fujigaoka.sql
    └── complete_linimo_all_stations_holiday_to_yagusa.sql
```

---

## 4. データベース設計

### 4.1 テーブル構成

#### stations（駅マスタ）
```sql
- id: INT PRIMARY KEY
- station_code: VARCHAR(50) UNIQUE
- station_name: VARCHAR(100)
- station_name_en: VARCHAR(100)
- order_index: INT
- travel_time_from_yagusa: INT  # 八草駅からの所要時間（分）
```

**データ件数**: 9駅

#### shuttle_bus_timetable（シャトルバス時刻表）
```sql
- id: INT PRIMARY KEY
- dia_type: ENUM('A', 'B', 'C')
- direction: ENUM('to_university', 'to_yagusa')
- departure_time: TIME
- arrival_time: TIME
- remarks: TEXT
- is_active: TINYINT(1) DEFAULT 1
```

**データ件数**:
- Aダイヤ: 77件（八草→大学）、77件（大学→八草）
- Bダイヤ: 32件×2方向
- Cダイヤ: 28件×2方向

#### linimo_timetable（リニモ時刻表）
```sql
- id: INT PRIMARY KEY
- station_code: VARCHAR(50)
- direction: ENUM('to_fujigaoka', 'to_yagusa')
- day_type: ENUM('weekday_green', 'holiday_red')
- departure_time: TIME
- is_active: TINYINT(1) DEFAULT 1
```

**データ件数**: 各駅×2方向×2曜日種別 = 約1000件以上

#### notices（お知らせ）
```sql
- id: INT PRIMARY KEY
- notice_type: ENUM('info', 'delay', 'suspension')
- target: ENUM('all', 'shuttle', 'linimo')
- title: VARCHAR(200)
- content: TEXT
- start_date: DATE
- end_date: DATE
- is_active: TINYINT(1) DEFAULT 1
```

#### system_settings（システム設定）
```sql
- id: INT PRIMARY KEY
- setting_key: VARCHAR(100) UNIQUE
- setting_value: TEXT
- description: TEXT
```

**設定項目**:
- transfer_time_minutes: 10
- default_destination: fujigaoka
- result_limit: 3

### 4.2 インデックス設計

```sql
-- 時刻表検索用
CREATE INDEX idx_shuttle_search ON shuttle_bus_timetable(dia_type, direction, departure_time, is_active);
CREATE INDEX idx_linimo_search ON linimo_timetable(station_code, direction, day_type, departure_time, is_active);

-- お知らせ検索用
CREATE INDEX idx_notices_active ON notices(target, is_active, start_date, end_date);
```

---

## 5. API設計

### 5.1 共通仕様

**レスポンス形式**:
```json
{
  "success": true/false,
  "data": { ... },
  "error": "error message" (if applicable)
}
```

**HTTPヘッダー**:
```
Content-Type: application/json; charset=utf-8
Access-Control-Allow-Origin: *
```

### 5.2 エンドポイント一覧

#### GET /api/get_next_connection.php
次の便を取得

**パラメータ**:
- `direction`: "to_station" | "to_university"
- `destination`: 駅コード（direction=to_stationの場合）
- `origin`: 駅コード（direction=to_universityの場合）

**レスポンス例**:
```json
{
  "success": true,
  "data": {
    "current_time": "2025年10月18日 22:50:49",
    "dia_type": "B",
    "dia_description": "土曜日",
    "day_type": "holiday_red",
    "routes": [...],
    "service_info": {...}
  }
}
```

#### GET /api/get_stations.php
駅リストを取得

**レスポンス例**:
```json
{
  "success": true,
  "stations": [
    {
      "station_code": "yagusa",
      "station_name": "八草",
      "travel_time_from_yagusa": 0
    },
    ...
  ]
}
```

#### GET /api/get_notices.php
お知らせを取得

**パラメータ**:
- `type`: "all" | "shuttle" | "linimo"

**レスポンス例**:
```json
{
  "success": true,
  "notices": []
}
```

---

## 6. フロントエンド設計

### 6.1 JavaScript モジュール構成

#### api.js（3.3KB）
- API通信の一元管理
- fetch APIラッパー
- エラーハンドリング

**主要関数**:
```javascript
API.getNextConnection(direction, destination, origin)
API.getStations()
API.getNotices(type)
```

#### app.js（3.6KB）
- 共通ユーティリティ
- カウントダウン表示
- 折りたたみUI
- 自動リロード（1分ごと）

#### index.js（24KB）
- トップページのメインロジック
- ルート情報のレンダリング
- フォーム操作
- HTMLエスケープ処理

### 6.2 セキュリティ対策

#### XSS対策
```javascript
function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return String(text).replace(/[&<>"']/g, m => map[m]);
}
```

全ての動的コンテンツに適用

#### SQLインジェクション対策
```php
$stmt = $pdo->prepare($sql);
$stmt->bindValue(':param', $value, PDO::PARAM_STR);
```

プリペアドステートメント必須

---

## 7. コア アルゴリズム

### 7.1 乗り継ぎ最適化

#### パターンA: 大学 → リニモ各駅
```
1. 現在時刻以降のシャトルバス取得
2. 各バスの八草駅到着時刻を計算
3. 到着時刻+乗り換え時間 以降のリニモを検索
4. 目的地までの所要時間を計算
5. 待ち時間でソート、上位N件を返す
```

#### パターンB: リニモ各駅 → 大学
```
1. 出発駅から八草駅行きのリニモ取得
2. 八草駅到着時刻を計算
3. 到着時刻+乗り換え時間 以降のシャトルバス検索
4. 大学到着時刻を計算
5. 待ち時間でソート、上位N件を返す
```

### 7.2 ダイヤ自動判定ロジック

```php
function getCurrentDiaType() {
    $month = (int)date('n');
    $dayOfWeek = (int)date('w'); // 0=日, 6=土

    // 土曜日 → Bダイヤ
    if ($dayOfWeek === 6) return 'B';

    // 日曜日 → 運行なし（Cダイヤ扱い）
    if ($dayOfWeek === 0) return 'C';

    // 8,9,2,3月の平日 → Cダイヤ
    if (in_array($month, [2, 3, 8, 9])) return 'C';

    // 4-7,10-1月の平日 → Aダイヤ
    return 'A';
}
```

---

## 8. UI/UX設計

### 8.1 モバイルファースト

- 最小幅: 320px（iPhone SE対応）
- タップターゲット: 最低44×44px
- フォントサイズ: 最小14px

### 8.2 カラースキーム

```css
--primary-color: #0066cc;     /* メインカラー */
--secondary-color: #6c757d;   /* サブカラー */
--success-color: #28a745;     /* 成功 */
--danger-color: #dc3545;      /* 警告・エラー */
--white: #ffffff;
--light-gray: #f8f9fa;
--border-color: #dee2e6;
```

### 8.3 折りたたみUI

- お知らせセクション: デフォルト折りたたみ
- ルート検索セクション: デフォルト折りたたみ
- その他のルート候補: クリックで展開

---

## 9. 開発・運用

### 9.1 環境構築

```bash
# MAMP起動
# データベース作成
mysql -u root -p -e "CREATE DATABASE ait_transport;"

# テーブル作成
mysql -u root -p ait_transport < sql/setup.sql

# データ投入
mysql -u root -p ait_transport < sql/complete_shuttle_a.sql
mysql -u root -p ait_transport < sql/complete_shuttle_bc.sql
mysql -u root -p ait_transport < sql/complete_linimo_*.sql
```

### 9.2 データ更新方法

#### 時刻表更新
1. PDFから新しいデータを手動転記
2. SQLスクリプトを作成
3. `mysql -u root -p ait_transport < update.sql`

#### お知らせ追加
```sql
INSERT INTO notices (notice_type, target, title, content, start_date, end_date, is_active)
VALUES ('info', 'all', 'お知らせタイトル', '内容', '2025-10-01', '2025-10-31', 1);
```

### 9.3 保守運用

- **データバックアップ**: 毎日
- **時刻表更新**: ダイヤ改正時（年1-2回）
- **お知らせ更新**: 必要に応じて
- **ログ確認**: Apache error.log

---

## 10. 実装ステータス

### Phase 1（完了）✅
- ✅ シャトルバス（八草⇔大学、A/B/Cダイヤ）
- ✅ リニモ（八草〜藤が丘、全9駅、平日/休日）
- ✅ 双方向乗り継ぎ検索
- ✅ 次の便自動表示
- ✅ ダイヤ自動判定
- ✅ お知らせ表示機能
- ✅ フロント/バックエンド分離
- ✅ モバイルファーストUI
- ✅ カウントダウン表示
- ✅ 運行時間外メッセージ

### Phase 2（将来実装予定）
- 管理画面（お知らせ・設定管理）
- 愛知環状線の追加

---

## 11. パフォーマンス指標

### 11.1 目標値

| 項目 | 目標 | 実測値 |
|------|------|--------|
| 初回ページロード | < 3秒 | ✅ 約1秒 |
| API応答時間 | < 500ms | ✅ 約200ms |
| モバイル対応 | 320px〜 | ✅ 対応 |
| ブラウザ対応 | Modern browsers | ✅ Chrome, Safari, Edge |

### 11.2 最適化施策

- 静的HTMLによる高速配信
- APIは非同期読み込み
- CSSは1ファイルに統合
- JavaScriptは3ファイルに分割（モジュール化）
- 画像なし（絵文字のみ使用）

---

## 12. セキュリティ

### 12.1 実装済み対策

- ✅ プリペアドステートメント（SQLインジェクション対策）
- ✅ HTMLエスケープ（XSS対策）
- ✅ フロント/バックエンド分離
- ✅ 入力値バリデーション
- ✅ エラーメッセージの適切な処理

### 12.2 Phase 2で実装予定

- CSRF対策（管理画面実装時）
- セッション管理
- パスワードハッシュ化

---

## 13. 参考資料

- [リニモ公式サイト](https://www.linimo.jp/)
- [愛知工業大学公式サイト](https://www.ait.ac.jp/)
- [PHP公式ドキュメント](https://www.php.net/docs.php)
- [MDN Web Docs](https://developer.mozilla.org/)

---

**最終更新**: 2025年10月18日
**バージョン**: Phase 1完成版
**作成者**: Claude Code
