# Aichi Kanjo to University Data Flow - Complete Documentation Index

This documentation package contains three comprehensive guides tracing the complete data flow for Aichi Kanjo (愛知環状線) to University routes.

## Quick Navigation

### For Quick Understanding (5-10 minutes)
Start with: **AICHI_KANJO_QUICK_REFERENCE.txt**
- Essential facts and quick lookup table
- Key files and line numbers
- Debugging checklist
- API response examples

### For Visual Understanding (10-15 minutes)
Start with: **AICHI_KANJO_VISUAL_SUMMARY.txt**
- ASCII flowchart showing complete data flow
- Step-by-step process visualization
- Key transformations table
- Color-coded flow with ASCII boxes

### For Complete Deep Dive (30-45 minutes)
Start with: **AICHI_KANJO_DATA_FLOW.md**
- Comprehensive line-by-line code walkthrough
- Database schema with examples
- Complete response structure
- All transformations and calculations
- Detailed notes and key insights

---

## Quick Summary

**Question:** Where do Aichi Kanjo departure times come from?

**Answer:** From the database `rail_timetable` table, column `departure_time`.

**Path:** 
```
Database (rail_timetable.departure_time) 
  → PHP (getNextRailTrains query)
  → JSON API response ('rail_departure' field)
  → JavaScript (route.rail_departure)
  → HTML display ("14:33 発")
```

**Key Database Query:**
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

---

## Core Data Points

### Request Parameters
- **Direction:** `to_university`
- **Line Code:** `aichi_kanjo`
- **Origin:** User-selected station (e.g., `yamaguchi`)
- **Destination:** null (unused)

### Key Functions (Call Chain)
1. `index.html` - User interface (Lines 52-59)
2. `assets/js/index.js::setRouteOption()` - Route selection (Lines 1416-1452)
3. `assets/js/api.js::getNextConnection()` - API request (Lines 55-73)
4. `api/get_next_connection.php` - Request routing (Lines 91-110)
5. `includes/db_functions_generic.php::calculateRailToUniversity()` - Main logic (Lines 190-302)
6. `includes/db_functions_generic.php::getNextRailTrains()` - Database query (Lines 24-53)

### Database Tables
- **rail_timetable** - Contains actual departure times
  - Columns: line_code, station_code, direction, departure_time, day_type, ...
  - Primary Query Column: departure_time
  
- **stations** - Contains station metadata
  - Columns: station_code, station_name, travel_time_from_yakusa, ...
  - Usage: Travel time calculation from Yakusa

### JSON Response Field
- **Field Name:** `rail_departure`
- **Parent:** Route object in `routes` array
- **Example Value:** `"14:33:00"`
- **Format:** HH:MM:SS (later formatted to HH:MM in JavaScript)

### Frontend Rendering
- **Access Path:** `route.rail_departure`
- **Format Function:** `formatTimeWithoutSeconds()`
- **Display:** "14:33 発" (departs at 14:33)

---

## Critical Differences: Aichi Kanjo vs Linimo

| Aspect | Linimo | Aichi Kanjo |
|--------|--------|-------------|
| **Function** | calculateStationToUniversity() | calculateRailToUniversity() |
| **Database** | linimo_timetable | rail_timetable |
| **JSON Field** | linimo_departure | rail_departure |
| **Direction** | to_yagusa | to_kozoji (default) or to_okazaki (fallback) |
| **Reverse Calc** | Not used | Used if direct trains not found |
| **Travel Time** | From Yakusa metadata | From Yakusa metadata |

---

## Data Transformations

```
DATABASE LAYER:
  rail_timetable.departure_time (TIME type)
  Example: '14:33:00'
         ↓
PHP LAYER:
  formatTime() called
  Returns string: '14:33:00'
         ↓
JSON API:
  'rail_departure': '14:33:00'
         ↓
JAVASCRIPT LAYER:
  route.rail_departure = '14:33:00'
  formatTimeWithoutSeconds() called
  Returns: '14:33'
         ↓
HTML DISPLAY:
  "14:33 発"
```

---

## Important Notes

1. **Departure times are NOT calculated** - They are actual database entries
2. **Day type matters** - Filtered by 'weekday_green' or 'holiday_red' (NOT shuttle A/B/C)
3. **Direction logic** - Aichi Kanjo is a circular line; system defaults to 'to_kozoji' direction
4. **Reverse calculation** - If no direct trains found, system queries Yakusa station in opposite direction
5. **Multiple routes** - System returns up to 3 route options, each with multiple shuttle alternatives

