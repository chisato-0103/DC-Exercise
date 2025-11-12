# Complete Data Flow Trace: 愛知環状線 → 大学 Routes (aichi_kanjo to_university)

## Overview
This document traces the complete data flow for routes from Aichi Kanjo (愛知環状線) stations to the university. This is the "from_aichi_kanjo" route option where users select an Aichi Kanjo station as the origin point.

---

## 1. FRONTEND REQUEST (assets/js/index.html + assets/js/index.js)

### User Selection Flow
**File**: `/Applications/MAMP/htdocs/DC-Exercise/index.html` (Lines 52-59)
```html
<label class="radio-option">
    <input type="radio" name="route_option" value="from_aichi_kanjo" 
           onchange="setRouteOption(this.value)">
    <span>🚆 愛知環状線駅 → 🏫 大学</span>
</label>
```

### Route Option Handler
**File**: `/Applications/MAMP/htdocs/DC-Exercise/assets/js/index.js` (Lines 1416-1452)

When user selects "from_aichi_kanjo" radio button:
```javascript
window.setRouteOption = function(routeOption) {
    // For "from_aichi_kanjo":
    case 'from_aichi_kanjo':
        direction = 'to_university';      // ← Direction: to_university
        lineCode = 'aichi_kanjo';         // ← Line Code: aichi_kanjo
        break;
    
    // Set hidden input fields
    document.getElementById('direction').value = 'to_university';
    document.getElementById('line_code').value = 'aichi_kanjo';
    
    // Update station select dropdown
    window.updateStationSelects('aichi_kanjo');
    
    // Toggle display fields
    toggleDirectionFields('to_university');
}
```

**Parameters Set**:
- `direction = 'to_university'`
- `lineCode = 'aichi_kanjo'`
- User selects origin station from dropdown (e.g., 'yamaguchi' = 山口)

### API Request
**File**: `/Applications/MAMP/htdocs/DC-Exercise/assets/js/index.js` (Lines 145-160)

```javascript
async function loadNextConnection() {
    const params = getURLParams();
    
    const data = await API.getNextConnection(
        'to_university',           // direction
        'aichi_kanjo',             // lineCode
        null,                      // destination (not used for to_university)
        'yamaguchi',               // origin (selected station)
        params.testDate,           // optional test date
        params.testTime            // optional test time
    );
}
```

### API Module Call
**File**: `/Applications/MAMP/htdocs/DC-Exercise/assets/js/api.js` (Lines 55-73)

```javascript
async function getNextConnection(direction, lineCode, destination, origin, testDate, testTime) {
    const params = { 
        direction: 'to_university',
        line_code: 'aichi_kanjo'
    };
    
    if (direction === 'to_university' && origin) {
        params.origin = 'yamaguchi';  // Selected origin station
    }
    
    // Add optional test parameters
    if (testDate) params.test_date = testDate;
    if (testTime) params.test_time = testTime;
    
    return await fetchAPI('api/get_next_connection.php', params);
}
```

### HTTP Request to API
```
GET /api/get_next_connection.php?direction=to_university&line_code=aichi_kanjo&origin=yamaguchi HTTP/1.1
```

---

## 2. API ENDPOINT ROUTING (api/get_next_connection.php)

**File**: `/Applications/MAMP/htdocs/DC-Exercise/api/get_next_connection.php`

### Request Parameter Parsing
Lines 20-31:
```php
$direction = $_GET['direction'] ?? 'to_station';  // = 'to_university'
$lineCode = $_GET['line_code'] ?? 'linimo';       // = 'aichi_kanjo'

if ($direction === 'to_station') {
    // ... (not executed for to_university)
} else {
    $origin = $_GET['origin'] ?? 'fujigaoka';     // = 'yamaguchi'
    $destination = null;
}
```

### Diagram Type & Day Type Determination
Lines 54-72:
```php
$diaType = getCurrentDiaType($testDate);      // e.g., 'A'
$dayType = getCurrentDayType();               // e.g., 'weekday_green'
```

### Route Calculation - CRITICAL ROUTING DECISION
Lines 91-110: **This is where aichi_kanjo to_university routes are handled**

