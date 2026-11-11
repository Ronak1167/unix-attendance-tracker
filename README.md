# UNIX-Based Student Attendance Tracker

**Jaypee Institute of Information Technology, Noida-62**  
*Department of Computer Science & Engineering and Information Technology*  
*Course:* Unix Programming Lab (`24B15CS214`) | **Year 2026-2027 (Batch B2)**  

---

### Project Information
- **Course Name:** Unix Programming Lab
- **Course Code:** 24B15CS214
- **Project Title:** UNIX-Based Student Attendance Tracker
- **Submitted To:** Prof. Hema N & Kritika Rohila
- **Submitted By:**
  1. **Pragya Ahlawat** (Enrolment No: `2501030121`)
  2. **Ronak Jain** (Enrolment No: `2501030128`)
  3. **Rishabh Tyagi** (Enrolment No: `2501030130`)
  4. **Shobhit Khatana** (Enrolment No: `2501030144`)

---

## 1. Project Overview & Architecture

The **UNIX-Based Student Attendance Tracker** is a modular, menu-driven command-line application built natively using POSIX shell scripting and core Linux/UNIX utilities (`awk`, `sed`, `grep`, `tar`, `gzip`, `chmod`, `ln`, `sort`, `cut`). 

Designed specifically to address the syllabus requirements of the JIIT Unix Programming Lab, it provides automated daily attendance recording, dynamic analytics, threshold alerts (< 75% defaulter detection), automated log compression/archiving, and strict permission-based access control without any external database or heavy runtime dependencies.

```
unix-attendance-tracker/
├── attendance.sh              # Master interactive CLI controller & argument dispatcher
├── data/
│   ├── students.csv           # Master database (RollNo, Name, Batch, Email)
│   └── current_day.log -> logs/att_YYYY-MM-DD.log  # Symbolic link (ln -sf) to active session
├── logs/
│   ├── att_2026-11-01.log     # Daily attendance logs with timestamps (YYYY-MM-DD)
│   ├── att_2026-11-02.log
│   └── ...
├── archives/
│   └── attendance_archive_YYYY-MM.tar.gz  # Compressed monthly backups (tar + gzip)
├── reports/
│   ├── attendance_summary_*.txt           # Exported human-readable summary reports
│   └── attendance_summary_*.csv           # Exported analytical CSV exports
├── scripts/
│   ├── common.sh              # Constants, colors, validation, and directory initializer
│   ├── student_ops.sh         # CRUD operations: add, remove, search, list (awk, sed, grep)
│   ├── mark_attendance.sh     # Daily marking (Rapid & Sequential modes, symlink generator)
│   ├── report_generator.awk   # Analytical AWK engine (calculates %, defaulters, student cards)
│   ├── report_ops.sh          # Reporting wrapper & export manager
│   ├── archive.sh             # Compression & restoration utility (tar -czvf / tar -xzvf)
│   └── security.sh            # POSIX permission hardening & audit utility (chmod 600/700/755)
├── tests/
│   └── run_tests.sh           # Automated 35-point regression & verification test harness
└── README.md                  # System manual and documentation
```

---

## 2. Core UNIX Utilities Used & Synopsis Alignment

| Requirement in Synopsis | UNIX Utility Used | Implementation Details |
| :--- | :--- | :--- |
| **Data Extraction & Analytics** | `awk` (GNU Awk) | Multi-file evaluation (`report_generator.awk`) cross-referencing `students.csv` and daily `att_*.log` files to calculate percentages and flag < 75% defaulters. |
| **Record Modification & Deletion** | `sed` (Stream Editor) | In-place atomic deletion of student records (`sed -i "/^$roll,/d"`). |
| **Query & Pattern Matching** | `grep` | Real-time case-insensitive lookup (`grep -i`) and duplicate roll number prevention (`grep -q "^$roll,"`). |
| **Field Splitting & Sorting** | `cut`, `tr`, `sort` | Input sanitization, whitespace stripping, and numeric sorting of master records (`sort -t',' -k1,1n`). |
| **Daily Session Link** | `ln` (Symbolic Link) | Atomic creation of soft link (`ln -sf "$log_file" "$DATA_DIR/current_day.log"`) pointing directly to the active session. |
| **Log Compression & Backups** | `tar`, `gzip` | Monthly archiving into `.tar.gz` with integrity verification (`tar -tzf`) and extraction (`tar -xzvf`). |
| **File Permissions & Security** | `chmod`, `stat` | Enforces `chmod 600` on master DB and logs (private), `chmod 700` on log directories, and `chmod 755` on executables. |

