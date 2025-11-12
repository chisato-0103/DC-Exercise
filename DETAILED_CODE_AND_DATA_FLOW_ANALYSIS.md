# Detailed Code and Data Flow Analysis

## Part 1: Data Integrity Comparison Matrix

### All 23 Aichi Kanjo Stations - Code Verification

| # | Station Name | Correct Code (stations table) | Code in rail_timetable | Match? | Records |
|---|--------------|-------------------------------|------------------------|--------|---------|
| 1 | 岡崎 | okazaki | okazaki | ✓ | ~120 |
| 2 | 中岡崎 | nakaokazaki | nakaokazaki | ✓ | ~120 |
| 3 | 北岡崎 | kita_okazaki | kitaokazaki | ✗ | 129 |
| 4 | 三河豊田 | mikawa_toyota | mikawatoyota | ✗ | 142 |
| 5 | 新豊田 | shin_toyota | shintoyota | ✗ | 141 |
| 6 | 愛環梅坪 | aikan_umetsubo | aikanumetubo | ✗ | 131 |
| 7 | 中水野 | nakamizuno | nakamizuno | ✓ | ~120 |
| 8 | 瀬戸市 | setoshi | setoshi | ✓ | ~120 |
| 9 | 瀬戸口 | setoguchi | setoguchi | ✓ | ~120 |
| 10 | 篠原 | sasabara | sasabara | ✓ | ~120 |
| 11 | 北野桝塚 | kitano_masuzuka | kitanomasuduka | ✗ | 132 |
| 12 | 六名 | mutsuna | mutsuna | ✓ | ~120 |
| 13 | 四郷 | shigo | shigo | ✓ | ~120 |
| 14 | 永覚 | ekaku | ekaku | ✓ | ~120 |
| 15 | 保見 | homi | homi | ✓ | ~120 |
| 16 | 貝津 | kaizu | kaizu | ✓ | ~120 |
| 17 | 三河上郷 | mikawa_kamigo | mikawakamigo | ✗ | 134 |
| 18 | 新上挙母 | shin_uwagoromo | shinuwagoromo | ✗ | 148 |
| 19 | 末野原 | suenohara | suenohara | ✓ | ~120 |
| 20 | 山口 | yamaguchi | yamaguchi | ✓ | ~120 |
| 21 | 高蔵寺 | kozoji | kozoji | ✓ | ~120 |
| 22 | 八草 (TRANSFER POINT) | yakusa | yakusa | WRONG | 132 |
| 23 | 台門 (UNKNOWN) | (not in stations) | daimon | INVALID | 128 |

**Summary**: 7 stations with wrong codes + 2 with invalid codes = 9 problematic entries
**Total Impact**: 957 invalid records (32.5% of 2,943)

---

## Part 2: Code Pattern Analysis

### Station Code Convention Mismatch Pattern

The issue follows a specific pattern - underscores are being removed:

```
CORRECT (stations table)     WRONG (rail_timetable)
---------------------------------------------------------------------------
aikan_umetsubo          -->  aikanumetubo              (-1 underscore)
kitano_masuzuka         -->  kitanomasuduka            (-1 underscore)
shin_uwagoromo          -->  shinuwagoromo            (-1 underscore)
shin_toyota             -->  shintoyota                (-1 underscore)
kita_okazaki            -->  kitaokazaki              (-1 underscore)
mikawa_kamigo           -->  mikawakamigo             (-1 underscore)
mikawa_toyota           -->  mikawatoyota             (-1 underscore)
```

All 7 affected stations have underscore removal issues. This suggests a systematic problem in the data source or transformation process.

---

## Part 3: SQL Query Execution Trace

### Scenario: User searches for trains from Shin-Toyota

#### Step 1: Frontend/API Call
```javascript
// From index.js or similar frontend code
fetch('/api/get_next_connection.php?direction=to_university&origin=shin_toyota&line_code=aichi_kanjo')
```

