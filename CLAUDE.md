# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a web application for Aichi Institute of Technology (AIT) that displays shuttle bus and Linimo (light rail) timetables and optimal transfer routes. The system helps users minimize waiting time when traveling between the university campus and Linimo stations via the Yagusa Station shuttle bus connection.

**Target Users**: AIT students, faculty, staff, and visitors

**Phase 1 Scope**:
- Shuttle bus: Yagusa Station ⇔ AIT Campus
- Linimo rail: Yagusa Station → Fujigaoka Station (all intermediate stations)

## Technology Stack

- **Frontend**: Vanilla JavaScript (no frameworks), HTML5, CSS3
- **Backend**: PHP 7.4+
- **Database**: MySQL 5.7+
- **Development Environment**: MAMP (Mac, Apache, MySQL, PHP)

## Project Structure (Planned)

```
/project-root/
├── index.php              # Top page (next available connection)
├── timetable.php          # Timetable display
├── search.php             # Transfer search results
├── api/
│   ├── get_next_connection.php    # Get next connection API
│   ├── search_connection.php      # Transfer search API
│   └── get_timetable.php          # Get timetable API
├── config/
│   ├── database.php       # DB connection config
│   └── settings.php       # System settings (transfer time, etc.)
├── includes/
│   ├── functions.php      # Common functions
│   └── db_functions.php   # DB operation functions
├── assets/
│   ├── css/style.css
│   └── js/app.js
└── sql/
    └── setup.sql          # DB initialization script
```

## Database Schema

### Core Tables

1. **shuttle_bus_timetable**: Shuttle bus schedules (3 diagram types: A/B/C)
2. **linimo_timetable**: Linimo rail schedules (weekday_green/holiday_red)
3. **stations**: Station master data with travel times from Yagusa
4. **notices**: Operation notices (delays, suspensions, info)
5. **system_settings**: Configurable parameters (transfer_time_minutes, current_dia_type, etc.)

### Key Design Decisions

- **Shuttle Bus Diagram Types**:
  - A: Regular semester weekdays (Apr-Jul, Oct-Jan)
  - B: Saturdays
  - C: School vacation periods (Aug, Sep, Feb, Mar weekdays)

- **Linimo Schedule Types**:
  - weekday_green: Apr-Jul, Oct-Jan weekdays
  - holiday_red: Holidays + Aug, Sep, Feb, Mar weekdays

- **Transfer Time**: Default 10 minutes (configurable in system_settings)
- **Shuttle Travel Time**: ~5 minutes
- **Linimo Travel Time**: 2 minutes between stations (3 min for final segment to Fujigaoka)

## Core Algorithm: Transfer Route Optimization

The system calculates optimal transfer routes by:

### Pattern A: University → Linimo Station
1. Get shuttle buses departing after current time
2. Calculate Yagusa arrival time for each shuttle
3. Find Linimo departures after (arrival_time + transfer_time)
4. Calculate total travel time to destination
5. Sort by waiting time and return top N results

### Pattern B: Linimo Station → University
1. Get Linimo trains from origin to Yagusa
2. Calculate Yagusa arrival time
3. Find shuttle buses after (arrival_time + transfer_time)
4. Calculate total travel time
5. Sort and return top N results

**Formula**:
```
total_time = shuttle_time + transfer_time + linimo_time
waiting_time = next_departure - current_time
```

## Configuration Management

Frequently changed settings should be managed via `config/settings.php` or `system_settings` table:

- `transfer_time_minutes`: Transfer time buffer (default: 10)
- `current_dia_type`: Active shuttle diagram (A/B/C)
- `default_destination`: Default destination station (default: fujigaoka)
- `result_limit`: Number of route candidates to display (default: 3)

## API Design

All APIs return JSON responses with structure:
```json
{
  "success": true/false,
  "data": { ... },
  "error": "error message" (if applicable)
}
```

## Development Notes

- **Mobile-First**: Responsive design prioritizing smartphone users
- **No Authentication**: Public access system
- **Data Updates**: Timetable changes require manual DB updates via SQL scripts
- **Security**: Use prepared statements for all queries, escape all output
- **Performance**: Target page load < 3 seconds
- **Maintainability**: All configurable parameters in settings files, not hardcoded

## Data Sources

The repository includes PDF timetables:
- `シャトルバス時刻表.pdf`: Shuttle bus schedules with all three diagram types
- `シャトルバス運行日程.pdf`: Shuttle bus operation calendar
- `リニモ時刻表.pdf`: Linimo rail timetables

These PDFs are the authoritative source for timetable data and should be parsed to populate the database.

## Future Phases

- **Phase 2**: Aichi Kanjō Line integration, favorites feature, admin panel
- **Phase 3**: Real-time delay information, push notifications