---

## 3. How OOP Concepts Are Simulated in POSIX Shell

As required by the JIIT Unix Programming Lab format (Chapter 2.2 and Chapter 4.1):

1. **Encapsulation**:
   - Master data files (`students.csv`) and raw logs are isolated within `data/` and `logs/`.
   - Access to raw files is restricted behind dedicated controller functions (`student_ops.sh`, `mark_attendance.sh`).
   - File permissions (`chmod 600`) act as **private access modifiers**, ensuring that only the authorized administrator can modify files directly.
2. **Abstraction**:
   - Users and faculty interact solely with high-level menu options in `attendance.sh`.
   - Complex internal pipe mechanics (AWK arrays, regular expressions, tar compression) are abstracted away.
3. **Modularity / Class Simulation**:
   - Distinct real-world domain entities are modeled in isolated scripts:
     - `student_ops.sh` represents the `Student` entity manager.
     - `mark_attendance.sh` represents the `AttendanceSession` entity.
     - `report_generator.awk` represents the `AnalyticsEngine` service.
     - `archive.sh` represents the `BackupManager` service.

---

## 4. Execution & Quickstart Guide

### Prerequisites
- Any standard Linux distribution (Ubuntu, Debian, Fedora, CentOS) OR **Windows Subsystem for Linux (WSL)** / macOS.
- GNU Bash v4.0 or higher.

### Step 1: Clone the Repository & Navigate In
```bash
git clone https://github.com/Ronak1167/unix-attendance-tracker.git
cd unix-attendance-tracker
```

### Step 2: Grant Execution Permissions (POSIX Systems)
```bash
chmod +x attendance.sh scripts/*.sh tests/*.sh
```

### Step 3: Run Interactive Application
```bash
./attendance.sh
```

### Step 4: Run Direct Command-Line Shortcuts
```bash
./attendance.sh --students     # View Master Student Directory
./attendance.sh --report       # View Full Attendance Audit & Statistics
./attendance.sh --defaulters   # View Students strictly below 75% attendance
./attendance.sh --test         # Execute Full Automated Test Suite
```

---

## 5. Automated Verification & Testing

The project includes an automated 35-point regression test harness (`tests/run_tests.sh`) that verifies all functional modules without manual human input:

```bash
./tests/run_tests.sh
```

### Test Coverage Highlights:
- **Suite 1: Filesystem & Environment** (Directory initialization, CSV headers).
- **Suite 2: Student Record CRUD** (Addition, duplicate roll number rejection, non-numeric validation, search, deletion via sed).
- **Suite 3: Multi-Session Logging** (Multi-day logs, automated timestamps, symlink resolution).
- **Suite 4: AWK Analytics & Defaulter Detection** (Exact percentage calculations, defaulter detection below 75%, individual student transcripts).
- **Suite 5: Report Persistence** (Exporting formatted text reports and analytical CSV summaries).
- **Suite 6: Archiving & Compression** (tar + gzip creation, tar integrity verification, decompression).
- **Suite 7: UNIX Security Hardening** (chmod 600/700/755 verification, audit table, temp cleanup).

---

## 6. Sustainable Development Goals (SDGs) Addressed

- **Primary SDG:** **SDG 4 - Quality Education** (Target 4.1): Transparent tracking of academic attendance, reducing student absenteeism, and early identification of at-risk students through automated defaulter alerts.
- **Secondary SDG:** **SDG 12 - Responsible Consumption and Production**: Eliminates paper-based attendance registers and heavy physical paperwork, transitioning institutions to a zero-paper, low-compute digital workflow.
- **Secondary SDG:** **SDG 9 - Industry, Innovation, and Infrastructure**: Demonstrates sustainable, ultra-lightweight software architecture running efficiently on low-resource hardware without high cloud carbon footprints.

