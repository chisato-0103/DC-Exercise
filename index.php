<?php
/**
 * トップページ - 次の便表示
 */

require_once __DIR__ . '/config/settings.php';
require_once __DIR__ . '/includes/functions.php';
require_once __DIR__ . '/includes/db_functions.php';

// 方向とパラメータの取得
$direction = $_GET['direction'] ?? 'to_station'; // to_station or to_university
$destination = $_GET['destination'] ?? getSetting('default_destination', DEFAULT_DESTINATION);
$origin = $_GET['origin'] ?? getSetting('default_destination', DEFAULT_DESTINATION);

// 現在時刻
$currentTime = getCurrentTime();
$currentDateTime = date('Y年n月j日 H:i:s');

// お知らせを取得
$notices = getActiveNotices('all');

// 乗り継ぎルートを計算
$routes = [];
if ($direction === 'to_station' && isValidStationCode($destination)) {
    // 大学 → リニモ各駅
    $routes = calculateUniversityToStation($destination, $currentTime);
    $fromName = '愛知工業大学';
    $toName = getStationName($destination);
} elseif ($direction === 'to_university' && isValidStationCode($origin)) {
    // リニモ各駅 → 大学
    $routes = calculateStationToUniversity($origin, $currentTime);
    $fromName = getStationName($origin);
    $toName = '愛知工業大学';
} else {
    $fromName = '愛知工業大学';
    $toName = getStationName($destination);
}

// 全駅リストを取得
$stations = getAllStations();

