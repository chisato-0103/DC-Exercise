<?php
/**
 * 乗り継ぎ検索ページ
 */

require_once __DIR__ . '/config/settings.php';
require_once __DIR__ . '/includes/functions.php';
require_once __DIR__ . '/includes/db_functions.php';

// パラメータ取得
$direction = $_GET['direction'] ?? 'to_station'; // to_station or to_university
$from = $_GET['from'] ?? '';
$to = $_GET['to'] ?? '';
$time = $_GET['time'] ?? getCurrentTime();

// 現在時刻
$currentDateTime = date('Y年n月j日 H:i:s');

// お知らせを取得
$notices = getActiveNotices('all');

// 全駅リストを取得
$stations = getAllStations();

// 検索実行
$routes = [];
$errorMessage = '';

if (!empty($from) && !empty($to)) {
    if ($direction === 'to_station' && $from === 'university') {
        // 大学→リニモ各駅
        if (isValidStationCode($to)) {
            $routes = calculateUniversityToStation($to, $time);
        } else {
            $errorMessage = '無効な目的地が指定されました。';
        }
    } elseif ($direction === 'to_university' && $to === 'university') {
        // リニモ各駅→大学
        if (isValidStationCode($from)) {
            $routes = calculateStationToUniversity($from, $time);
        } else {
            $errorMessage = '無効な出発地が指定されました。';
        }
    } else {
        $errorMessage = '現在、この区間の検索には対応していません。';
    }
}
?>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>乗り継ぎ検索 - 愛工大交通情報システム</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <!-- ヘッダー -->
    <header class="header">
        <h1>愛工大交通情報システム</h1>
        <p>乗り継ぎ検索</p>
    </header>

    <div class="container">
        <!-- お知らせエリア -->
        <?php if (!empty($notices)): ?>
        <section class="notices">
            <h2>📢 運行情報・お知らせ</h2>
            <?php foreach ($notices as $notice): ?>
            <div class="notice-item <?php echo $notice['notice_type'] === 'suspension' ? 'danger' : ($notice['notice_type'] === 'delay' ? 'warning' : ''); ?>">
                <div class="notice-title"><?php echo h($notice['title']); ?></div>
                <div class="notice-content"><?php echo h($notice['content']); ?></div>
            </div>
            <?php endforeach; ?>
        </section>
        <?php endif; ?>

        <!-- 検索フォーム -->
        <section class="search-area">
            <form class="search-form" method="GET" action="search.php">
                <div class="form-group">
                    <label for="direction">方向</label>
                    <select name="direction" id="direction">
                        <option value="to_station" <?php echo $direction === 'to_station' ? 'selected' : ''; ?>>大学 → リニモ各駅</option>
                        <option value="to_university" <?php echo $direction === 'to_university' ? 'selected' : ''; ?>>リニモ各駅 → 大学</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="from">出発地</label>
                    <select name="from" id="from">
                        <option value="university" <?php echo $from === 'university' ? 'selected' : ''; ?>>愛知工業大学</option>
                        <?php foreach ($stations as $station): ?>
                            <?php if ($station['station_code'] !== 'yagusa'): ?>
                            <option value="<?php echo h($station['station_code']); ?>"
                                    <?php echo $from === $station['station_code'] ? 'selected' : ''; ?>>
                                <?php echo h($station['station_name']); ?>
                            </option>
                            <?php endif; ?>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div class="form-group">
                    <label for="to">目的地</label>
                    <select name="to" id="to">
                        <option value="university" <?php echo $to === 'university' ? 'selected' : ''; ?>>愛知工業大学</option>
                        <?php foreach ($stations as $station): ?>
                            <?php if ($station['station_code'] !== 'yagusa'): ?>
                            <option value="<?php echo h($station['station_code']); ?>"
                                    <?php echo $to === $station['station_code'] ? 'selected' : ''; ?>>
                                <?php echo h($station['station_name']); ?>
                            </option>
                            <?php endif; ?>
                        <?php endforeach; ?>
                    </select>
                </div>

                <button type="submit" class="btn btn-primary">検索</button>
            </form>
        </section>

        <!-- 検索結果エリア -->
        <?php if (!empty($from) && !empty($to)): ?>
        <section class="results">
            <div class="current-time">
                現在時刻: <?php echo h($currentDateTime); ?>
            </div>

            <?php if (!empty($errorMessage)): ?>
                <div class="error-message">
                    <strong>エラー</strong>
                    <?php echo h($errorMessage); ?>
                </div>
            <?php elseif (empty($routes)): ?>
                <div class="error-message">
                    <strong>お知らせ</strong>
                    現在、表示可能な乗り継ぎルートがありません。運行時間をご確認ください。
                </div>
            <?php else: ?>
                <div class="route-cards">
                    <?php foreach ($routes as $index => $route): ?>
                    <div class="route-card">
                        <div class="route-header">
                            <span class="route-number">ルート <?php echo $index + 1; ?></span>
                            <span class="route-total-time"><?php echo h($route['total_time']); ?>分</span>
                        </div>

                        <div class="route-steps">
                            <?php if ($direction === 'to_station'): ?>
                                <!-- 大学発 -->
                                <div class="route-step">
                                    <div class="route-step-icon">🏫</div>
                                    <div class="route-step-content">
                                        <div class="route-step-time">愛知工業大学 発 <?php echo h($route['shuttle_departure']); ?></div>
                                        <div class="route-step-detail">シャトルバスで出発</div>
                                    </div>
                                </div>
                                <div class="route-arrow">↓</div>
                                <div class="route-step">
                                    <div class="route-step-icon">🚌</div>
                                    <div class="route-step-content">
                                        <div class="route-step-time">八草駅 着 <?php echo h($route['shuttle_arrival']); ?></div>
                                        <div class="route-step-detail">シャトルバス約5分</div>
                                    </div>
                                </div>
                                <div class="route-arrow">↓</div>
                                <div class="route-step">
                                    <div class="route-step-icon">⏱️</div>
                                    <div class="route-step-content">
                                        <div class="route-step-time">乗り換え時間: <?php echo h($route['transfer_time']); ?>分</div>
                                        <div class="route-step-detail">リニモへ乗り換え</div>
                                    </div>
                                </div>
                                <div class="route-arrow">↓</div>
                                <div class="route-step">
                                    <div class="route-step-icon">🚃</div>
                                    <div class="route-step-content">
                                        <div class="route-step-time">八草駅 発 <?php echo h($route['linimo_departure']); ?></div>
                                        <div class="route-step-detail">リニモで出発</div>
                                    </div>
                                </div>
                                <div class="route-arrow">↓</div>
                                <div class="route-step">
                                    <div class="route-step-icon">🏁</div>
                                    <div class="route-step-content">
                                        <div class="route-step-time"><?php echo h($route['destination_name']); ?> 着 <?php echo h($route['destination_arrival']); ?></div>
                                        <div class="route-step-detail">到着</div>
                                    </div>
                                </div>
                            <?php else: ?>
                                <!-- リニモ駅発 -->
                                <div class="route-step">
                                    <div class="route-step-icon">🏁</div>
                                    <div class="route-step-content">
                                        <div class="route-step-time"><?php echo h($route['origin_name']); ?> 発 <?php echo h($route['origin_departure']); ?></div>
                                        <div class="route-step-detail">リニモで出発</div>
                                    </div>
                                </div>
                                <div class="route-arrow">↓</div>
                                <div class="route-step">
                                    <div class="route-step-icon">🚃</div>
                                    <div class="route-step-content">
                                        <div class="route-step-time">八草駅 着 <?php echo h($route['yagusa_arrival']); ?></div>
                                        <div class="route-step-detail">リニモ</div>
                                    </div>
                                </div>
                                <div class="route-arrow">↓</div>
                                <div class="route-step">
                                    <div class="route-step-icon">⏱️</div>
                                    <div class="route-step-content">
                                        <div class="route-step-time">乗り換え時間: <?php echo h($route['transfer_time']); ?>分</div>
                                        <div class="route-step-detail">シャトルバスへ乗り換え</div>
                                    </div>
                                </div>
                                <div class="route-arrow">↓</div>
                                <div class="route-step">
                                    <div class="route-step-icon">🚌</div>
                                    <div class="route-step-content">
                                        <div class="route-step-time">八草駅 発 <?php echo h($route['shuttle_departure']); ?></div>
                                        <div class="route-step-detail">シャトルバスで出発</div>
                                    </div>
                                </div>
                                <div class="route-arrow">↓</div>
                                <div class="route-step">
                                    <div class="route-step-icon">🏫</div>
                                    <div class="route-step-content">
                                        <div class="route-step-time">愛知工業大学 着 <?php echo h($route['university_arrival']); ?></div>
                                        <div class="route-step-detail">到着</div>
                                    </div>
                                </div>
                            <?php endif; ?>
                        </div>

                        <div class="route-summary">
                            <div class="summary-item">
                                <span class="summary-label">待ち時間</span>
                                <span class="summary-value"><?php echo h($route['waiting_time']); ?>分</span>
                            </div>
                            <div class="summary-item">
                                <span class="summary-label">乗り換え</span>
                                <span class="summary-value"><?php echo h($route['transfer_time']); ?>分</span>
                            </div>
                            <div class="summary-item">
                                <span class="summary-label">総所要時間</span>
                                <span class="summary-value"><?php echo h($route['total_time']); ?>分</span>
                            </div>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </section>
        <?php endif; ?>

        <!-- ナビゲーションボタン -->
        <div class="nav-buttons">
            <a href="index.php" class="btn btn-secondary">トップに戻る</a>
            <a href="timetable.php" class="btn btn-secondary">時刻表を見る</a>
        </div>
    </div>

    <!-- フッター -->
    <footer class="footer">
        <p>&copy; 2025 愛知工業大学 交通情報システム</p>
        <p>シャトルバスとリニモの時刻は変更される場合があります</p>
    </footer>

    <!-- JavaScript -->
    <script src="assets/js/app.js"></script>
</body>
</html>
