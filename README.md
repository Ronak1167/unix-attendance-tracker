# UNIX-Based Student Attendance Tracker

**Jaypee Institute of Information Technology, Noida-62**  
*Department of Computer Science & Engineering and Information Technology*  
*Course:* Unix Programming Lab (`24B15CS214`) | **Academic Year: 2026-2027 (Batch B2)**  

---

### Project Information & Team Details
- **Project Title:** UNIX-Based Student Attendance Tracker
- **Course Name:** Unix Programming Lab
- **Course Code:** `24B15CS214`
- **Submitted To:** **Prof. Hema N** & **Prof. Kritika Rohila**
- **Submitted By (Batch B2):**
  1. **Pragya Ahlawat** (Enrolment No: `2501030121`)
  2. **Ronak Jain** (Enrolment No: `2501030128`)
  3. **Rishabh Tyagi** (Enrolment No: `2501030130`)
  4. **Shobhit Khatana** (Enrolment No: `2501030144`)
- **GitHub Repository:** [https://github.com/Ronak1167/unix-attendance-tracker](https://github.com/Ronak1167/unix-attendance-tracker)

---

## Table of Contents
1. [Project Overview & Architecture](#1-project-overview--architecture)
2. [What Features the System Has & What It Can Do](#2-what-features-the-system-has--what-it-can-do)
3. [Zero-Hardcoding & Cross-Platform Portability](#3-zero-hardcoding--cross-platform-portability)
4. [How to Setup & Run on Any Laptop](#4-how-to-setup--run-on-any-laptop)
5. [Interactive Menu Navigation Guide](#5-interactive-menu-navigation-guide)
6. [Quick Command-Line Shortcuts (CLI Mode)](#6-quick-command-line-shortcuts-cli-mode)
7. [Faculty Presentation Demo Script (Step-by-Step)](#7-faculty-presentation-demo-script-step-by-step)
8. [Faculty Viva Q&A Cheat Sheet](#8-faculty-viva-qa-cheat-sheet)
9. [Emergency Troubleshooting & Quick Fixes](#9-emergency-troubleshooting--quick-fixes)
10. [Sustainable Development Goals (SDGs)](#10-sustainable-development-goals-sdgs)

---

## 1. Project Overview & Architecture

The **UNIX-Based Student Attendance Tracker** is a modular, high-performance command-line application built natively using POSIX-compliant GNU Bash and core UNIX text processing and file management utilities (`awk`, `sed`, `grep`, `tar`, `gzip`, `chmod`, `ln`, `sort`, `cut`). 

Designed specifically for the laboratory curriculum of the JIIT Department of CSE & IT, it delivers daily attendance logging with automated timestamps, multi-session analytics, threshold alerts (< 75% defaulter detection), automated log compression/archiving, and strict POSIX permission hardening without requiring external database engines (like MySQL) or heavy runtime environments.

### System Directory Layout
```text
unix-attendance-tracker/
├── attendance.sh              # Master interactive CLI controller & argument dispatcher
├── data/
│   ├── students.csv           # Master database (RollNo, Name, Batch, Email)
│   └── current_day.log -> logs/att_YYYY-MM-DD.log  # Symbolic link (ln -sf) to active session
├── logs/
│   ├── att_2026-11-01.log     # Daily transaction logs with timestamps (YYYY-MM-DD)
│   ├── att_2026-11-02.log
│   └── ...
├── archives/
│   └── attendance_archive_YYYY-MM.tar.gz  # Compressed monthly backups (tar + gzip)
├── reports/
│   ├── attendance_summary_*.txt           # Formatted tabular audit reports
│   └── attendance_summary_*.csv           # Analytical CSV exports
├── scripts/
│   ├── common.sh              # Shared configuration, colors, timestamps, border helper
│   ├── student_ops.sh         # CRUD operations: add, remove, search, list (awk, sed, grep)
│   ├── mark_attendance.sh     # Daily marking (Rapid & Step modes, symlink generator)
│   ├── report_generator.awk   # Multi-file analytical AWK engine (% & defaulter logic)
│   ├── report_ops.sh          # Reporting wrapper & export manager
│   ├── archive.sh             # Compression & restoration utility (tar -czvf / tar -xzvf)
│   └── security.sh            # POSIX permission hardening & audit utility (chmod 600/700/755)
├── tests/
│   └── run_tests.sh           # Automated 35-point regression & verification test harness
├── JIIT_Unix_Lab_PBL_Report.md# Complete 4-Chapter Lab Report matching JIIT format
└── README.md                  # Comprehensive documentation and viva manual
```

---

## 2. What Features the System Has & What It Can Do

| Feature Module | Script | UNIX Tools Used | Capabilities |
| :--- | :--- | :--- | :--- |
| **1. Student Management (CRUD)** | `student_ops.sh` | `awk`, `sed`, `grep`, `sort` | • **Add Student:** Validates numeric roll number, checks for duplicates via `grep -q`, appends to master CSV, and keeps records numerically sorted.<br>• **Delete Student:** Uses atomic in-place deletion (`sed -i`) with safety backup creation (`.bak`).<br>• **Search Student:** Fast case-insensitive keyword search (`grep -i`) by Roll Number or Name.<br>• **Directory Table:** Displays all students in an aligned tabular view. |
| **2. Daily Attendance Marking** | `mark_attendance.sh` | `date`, `ln`, `awk`, `cat` | • **Standard Date Format:** Uses `YYYY-MM-DD` (e.g. `2026-11-11`).<br>• **Live Timestamps:** Every record logs the exact time of entry (`YYYY-MM-DD HH:MM:SS`).<br>• **Two Marking Workflows:**<br>&nbsp;&nbsp;&nbsp;&nbsp;a) *Rapid Exception Mode:* Defaults all students to `PRESENT`; instructor enters only absent roll numbers.<br>&nbsp;&nbsp;&nbsp;&nbsp;b) *Step-by-Step Mode:* Prompts student by student (`[P/a]`, Enter defaults to `P`).<br>• **Duplicate Protection:** Warns if today's attendance has already been logged. |
| **3. Active Session Pointer** | `mark_attendance.sh` | `ln -sf`, `readlink` | • Creates a dynamic POSIX soft link: `data/current_day.log -> logs/att_YYYY-MM-DD.log`.<br>• Allows faculty to immediately inspect today's session in $O(1)$ time without searching directories. |
| **4. AWK Analytics & Defaulter Engine** | `report_generator.awk` | `gawk` / `awk` | • **Cross-Referencing:** Evaluates `students.csv` against multiple `logs/att_*.log` files in a single pass.<br>• **Mathematical Calculation:** Computes Total Held, Attended, Absent, and Attendance % down to 2 decimal places.<br>• **Defaulter Categorization:** Flags students strictly below the 75% threshold (or custom threshold).<br>• **Individual Transcripts:** Detailed date-by-date attendance card for any specific student. |
| **5. Analytical Disk Exports** | `report_ops.sh` | `awk`, `cat` | • Generates human-readable `.txt` audit reports in `reports/`.<br>• Generates structured `.csv` files for downstream Excel/ERP ingestion with generation timestamps. |
| **6. Monthly Log Archival & Backup** | `archive.sh` | `tar`, `gzip`, `find`, `du` | • Compresses monthly logs (`att_YYYY-MM-*.log`) into `attendance_archive_YYYY-MM.tar.gz` using `tar -czvf`.<br>• Verifies archive integrity using `tar -tzf`.<br>• Supports full archive decompression (`tar -xzvf`) to restore old logs.<br>• Optionally purges raw archived logs to recover disk space. |
| **7. UNIX Security & Permission Hardening** | `security.sh` | `chmod`, `stat`, `ls` | • Enforces Discretionary Access Control (DAC):<br>&nbsp;&nbsp;&nbsp;&nbsp;`chmod 600` on `students.csv` and daily logs (admin read/write only).<br>&nbsp;&nbsp;&nbsp;&nbsp;`chmod 700` on `logs/`, `archives/`, `reports/` directories.<br>&nbsp;&nbsp;&nbsp;&nbsp;`chmod 755` on executable scripts.<br>• Generates a live permission audit compliance table. |
| **8. Automated 35-Point Test Suite** | `run_tests.sh` | `bash`, coreutils | • Fully automated test harness verifying all 7 modules end-to-end with 100% test pass metrics. |

---

## 3. Zero-Hardcoding & Cross-Platform Portability

1. **No Hardcoded Machine Paths**: Every script calculates its base location dynamically using:
   ```bash
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
   ```
   The repository can be cloned into `/home/user`, `C:\workspace`, `/tmp`, or a USB flash drive, and it will run immediately without any configuration edits.
2. **Standard POSIX Line Feeds (`LF`)**: All scripts are saved with native Unix LF (`\n`) line endings. No `\r\n` (CRLF) corruption.
3. **Supported Operating Systems**:
   - Ubuntu / Debian / Fedora / Arch Linux / CentOS
   - Windows 10 / 11 using **Windows Subsystem for Linux (WSL2)** or **Git Bash**
   - macOS (all versions, Terminal / zsh / bash)

---

## 4. How to Setup & Run on Any Laptop

### Method A: Running on Windows (via WSL Ubuntu or Git Bash)
1. Open **PowerShell** or **Windows Terminal** and enter WSL:
   ```powershell
   wsl
   ```
2. Clone the repository and navigate in:
   ```bash
   git clone https://github.com/Ronak1167/unix-attendance-tracker.git
   cd unix-attendance-tracker
   ```
3. Grant execution permissions:
   ```bash
   chmod +x attendance.sh scripts/*.sh tests/*.sh
   ```
4. Launch the application:
   ```bash
   ./attendance.sh
   ```

### Method B: Running on macOS (MacBook)
1. Open the **Terminal** app.
2. Clone and run:
   ```bash
   git clone https://github.com/Ronak1167/unix-attendance-tracker.git
   cd unix-attendance-tracker
   chmod +x attendance.sh scripts/*.sh tests/*.sh
   ./attendance.sh
   ```

### Method C: Running on Linux (Ubuntu Lab Computers)
1. Open terminal (`Ctrl + Alt + T`).
2. Run:
   ```bash
   git clone https://github.com/Ronak1167/unix-attendance-tracker.git
   cd unix-attendance-tracker
   chmod +x attendance.sh scripts/*.sh tests/*.sh
   ./attendance.sh
   ```

---

## 5. Interactive Menu Navigation Guide

When launched via `./attendance.sh`, you are presented with an ANSI-colored menu:

```text
==================================================================================================
                  JAYPEE INSTITUTE OF INFORMATION TECHNOLOGY, NOIDA-62                  
                    Department of Computer Science & Engineering and IT                 
                    UNIX-BASED STUDENT ATTENDANCE TRACKER (PBL 2026-2027)               
==================================================================================================
 Course: Unix Programming Lab (24B15CS214) | Batch: B2
 Submitted By: Pragya (121) | Ronak (128) | Rishabh (130) | Shobhit (144)
 Submitted To: Prof. Hema N & Kritika Rohila
 Live System Clock: 2026-11-11 11:35:00 IST
--------------------------------------------------------------------------------------------------
MAIN CONTROL DASHBOARD:
  1. Mark Daily Attendance (Interactive & Rapid Modes)
  2. Student Record Management (Add, Remove, Search, Directory)
  3. Attendance Analytics & Reports (Percentage, <75% Defaulters)
  4. Inspect Active Session (Symlink: data/current_day.log)
  5. Historical Log Archiving & Compression (tar + gzip)
  6. UNIX Security & Permission Hardening (chmod Audit)
  7. Run Complete Automated Test Suite & Self-Diagnostics
  8. Exit System
--------------------------------------------------------------------------------------------------
Enter choice [1-8]: 
```

### Menu Options Breakdown:

- **Option 1: Mark Daily Attendance**
  - Prompts for date (default is current real date `YYYY-MM-DD`).
  - Asks for mode: `1` for **Rapid Exception Mode** (all present, type absent roll numbers), or `2` for **Step-by-Step Mode** (prompts student by student).
  - Automatically updates symlink `data/current_day.log`.
- **Option 2: Student Record Management**
  - Submenu: List all students, Add student, Search student, Remove student.
- **Option 3: Attendance Analytics & Reports**
  - Submenu: Full class summary, Defaulters list (<75%), Custom threshold analysis (e.g. 80%), Individual student transcript card, Export reports to TXT/CSV.
- **Option 4: Inspect Active Session (Symlink)**
  - Resolves `data/current_day.log` via `readlink -f` and prints today's attendance turnout table.
- **Option 5: Historical Log Archiving (tar + gzip)**
  - Lists archives, compresses monthly logs into `.tar.gz`, verifies with `tar -tzf`, or decompresses back into `logs/`.
- **Option 6: UNIX Security & Permissions Hardening**
  - Displays file permissions table (`stat -c "%a %A"`) and enforces `chmod 600/700/755`.
- **Option 7: Run Automated Test Suite**
  - Executes `tests/run_tests.sh` running 35 automated tests.
- **Option 8: Exit**
  - Gracefully exits the terminal application.

---

## 6. Quick Command-Line Shortcuts (CLI Mode)

You do not need to click through menus if you want to quickly demonstrate a feature:

```bash
# 1. View full attendance audit table & class statistics:
./attendance.sh --report

# 2. View attendance defaulters list strictly below 75%:
./attendance.sh --defaulters

# 3. View master student directory of Batch B2:
./attendance.sh --students

# 4. Run the complete automated 35-point test harness:
./attendance.sh --test

# 5. Display command-line help manual:
./attendance.sh --help
```

---

## 7. Faculty Presentation Demo Script (Step-by-Step)

Follow this structured 2-minute walkthrough when presenting to **Prof. Hema N & Kritika Rohila**:

1. **Introduction (15 seconds)**:  
   *"Respected Ma'am, our project is the UNIX-Based Student Attendance Tracker for Unix Lab (24B15CS214). Built with native POSIX shell scripting, it eliminates the need for paper registers and heavy databases by leveraging core UNIX utilities like `awk`, `sed`, `grep`, `tar`, `gzip`, and `chmod`."*

2. **Step 1: Show the Master Student Directory**:  
   ```bash
   ./attendance.sh --students
   ```  
   *Explain: "Our master database is stored in `data/students.csv`. We format and render this table dynamically using `awk`."*

3. **Step 2: Demonstrate Daily Marking & Live Timestamps**:  
   ```bash
   ./attendance.sh
   # Select Option 1
   ```  
   *Explain: "When marking attendance, faculty can choose Rapid Mode where all students default to Present, and only absent roll numbers are entered. Every transaction logs an automated system timestamp with date format `YYYY-MM-DD`."*

4. **Step 3: Show the Active Symbolic Link**:  
   ```bash
   # Select Option 4 from main menu
   ```  
   *Explain: "We use a symbolic link (`ln -sf`) pointing `data/current_day.log` to today's file, allowing instant retrieval of the active session in $O(1)$ time."*

5. **Step 4: Demonstrate the AWK Analytics & Defaulters List (< 75%)**:  
   ```bash
   ./attendance.sh --report
   ./attendance.sh --defaulters
   ```  
   *Explain: "Our `report_generator.awk` engine reads across all daily logs, calculates total sessions, attended days, and exact percentages, and immediately isolates defaulters below 75% for exam detention notices."*

6. **Step 5: Demonstrate Individual Student Transcript**:  
   ```bash
   # Select Option 3 -> Option 4 -> Enter Roll Number: 2501030128 (Ronak Jain)
   ```  
   *Explain: "Faculty can pull up any student's individual attendance card showing their status on every single date."*

7. **Step 6: Demonstrate Archiving & Security**:  
   ```bash
   # Select Option 5 (Archiving) and Option 6 (Security)
   ```  
   *Explain: "Older logs are compressed into `.tar.gz` using `tar -czvf` with integrity verification via `tar -tzf`. To protect student records, `chmod 600` ensures only the administrator can edit data."*

8. **Step 7: Run the Automated Test Harness**:  
   ```bash
   ./attendance.sh --test
   ```  
   *Explain: "We built an automated 35-point regression test suite verifying all modules without human input, achieving 100% test pass rate."*

---

## 8. Faculty Viva Q&A Cheat Sheet

If the faculty asks technical questions during your evaluation, use these precise answers:

### Q1: "How does your AWK script calculate attendance across multiple separate files?"
> **Answer:** *"In `report_generator.awk`, we pass both `data/students.csv` and `logs/att_*.log`. Using AWK's pattern matching (`FILENAME ~ /students\.csv$/`), AWK first loads student metadata into associative arrays. Then, for every daily log file, it parses field 1 (RollNo) and field 3 (Status). In the `END` block, AWK iterates over the student array, computes `(p_count / total_classes) * 100.0`, and formats the tabular report."*

### Q2: "How is student deletion implemented without corrupting the CSV file?"
> **Answer:** *"We use `sed -i "/^${roll},/d" students.csv`. The `-i` flag performs an in-place edit on the file stream. Before executing the deletion, `student_ops.sh` automatically creates a safety backup (`students.csv.bak`) to guarantee atomic rollback if interrupted."*

### Q3: "How did you prevent duplicate student roll numbers?"
> **Answer:** *"Before appending any student record, we execute `grep -q "^${roll}," students.csv`. The `-q` (quiet) flag checks for pattern existence without outputting text. If grep returns exit status 0, the script catches the duplicate, logs a warning, and aborts the addition."*

### Q4: "How are Object-Oriented Programming (OOP) concepts used in a procedural Bash script?"
> **Answer:** *"While Bash is procedural, we simulate OOP through modular software engineering:  
> 1. **Encapsulation:** Raw data files in `data/` and `logs/` are hidden behind accessor functions; `chmod 600` acts as a private access modifier.  
> 2. **Abstraction:** High-level menu options in `attendance.sh` hide low-level `awk`, `sed`, and `tar` pipeline mechanics.  
> 3. **Modularity / Classes:** Each script models a domain entity (`student_ops.sh` = StudentManager, `mark_attendance.sh` = AttendanceSession, `report_generator.awk` = AnalyticsEngine, `archive.sh` = BackupService)."*

### Q5: "Why did you use symbolic links (`ln -sf`)?"
> **Answer:** *"Symbolic links act as filesystem pointers. By dynamically updating `data/current_day.log` to point to `logs/att_YYYY-MM-DD.log`, any script, backup tool, or faculty member can access today's attendance log directly without having to construct date strings or parse directory listings."*

### Q6: "How do you verify the integrity of your compressed archives?"
> **Answer:** *"After creating the archive using `tar -czvf`, the script immediately executes `tar -tzf archive.tar.gz`. The `-t` flag reads and tests the tarball table of contents without extracting. If the archive is corrupt, tar returns a non-zero exit code, alerting the user before any original logs are purged."*

---

## 9. Emergency Troubleshooting & Quick Fixes

If something goes wrong while presenting on a different laptop, run these one-liners:

| Symptom | Cause | Quick 1-Line Fix |
| :--- | :--- | :--- |
| **`Permission denied: ./attendance.sh`** | Scripts lost execute bit after git clone | `chmod +x attendance.sh scripts/*.sh tests/*.sh` |
| **`bash: ./attendance.sh: /bin/bash^M: bad interpreter`** | Windows CRLF line endings entered file | `find . -type f -name "*.sh" -exec sed -i 's/\r$//' {} +` |
| **`Warning: Symbolic link does not exist`** | Attendance has not been marked yet | Run `./attendance.sh`, select Option 1, and mark today's session. |
| **`Warning: No attendance sessions recorded yet`** | Logs directory was emptied or cleaned | Run `./attendance.sh --test` — it automatically creates 5 verified sample sessions! |
| **Terminal output looks cut off** | Terminal window is too narrow | Enlarge terminal window to at least 100 characters wide or press `Ctrl + -` to zoom out. |

---

## 10. Sustainable Development Goals (SDGs)

- **SDG 4: Quality Education (Target 4.1)**: Real-time, transparent attendance tracking, reducing student absenteeism, and providing automated early warnings for academic counseling.
- **SDG 12: Responsible Consumption and Production**: Eliminates paper registers and printed defaulter rosters, moving the department toward a 100% paperless workflow.
- **SDG 9: Industry, Innovation, and Infrastructure**: Ultra-lightweight software footprint (< 2 MB RAM) that runs on legacy and low-power hardware without heavy server infrastructure.