// 次の便（最初のルート）
$nextRoute = !empty($routes) ? $routes[0] : null;
?>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>愛工大交通情報システム</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
    <!-- ヘッダー -->
    <header class="header">
        <h1>愛工大交通情報システム</h1>
        <p>シャトルバス＆リニモ乗り継ぎ案内</p>
    </header>

    <div class="container">
        <!-- 現在時刻 -->
        <div class="current-time">
            現在時刻: <?php echo h($currentDateTime); ?>
        </div>

        <!-- 次の便 - 大型表示 -->
        <?php if ($nextRoute): ?>
        <div class="next-departure" onclick="this.classList.toggle('expanded')">
            <div class="next-departure-title"><?php echo $direction === 'to_station' ? '次に乗るシャトルバス' : '次に乗るリニモ'; ?></div>
            <div class="next-departure-time"><?php echo h($direction === 'to_station' ? $nextRoute['shuttle_departure'] : $nextRoute['linimo_departure']); ?> 発</div>
            <div class="next-departure-info">
                <?php echo $direction === 'to_station'
                    ? '🏫 ' . h($fromName) . ' → 🚌 八草駅 → 🚃 ' . h($toName)
                    : '🚃 ' . h($fromName) . ' → 🚌 八草駅 → 🏫 ' . h($toName); ?>
            </div>
            <div style="text-align: center;">
                <span class="countdown" id="countdown" data-departure="<?php echo h($direction === 'to_station' ? $nextRoute['shuttle_departure'] : $nextRoute['linimo_departure']); ?>">
                    あと <?php echo h($nextRoute['waiting_time']); ?> 分
                </span>
            </div>
            <div style="text-align: center; margin-top: 0.5rem; opacity: 0.9; font-size: 0.9rem;">
                タップで詳細を表示 ▼
            </div>

            <!-- 詳細ルート（折りたたみ） -->
            <div class="next-departure-details">
                <div style="margin-top: 1rem; padding-top: 1rem; border-top: 1px solid rgba(255,255,255,0.3);">
                    <div class="route-steps" style="color: white;">
                        <?php if ($direction === 'to_station'): ?>
                        <!-- 大学発 -->
                        <div class="route-step">
                            <div class="route-step-icon" style="background-color: rgba(255,255,255,0.2);">🏫</div>
                            <div class="route-step-content">
                                <div class="route-step-time">愛知工業大学 発 <?php echo h($nextRoute['shuttle_departure']); ?></div>
                                <div class="route-step-detail">シャトルバスで出発</div>
                            </div>
                        </div>

                        <div class="route-arrow" style="color: white;">↓</div>

                        <!-- 八草駅着 -->
                        <div class="route-step">
                            <div class="route-step-icon" style="background-color: rgba(255,255,255,0.2);">🚌</div>
                            <div class="route-step-content">
                                <div class="route-step-time">八草駅 着 <?php echo h($nextRoute['shuttle_arrival']); ?></div>
                                <div class="route-step-detail">シャトルバス約5分</div>
                            </div>
                        </div>

                        <div class="route-arrow" style="color: white;">↓</div>

                        <!-- 乗り換え -->
                        <div class="route-step">
                            <div class="route-step-icon" style="background-color: rgba(255,255,255,0.2);">⏱️</div>
                            <div class="route-step-content">
                                <div class="route-step-time">乗り換え時間: <?php echo h($nextRoute['transfer_time']); ?>分</div>
                                <div class="route-step-detail">リニモへ乗り換え</div>
                            </div>
                        </div>

                        <div class="route-arrow" style="color: white;">↓</div>

                        <!-- 八草駅発（リニモ） -->
                        <div class="route-step">
                            <div class="route-step-icon" style="background-color: rgba(255,255,255,0.2);">🚃</div>
                            <div class="route-step-content">
                                <div class="route-step-time">八草駅 発 <?php echo h($nextRoute['linimo_departure']); ?></div>
                                <div class="route-step-detail">リニモで出発</div>
                            </div>
                        </div>

                        <div class="route-arrow" style="color: white;">↓</div>

                        <!-- 目的地着 -->
                        <div class="route-step">
                            <div class="route-step-icon" style="background-color: rgba(255,255,255,0.2);">🏁</div>
                            <div class="route-step-content">
                                <div class="route-step-time"><?php echo h($nextRoute['destination_name']); ?> 着 <?php echo h($nextRoute['destination_arrival']); ?></div>
                                <div class="route-step-detail">到着</div>
                            </div>
                        </div>
                        <?php else: ?>
                        <!-- 駅発（リニモ） -->
                        <div class="route-step">
                            <div class="route-step-icon" style="background-color: rgba(255,255,255,0.2);">🚃</div>
                            <div class="route-step-content">
                                <div class="route-step-time"><?php echo h($nextRoute['origin_name']); ?> 発 <?php echo h($nextRoute['linimo_departure']); ?></div>
                                <div class="route-step-detail">リニモで出発</div>
                            </div>
                        </div>

                        <div class="route-arrow" style="color: white;">↓</div>

                        <!-- 八草駅着（リニモ） -->
                        <div class="route-step">
                            <div class="route-step-icon" style="background-color: rgba(255,255,255,0.2);">🚃</div>
                            <div class="route-step-content">
                                <div class="route-step-time">八草駅 着 <?php echo h($nextRoute['linimo_arrival']); ?></div>
                                <div class="route-step-detail">リニモ約<?php echo h($nextRoute['linimo_time']); ?>分</div>
                            </div>
                        </div>

                        <div class="route-arrow" style="color: white;">↓</div>

                        <!-- 乗り換え -->
                        <div class="route-step">
                            <div class="route-step-icon" style="background-color: rgba(255,255,255,0.2);">⏱️</div>
                            <div class="route-step-content">
                                <div class="route-step-time">乗り換え時間: <?php echo h($nextRoute['transfer_time']); ?>分</div>
                                <div class="route-step-detail">シャトルバスへ乗り換え</div>
                            </div>
                        </div>

                        <div class="route-arrow" style="color: white;">↓</div>

                        <!-- 八草駅発（シャトルバス） -->
                        <div class="route-step">
                            <div class="route-step-icon" style="background-color: rgba(255,255,255,0.2);">🚌</div>
                            <div class="route-step-content">
                                <div class="route-step-time">八草駅 発 <?php echo h($nextRoute['shuttle_departure']); ?></div>
                                <div class="route-step-detail">シャトルバスで出発</div>
                            </div>
                        </div>

                        <div class="route-arrow" style="color: white;">↓</div>

                        <!-- 大学着 -->
                        <div class="route-step">
                            <div class="route-step-icon" style="background-color: rgba(255,255,255,0.2);">🏁</div>
                            <div class="route-step-content">
                                <div class="route-step-time">愛知工業大学 着 <?php echo h($nextRoute['shuttle_arrival']); ?></div>
                                <div class="route-step-detail">到着</div>
                            </div>
                        </div>
                        <?php endif; ?>
                    </div>

                    <div class="route-summary" style="background-color: rgba(255,255,255,0.1); border-top-color: rgba(255,255,255,0.3);">
                        <div class="summary-item">
                            <span class="summary-label">待ち時間</span>
                            <span class="summary-value" style="color: white;"><?php echo h($nextRoute['waiting_time']); ?>分</span>
                        </div>
                        <div class="summary-item">
                            <span class="summary-label">乗り換え</span>
                            <span class="summary-value" style="color: white;"><?php echo h($nextRoute['transfer_time']); ?>分</span>
                        </div>
                        <div class="summary-item">
                            <span class="summary-label">総所要時間</span>
                            <span class="summary-value" style="color: white;"><?php echo h($nextRoute['total_time']); ?>分</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php else: ?>
        <div class="error-message">
            <strong>お知らせ</strong>
            現在、表示可能な乗り継ぎルートがありません。運行時間をご確認ください。
        </div>
        <?php endif; ?>

        <!-- お知らせエリア（折りたたみ可能） -->
        <?php if (!empty($notices)): ?>
        <section class="notices collapsible">
            <div class="collapsible-header">
                <span>📢 運行情報・お知らせ</span>
                <span class="collapsible-icon">▼</span>
            </div>
            <div class="collapsible-content">
                <?php foreach ($notices as $notice): ?>
                <div class="notice-item <?php echo $notice['notice_type'] === 'suspension' ? 'danger' : ($notice['notice_type'] === 'delay' ? 'warning' : ''); ?>">
                    <div class="notice-title"><?php echo h($notice['title']); ?></div>
                    <div class="notice-content"><?php echo h($notice['content']); ?></div>
                </div>
                <?php endforeach; ?>
            </div>
        </section>
        <?php endif; ?>

        <!-- ルート検索（折りたたみ可能） -->
        <section class="search-area collapsible">
            <div class="collapsible-header">
                <span>📍 ルート検索</span>
                <span class="collapsible-icon">▼</span>
            </div>
            <div class="collapsible-content">
                <form class="search-form" method="GET" action="index.php">
                    <div class="form-group">
                        <label for="direction">方向を選択</label>
                        <select name="direction" id="direction" onchange="toggleDirectionFields(this.value)">
                            <option value="to_station" <?php echo $direction === 'to_station' ? 'selected' : ''; ?>>🏫 大学 → 🚃 リニモ各駅</option>
                            <option value="to_university" <?php echo $direction === 'to_university' ? 'selected' : ''; ?>>🚃 リニモ各駅 → 🏫 大学</option>
                        </select>
                    </div>

                    <div class="form-group" id="destination-group" style="<?php echo $direction === 'to_university' ? 'display:none;' : ''; ?>">
                        <label for="destination">目的地を選択</label>
                        <select name="destination" id="destination">
                            <?php foreach ($stations as $station): ?>
                                <?php if ($station['station_code'] !== 'yagusa'): // 八草駅は除外 ?>
                                <option value="<?php echo h($station['station_code']); ?>"
                                        <?php echo $destination === $station['station_code'] ? 'selected' : ''; ?>>
                                    <?php echo h($station['station_name']); ?>
                                </option>
                                <?php endif; ?>
                            <?php endforeach; ?>
                        </select>
                    </div>

                    <div class="form-group" id="origin-group" style="<?php echo $direction === 'to_station' ? 'display:none;' : ''; ?>">
                        <label for="origin">出発地を選択</label>
                        <select name="origin" id="origin">
                            <?php foreach ($stations as $station): ?>
                                <?php if ($station['station_code'] !== 'yagusa'): // 八草駅は除外 ?>
                                <option value="<?php echo h($station['station_code']); ?>"
                                        <?php echo $origin === $station['station_code'] ? 'selected' : ''; ?>>
                                    <?php echo h($station['station_name']); ?>
                                </option>
                                <?php endif; ?>
                            <?php endforeach; ?>
                        </select>
                    </div>

                    <button type="submit" class="btn btn-primary">検索</button>
                </form>
            </div>
        </section>

        <script>
        function toggleDirectionFields(direction) {
            const destinationGroup = document.getElementById('destination-group');
            const originGroup = document.getElementById('origin-group');

            if (direction === 'to_station') {
                destinationGroup.style.display = '';
                originGroup.style.display = 'none';
            } else {
                destinationGroup.style.display = 'none';
                originGroup.style.display = '';
            }
        }
        </script>

        <!-- その他のルート -->
        <?php if (count($routes) > 1): ?>
        <section class="results">
            <h3 style="margin-bottom: 1rem; color: var(--primary-color);">他の候補</h3>
            <?php foreach (array_slice($routes, 1) as $index => $route): ?>
            <div class="route-card-compact" onclick="this.classList.toggle('expanded')">
                <div class="route-header">
                    <span class="route-number">ルート <?php echo $index + 2; ?></span>
                    <span class="route-total-time"><?php echo h($route['total_time']); ?>分</span>
                </div>

                <div class="route-quick-info">
                    <span class="route-quick-time">
                        <?php echo $direction === 'to_station' ? '🏫 ' . h($route['shuttle_departure']) : '🚃 ' . h($route['linimo_departure']); ?> 発
                    </span>
                    <span class="expand-icon">▼</span>
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

                    <!-- 八草駅着 -->
                    <div class="route-step">
                        <div class="route-step-icon">🚌</div>
                        <div class="route-step-content">
                            <div class="route-step-time">八草駅 着 <?php echo h($route['shuttle_arrival']); ?></div>
                            <div class="route-step-detail">シャトルバス約5分</div>
                        </div>
                    </div>

                    <div class="route-arrow">↓</div>

                    <!-- 乗り換え -->
                    <div class="route-step">
                        <div class="route-step-icon">⏱️</div>
                        <div class="route-step-content">
                            <div class="route-step-time">乗り換え時間: <?php echo h($route['transfer_time']); ?>分</div>
                            <div class="route-step-detail">リニモへ乗り換え</div>
                        </div>
                    </div>

                    <div class="route-arrow">↓</div>

                    <!-- 八草駅発（リニモ） -->
                    <div class="route-step">
                        <div class="route-step-icon">🚃</div>
                        <div class="route-step-content">
                            <div class="route-step-time">八草駅 発 <?php echo h($route['linimo_departure']); ?></div>
                            <div class="route-step-detail">リニモで出発</div>
                        </div>
                    </div>

                    <div class="route-arrow">↓</div>

                    <!-- 目的地着 -->
                    <div class="route-step">
                        <div class="route-step-icon">🏁</div>
                        <div class="route-step-content">
                            <div class="route-step-time"><?php echo h($route['destination_name']); ?> 着 <?php echo h($route['destination_arrival']); ?></div>
                            <div class="route-step-detail">到着</div>
                        </div>
                    </div>
                    <?php else: ?>
                    <!-- 駅発（リニモ） -->
                    <div class="route-step">
                        <div class="route-step-icon">🚃</div>
                        <div class="route-step-content">
                            <div class="route-step-time"><?php echo h($route['origin_name']); ?> 発 <?php echo h($route['linimo_departure']); ?></div>
                            <div class="route-step-detail">リニモで出発</div>
                        </div>
                    </div>

                    <div class="route-arrow">↓</div>

                    <!-- 八草駅着（リニモ） -->
                    <div class="route-step">
                        <div class="route-step-icon">🚃</div>
                        <div class="route-step-content">
                            <div class="route-step-time">八草駅 着 <?php echo h($route['linimo_arrival']); ?></div>
                            <div class="route-step-detail">リニモ約<?php echo h($route['linimo_time']); ?>分</div>
                        </div>
                    </div>

                    <div class="route-arrow">↓</div>

                    <!-- 乗り換え -->
                    <div class="route-step">
                        <div class="route-step-icon">⏱️</div>
                        <div class="route-step-content">
                            <div class="route-step-time">乗り換え時間: <?php echo h($route['transfer_time']); ?>分</div>
                            <div class="route-step-detail">シャトルバスへ乗り換え</div>
                        </div>
                    </div>

                    <div class="route-arrow">↓</div>

                    <!-- 八草駅発（シャトルバス） -->
                    <div class="route-step">
                        <div class="route-step-icon">🚌</div>
                        <div class="route-step-content">
                            <div class="route-step-time">八草駅 発 <?php echo h($route['shuttle_departure']); ?></div>
                            <div class="route-step-detail">シャトルバスで出発</div>
                        </div>
                    </div>

                    <div class="route-arrow">↓</div>

                    <!-- 大学着 -->
                    <div class="route-step">
                        <div class="route-step-icon">🏁</div>
                        <div class="route-step-content">
                            <div class="route-step-time">愛知工業大学 着 <?php echo h($route['shuttle_arrival']); ?></div>
                            <div class="route-step-detail">到着</div>
                        </div>
                    </div>
                    <?php endif; ?>

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
            </div>
            <?php endforeach; ?>
        </section>
        <?php endif; ?>

        <!-- ナビゲーションボタン -->
        <div class="nav-buttons">
            <a href="search.php" class="btn btn-primary">詳細検索</a>
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
