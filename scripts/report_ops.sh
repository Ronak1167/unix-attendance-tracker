#!/usr/bin/env bash
# ==============================================================================
# report_ops.sh - Report Generation & Analytics Controller
# Course: Unix Programming Lab (24B15CS214) | JIIT Noida-62
# Project: UNIX-Based Student Attendance Tracker
# Utilizes: awk, sort, cut, tr, sed
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
init_system

AWK_SCRIPT="$SCRIPTS_DIR/report_generator.awk"

# Check if any logs exist
check_logs_exist() {
    local log_count
    log_count=$(find "$LOGS_DIR" -name "att_*.log" | wc -l)
    if [[ "$log_count" -eq 0 ]]; then
        log_warn "No daily attendance logs found in $LOGS_DIR. Please mark attendance for at least one session."
        return 1
    fi
    return 0
}

# Run Full Summary
generate_full_summary() {
    local threshold="${1:-$DEFAULT_THRESHOLD}"
    if ! check_logs_exist; then return 1; fi

    awk -F',' -v threshold="$threshold" -v report_type="summary" -f "$AWK_SCRIPT" "$MASTER_FILE" "$LOGS_DIR"/att_*.log
}

# Run Defaulters Report
generate_defaulters_report() {
    local threshold="${1:-$DEFAULT_THRESHOLD}"
    if ! check_logs_exist; then return 1; fi

    awk -F',' -v threshold="$threshold" -v report_type="defaulters" -f "$AWK_SCRIPT" "$MASTER_FILE" "$LOGS_DIR"/att_*.log
}

# Run Individual Student Transcript
generate_student_transcript() {
    local target_roll="$1"
    if ! check_logs_exist; then return 1; fi

    if [[ -z "$target_roll" ]]; then
        print_banner "STUDENT ATTENDANCE TRANSCRIPT LOOKUP"
        read -rp "Enter Student Roll Number: " target_roll
    fi

    if ! validate_roll_number "$target_roll"; then
        log_error "Invalid roll number: '$target_roll'."
        return 1
    fi

    awk -F',' -v threshold="$DEFAULT_THRESHOLD" -v report_type="student" -v target_roll="$target_roll" -f "$AWK_SCRIPT" "$MASTER_FILE" "$LOGS_DIR"/att_*.log
}

# Export Report to Disk (TXT & CSV formats) with live timestamp
export_report() {
    local threshold="${1:-$DEFAULT_THRESHOLD}"
    if ! check_logs_exist; then return 1; fi

    local timestamp
    timestamp="$(date +%Y-%m-%d_%H%M%S)"
    local txt_report="$REPORTS_DIR/attendance_summary_${timestamp}.txt"
    local csv_report="$REPORTS_DIR/attendance_summary_${timestamp}.csv"

    log_info "Generating report files in $REPORTS_DIR at $(get_current_timestamp)..."

    # Generate Human-Readable Formatted Text Report
    awk -F',' -v threshold="$threshold" -v report_type="summary" -f "$AWK_SCRIPT" "$MASTER_FILE" "$LOGS_DIR"/att_*.log > "$txt_report"

    # Generate Machine-Readable CSV Report using awk
    awk -F',' -v threshold="$threshold" '
    BEGIN {
        OFS = ","
    }
    FILENAME ~ /students\.csv$/ {
        if (FNR > 1 && $1 != "") {
            order[++n] = $1; name[$1] = $2; batch[$1] = $3; email[$1] = $4;
            p[$1] = 0; tot[$1] = 0;
        }
        next
    }
    FILENAME ~ /att_[0-9]{4}-?[0-9]{2}-?[0-9]{2}\.log$/ {
        if ($1 != "" && $3 != "") {
            tot[$1]++;
            st = toupper($3)
            if (st == "P" || st == "PRESENT") p[$1]++;
        }
    }
    END {
        print "RollNo,Name,Batch,Email,TotalSessions,Attended,Absent,Percentage,Status,ReportGeneratedAt"
        for (i = 1; i <= n; i++) {
            r = order[i];
            a = tot[r] - p[r];
            pct = (tot[r] > 0) ? (p[r] / tot[r]) * 100 : 0;
            st = (pct >= threshold) ? "ELIGIBLE" : "DEFAULTER";
            printf "%s,\"%s\",%s,%s,%d,%d,%d,%.2f,%s,\"%s\"\n", r, name[r], batch[r], email[r], tot[r], p[r], a, pct, st, strftime("%Y-%m-%d %H:%M:%S")
        }
    }
    ' "$MASTER_FILE" "$LOGS_DIR"/att_*.log > "$csv_report"

    log_success "Formatted Text Report saved to : $txt_report"
    log_success "Analytical CSV Export saved to  : $csv_report"
    return 0
}

# Interactive Report Submenu
report_menu() {
    while true; do
        clear 2>/dev/null || true
        print_banner "ATTENDANCE ANALYTICS & REPORT GENERATOR"
        echo "1. Full Class Attendance Summary (Default 75% Criterion)"
        echo "2. Attendance Defaulters List (< 75%)"
        echo "3. Custom Threshold Analysis (e.g. 80%, 85%)"
        echo "4. Individual Student Detailed Transcript"
        echo "5. Export Reports to Disk (TXT & CSV)"
        echo "6. Return to Main Menu"
        echo ""
        read -rp "Enter your choice [1-6]: " rchoice
        case "$rchoice" in
            1) generate_full_summary; pause_prompt ;;
            2) generate_defaulters_report; pause_prompt ;;
            3)
                read -rp "Enter custom attendance threshold % (e.g. 80): " custom_th
                generate_full_summary "$custom_th"
                pause_prompt
                ;;
            4) generate_student_transcript; pause_prompt ;;
            5) export_report; pause_prompt ;;
            6) break ;;
            *) log_error "Invalid option. Please choose 1-6."; pause_prompt ;;
        esac
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "$#" -eq 0 ]]; then
        report_menu
    else
        "$@"
    fi
fi