```php
} elseif ($direction === 'to_university') {
    // 路線駅または八草駅 → 大学
    if ($origin === 'yakusa') {
        // Yagusa Station → University (not this case)
        $routes = calculateYagusaToUniversity($time, $limit);
    } elseif (isValidStationCode($origin)) {
        // Rail station → University
        if ($lineCode === 'linimo') {
            // Linimo station route
            $routes = calculateStationToUniversity($origin, $time, $limit);
        } elseif ($lineCode === 'aichi_kanjo') {
            // ← THIS IS EXECUTED FOR AICHI KANJO
            $routes = calculateRailToUniversity(
                $lineCode,          // 'aichi_kanjo'
                $origin,            // 'yamaguchi'
                $time,              // current time
                $limit,             // number of results
                $dayType            // 'weekday_green' or 'holiday_red'
            );
        }
    }
}
```

**Key Function Called**: `calculateRailToUniversity()` in db_functions_generic.php

---

## 3. CORE DATABASE FUNCTION (includes/db_functions_generic.php)

### Function Definition
**File**: `/Applications/MAMP/htdocs/DC-Exercise/includes/db_functions_generic.php` (Lines 190-302)

```php
function calculateRailToUniversity($lineCode, $originCode, $currentTime, $limit = 3, $dayType = null) {
    // $lineCode = 'aichi_kanjo'
    // $originCode = 'yamaguchi'
    // $currentTime = '14:30:00' (example)
    // $dayType = 'weekday_green'
```

### Step 1: Get Origin Station Information
Lines 198-202:
```php
$originInfo = getStationInfo($originCode);  // Get 'yamaguchi' station info
if (!$originInfo) {
    return [];
}

// $originInfo contains:
// - station_code: 'yamaguchi'
// - station_name: '山口'
// - travel_time_from_yakusa: 4 (minutes)
// - line_type: 'aichi_kanjo'

$railTravelTime = (int)$originInfo['travel_time_from_yakusa'];  // = 4 minutes
```

### Step 2: Determine Rail Direction
Lines 206-208: **Important logic for Aichi Kanjo's circular line**
```php
$railDirection = ($lineCode === 'linimo') ? 'to_yagusa' : 'to_kozoji';
// For aichi_kanjo: $railDirection = 'to_kozoji'
// This is the direction from origin station TOWARDS Yagusa
```

**Note on Aichi Kanjo Directions**:
- `to_kozoji` (to Kozoji/高蔵寺): One direction on the circle
- `to_okazaki` (to Okazaki/岡崎): Other direction on the circle
- The system needs to query which direction goes to Yagusa from the origin station

### Step 3: Get Next Rail Trains (CRITICAL - WHERE DEPARTURE TIMES COME FROM)
Lines 210-217:

```php
$railTrains = getNextRailTrains(
    $lineCode,           // 'aichi_kanjo'
    $originCode,         // 'yamaguchi' (the user's selected station)
    $railDirection,      // 'to_kozoji'
    $currentTime,        // '14:30:00'
    $dayType,            // 'weekday_green'
    30                   // limit
);

// If no direct trains found, try reverse calculation
$useReverseCalculation = empty($railTrains);
if ($useReverseCalculation) {
    $reverseDirection = 'to_okazaki';
    $railTrains = getNextRailTrains(
        'aichi_kanjo',
        'yakusa',          // Get trains FROM Yagusa
        'to_okazaki',      // In the other direction
        $currentTime,
        $dayType,
        30
    );
}
```

### Function: getNextRailTrains (WHERE THE QUERY HAPPENS)
**File**: `/Applications/MAMP/htdocs/DC-Exercise/includes/db_functions_generic.php` (Lines 24-53)