#### Step 2: API Processing (get_next_connection.php, lines 98-109)
```php
} elseif (isValidStationCode($origin)) {
    // 路線駅 → 大学
    if ($lineCode === 'linimo') {
        // リニモ駅から
        $routes = calculateStationToUniversity($origin, $time, $limit);
    } elseif ($lineCode === 'aichi_kanjo') {
        // 愛知環状線駅から
        $routes = calculateRailToUniversity($lineCode, $origin, $time, $limit, $dayType);
        // Calls with: 'aichi_kanjo', 'shin_toyota', current_time, limit, dayType
    }
}
```

#### Step 3: calculateRailToUniversity() Call (db_functions_generic.php, lines 190-302)
```php
function calculateRailToUniversity($lineCode, $originCode, $currentTime, $limit = 3, $dayType = null) {
    // Line 204: Get travel time
    $railTravelTime = (int)$originInfo['travel_time_from_yakusa'];
    
    // Line 208: Determine direction for reverse calculation
    $railDirection = ($lineCode === 'linimo') ? 'to_yagusa' : 'to_kozoji';
    
    // Line 210: GET TRAINS FROM ORIGIN STATION
    $railTrains = getNextRailTrains($lineCode, $originCode, $railDirection, $currentTime, $dayType, 30);
    // Calls: getNextRailTrains('aichi_kanjo', 'shin_toyota', 'to_kozoji', '09:00:00', 'weekday_green', 30)
}
```

#### Step 4: getNextRailTrains() Query (db_functions_generic.php, lines 24-53)
```php
$sql = "SELECT * FROM rail_timetable
        WHERE line_code = :line_code
        AND station_code = :station_code
        AND direction = :direction
        AND departure_time >= :current_time
        AND day_type = :day_type
        AND is_active = 1
        ORDER BY departure_time ASC
        LIMIT :limit";

// Parameter binding:
// :line_code      = 'aichi_kanjo'      ✓ Exists in DB
// :station_code   = 'shin_toyota'      ✗ Does NOT exist (DB has 'shintoyota')
// :direction      = 'to_kozoji'        ✓ Valid
// :current_time   = '09:00:00'         ✓ Valid
// :day_type       = 'weekday_green'    ✓ Exists in DB
// :limit          = 30                 ✓ Valid
```

#### Step 5: SQL Execution Result
```sql
SELECT * FROM rail_timetable
WHERE line_code = 'aichi_kanjo'
AND station_code = 'shin_toyota'           -- PROBLEM: No rows match this!
AND direction = 'to_kozoji'
AND departure_time >= '09:00:00'
AND day_type = 'weekday_green'
AND is_active = 1
ORDER BY departure_time ASC
LIMIT 30;

RESULT: 0 rows returned
```

#### Step 6: Function Returns Empty
```php
// db_functions_generic.php, line 47
return $stmt->fetchAll();  // Returns empty array []
```

#### Step 7: API Returns No Results
```php
// Back in calculateRailToUniversity(), line 210
if (empty($railTrains)) {
    continue;  // Skip this shuttle bus option
}

// Eventually...
return [];  // No routes found
```

#### Step 8: Frontend Shows "No Service"
```javascript
if (empty($routes)) {
    // Show service_info (end-of-day message)
    // User sees: "No results available"
}
```

---

## Part 4: What SHOULD Happen vs What DOES Happen

### Scenario: Trains departing from Shin-Toyota at 09:00 AM (weekday)

#### Expected Result
```
Query for: station_code = 'shin_toyota' AND direction = 'to_kozoji'

Expected return: 141 rows (all trains from this station toward Kozoji)
Examples:
  - 09:01:00 (Terminal: 高蔵寺)
  - 09:11:00 (Terminal: 高蔵寺)
  - 09:17:00 (Terminal: 高蔵寺)
  - ... 138 more
```

#### Actual Result
```
Query executes:
  WHERE station_code = 'shin_toyota'
  
Actual database has:
  'shintoyota' (without underscore)

Return: 0 rows (FAILURE)

But if we query with wrong code:
  WHERE station_code = 'shintoyota'
  
Returns: 141 rows (SUCCESS - but using wrong code!)
```

