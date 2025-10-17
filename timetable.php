<?php
/**
 * 時刻表ページ
 */

require_once __DIR__ . '/config/settings.php';
require_once __DIR__ . '/includes/functions.php';
require_once __DIR__ . '/includes/db_functions.php';

// パラメータ取得
$type = $_GET['type'] ?? 'shuttle'; // shuttle or linimo
$diaType = $_GET['dia'] ?? getCurrentDiaType();
$direction = $_GET['direction'] ?? 'to_university';
$dayType = $_GET['day_type'] ?? getCurrentDayType();
$stationCode = $_GET['station'] ?? 'yagusa';

// シャトルバスの時刻表を取得
function getShuttleTimetable($direction, $diaType) {
    try {
        $pdo = getDbConnection();
        $sql = "SELECT * FROM shuttle_bus_timetable
                WHERE direction = :direction
                AND dia_type = :dia_type
                AND is_active = 1
                ORDER BY departure_time ASC";

        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':direction', $direction, PDO::PARAM_STR);
        $stmt->bindValue(':dia_type', $diaType, PDO::PARAM_STR);
        $stmt->execute();

        return $stmt->fetchAll();
    } catch (PDOException $e) {
        logError('Failed to get shuttle timetable', $e);
        return [];
    }
}

// リニモの時刻表を取得
function getLinimoTimetable($stationCode, $direction, $dayType) {
    try {
        $pdo = getDbConnection();
        $sql = "SELECT * FROM linimo_timetable
                WHERE station_code = :station_code
                AND direction = :direction
                AND day_type = :day_type
                AND is_active = 1
                ORDER BY departure_time ASC";

        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':station_code', $stationCode, PDO::PARAM_STR);
        $stmt->bindValue(':direction', $direction, PDO::PARAM_STR);
        $stmt->bindValue(':day_type', $dayType, PDO::PARAM_STR);
        $stmt->execute();

        return $stmt->fetchAll();
    } catch (PDOException $e) {
        logError('Failed to get linimo timetable', $e);
        return [];
    }
}

// 時刻を時間ごとにグループ化
function groupByHour($timetable) {
    $grouped = [];
    foreach ($timetable as $entry) {
        $hour = (int)date('G', strtotime($entry['departure_time']));
        if (!isset($grouped[$hour])) {
            $grouped[$hour] = [];
        }
        $grouped[$hour][] = date('i', strtotime($entry['departure_time']));
    }
    ksort($grouped);
    return $grouped;
}

$timetableData = [];
if ($type === 'shuttle') {
    $timetableData = getShuttleTimetable($direction, $diaType);
} elseif ($type === 'linimo') {
    $timetableData = getLinimoTimetable($stationCode, $direction, $dayType);
}

$groupedTimetable = groupByHour($timetableData);

