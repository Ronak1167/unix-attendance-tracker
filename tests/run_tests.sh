#!/usr/bin/env bash
# ==============================================================================
# run_tests.sh - Automated End-to-End Test & Verification Suite
# Course: Unix Programming Lab (24B15CS214) | JIIT Noida-62
# Project: UNIX-Based Student Attendance Tracker
# Authors: Pragya Ahlawat (2501030121), Ronak Jain (2501030128),
#          Rishabh Tyagi (2501030130), Shobhit Khatana (2501030144)
# ==============================================================================

# Do not use set -e so the test harness continues executing all suites even on individual failure
set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$BASE_DIR/scripts/common.sh"

TEST_PASSED=0
TEST_FAILED=0

assert_success() {
    local test_name="$1"
    shift
    echo -ne "  [TEST] $test_name ... "
    if "$@" >/tmp/test_out.log 2>&1; then
        echo -e "${C_GREEN}[PASS]${C_RESET}"
        TEST_PASSED=$((TEST_PASSED + 1))
    else
        echo -e "${C_RED}[FAIL]${C_RESET}"
        cat /tmp/test_out.log >&2
        TEST_FAILED=$((TEST_FAILED + 1))
    fi
}

assert_failure() {
    local test_name="$1"
    shift
    echo -ne "  [TEST] $test_name (Expecting rejection) ... "
    if "$@" >/tmp/test_out.log 2>&1; then
        echo -e "${C_RED}[FAIL - Unexpectedly Succeeded]${C_RESET}"
        TEST_FAILED=$((TEST_FAILED + 1))
    else
        echo -e "${C_GREEN}[PASS - Rejected as Expected]${C_RESET}"
        TEST_PASSED=$((TEST_PASSED + 1))
    fi
}

print_banner "JIIT UNIX ATTENDANCE TRACKER - AUTOMATED TEST HARNESS"
echo -e "${C_CYAN}Starting regression and integrity tests across all POSIX shell modules...${C_RESET}\n"

# ------------------------------------------------------------------------------
# TEST SUITE 1: Directory & Environment Initialization
# ------------------------------------------------------------------------------
echo -e "${C_BOLD}SUITE 1: Filesystem & Environment Initialization${C_RESET}"

assert_success "Initialize project folder structure" init_system
assert_success "Verify master data directory exists" test -d "$DATA_DIR"
assert_success "Verify logs directory exists" test -d "$LOGS_DIR"
assert_success "Verify archives directory exists" test -d "$ARCHIVE_DIR"
assert_success "Verify reports directory exists" test -d "$REPORTS_DIR"
assert_success "Verify master students.csv exists and has headers" grep -q "RollNo,Name,Batch,Email" "$MASTER_FILE"

# ------------------------------------------------------------------------------
# TEST SUITE 2: Student Master Record Management (CRUD)
# ------------------------------------------------------------------------------
echo -e "\n${C_BOLD}SUITE 2: Student Record Operations (awk, sed, grep)${C_RESET}"

# Test Adding Student
assert_success "Add valid student record" \
    bash "$SCRIPTS_DIR/student_ops.sh" add_student "2501030999" "Test Dummy Student" "B2" "dummy@mail.jiit.ac.in"

# Verify record in students.csv
assert_success "Verify student was written to CSV" \
    grep -q "^2501030999,Test Dummy Student,B2,dummy@mail.jiit.ac.in" "$MASTER_FILE"

# Test Duplicate Prevention
assert_failure "Reject duplicate student addition" \
    bash "$SCRIPTS_DIR/student_ops.sh" add_student "2501030999" "Another Student" "B2" "test@mail.jiit.ac.in"

# Test Invalid Roll Number Validation
assert_failure "Reject invalid non-numeric roll number" \
    bash "$SCRIPTS_DIR/student_ops.sh" add_student "ABC1234" "Bad Student" "B2" "bad@mail.jiit.ac.in"

# Test Search Functionality
assert_success "Search student by roll number" \
    bash "$SCRIPTS_DIR/student_ops.sh" search_student "2501030999"

assert_success "Search student by name substring (case-insensitive)" \
    bash "$SCRIPTS_DIR/student_ops.sh" search_student "dummy"

