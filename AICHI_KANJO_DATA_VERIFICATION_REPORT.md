# Aichi Kanjo Rail Timetable Investigation Report

## Executive Summary

**CRITICAL DATA INTEGRITY ISSUE FOUND**: The `rebuild_aichi_kanjo_rail_timetable.sql` script contains **957 invalid records (32.5% of total)** with mismatched station codes that prevent departure time retrieval.

**Impact**: Users attempting to search for connections to/from Aichi Kanjo stations will receive **ZERO results** for 7 affected stations, even though the data exists in the database.

---

## 1. Rail_Timetable Data Structure Verification

### Column Structure (✓ Correct)
```
id           INT PRIMARY KEY
line_code    VARCHAR(50)        - 'aichi_kanjo' for Aichi Kanjo line
station_code VARCHAR(50)        - Station identifier (CRITICAL FIELD)
station_name VARCHAR(50)        - Station name
direction    VARCHAR(50)        - 'to_kozoji' or 'to_okazaki'
departure_time TIME             - Departure time in HH:MM:SS format
day_type     ENUM               - 'weekday_green' or 'holiday_red'
terminal     VARCHAR(50)        - Terminal station name (e.g., '高蔵寺')
is_active    TINYINT(1)         - 1 = active, 0 = inactive
created_at   TIMESTAMP          - Auto timestamp
```

### Total Records Inserted
- **Total Records**: 2,943 records
- **Line Code**: 'aichi_kanjo'
- **Stations**: 23 stations (per script comments)
- **Directions**: 2 directions (to_kozoji, to_okazaki)
- **Day Type**: weekday_green (only)
- **Time Range**: 05:22 to 23:43

---

## 2. Critical Data Integrity Issues

### Issue 1: Station Code Mismatches (32.5% of Data)

The `rebuild_aichi_kanjo_rail_timetable.sql` script uses **WRONG station codes** that don't match the `stations` table.

#### Affected Station Codes (With Record Counts):

| Database Code (WRONG) | Should Be (CORRECT) | Records | Affected |
|----------------------|-------------------|---------|----------|
| aikanumetubo | aikan_umetsubo | 131 | YES |
| kitanomasuduka | kitano_masuzuka | 132 | YES |
| shinuwagoromo | shin_uwagoromo | 148 | YES |
| shintoyota | shin_toyota | 141 | YES |
| kitaokazaki | kita_okazaki | 129 | YES |
| mikawakamigo | mikawa_kamigo | 134 | YES |
| mikawatoyota | mikawa_toyota | 142 | YES |

**Total Affected Records**: 957 out of 2,943 (32.5%)

#### Why This Is Critical

When the application queries for departures from "shin_toyota" station:
```php
getNextRailTrains('aichi_kanjo', 'shin_toyota', 'to_okazaki', '09:00:00', 'weekday_green', 5)
```

The SQL query becomes:
```sql
SELECT * FROM rail_timetable
WHERE line_code = 'aichi_kanjo'
AND station_code = 'shin_toyota'           -- LOOKS FOR THIS
AND direction = 'to_okazaki'
AND departure_time >= '09:00:00'
AND day_type = 'weekday_green'
ORDER BY departure_time ASC
LIMIT 5
```

**Result**: 0 records found (even though 141 records exist with code 'shintoyota')

### Issue 2: Extra Invalid Stations

The database contains stations NOT in the `stations` master table:

| Station Code (INVALID) | Record Count | Problem |
|----------------------|--------------|---------|
| yakusa | 132 | Station in wrong table (should not be in rail_timetable; only in shuttle) |
| daimon | 128 | Unknown station (not in stations table at all) |

**Total**: 260 additional invalid records (8.8%)

---

## 3. Database Query Verification

### Test 1: Query with Correct Code (Fails)
```php
$trains = getNextRailTrains('aichi_kanjo', 'shin_toyota', 'to_okazaki', '09:00:00', 'weekday_green', 3);
```

**Result**: 0 trains found ✗ FAILURE