// ダイヤ種別の説明
global $DIA_TYPE_DESCRIPTIONS, $DAY_TYPE_DESCRIPTIONS;
$diaDescription = $DIA_TYPE_DESCRIPTIONS[$diaType] ?? '';
$dayDescription = $DAY_TYPE_DESCRIPTIONS[$dayType] ?? '';
?>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>時刻表 - 愛工大交通情報システム</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        .timetable-controls {
            background-color: var(--white);
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: var(--shadow);
        }
        .timetable-controls form {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            align-items: flex-end;
        }
        .timetable-table {
            background-color: var(--white);
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: var(--shadow);
            overflow-x: auto;
        }
        .timetable-table table {
            width: 100%;
            border-collapse: collapse;
        }
        .timetable-table th {
            background-color: var(--primary-color);
            color: var(--white);
            padding: 0.75rem;
            text-align: left;
            font-weight: bold;
        }
        .timetable-table td {
            padding: 0.75rem;
            border-bottom: 1px solid var(--border-color);
        }
        .timetable-table tr:hover {
            background-color: #f8f9fa;
        }
        .hour-cell {
            font-weight: bold;
            font-size: 1.2rem;
            color: var(--primary-color);
            vertical-align: top;
            width: 60px;
        }
        .minutes-cell {
            font-family: monospace;
            line-height: 1.8;
        }
        .dia-info {
            background-color: #e7f3ff;
            padding: 0.75rem;
            border-radius: 4px;
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <!-- ヘッダー -->
    <header class="header">
        <h1>愛工大交通情報システム</h1>
        <p>時刻表</p>
    </header>

    <div class="container">
        <!-- 時刻表コントロール -->
        <section class="timetable-controls">
            <form method="GET" action="timetable.php">
                <div class="form-group">
                    <label for="type">種別</label>
                    <select name="type" id="type">
                        <option value="shuttle" <?php echo $type === 'shuttle' ? 'selected' : ''; ?>>シャトルバス</option>
                        <option value="linimo" <?php echo $type === 'linimo' ? 'selected' : ''; ?>>リニモ</option>
                    </select>
                </div>

                <?php if ($type === 'shuttle'): ?>
                <div class="form-group">
                    <label for="dia">ダイヤ</label>
                    <select name="dia" id="dia">
                        <option value="A" <?php echo $diaType === 'A' ? 'selected' : ''; ?>>Aダイヤ（授業期間平日）</option>
                        <option value="B" <?php echo $diaType === 'B' ? 'selected' : ''; ?>>Bダイヤ（土曜日）</option>
                        <option value="C" <?php echo $diaType === 'C' ? 'selected' : ''; ?>>Cダイヤ（学校休業期間）</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="direction">方向</label>
                    <select name="direction" id="direction">
                        <option value="to_university" <?php echo $direction === 'to_university' ? 'selected' : ''; ?>>八草駅 → 大学</option>
                        <option value="to_yagusa" <?php echo $direction === 'to_yagusa' ? 'selected' : ''; ?>>大学 → 八草駅</option>
                    </select>
                </div>
                <?php elseif ($type === 'linimo'): ?>
                <div class="form-group">
                    <label for="station">駅</label>
                    <select name="station" id="station">
                        <option value="yagusa" <?php echo $stationCode === 'yagusa' ? 'selected' : ''; ?>>八草</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="direction">方向</label>
                    <select name="direction" id="direction">
                        <option value="to_fujigaoka" <?php echo $direction === 'to_fujigaoka' ? 'selected' : ''; ?>>藤が丘方面</option>
                        <option value="to_yagusa" <?php echo $direction === 'to_yagusa' ? 'selected' : ''; ?>>八草方面</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="day_type">曜日種別</label>
                    <select name="day_type" id="day_type">
                        <option value="weekday_green" <?php echo $dayType === 'weekday_green' ? 'selected' : ''; ?>>平日（緑時刻）</option>
                        <option value="holiday_red" <?php echo $dayType === 'holiday_red' ? 'selected' : ''; ?>>休日（赤時刻）</option>
                    </select>
                </div>
                <?php endif; ?>

                <button type="submit" class="btn btn-primary">表示</button>
            </form>
        </section>

        <!-- 時刻表表示 -->
        <section class="timetable-table">
            <?php if ($type === 'shuttle'): ?>
                <div class="dia-info">
                    <strong><?php echo h($diaType); ?>ダイヤ</strong>: <?php echo h($diaDescription); ?><br>
                    <strong>方向</strong>: <?php echo $direction === 'to_university' ? '八草駅 → 愛知工業大学' : '愛知工業大学 → 八草駅'; ?><br>
                    <strong>所要時間</strong>: 約5分
                </div>

                <?php if (empty($groupedTimetable)): ?>
                    <div class="error-message">
                        時刻表データがありません。
                    </div>
                <?php else: ?>
                    <table>
                        <thead>
                            <tr>
                                <th>時</th>
                                <th>分</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($groupedTimetable as $hour => $minutes): ?>
                            <tr>
                                <td class="hour-cell"><?php echo h($hour); ?></td>
                                <td class="minutes-cell">
                                    <?php echo h(implode(', ', $minutes)); ?>
                                </td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php endif; ?>
            <?php elseif ($type === 'linimo'): ?>
                <div class="dia-info">
                    <strong>駅</strong>: <?php echo h(getStationName($stationCode)); ?><br>
                    <strong>方向</strong>: <?php echo $direction === 'to_fujigaoka' ? '藤が丘方面' : '八草方面'; ?><br>
                    <strong>曜日種別</strong>: <?php echo h($dayDescription); ?>
                </div>

                <?php if (empty($groupedTimetable)): ?>
                    <div class="error-message">
                        時刻表データがありません。
                    </div>
                <?php else: ?>
                    <table>
                        <thead>
                            <tr>
                                <th>時</th>
                                <th>分</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($groupedTimetable as $hour => $minutes): ?>
                            <tr>
                                <td class="hour-cell"><?php echo h($hour); ?></td>
                                <td class="minutes-cell">
                                    <?php echo h(implode(', ', $minutes)); ?>
                                </td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                <?php endif; ?>
            <?php endif; ?>
        </section>

        <!-- ナビゲーションボタン -->
        <div class="nav-buttons">
            <a href="index.php" class="btn btn-secondary">トップに戻る</a>
        </div>
    </div>

    <!-- フッター -->
    <footer class="footer">
        <p>&copy; 2025 愛知工業大学 交通情報システム</p>
        <p style="font-size: 0.85em; margin-top: 8px;">
            <strong>免責事項：</strong>本システムは愛知工業大学の学生向け通学支援を目的とした非営利の情報提供サービスです。<br>
            時刻表データは公開情報を参考にしていますが、実際の運行状況と異なる場合があります。<br>
            正確な時刻は<a href="https://www.linimo.jp/" target="_blank" rel="noopener">リニモ公式サイト</a>でご確認ください。
        </p>
    </footer>
</body>
</html>
