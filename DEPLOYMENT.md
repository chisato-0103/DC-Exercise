# EC2 デプロイメントガイド

このドキュメントは、本アプリケーションを AWS EC2 にデプロイする際の重要な設定情報を記載しています。

## 前提条件

- Ubuntu 環境の EC2 インスタンス
- Apache + PHP + MySQL がセットアップ済み
- GitHub Actions による自動デプロイが有効

## 必須：.env ファイルの設定

### 重要 ⚠️

**EC2 に `.env` ファイルが存在しないと、アプリケーションは MySQL に接続できません。**

### .env ファイルの作成

EC2 にログインして以下を実行してください：

```bash
sudo tee /var/www/html/.env > /dev/null << 'EOF'
# Database Configuration for EC2
DB_HOST=localhost
DB_PORT=3306
DB_NAME=ait_transport
DB_USER=root
DB_PASS=rootpass123
EOF

# パーミッション設定
sudo chmod 644 /var/www/html/.env
sudo chown www-data:www-data /var/www/html/.env
```

### .env ファイルの確認

```bash
cat /var/www/html/.env
```

出力例：
```
# Database Configuration for EC2
DB_HOST=localhost
DB_PORT=3306
DB_NAME=ait_transport
DB_USER=root
DB_PASS=rootpass123
```

## トラブルシューティング

### 「表示可能な乗り継ぎルートがありません」というエラーが出る

原因：MySQL に接続できていない可能性があります。

**確認方法：**

```bash
# PHP で接続テスト
php -r "
require_once '/var/www/html/config/database.php';
try {
    \$pdo = getDbConnection();
    echo 'Database connection: OK\n';
} catch (Exception \$e) {
    echo 'Error: ' . \$e->getMessage() . '\n';
}
"
```

**解決方法：**

1. `.env` ファイルが存在するか確認
   ```bash
   ls -la /var/www/html/.env
   ```

2. `.env` ファイルのパーミッションを確認
   ```bash
   stat /var/www/html/.env
   ```
   - `Access: (0644/-rw-r--r--)` であることを確認

3. `.env` の内容が正しいか確認
   ```bash
   cat /var/www/html/.env
   ```

4. MySQL が起動しているか確認
   ```bash
   sudo systemctl status mysql
   sudo systemctl start mysql  # 起動していなければ開始
   ```

5. MySQL にアクセス可能か確認
   ```bash
   mysql -h localhost -u root -prootpass123 ait_transport -e "SELECT COUNT(*) FROM shuttle_bus_timetable;"
   ```

### 自動デプロイ後に接続できなくなった

**原因：** GitHub Actions でプルされた時に `.env` ファイルが上書きされた可能性があります。

`.env` ファイルは `.gitignore` に記載されているため、Git には含まれません。ただし、以前削除されていた場合は再作成が必要です。

**解決方法：**

上記の「.env ファイルの作成」セクションを参照して、再度 `.env` を作成してください。

## 環境変数の説明

| 変数 | 説明 | EC2 の値 | MAMP の値 |
|------|------|---------|---------|
| `DB_HOST` | MySQL ホスト | `localhost` | `localhost` |
| `DB_PORT` | MySQL ポート | `3306` | `8889` |
| `DB_NAME` | データベース名 | `ait_transport` | `ait_transport` |
| `DB_USER` | MySQL ユーザー | `root` | `root` |
| `DB_PASS` | MySQL パスワード | `rootpass123` | `root` |

## GitHub Actions デプロイフロー

1. ローカルで変更をコミット・プッシュ
2. GitHub Actions が自動実行
3. EC2 にコード がプル
4. Web サーバーが自動リロード
5. `.env` ファイル は Git に含まれないため、EC2 の既存 `.env` が保持される ✅

## 新しい Claude Code セッション開始時

新しく Claude Code を起動した際は、以下を確認してください：

```bash
# EC2 に .env が存在するか確認
ssh ubuntu@<EC2_IP>
cat /var/www/html/.env

# なければ、上記の「.env ファイルの作成」セクションを実行
```

## セキュリティに関する注意

- `.env` ファイルには本番パスワードが含まれているため、絶対に Git にコミットしないでください
- `.gitignore` に `.env` が記載されていることを確認してください
- `.env.example` をテンプレートとして管理し、本番パスワードは記載しないでください

## 参考リンク

- [config/database.php](./config/database.php) - データベース接続設定
- [.env.example](./.env.example) - 環境変数のテンプレート
- [.gitignore](./.gitignore) - Git 除外設定