---

## Part 5: Impact by Feature

### Feature 1: University → Aichi Kanjo Station
**Status**: BROKEN for 7 stations

```
calculateUniversityToRail()
  └─> getNextRailTrains('aichi_kanjo', destination, 'to_okazaki', ...)
      └─> station_code = 'shin_toyota' (WRONG - expects 'shintoyota')
          └─> Result: 0 trains
              └─> User sees: "No connections available"
```

**Affected Stations** (can't search TO these stations):
1. shin_toyota (新豊田)
2. aikan_umetsubo (愛環梅坪)
3. kitano_masuzuka (北野桝塚)
4. shin_uwagoromo (新上挙母)
5. kita_okazaki (北岡崎)
6. mikawa_kamigo (三河上郷)
7. mikawa_toyota (三河豊田)

### Feature 2: Aichi Kanjo Station → University
**Status**: BROKEN for 7 stations

```
calculateRailToUniversity()
  └─> getNextRailTrains('aichi_kanjo', origin, 'to_kozoji', ...)
      └─> station_code = 'shin_toyota' (WRONG - expects 'shintoyota')
          └─> Result: 0 trains
              └─> User sees: "No connections available"
```

**Affected Stations** (can't search FROM these stations):
- Same 7 stations as above

### Feature 3: Yakusa Transfer Point
**Status**: CORRUPTED with invalid data

```
rail_timetable contains:
  132 rows with station_code = 'yakusa'

These should NOT be here because:
  - Yakusa is the TRANSFER POINT between shuttle/linimo
  - Only shuttle_bus_timetable and linimo_timetable should have yakusa
  - These 132 rows cause confusion and data inconsistency
```

### Feature 4: Unknown Daimon Station
**Status**: CORRUPTED with unknown data

```
rail_timetable contains:
  128 rows with station_code = 'daimon'

This is INVALID because:
  - 'daimon' is not in the stations master table
  - The station doesn't exist (タイプミス？)
  - These 128 rows are orphaned with no station definition
```

---

## Part 6: Example Data Comparison

### Data for Shin-Toyota Station, to_kozoji direction

#### What's IN the Database (WRONG)
```sql
SELECT * FROM rail_timetable 
WHERE station_code = 'shintoyota' 
AND direction = 'to_kozoji' 
AND day_type = 'weekday_green'
LIMIT 5;

Results:
┌────┬─────────────┬──────────────┬───────────┬────────────────┬────────────────┬──────────┬────────────┬────────────┐
│ id │ line_code   │ station_code │ station_name │ direction   │ departure_time │ day_type │ terminal   │ is_active  │
├────┼─────────────┼──────────────┼───────────┼────────────────┼────────────────┼──────────┼────────────┼────────────┤
│    │ aichi_kanjo │ shintoyota   │ 新豊田     │ to_kozoji   │ 05:37:00       │ weekday_green │ 高蔵寺 │ 1      │
│    │ aichi_kanjo │ shintoyota   │ 新豊田     │ to_kozoji   │ 05:52:00       │ weekday_green │ 高蔵寺 │ 1      │
│    │ aichi_kanjo │ shintoyota   │ 新豊田     │ to_kozoji   │ 06:05:00       │ weekday_green │ 高蔵寺 │ 1      │
│    │ aichi_kanjo │ shintoyota   │ 新豊田     │ to_kozoji   │ 06:21:00       │ weekday_green │ 高蔵寺 │ 1      │
│    │ aichi_kanjo │ shintoyota   │ 新豊田     │ to_kozoji   │ 06:37:00       │ weekday_green │ 高蔵寺 │ 1      │
└────┴─────────────┴──────────────┴───────────┴────────────────┴────────────────┴──────────┴────────────┴────────────┘
```

#### What the Code EXPECTS (CORRECT)
```sql
SELECT * FROM rail_timetable 
WHERE station_code = 'shin_toyota'    -- CODE EXPECTS THIS
AND direction = 'to_kozoji' 
AND day_type = 'weekday_green'
LIMIT 5;

Results: 0 rows (EMPTY - Data doesn't exist with this code!)

But the stations table has:
SELECT * FROM stations WHERE station_code = 'shin_toyota';
┌────────────────┬─────────────────┬────────────────┬────────────────┬──────────────────┬───────────────────────┐
│ station_code   │ station_name    │ station_name_en│ order_index    │ travel_time_from_yakusa │ line_type       │
├────────────────┼─────────────────┼────────────────┼────────────────┼──────────────────┼───────────────────────┤
│ shin_toyota    │ 新豊田          │ Shin-Toyota    │ 14             │ 18               │ aichi_kanjo     │
└────────────────┴─────────────────┴────────────────┴────────────────┴──────────────────┴───────────────────────┘
```

---

## Part 7: Root Cause Analysis

### Where Did the Wrong Codes Come From?

The `rebuild_aichi_kanjo_rail_timetable.sql` script shows the issue clearly:

**Line 31 of rebuild script:**
```sql
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, terminal, is_active) VALUES
```

**Lines 32-50+ Examples:**
```sql
('aichi_kanjo', 'shintoyota', '新豊田', 'to_kozoji', '05:37:00', 'weekday_green', '高蔵寺', 1),
('aichi_kanjo', 'shintoyota', '新豊田', 'to_okazaki', '05:38:00', 'weekday_green', '岡崎', 1),
...
('aichi_kanjo', 'aikanumetubo', '愛環梅坪', 'to_kozoji', '05:40:00', 'weekday_green', '高蔵寺', 1),
...
```

**Hypothesis**: 
- The SQL script was likely generated from JSON data
- During JSON → SQL conversion, underscore removal happened
- Could be automatic camelCase conversion
- Or manual typo during data entry

**Note**: The script comments say "JSONデータから正確に抽出した" (accurately extracted from JSON data), so the issue is in the JSON source or its conversion.

---

## Part 8: Test Case for Verification

### Test 1: Basic Query Failure
```php
// This returns 0 - FAILURE
$result = getNextRailTrains('aichi_kanjo', 'shin_toyota', 'to_kozoji', '09:00:00', 'weekday_green', 5);
assert(count($result) === 0, "ERROR: Expected 0 but got " . count($result));
```

### Test 2: Wrong Code Success
```php
// This returns 141+ - SUCCESS but using wrong code
$result = getNextRailTrains('aichi_kanjo', 'shintoyota', 'to_kozoji', '09:00:00', 'weekday_green', 5);
assert(count($result) > 0, "ERROR: Expected >0 but got " . count($result));
```

### Test 3: Station Code Validation
```php
// Should be in stations table
$station = getStationInfo('shin_toyota');
assert($station !== null, "ERROR: shin_toyota not found in stations table");

// But query returns nothing
$result = getNextRailTrains('aichi_kanjo', 'shin_toyota', 'to_kozoji', '09:00:00', 'weekday_green', 5);
assert(count($result) === 0, "ERROR: Station code mismatch detected!");
```

### Test 4: All Affected Stations
```php
$affectedStations = [
    'shin_toyota',      // Has 141 records with code 'shintoyota'
    'aikan_umetsubo',   // Has 131 records with code 'aikanumetubo'
    'kitano_masuzuka',  // Has 132 records with code 'kitanomasuduka'
    'shin_uwagoromo',   // Has 148 records with code 'shinuwagoromo'
    'kita_okazaki',     // Has 129 records with code 'kitaokazaki'
    'mikawa_kamigo',    // Has 134 records with code 'mikawakamigo'
    'mikawa_toyota',    // Has 142 records with code 'mikawatoyota'
];

foreach ($affectedStations as $station) {
    $result = getNextRailTrains('aichi_kanjo', $station, 'to_kozoji', '09:00:00', 'weekday_green', 5);
    assert(count($result) === 0, "ERROR: $station returned " . count($result) . " rows (expected 0)");
}
```