```php
function getNextRailTrains($lineCode, $stationCode, $direction, $currentTime, $dayType, $limit = 5) {
    try {
        $pdo = getDbConnection();

        // THIS IS THE CRITICAL DATABASE QUERY FOR DEPARTURE TIMES
        $sql = "SELECT * FROM rail_timetable
                WHERE line_code = :line_code
                AND station_code = :station_code
                AND direction = :direction
                AND departure_time >= :current_time
                AND day_type = :day_type
                AND is_active = 1
                ORDER BY departure_time ASC
                LIMIT :limit";

        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':line_code', $lineCode, PDO::PARAM_STR);      // 'aichi_kanjo'
        $stmt->bindValue(':station_code', $stationCode, PDO::PARAM_STR); // 'yamaguchi'
        $stmt->bindValue(':direction', $direction, PDO::PARAM_STR);      // 'to_kozoji'
        $stmt->bindValue(':current_time', $currentTime, PDO::PARAM_STR); // '14:30:00'
        $stmt->bindValue(':day_type', $dayType, PDO::PARAM_STR);         // 'weekday_green'
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);              // 30

        $stmt->execute();
        return $stmt->fetchAll();  // Returns array of trains
    } catch (PDOException $e) {
        logError('Failed to get next rail trains', $e);
        return [];
    }
}
```

### Database Query Analysis

**EXACT QUERY EXECUTED**:
```sql
SELECT * FROM rail_timetable
WHERE line_code = 'aichi_kanjo'
AND station_code = 'yamaguchi'
AND direction = 'to_kozoji'
AND departure_time >= '14:30:00'
AND day_type = 'weekday_green'
AND is_active = 1
ORDER BY departure_time ASC
LIMIT 30
```

**Example Result Set**:
```
id | line_code    | station_code | station_name | direction  | departure_time | day_type       | terminal | is_active
---|--------------|--------------|--------------|------------|----------------|----------------|-----------|---------
1  | aichi_kanjo  | yamaguchi    | 山口         | to_kozoji  | 14:33:00       | weekday_green  | 高蔵寺   | 1
2  | aichi_kanjo  | yamaguchi    | 山口         | to_kozoji  | 14:49:00       | weekday_green  | 高蔵寺   | 1
3  | aichi_kanjo  | yamaguchi    | 山口         | to_kozoji  | 15:05:00       | weekday_green  | 高蔵寺   | 1
4  | aichi_kanjo  | yamaguchi    | 山口         | to_kozoji  | 15:21:00       | weekday_green  | 高蔵寺   | 1
...
```

### Step 4: Process Retrieved Trains
Lines 221-294 (back in calculateRailToUniversity):

```php
$routes = [];

foreach ($railTrains as $rail) {
    if ($useReverseCalculation) {
        // If trains were from Yagusa, calculate backwards
        $yagusaDepartureTime = $rail['departure_time'];       // e.g., '14:33:00'
        $originDepartureTime = addMinutes($yagusaDepartureTime, -$railTravelTime);
        // $originDepartureTime = 14:33 - 4 min = 14:29:00
        
        if (compareTime($originDepartureTime, $currentTime) < 0) {
            continue;  // Skip if departure is in the past
        }
        
        $yagusaArrivalTime = addMinutes($yagusaDepartureTime, 2);  // ~2 min to Yagusa
    } else {
        // Use actual departure time from origin station
        $originDepartureTime = $rail['departure_time'];  // e.g., '14:33:00'
        
        // Calculate Yagusa arrival time
        $yagusaArrivalTime = addMinutes($originDepartureTime, $railTravelTime);  // 14:33 + 4 = 14:37
    }

    // Calculate minimum shuttle departure time (with transfer buffer)
    $minShuttleTime = addMinutes($yagusaArrivalTime, $transferTime);  // 14:37 + 10 = 14:47

    // Get shuttle buses after the transfer window
    $shuttleBuses = getNextShuttleBuses('to_university', $minShuttleTime, $diaType, 3);

    if (empty($shuttleBuses)) {
        continue;  // No shuttle available
    }

    $shuttle = $shuttleBuses[0];

    // Calculate times
    $totalTime = calculateDuration($originDepartureTime, $shuttle['arrival_time']);
    $waitingTime = calculateDuration($currentTime, $originDepartureTime);
    $actualTransferTime = calculateDuration($yagusaArrivalTime, $shuttle['departure_time']);

    // Generate shuttle options (multiple shuttles)
    $shuttleOptions = [];
    foreach ($shuttleBuses as $option) {
        $optionDepartureTime = $option['departure_time'];
        $optionArrivalTime = $option['arrival_time'];
        $optionTransferTime = calculateDuration($yagusaArrivalTime, $optionDepartureTime);
        $optionTotalTime = calculateDuration($currentTime, $optionArrivalTime);

        $shuttleOptions[] = [
            'shuttle_departure' => formatTime($optionDepartureTime),
            'shuttle_arrival' => formatTime($optionArrivalTime),
            'transfer_time' => $optionTransferTime,
            'total_time' => $optionTotalTime
        ];
    }

    // Build route object
    $routes[] = [
        'rail_departure' => formatTime($originDepartureTime),      // e.g., '14:33'
        'rail_arrival' => formatTime($yagusaArrivalTime),          // e.g., '14:37'
        'shuttle_departure' => formatTime($shuttle['departure_time']),
        'shuttle_arrival' => formatTime($shuttle['arrival_time']),
        'transfer_time' => $actualTransferTime,
        'total_time' => $totalTime,
        'waiting_time' => $waitingTime,
        'rail_time' => $railTravelTime,                            // 4 minutes
        'origin_name' => $originInfo['station_name'],              // '山口'
        'shuttle_options' => $shuttleOptions,
        'line_code' => $lineCode                                   // 'aichi_kanjo'
    ];

    if (count($routes) >= $limit) {
        break;
    }
}

return $routes;
```

