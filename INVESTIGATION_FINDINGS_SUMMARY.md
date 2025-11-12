# Aichi Kanjo Rail Timetable - Investigation Findings Summary

**Investigation Date**: 2025-11-10  
**Status**: CRITICAL DATA INTEGRITY ISSUES CONFIRMED  
**Severity**: CRITICAL - 32.5% of Aichi Kanjo data is unusable

---

## Quick Summary

The Aichi Kanjo rail timetable data in the database contains **critical station code mismatches** that completely prevent departure time retrieval for 7 stations. Users searching for connections to/from these stations will get **zero results**, even though the data exists in the database.

---

## Key Findings

### Finding 1: Station Code Mismatch (CRITICAL)
**Impact**: Complete feature failure for 7 Aichi Kanjo stations

| Issue | Count | Records Affected | Status |
|-------|-------|------------------|--------|
| Wrong station codes | 7 | 957 | CRITICAL |
| Invalid stations | 2 | 260 | MAJOR |
| **TOTAL** | **9** | **1,217 (41.4%)** | **BROKEN** |

### Finding 2: Database Structure
**Rail_Timetable Status**: ✓ Correct structure, ✗ Corrupt data

- **Columns**: Correct (10 columns including departure_time)
- **Line Code**: 'aichi_kanjo' - Correct
- **Stations**: 23 entries (but 7 with wrong codes, 2 invalid)
- **Directions**: 2 valid (to_kozoji, to_okazaki)
- **Day Types**: weekday_green only (should include holiday_red)
- **Record Count**: 2,943 total
  - 1,986 records (67.5%) = usable
  - 957 records (32.5%) = unusable due to code mismatch
  - 260 records (8.8%) = invalid stations

### Finding 3: getNextRailTrains() Function
**Status**: ✓ Function implementation is CORRECT

The PHP function in `db_functions_generic.php` is correctly implemented:
- Uses prepared statements with proper parameter binding
- Correct SQL query structure
- Proper error handling
- Returns empty array on no results

**Problem**: It queries for correct station codes that don't exist in the database.

### Finding 4: Query Verification Results

| Test Case | Query | Result | Status |
|-----------|-------|--------|--------|
| Yamaguchi (correct) | `getNextRailTrains(..., 'yamaguchi', 'to_kozoji', ...)` | 120+ rows | ✓ Works |
| Shin-Toyota (correct code) | `getNextRailTrains(..., 'shin_toyota', 'to_kozoji', ...)` | 0 rows | ✗ Fails |
| Shin-Toyota (wrong code) | `getNextRailTrains(..., 'shintoyota', 'to_kozoji', ...)` | 141 rows | ✓ Works |

---

## Detailed Issues

### Issue A: Station Code Format Mismatch

**Pattern**: Underscores removed from station codes

```
Correct (stations table)     Wrong (rail_timetable)      Records
aikan_umetsubo          -->  aikanumetubo             131
kitano_masuzuka         -->  kitanomasuduka           132
shin_uwagoromo          -->  shinuwagoromo            148
shin_toyota             -->  shintoyota               141
kita_okazaki            -->  kitaokazaki              129
mikawa_kamigo           -->  mikawakamigo             134
mikawa_toyota           -->  mikawatoyota             142
                                                     -----
                                            Total:   957
```

**Root Cause**: Data generation process (likely JSON to SQL conversion) removed underscores

**Impact**: 
- Feature 1 broken: University → Aichi Kanjo stations (7 stations)
- Feature 2 broken: Aichi Kanjo stations → University (7 stations)
- Users see: "No connections available" (false - data exists)

### Issue B: Invalid Yakusa Entries

**Location**: rail_timetable, station_code = 'yakusa'
**Records**: 132
**Problem**: Yakusa is the transfer point, should NOT appear in Aichi Kanjo timetable

Yakusa should only appear in:
- shuttle_bus_timetable (correct)
- linimo_timetable (correct)
- NOT in rail_timetable (but has 132 rows)

### Issue C: Unknown Daimon Station

**Location**: rail_timetable, station_code = 'daimon'
**Records**: 128
**Problem**: Station not in stations master table

