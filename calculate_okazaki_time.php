<?php
/**
 * Calculate the actual travel time from yakusa to okazaki
 */

require_once __DIR__ . '/config/database.php';

try {
    $pdo = getDbConnection();

    echo "=== Finding actual travel time from yakusa to okazaki ===\n\n";

    // Get a sample train from yakusa to okazaki
    $stmt = $pdo->prepare("SELECT departure_time FROM rail_timetable
                          WHERE line_code = 'aichi_kanjo'
                          AND station_code = 'yakusa'
                          AND direction = 'to_okazaki'
                          ORDER BY departure_time ASC
                          LIMIT 1");
    $stmt->execute();
    $yakusaData = $stmt->fetch();

    if ($yakusaData) {
        $yakusaDeparture = $yakusaData['departure_time'];
        echo "Sample train departs Yakusa at: $yakusaDeparture\n\n";

        // Find the first station after yakusa and see when it arrives
        // Get all stations in order on the to_okazaki route
        echo "=== Stations on to_okazaki route (in order of departure) ===\n";
        $stmt = $pdo->prepare("SELECT DISTINCT station_code, station_name, departure_time
                              FROM rail_timetable
                              WHERE line_code = 'aichi_kanjo'
                              AND direction = 'to_okazaki'
                              AND departure_time = :time
                              ORDER BY station_code");
        $stmt->bindValue(':time', $yakusaDeparture);
        $stmt->execute();

        $stations = [];
        while ($row = $stmt->fetch()) {
            $stations[] = $row;
            echo "  {$row['station_code']}: {$row['departure_time']}\n";
        }

        echo "\n=== Travel time from yakusa to other stations ===\n";
        foreach ($stations as $station) {
            $stationCode = $station['station_code'];
            if ($stationCode === 'yakusa') continue;

            // Get travel time from stations table
            $stmt = $pdo->prepare("SELECT travel_time_from_yagusa FROM stations WHERE station_code = :code");
            $stmt->bindValue(':code', $stationCode);
            $stmt->execute();
            $stationInfo = $stmt->fetch();

            if ($stationInfo) {
                echo "  $stationCode: {$stationInfo['travel_time_from_yagusa']} minutes from yakusa\n";
            }
        }

        // Now let's check if okazaki is in this list
        $stmt = $pdo->prepare("SELECT COUNT(*) as count FROM rail_timetable
                              WHERE line_code = 'aichi_kanjo'
                              AND direction = 'to_okazaki'
                              AND station_code = 'okazaki'");
        $stmt->execute();
        $okazakiCount = $stmt->fetch();

        echo "\n=== Okazaki on to_okazaki route? ===\n";
        echo "Records: " . $okazakiCount['count'] . "\n";

        if ($okazakiCount['count'] > 0) {
            $stmt = $pdo->prepare("SELECT * FROM rail_timetable
                                  WHERE line_code = 'aichi_kanjo'
                                  AND direction = 'to_okazaki'
                                  AND station_code = 'okazaki'
                                  LIMIT 3");
            $stmt->execute();

            while ($row = $stmt->fetch()) {
                echo "  Departure: {$row['departure_time']}\n";
            }
        }

        // Check if it should be on the to_kozoji direction instead
        echo "\n=== Checking to_kozoji direction ===\n";
        $stmt = $pdo->prepare("SELECT COUNT(*) as count FROM rail_timetable
                              WHERE line_code = 'aichi_kanjo'
                              AND direction = 'to_kozoji'
                              AND station_code = 'okazaki'");
        $stmt->execute();
        $okazakiKozoji = $stmt->fetch();

        echo "Okazaki records on to_kozoji: " . $okazakiKozoji['count'] . "\n";

        if ($okazakiKozoji['count'] > 0) {
            $stmt = $pdo->prepare("SELECT * FROM rail_timetable
                                  WHERE line_code = 'aichi_kanjo'
                                  AND direction = 'to_kozoji'
                                  AND station_code = 'okazaki'
                                  ORDER BY departure_time ASC
                                  LIMIT 3");
            $stmt->execute();

            while ($row = $stmt->fetch()) {
                echo "  Departure: {$row['departure_time']}\n";
            }
        }

    } else {
        echo "No yakusa data found!\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