---

## 4. API RESPONSE STRUCTURE

**File**: `/Applications/MAMP/htdocs/DC-Exercise/api/get_next_connection.php` (Lines 201-213)

```php
jsonResponse(true, [
    'current_time' => '14:30:00',
    'dia_type' => 'A',
    'dia_description' => 'ダイヤA（授業期間平日）',
    'day_type' => 'weekday_green',
    'day_description' => '平日',
    'direction' => 'to_university',
    'line_code' => 'aichi_kanjo',
    'from_name' => '山口',
    'to_name' => '愛知工業大学',
    'routes' => [
        {
            'rail_departure' => '14:33',          // ← AICHI KANJO DEPARTURE
            'rail_arrival' => '14:37',            // ← YAGUSA ARRIVAL
            'shuttle_departure' => '14:47',
            'shuttle_arrival' => '14:52',
            'transfer_time' => 10,
            'total_time' => 19,
            'waiting_time' => 3,
            'rail_time' => 4,
            'origin_name' => '山口',
            'shuttle_options' => [
                {
                    'shuttle_departure' => '14:47',
                    'shuttle_arrival' => '14:52',
                    'transfer_time' => 10,
                    'total_time' => 19
                },
                {
                    'shuttle_departure' => '15:02',
                    'shuttle_arrival' => '15:07',
                    'transfer_time' => 25,
                    'total_time' => 34
                }
            ],
            'line_code' => 'aichi_kanjo'
        },
        // ... more routes
    ],
    'service_info' => null
]);
```

### Response Field Mapping for aichi_kanjo

For aichi_kanjo to_university routes, the response contains:
- `rail_departure`: Departure time from the Aichi Kanjo station (e.g., 山口)
- `rail_arrival`: Arrival time at Yagusa Station
- `rail_time`: Travel time on Aichi Kanjo (in minutes)
- `shuttle_departure`: First available shuttle departure
- `shuttle_arrival`: Shuttle arrival at university
- `shuttle_options`: Array of alternative shuttle options with their times

---

## 5. FRONTEND RENDERING (assets/js/index.js)

### Response Reception
**File**: `/Applications/MAMP/htdocs/DC-Exercise/assets/js/index.js` (Lines 145-200)

```javascript
async function loadNextConnection() {
    const data = await API.getNextConnection(
        'to_university',
        'aichi_kanjo',
        null,
        'yamaguchi',
        params.testDate,
        params.testTime
    );
    
    // Response received and passed to rendering
    renderRoutes(data);
}
```

### Route Rendering - Next Departure Display
**File**: `/Applications/MAMP/htdocs/DC-Exercise/assets/js/index.js` (Lines 256-404)

When direction is 'to_university' and origin is NOT '八草駅':