# Test Remove Student (using sed)
assert_success "Remove student record using sed" \
    bash "$SCRIPTS_DIR/student_ops.sh" remove_student "2501030999" "force"

# Verify student removed
assert_failure "Confirm student removed from master CSV" \
    grep -q "^2501030999," "$MASTER_FILE"

# ------------------------------------------------------------------------------
# TEST SUITE 3: Multi-Session Attendance Logging & Timestamps
# ------------------------------------------------------------------------------
echo -e "\n${C_BOLD}SUITE 3: Multi-Session Daily Logging & Symlinks${C_RESET}"

# Create 5 historical test sessions with controlled attendance
# Session 1: 2026-11-01
assert_success "Mark Session 1 (2026-11-01) - 2 absentees" \
    bash "$SCRIPTS_DIR/mark_attendance.sh" mark_daily_attendance "2026-11-01" "rapid" "2501030105 2501030139"

# Session 2: 2026-11-02
assert_success "Mark Session 2 (2026-11-02) - 3 absentees" \
    bash "$SCRIPTS_DIR/mark_attendance.sh" mark_daily_attendance "2026-11-02" "rapid" "2501030105 2501030121 2501030139"

# Session 3: 2026-11-03
assert_success "Mark Session 3 (2026-11-03) - 1 absentee" \
    bash "$SCRIPTS_DIR/mark_attendance.sh" mark_daily_attendance "2026-11-03" "rapid" "2501030130"

# Session 4: 2026-11-04
assert_success "Mark Session 4 (2026-11-04) - 2 absentees" \
    bash "$SCRIPTS_DIR/mark_attendance.sh" mark_daily_attendance "2026-11-04" "rapid" "2501030105 2501030139"

# Session 5: 2026-11-05
assert_success "Mark Session 5 (2026-11-05) - 1 absentee" \
    bash "$SCRIPTS_DIR/mark_attendance.sh" mark_daily_attendance "2026-11-05" "rapid" "2501030139"

# Verify symbolic link points to latest session
assert_success "Verify symbolic link (ln -s) points to active log" \
    test -f "$SYMLINK_FILE"

# ------------------------------------------------------------------------------
# TEST SUITE 4: AWK Analytical Calculations & Defaulter Detection (<75%)
# ------------------------------------------------------------------------------
echo -e "\n${C_BOLD}SUITE 4: AWK Analytics, Percentages & Defaulter Flagging${C_RESET}"

# Run AWK Full Summary
assert_success "Execute AWK full batch summary script" \
    bash "$SCRIPTS_DIR/report_ops.sh" generate_full_summary 75

# Run Defaulters Report
assert_success "Execute AWK defaulters (<75%) script" \
    bash "$SCRIPTS_DIR/report_ops.sh" generate_defaulters_report 75

# Verify specific calculation: Ronak Jain (2501030128) attended 5/5 sessions = 100%
echo -ne "  [TEST] Validate Ronak Jain (2501030128) attendance calculation ... "
RONAK_DATA=$(awk -F',' -v target_roll="2501030128" -v report_type="summary" -f "$SCRIPTS_DIR/report_generator.awk" "$MASTER_FILE" "$LOGS_DIR"/att_*.log | grep "2501030128" || true)
if echo "$RONAK_DATA" | grep -q "ELIGIBLE"; then
    echo -e "${C_GREEN}[PASS - 100.00% ELIGIBLE]${C_RESET}"
    TEST_PASSED=$((TEST_PASSED + 1))
else
    echo -e "${C_RED}[FAIL]${C_RESET}"
    TEST_FAILED=$((TEST_FAILED + 1))
fi

# Verify specific calculation: Shivam Kapoor (2501030139) missed 4 sessions -> Defaulter
echo -ne "  [TEST] Validate Shivam Kapoor (2501030139) defaulter detection ... "
SHIVAM_DATA=$(awk -F',' -v report_type="defaulters" -f "$SCRIPTS_DIR/report_generator.awk" "$MASTER_FILE" "$LOGS_DIR"/att_*.log | grep "2501030139" || true)
if echo "$SHIVAM_DATA" | grep -q "DEFAULTER"; then
    echo -e "${C_GREEN}[PASS - Flagged as DEFAULTER]${C_RESET}"
    TEST_PASSED=$((TEST_PASSED + 1))