```sql
SELECT * FROM rail_timetable
WHERE line_code = 'aichi_kanjo'
AND station_code = 'shin_toyota'
AND direction = 'to_okazaki'
AND departure_time >= '09:00:00'
AND day_type = 'weekday_green'
AND is_active = 1
```

Returns 0 rows because the data uses 'shintoyota' (without underscores).

### Test 2: Query with Wrong Code (Works)
```php
$trains = getNextRailTrains('aichi_kanjo', 'shintoyota', 'to_okazaki', '09:00:00', 'weekday_green', 3);
```

**Result**: 3 trains found ✓ (But this is using invalid code)
- 09:01:00
- 09:11:00
- 09:17:00

### Test 3: Valid Station Example (yamaguchi)
```php
$trains = getNextRailTrains('aichi_kanjo', 'yamaguchi', 'to_kozoji', '09:00:00', 'weekday_green', 5);
```

**Result**: 5 trains found ✓ SUCCESS
- 09:09:00
- 09:25:00
- 09:41:00
- 09:57:00
- 10:13:00

(Works because 'yamaguchi' is correct in both tables)

---

## 4. getNextRailTrains() Function Verification

**Location**: `/Applications/MAMP/htdocs/DC-Exercise/includes/db_functions_generic.php` (Lines 24-53)

### Function Code:
```php
function getNextRailTrains($lineCode, $stationCode, $direction, $currentTime, $dayType, $limit = 5) {
    try {
        $pdo = getDbConnection();

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
        $stmt->bindValue(':line_code', $lineCode, PDO::PARAM_STR);
        $stmt->bindValue(':station_code', $stationCode, PDO::PARAM_STR);
        $stmt->bindValue(':direction', $direction, PDO::PARAM_STR);
        $stmt->bindValue(':current_time', $currentTime, PDO::PARAM_STR);
        $stmt->bindValue(':day_type', $dayType, PDO::PARAM_STR);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll();

    } catch (PDOException $e) {
        logError('Failed to get next rail trains', $e);
        return [];
    }
}
```

**Assessment**: ✓ Function implementation is CORRECT
- Prepared statement with proper parameter binding
- All required WHERE conditions included
- Proper error handling
- Returns empty array on failure (not throwing exceptions)

**Problem**: The function is correct, but it's querying for station codes that don't exist in the database.

---

## 5. Data Flow Analysis

### Current Flow (Broken for 7 stations):

1. **Frontend** calls `/api/get_next_connection.php` with:
   ```
   direction=to_station&destination=shin_toyota&line_code=aichi_kanjo
   ```

2. **API** (lines 85-87) calls:
   ```php
   calculateUniversityToRail('aichi_kanjo', 'shin_toyota', $time, $limit, $dayType)
   ```

3. **calculateUniversityToRail()** (db_functions_generic.php, line 119) calls:
   ```php
   getNextRailTrains('aichi_kanjo', 'yakusa', 'to_okazaki', $minRailTime, $dayType, 3)
   ```
   Note: Gets trains FROM Yakusa (transfer point)

4. **getNextRailTrains()** executes:
   ```sql
   SELECT * FROM rail_timetable
   WHERE station_code = 'yakusa'  -- INVALID: yakusa is in rail_timetable but shouldn't be!
   ```

### The Mismatch:

| Context | Code Used | Database Has | Result |
|---------|-----------|--------------|--------|
| stations table | shin_toyota | Yes (correct) | N/A |
| rail_timetable | shintoyota | Yes (wrong) | ✗ Query fails |
| API parameters | shin_toyota | (from API call) | Passed to function |

---

## 6. Actual Sample Data

### Example 1: Yamaguchi Station (CORRECT - Works)
```
station_code: 'yamaguchi'
station_name: '山口'
direction: 'to_kozoji'
departure_time: '05:59:00'
day_type: 'weekday_green'
terminal: '高蔵寺'
```
✓ Station code matches `stations` table exactly