```javascript
function renderNextDeparture(route, direction, lineCode = 'linimo') {
    let departureTime = '';
    let title = '';
    let routeInfo = '';

    if (direction === 'to_university') {
        if (route.origin_name === '八草駅') {
            // Yagusa to University case
            departureTime = formatTimeWithoutSeconds(route.shuttle_departure);
        } else {
            // Rail Station → University (THIS CASE)
            const railDepartureField = route.line_code === 'aichi_kanjo' ? 
                'rail_departure' :  // ← FOR AICHI KANJO
                'linimo_departure'; // (for Linimo)
            
            const railNameLabel = route.line_code === 'aichi_kanjo' ? 
                '電車' : 'リニモ';

            // DISPLAY AICHI KANJO DEPARTURE TIME
            departureTime = formatTimeWithoutSeconds(route[railDepartureField]);
            // e.g., '14:33' (extracted from '14:33:00')
            
            title = `次の${railNameLabel}は`;  // "次の電車は"
            
            routeInfo = `<img src="assets/image/train-svgrepo-com 2.svg" /> 
                         ${escapeHtml(route.origin_name)} → 
                         <img src="assets/image/bus-svgrepo-com 2.svg" /> 
                         八草駅 → 
                         <img src="assets/image/school-flag-svgrepo-com 2.svg" /> 
                         愛知工業大学`;
        }
    }

    container.innerHTML = `
        <div class="next-departure-title">${title}</div>
        <div class="next-departure-time">${escapeHtml(departureTime)} 発</div>
        <div class="next-departure-info">
            ${routeInfo}
        </div>
        <div style="text-align: center;">
            <span class="countdown" id="countdown" data-departure="${escapeHtml(departureTime)}">
                あと ${escapeHtml(route.waiting_time)} 分
            </span>
        </div>
        <div class="next-departure-details">
            ${renderRouteDetails(route, direction, lineCode)}
        </div>
    `;
}
```

### Route Details Rendering
**File**: `/Applications/MAMP/htdocs/DC-Exercise/assets/js/index.js` (Lines 610-693)

For aichi_kanjo to_university:

```javascript
function renderRouteDetails(route, direction, lineCode = 'linimo') {
    // ... (direction === 'to_university' check)
    
    if (route.origin_name !== '八草駅') {
        // Rail station → University
        const railDepartureField = lineCode === 'aichi_kanjo' ? 
            'rail_departure' : 'linimo_departure';
        const railArrivalField = lineCode === 'aichi_kanjo' ? 
            'rail_arrival' : 'linimo_arrival';
        const railTimeField = lineCode === 'aichi_kanjo' ? 
            'rail_time' : 'linimo_time';
        const railVerbLabel = lineCode === 'aichi_kanjo' ? 
            '電車' : 'リニモ';

        html += `
            <div class="route-step">
                <img src="assets/image/train-svgrepo-com 2.svg" />
                <div class="route-step-content">
                    <div class="route-step-time">
                        ${escapeHtml(route.origin_name)} 発 
                        ${escapeHtml(formatTimeWithoutSeconds(route[railDepartureField]))}
                    </div>
                    <div class="route-step-detail">${railVerbLabel}で出発</div>
                </div>
            </div>
            <div class="route-arrow" style="color: white;">↓</div>
            <div class="route-step">
                <img src="assets/image/bus-svgrepo-com 2.svg" />
                <div class="route-step-content">
                    <div class="route-step-time">
                        八草駅 着 
                        ${escapeHtml(formatTimeWithoutSeconds(route[railArrivalField]))}
                    </div>
                    <div class="route-step-detail">
                        ${railVerbLabel}約${escapeHtml(route[railTimeField])}分
                    </div>
                </div>
            </div>
            <!-- Shuttle options follow -->
        `;
    }
}
```

### Time Formatting
**File**: `/Applications/MAMP/htdocs/DC-Exercise/assets/js/index.js` (Lines 244-251)

```javascript
function formatTimeWithoutSeconds(timeStr) {
    if (!timeStr) return '';
    // HH:MM:SS → HH:MM
    if (timeStr.length > 5) {
        return timeStr.substring(0, 5);
    }
    return timeStr;
}
// Input: '14:33:00' → Output: '14:33'
```

---

## 6. DATABASE SCHEMA

**File**: `/Applications/MAMP/htdocs/DC-Exercise/sql/setup.sql`

### rail_timetable Table Definition