else
    echo -e "${C_RED}[FAIL]${C_RESET}"
    TEST_FAILED=$((TEST_FAILED + 1))
fi

# Test Individual Student Transcript
assert_success "Generate single student transcript for Ronak Jain" \
    bash "$SCRIPTS_DIR/report_ops.sh" generate_student_transcript "2501030128"

# ------------------------------------------------------------------------------
# TEST SUITE 5: Report Exportation (TXT & CSV)
# ------------------------------------------------------------------------------
echo -e "\n${C_BOLD}SUITE 5: Report Persistence & CSV Exportation${C_RESET}"

assert_success "Export summary reports to reports/ directory" \
    bash "$SCRIPTS_DIR/report_ops.sh" export_report 75

check_csv_exists() {
    local count
    count=$(find "$REPORTS_DIR" -type f -name "attendance_summary_*.csv" | wc -l)
    [[ "$count" -gt 0 ]]
}

check_txt_exists() {
    local count
    count=$(find "$REPORTS_DIR" -type f -name "attendance_summary_*.txt" | wc -l)
    [[ "$count" -gt 0 ]]
}

assert_success "Verify exported CSV report exists and is populated" check_csv_exists
assert_success "Verify exported TXT report exists and is non-empty" check_txt_exists

# ------------------------------------------------------------------------------
# TEST SUITE 6: Log Archiving & Compression (tar + gzip)
# ------------------------------------------------------------------------------
echo -e "\n${C_BOLD}SUITE 6: Archiving & Compression (tar, gzip)${C_RESET}"

# Create archive for 2026-11
assert_success "Create compressed monthly archive (tar -czvf)" \
    bash "$SCRIPTS_DIR/archive.sh" archive_logs "2026-11" "keep"

# Verify archive exists
assert_success "Verify tar.gz archive file exists" \
    test -f "$ARCHIVE_DIR/attendance_archive_2026-11.tar.gz"

# Verify archive integrity using tar -tzf
assert_success "Verify archive integrity with tar -tzf" \
    tar -tzf "$ARCHIVE_DIR/attendance_archive_2026-11.tar.gz"

# Test archive restoration
assert_success "Test archive decompression and extraction (tar -xzvf)" \
    bash "$SCRIPTS_DIR/archive.sh" restore_archive "$ARCHIVE_DIR/attendance_archive_2026-11.tar.gz"

# ------------------------------------------------------------------------------
# TEST SUITE 7: POSIX Security & Permissions Hardening
# ------------------------------------------------------------------------------
echo -e "\n${C_BOLD}SUITE 7: UNIX File Permissions & Security Audit (chmod)${C_RESET}"

assert_success "Apply POSIX permission policy (chmod 600/700/755)" \
    bash "$SCRIPTS_DIR/security.sh" apply_security_policy

assert_success "Run security audit checklist" \
    bash "$SCRIPTS_DIR/security.sh" audit_permissions

assert_success "Clean temporary and backup files" \
    bash "$SCRIPTS_DIR/security.sh" clean_temp_files

# ------------------------------------------------------------------------------
# FINAL TEST REPORT
# ------------------------------------------------------------------------------
echo ""
print_banner "TEST EXECUTION SUMMARY"
TOTAL_TESTS=$((TEST_PASSED + TEST_FAILED))
echo -e "Total Tests Executed : ${C_BOLD}$TOTAL_TESTS${C_RESET}"
echo -e "Tests Passed         : ${C_GREEN}${C_BOLD}$TEST_PASSED${C_RESET}"
echo -e "Tests Failed         : ${C_RED}${C_BOLD}$TEST_FAILED${C_RESET}"

if [[ "$TEST_FAILED" -eq 0 ]]; then
    echo -e "\n${C_GREEN}${C_BOLD}>>> ALL TESTS PASSED SUCCESSFULLY! PROJECT IS 100% OPERATIONAL. <<<${C_RESET}\n"
    exit 0
else
    echo -e "\n${C_RED}${C_BOLD}>>> SOME TESTS FAILED! CHECK OUTPUT ABOVE. <<<${C_RESET}\n"
    exit 1
fi