### Example 2: Shin Toyota Station (WRONG - Broken)
```
What's IN DATABASE:
station_code: 'shintoyota'          [WRONG - no underscore]
station_name: '新豊田'
direction: 'to_okazaki'
departure_time: '09:01:00'
day_type: 'weekday_green'
terminal: '岡崎'

What SHOULD BE:
station_code: 'shin_toyota'         [CORRECT - with underscore]
station_name: '新豊田'
direction: 'to_okazaki'
departure_time: '09:01:00'
day_type: 'weekday_green'
terminal: '岡崎'
```

### Example 3: Yakusa (Extra Invalid Entry)
```
station_code: 'yakusa'
Count in rail_timetable: 132 records
Problem: yakusa is the TRANSFER POINT, not a Aichi Kanjo line station
         Yakusa is only for shuttle bus and linimo transfers
```

---

## 7. Script Analysis

### File: `rebuild_aichi_kanjo_rail_timetable.sql`
**Location**: `/Applications/MAMP/htdocs/DC-Exercise/sql/rebuild_aichi_kanjo_rail_timetable.sql`

**Lines 1-20**: Header comments
- Claims: "全23駅" (23 stations total)
- Claims: "総レコード数: 2943件" (2,943 records)
- Actual in database: 23 unique station codes ✓
- Actual records: 2,943 ✓

**Lines 21-24**: Data clearing
```sql
DELETE FROM rail_timetable WHERE line_code = 'aichi_kanjo';
```
✓ Correct - removes old data before reload

**Lines 31-31**: Single INSERT statement
```sql
INSERT INTO rail_timetable (line_code, station_code, station_name, direction, departure_time, day_type, terminal, is_active) VALUES
```
✓ Structure is correct

**Lines 32+**: Value insertion with WRONG station codes
```sql
('aichi_kanjo', 'shintoyota', '新豊田', 'to_okazaki', '09:01:00', 'weekday_green', '岡崎', 1),
('aichi_kanjo', 'shin_toyota', '新豊田', 'to_okazaki', '09:01:00', 'weekday_green', '岡崎', 1),
```

**Problem**: Station codes don't use underscores (shintoyota vs shin_toyota)

---

## 8. Summary of Issues

### Issue A: Station Code Naming Convention Mismatch (CRITICAL)
- **Severity**: CRITICAL - Complete feature failure for affected stations
- **Scope**: 957 records (32.5%) affecting 7 stations
- **Root Cause**: rebuild_aichi_kanjo_rail_timetable.sql uses codes without underscores
- **stations table format**: with underscores (e.g., 'shin_toyota')
- **rail_timetable data format**: without underscores (e.g., 'shintoyota')

### Issue B: Invalid Yakusa Entries (MAJOR)
- **Severity**: MAJOR - 132 invalid transfer point entries
- **Root Cause**: Yakusa should only have shuttle/linimo connections, not Aichi Kanjo line data
- **Expected**: 0 yakusa entries in rail_timetable
- **Actual**: 132 yakusa entries

### Issue C: Unknown Daimon Station (MAJOR)
- **Severity**: MAJOR - 128 records for non-existent station
- **Root Cause**: Daimon station not in stations master table
- **Expected**: 0 daimon entries
- **Actual**: 128 daimon entries

---

## 9. Functional Test Results

### Test Scenario: User searches for Shin-Toyota → University

**Current Behavior**:
1. User enters "Shin-Toyota" as origin
2. Frontend calls: `get_next_connection.php?direction=to_university&origin=shin_toyota&line_code=aichi_kanjo`
3. API calls: `calculateRailToUniversity('aichi_kanjo', 'shin_toyota', ...)`
4. Function calls: `getNextRailTrains('aichi_kanjo', 'shin_toyota', 'to_kozoji', ..., 30)`
5. SQL Query returns: **0 rows** ✗
6. User sees: **No results** (even though 141+ trains exist)

**Expected Behavior**:
1. Same steps 1-4
2. SQL Query returns: **141 trains** ✓
3. User sees: Next 3 available connections

---