- Not a valid Aichi Kanjo line station
- No station definition exists
- Data is orphaned and inconsistent

---

## Affected Stations

### Cannot Search FROM these stations (to_university):
1. shin_toyota (新豊田) - 141 records
2. aikan_umetsubo (愛環梅坪) - 131 records
3. kitano_masuzuka (北野桝塚) - 132 records
4. shin_uwagoromo (新上挙母) - 148 records
5. kita_okazaki (北岡崎) - 129 records
6. mikawa_kamigo (三河上郷) - 134 records
7. mikawa_toyota (三河豊田) - 142 records

### Cannot Search TO these stations (from university):
Same 7 stations as above

### Working Stations (14 of 21):
- okazaki, nakaokazaki, nakamizuno, setoshi, setoguchi, sasabara, mutsuna, shigo, ekaku, homi, kaizu, suenohara, yamaguchi, kozoji

---

## Data Flow Issue

When user searches for trains from "shin_toyota":

```
1. Frontend: /api/get_next_connection.php?origin=shin_toyota
              
2. API: calculateRailToUniversity('aichi_kanjo', 'shin_toyota', ...)

3. Function: getNextRailTrains('aichi_kanjo', 'shin_toyota', 'to_kozoji', ...)

4. SQL Query:
   SELECT * FROM rail_timetable
   WHERE station_code = 'shin_toyota'    <-- Looks for this
   AND direction = 'to_kozoji'
   
5. Database Result: 0 rows (FAILURE)
   Database actually has: 141 rows with code 'shintoyota'
   
6. User sees: "No results available"
```

---

## Verification Test Results

### Test Environment
- Database: MySQL (ait_transport)
- PHP Version: 8.3.14
- Time: 2025-11-10 11:30 AM

### Test Results

**Test 1: Direct SQL Query (shintoyota - WRONG CODE)**
```sql
SELECT * FROM rail_timetable 
WHERE station_code = 'shintoyota' AND direction = 'to_kozoji'
LIMIT 5;
```
Result: 141 rows found (times: 05:37, 05:52, 06:05, 06:21, 06:37...)

**Test 2: Direct SQL Query (shin_toyota - CORRECT CODE)**
```sql
SELECT * FROM rail_timetable 
WHERE station_code = 'shin_toyota' AND direction = 'to_kozoji'
LIMIT 5;
```
Result: 0 rows found

**Test 3: Function Call with Correct Code**
```php
$trains = getNextRailTrains('aichi_kanjo', 'shin_toyota', 'to_kozoji', '09:00:00', 'weekday_green', 5);
```
Result: Empty array (0 trains)

**Test 4: Function Call with Wrong Code**
```php
$trains = getNextRailTrains('aichi_kanjo', 'shintoyota', 'to_kozoji', '09:00:00', 'weekday_green', 5);
```
Result: 3 trains (09:01:00, 09:11:00, 09:17:00)

**Test 5: Station Code Comparison**
```
Stations in stations table (aichi_kanjo):        21 stations
Unique codes in rail_timetable (aichi_kanjo):   23 codes
Mismatch: 7 stations have different codes
```

---

## Root Cause

### Source of Issue
**File**: `sql/rebuild_aichi_kanjo_rail_timetable.sql`
**Lines**: 31 (INSERT statement) through 2974 (last value)
**Comment**: "JSONデータから正確に抽出した" (extracted accurately from JSON data)

**Problem**: JSON → SQL conversion removed underscores from station codes

**Evidence**: 
- Script comment claims accuracy from JSON
- All 7 affected stations have systematic underscore removal
- Pattern is consistent: `shin_toyota` → `shintoyota`
- Suggests automated conversion error, not manual typo

---

## Recommendations

### IMMEDIATE ACTION REQUIRED

#### Option A: Fix SQL Script (RECOMMENDED)
1. Regenerate `rebuild_aichi_kanjo_rail_timetable.sql` with correct codes
2. Use station codes directly from `stations` table
3. Remove yakusa and daimon entries
4. Include holiday_red day_type (currently missing)
5. Re-run: `mysql -u root -p ait_transport < sql/rebuild_aichi_kanjo_rail_timetable.sql`