---

## How to Use These Documents

### Scenario 1: Quick Fact Lookup
**Use:** AICHI_KANJO_QUICK_REFERENCE.txt
- Find field names, file locations, and key functions
- Use debugging checklist
- Look at API response examples

### Scenario 2: Understanding the Flow
**Use:** AICHI_KANJO_VISUAL_SUMMARY.txt
- Follow the ASCII flowchart
- See how data moves through the system
- Understand the transformation pipeline

### Scenario 3: Implementation/Debugging
**Use:** AICHI_KANJO_DATA_FLOW.md
- Read code line-by-line explanations
- Find exact SQL queries
- See complete database schema
- View response structure examples

### Scenario 4: Development
**Use:** All three documents
- Use Quick Reference for navigation
- Use Visual Summary to understand architecture
- Use Data Flow for detailed implementation

---

## Key Files Reference

| File Path | Purpose | Critical Sections |
|-----------|---------|-------------------|
| `/Applications/MAMP/htdocs/DC-Exercise/index.html` | User interface | Lines 52-59 (radio button) |
| `/Applications/MAMP/htdocs/DC-Exercise/assets/js/index.js` | Frontend logic | Lines 1416-1452, 145-160, 256-404 |
| `/Applications/MAMP/htdocs/DC-Exercise/assets/js/api.js` | API communication | Lines 55-73 |
| `/Applications/MAMP/htdocs/DC-Exercise/api/get_next_connection.php` | API endpoint | Lines 91-110 |
| `/Applications/MAMP/htdocs/DC-Exercise/includes/db_functions_generic.php` | Core logic | Lines 190-302, 24-53 |
| `/Applications/MAMP/htdocs/DC-Exercise/includes/db_functions.php` | Database helpers | Lines 93-108 |
| `/Applications/MAMP/htdocs/DC-Exercise/sql/setup.sql` | Schema | Tables for rail_timetable and stations |

---

## Direct Answers to Common Questions

**Q: Where does the departure time come from?**
A: `rail_timetable.departure_time` column in the database.

**Q: Is it calculated or estimated?**
A: Neither - it's an actual timetable entry stored in the database.

**Q: What function retrieves it?**
A: `getNextRailTrains()` in `includes/db_functions_generic.php` (Lines 24-53)

**Q: What's the JSON field name?**
A: `rail_departure` in the route response object.

**Q: How does JavaScript access it?**
A: `route.rail_departure` (string, format: "HH:MM:SS")

**Q: How is it displayed?**
A: After `formatTimeWithoutSeconds()` converts "14:33:00" to "14:33", displayed as "14:33 発"

**Q: What if no trains are found?**
A: System tries reverse calculation using Yakusa station in opposite direction.

**Q: Why 'to_kozoji' direction?**
A: Aichi Kanjo is a circular line; this is the default direction toward Yakusa. Fallback is 'to_okazaki'.

---

## Version Information

- **Documentation Created:** 2025-11-10
- **For System:** AIT Transport System (愛知工業大学 交通情報システム)
- **Codebase:** DC-Exercise
- **Coverage:** Complete data flow for aichi_kanjo to_university routes

---

## Related Documentation

- **CLAUDE.md** - Overall system architecture and design
- **DEPLOYMENT.md** - Deployment instructions
- **README.md** - Project overview

---

## Document Sizes

- **AICHI_KANJO_QUICK_REFERENCE.txt** - 10 KB (Quick lookup)
- **AICHI_KANJO_VISUAL_SUMMARY.txt** - 25 KB (Visual explanation)
- **AICHI_KANJO_DATA_FLOW.md** - 28 KB (Complete reference)
- **AICHI_KANJO_DOCUMENTATION_INDEX.md** - This file

**Total Documentation:** 63 KB of comprehensive guides

---

## How to Navigate

1. **Just arriving?** Start with the Quick Reference
2. **Visual learner?** Start with the Visual Summary
3. **Need details?** Start with the Data Flow guide
4. **Looking for specific code?** Use the file reference tables
5. **Debugging?** Check the debugging checklist in Quick Reference

---

*End of Documentation Index*