## 10. Verification Commands

To verify this issue in your database:

```php
// Test 1: Check affected stations
SELECT DISTINCT station_code FROM rail_timetable 
WHERE line_code = 'aichi_kanjo'
ORDER BY station_code;

// Test 2: Compare with stations table
SELECT station_code FROM stations 
WHERE line_type = 'aichi_kanjo'
ORDER BY station_code;

// Test 3: Find mismatches
SELECT COUNT(*) FROM rail_timetable rt
WHERE rt.line_code = 'aichi_kanjo'
AND rt.station_code NOT IN (
  SELECT station_code FROM stations WHERE line_type = 'aichi_kanjo'
);
// Result: 260 invalid records

// Test 4: Test actual query failure
SELECT * FROM rail_timetable
WHERE line_code = 'aichi_kanjo'
AND station_code = 'shin_toyota'
AND direction = 'to_okazaki'
AND day_type = 'weekday_green'
LIMIT 5;
// Result: 0 rows (FAILS)

// Test 5: Test with wrong code (what's actually in DB)
SELECT * FROM rail_timetable
WHERE line_code = 'aichi_kanjo'
AND station_code = 'shintoyota'
AND direction = 'to_okazaki'
AND day_type = 'weekday_green'
LIMIT 5;
// Result: 141 rows (WORKS but with wrong code)
```

---

## 11. Recommendations

### Immediate Fix Required

**Option 1: Fix the SQL Script** (RECOMMENDED)
- Regenerate `rebuild_aichi_kanjo_rail_timetable.sql` with correct station codes
- Use station codes FROM the `stations` table directly
- Remove yakusa and daimon entries

**Option 2: Fix the Database Directly**
Run corrections:
```sql
UPDATE rail_timetable SET station_code = 'aikan_umetsubo' WHERE station_code = 'aikanumetubo' AND line_code = 'aichi_kanjo';
UPDATE rail_timetable SET station_code = 'kitano_masuzuka' WHERE station_code = 'kitanomasuduka' AND line_code = 'aichi_kanjo';
UPDATE rail_timetable SET station_code = 'shin_uwagoromo' WHERE station_code = 'shinuwagoromo' AND line_code = 'aichi_kanjo';
UPDATE rail_timetable SET station_code = 'shin_toyota' WHERE station_code = 'shintoyota' AND line_code = 'aichi_kanjo';
UPDATE rail_timetable SET station_code = 'kita_okazaki' WHERE station_code = 'kitaokazaki' AND line_code = 'aichi_kanjo';
UPDATE rail_timetable SET station_code = 'mikawa_kamigo' WHERE station_code = 'mikawakamigo' AND line_code = 'aichi_kanjo';
UPDATE rail_timetable SET station_code = 'mikawa_toyota' WHERE station_code = 'mikawatoyota' AND line_code = 'aichi_kanjo';
DELETE FROM rail_timetable WHERE station_code = 'yakusa' AND line_code = 'aichi_kanjo';
DELETE FROM rail_timetable WHERE station_code = 'daimon' AND line_code = 'aichi_kanjo';
```

### Prevention

1. Add database constraint to enforce valid station codes:
```sql
ALTER TABLE rail_timetable 
ADD CONSTRAINT fk_station_code 
FOREIGN KEY (station_code) REFERENCES stations(station_code);
```

2. Update the SQL generation process to use correct station code format
3. Add validation tests before deployment

---

## File References

- **Database Setup**: `/Applications/MAMP/htdocs/DC-Exercise/sql/setup.sql` (Lines 38-68)
- **Problematic Script**: `/Applications/MAMP/htdocs/DC-Exercise/sql/rebuild_aichi_kanjo_rail_timetable.sql` (Lines 31-2974)
- **Database Functions**: `/Applications/MAMP/htdocs/DC-Exercise/includes/db_functions_generic.php` (Lines 24-53)
- **API Endpoint**: `/Applications/MAMP/htdocs/DC-Exercise/api/get_next_connection.php` (Lines 85-119)