```sql
CREATE TABLE rail_timetable (
    id INT PRIMARY KEY AUTO_INCREMENT,
    line_code VARCHAR(50) NOT NULL COMMENT '路線コード: aichi_kanjo など',
    station_code VARCHAR(50) NOT NULL COMMENT '駅コード',
    station_name VARCHAR(50) NOT NULL COMMENT '駅名',
    direction VARCHAR(50) NOT NULL COMMENT '方向: to_kozoji, to_okazaki など',
    departure_time TIME NOT NULL COMMENT '発車時刻',
    day_type ENUM('weekday_green', 'holiday_red') NOT NULL 
        COMMENT '曜日種別: weekday_green=平日(4-7,10-1月), holiday_red=土休日+学校休業期間(8,9,2,3月)',
    terminal VARCHAR(50) COMMENT '最終駅（愛知環状線用）',
    is_active BOOLEAN DEFAULT TRUE COMMENT '運行中フラグ',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_line_station_direction (line_code, station_code, direction),
    INDEX idx_line_day_type (line_code, day_type),
    INDEX idx_departure_time (departure_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### stations Table Definition (Relevant for travel_time_from_yakusa)

```sql
CREATE TABLE stations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    station_code VARCHAR(50) UNIQUE NOT NULL,
    station_name VARCHAR(50) NOT NULL,
    station_name_en VARCHAR(100),
    order_index INT NOT NULL,
    travel_time_from_yakusa INT NOT NULL COMMENT '八草駅からの所要時間（分）',
    line_type VARCHAR(50) COMMENT 'リニモ or 愛知環状線',
    ...
);

-- Example for Aichi Kanjo stations:
INSERT INTO stations VALUES
(..., 'yamaguchi', '山口', 'Yamaguchi', 29, 4, 'aichi_kanjo', ...),
(..., 'kozoji', '高蔵寺', 'Kozoji', 30, 17, 'aichi_kanjo', ...),
(..., 'okazaki', '岡崎', 'Okazaki', 10, 50, 'aichi_kanjo', ...),
```

### Sample Data in rail_timetable

**File**: `/Applications/MAMP/htdocs/DC-Exercise/sql/rebuild_aichi_kanjo_rail_timetable.sql` (Lines 31-50)

```sql
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, terminal, is_active) VALUES
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '05:59:00', 'weekday_green', '高蔵寺', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '06:12:00', 'weekday_green', '岡崎', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '06:27:00', 'weekday_green', '岡崎', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '06:26:00', 'weekday_green', '高蔵寺', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '06:44:00', 'weekday_green', '高蔵寺', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_okazaki', '07:01:00', 'weekday_green', '岡崎', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '07:00:00', 'weekday_green', '高蔵寺', 1),
...
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '14:33:00', 'weekday_green', '高蔵寺', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '14:49:00', 'weekday_green', '高蔵寺', 1),
('aichi_kanjo', 'yamaguchi', '山口', 'to_kozoji', '15:05:00', 'weekday_green', '高蔵寺', 1),
```

---

## 7. COMPLETE DATA FLOW SUMMARY

### Departure Time Source

**Origin**: `rail_timetable.departure_time`

**Path**:
```
rail_timetable.departure_time (TIME field in database)
                    ↓
getNextRailTrains() function returns array with 'departure_time'
                    ↓
calculateRailToUniversity() formats as formatTime($originDepartureTime)
                    ↓
API response: 'rail_departure' field (e.g., '14:33:00')
                    ↓
JavaScript renderNextDeparture() extracts from route.rail_departure
                    ↓
formatTimeWithoutSeconds() converts '14:33:00' → '14:33'
                    ↓