#### Option B: Fix Database Directly
Run these UPDATE statements:
```sql
UPDATE rail_timetable SET station_code = 'aikan_umetsubo' 
WHERE station_code = 'aikanumetubo' AND line_code = 'aichi_kanjo';

UPDATE rail_timetable SET station_code = 'kitano_masuzuka' 
WHERE station_code = 'kitanomasuduka' AND line_code = 'aichi_kanjo';

UPDATE rail_timetable SET station_code = 'shin_uwagoromo' 
WHERE station_code = 'shinuwagoromo' AND line_code = 'aichi_kanjo';

UPDATE rail_timetable SET station_code = 'shin_toyota' 
WHERE station_code = 'shintoyota' AND line_code = 'aichi_kanjo';

UPDATE rail_timetable SET station_code = 'kita_okazaki' 
WHERE station_code = 'kitaokazaki' AND line_code = 'aichi_kanjo';

UPDATE rail_timetable SET station_code = 'mikawa_kamigo' 
WHERE station_code = 'mikawakamigo' AND line_code = 'aichi_kanjo';

UPDATE rail_timetable SET station_code = 'mikawa_toyota' 
WHERE station_code = 'mikawatoyota' AND line_code = 'aichi_kanjo';

DELETE FROM rail_timetable 
WHERE station_code = 'yakusa' AND line_code = 'aichi_kanjo';

DELETE FROM rail_timetable 
WHERE station_code = 'daimon' AND line_code = 'aichi_kanjo';
```

### LONG-TERM PREVENTION

1. **Add Foreign Key Constraint**
```sql
ALTER TABLE rail_timetable 
ADD CONSTRAINT fk_rail_station_code 
FOREIGN KEY (station_code) REFERENCES stations(station_code);
```

2. **Add Validation Tests**
- Query each station code before deployment
- Verify all stations have >0 records
- Compare rail_timetable codes with stations table

3. **Data Generation Process**
- Document JSON to SQL conversion rules
- Test underscore handling in conversion
- Add pre-deployment validation

---

## File References

**Report Files** (newly created):
- `/Applications/MAMP/htdocs/DC-Exercise/AICHI_KANJO_DATA_VERIFICATION_REPORT.md` - Full investigation
- `/Applications/MAMP/htdocs/DC-Exercise/DETAILED_CODE_AND_DATA_FLOW_ANALYSIS.md` - Technical analysis
- `/Applications/MAMP/htdocs/DC-Exercise/INVESTIGATION_FINDINGS_SUMMARY.md` - This file

**Source Files**:
- `/Applications/MAMP/htdocs/DC-Exercise/sql/setup.sql` - Station definitions (lines 38-68)
- `/Applications/MAMP/htdocs/DC-Exercise/sql/rebuild_aichi_kanjo_rail_timetable.sql` - Problem source
- `/Applications/MAMP/htdocs/DC-Exercise/includes/db_functions_generic.php` - getNextRailTrains() function
- `/Applications/MAMP/htdocs/DC-Exercise/api/get_next_connection.php` - API endpoint

---

## Next Steps

1. **Verify Issue** (DONE)
   - Confirmed 957 records with mismatched codes
   - Confirmed 260 records with invalid stations
   - Confirmed queries return 0 results for 7 stations

2. **Fix Data** (REQUIRED)
   - Choose Option A (script fix) or Option B (database updates)
   - Recommend Option A for completeness

3. **Test Fix** (REQUIRED)
   - Run queries for each affected station
   - Verify results match expected record counts
   - Test full search flow end-to-end

4. **Implement Prevention** (RECOMMENDED)
   - Add foreign key constraint
   - Add validation tests
   - Document data generation process

---

## Questions for Investigation

1. Why was yakusa added to rail_timetable? (Should be shuttle/linimo only)
2. What is "daimon" station? (Not a valid Aichi Kanjo station)
3. Where did the JSON data come from? (Original source?)
4. Was there a conversion tool that removed underscores?
5. Should holiday_red data be added to rail_timetable?

---

**Investigation Complete**: All findings verified with live database queries  
**Recommendation**: Implement immediate fix (Option A preferred)  
**Timeline**: Fix can be deployed within 1 hour