HTML displays as "14:33 発" (departs at 14:33)
```

### Query Chain

1. **Frontend Request**:
   - User selects: "from_aichi_kanjo" → direction='to_university', lineCode='aichi_kanjo'
   - User selects origin: 'yamaguchi'
   - Calls: `API.getNextConnection('to_university', 'aichi_kanjo', null, 'yamaguchi')`

2. **API Routing**:
   - GET `/api/get_next_connection.php?direction=to_university&line_code=aichi_kanjo&origin=yamaguchi`
   - Routes to: `calculateRailToUniversity('aichi_kanjo', 'yamaguchi', $currentTime, 3, 'weekday_green')`

3. **Database Query** (the critical query):
   ```sql
   SELECT * FROM rail_timetable
   WHERE line_code = 'aichi_kanjo'
   AND station_code = 'yamaguchi'
   AND direction = 'to_kozoji'
   AND departure_time >= '14:30:00'
   AND day_type = 'weekday_green'
   AND is_active = 1
   ORDER BY departure_time ASC
   LIMIT 30
   ```

4. **Result Processing**:
   - First train departure time: '14:33:00' (from database)
   - Calculate Yagusa arrival: 14:33 + 4 min = 14:37
   - Find shuttle after: 14:37 + 10 min = 14:47
   - Build route object with `'rail_departure' => '14:33:00'`

5. **API Response**:
   - Send JSON with `'rail_departure': '14:33:00'`

6. **Frontend Display**:
   - Extract: `route.rail_departure = '14:33:00'`
   - Format: `formatTimeWithoutSeconds('14:33:00')` → '14:33'
   - Display: "次の電車は 14:33 発"

---

## 8. KEY DIFFERENCES BY LINE CODE

### For Linimo (linimo to_university):
- Uses `calculateStationToUniversity()` function
- Queries `linimo_timetable` table
- Response field: `'linimo_departure'`
- Frontend field access: `route.linimo_departure`

### For Aichi Kanjo (aichi_kanjo to_university):
- Uses `calculateRailToUniversity()` function
- Queries `rail_timetable` table
- Response field: `'rail_departure'`
- Frontend field access: `route.rail_departure`
- Can use reverse calculation if direct trains not found

---

## 9. TRANSFORMATIONS & CALCULATIONS

### Database to PHP
- `departure_time` (TIME type) → extracted as string '14:33:00'

### PHP Helper Functions
- `formatTime($time)` → formats TIME to '14:33:00'
- `addMinutes($time, $minutes)` → adds/subtracts minutes
- `calculateDuration($startTime, $endTime)` → returns integer minutes

### PHP to JavaScript
- PHP array → JSON string
- '14:33:00' format preserved in JSON

### JavaScript to HTML
- `formatTimeWithoutSeconds()` → removes seconds: '14:33:00' → '14:33'
- `escapeHtml()` → XSS protection

---

## 10. FILES & LINE NUMBERS REFERENCE

| Component | File | Lines |
|-----------|------|-------|
| HTML Form | index.html | 52-59 |
| Route Selection | assets/js/index.js | 1416-1452 |
| API Call | assets/js/index.js | 145-160 |
| API Module | assets/js/api.js | 55-73 |
| API Endpoint Routing | api/get_next_connection.php | 91-110 |
| Core Function (aichi_kanjo) | includes/db_functions_generic.php | 190-302 |
| getNextRailTrains Query | includes/db_functions_generic.php | 24-53 |
| getStationInfo | includes/db_functions.php | 93-108 |
| Render Next Departure | assets/js/index.js | 256-404 |
| Render Route Details | assets/js/index.js | 610-693 |
| Format Time | assets/js/index.js | 244-251 |
| DB Schema rail_timetable | sql/setup.sql | (lines 203-217) |
| DB Schema stations | sql/setup.sql | (lines 23-68) |
| Sample Data | sql/rebuild_aichi_kanjo_rail_timetable.sql | 31-50 |

---

## 11. CRITICAL NOTES

1. **Direction Logic**: For Aichi Kanjo (circular line), the direction defaults to 'to_kozoji' when calculating routes to university. If no trains are found, it tries reverse calculation with 'to_okazaki'.

2. **Travel Time Source**: The `travel_time_from_yakusa` is stored in the `stations` table, not calculated from timetable data. For yamaguchi, this is 4 minutes.

3. **Departure Times Are NOT Calculated**: They are actual times stored in `rail_timetable.departure_time` column. No algorithmic generation or estimation based on shuttle times.

4. **Day Type Matters**: The query filters by `day_type` (weekday_green or holiday_red), not the shuttle `dia_type` (A/B/C). These are independent scheduling systems.

5. **Multiple Options**: The system returns 3 route options by default (limit=3), each with potentially multiple shuttle options within that route.

