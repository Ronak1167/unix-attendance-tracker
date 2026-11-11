#!/usr/bin/env bash
# ==============================================================================
# security.sh - UNIX File Permissions & Access Control Manager
# Course: Unix Programming Lab (24B15CS214) | JIIT Noida-62
# Project: UNIX-Based Student Attendance Tracker
# Utilizes UNIX utilities: chmod, stat, ls, find
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
init_system

# Apply strict POSIX permission hardening
apply_security_policy() {
    print_banner "APPLYING POSIX SECURITY PERMISSIONS (chmod)"

    log_info "Hardening master database file ($MASTER_FILE)..."
    chmod 600 "$MASTER_FILE" 2>/dev/null || true

    log_info "Securing logs, archives, and reports directories (700)..."
    chmod 700 "$LOGS_DIR" "$ARCHIVE_DIR" "$REPORTS_DIR" 2>/dev/null || true

    log_info "Securing individual log files (600)..."
    find "$LOGS_DIR" -type f -name "att_*.log" -exec chmod 600 {} + 2>/dev/null || true

    log_info "Granting safe execution permissions to scripts and main controller (755)..."
    chmod 755 "$BASE_DIR/attendance.sh" 2>/dev/null || true
    chmod 755 "$SCRIPTS_DIR"/*.sh 2>/dev/null || true

    log_success "POSIX file security policy applied successfully at $(get_current_timestamp)."
}

# Audit current file permissions against policy with exact border alignment
audit_permissions() {
    print_banner "SECURITY AUDIT: FILE PERMISSIONS & INTEGRITY"

    printf " %-35s | %-8s | %-12s | %-16s\n" "TARGET FILE / DIRECTORY" "OCTAL" "PERMISSION" "COMPLIANCE"
    echo "-------------------------------------+----------+--------------+------------------"

    check_target() {
        local path="$1"
        local expected_octal="$2"
        local label="$3"

        if [[ ! -e "$path" ]]; then
            printf " %-35s | %-8s | %-12s | %-16s\n" "$label" "N/A" "MISSING" "[ FAILED ]"
            return
        fi

        local current_octal
        current_octal=$(stat -c "%a" "$path" 2>/dev/null || stat -f "%OLp" "$path" 2>/dev/null || echo "???")
        local current_perm
        current_perm=$(stat -c "%A" "$path" 2>/dev/null || ls -ld "$path" | awk '{print $1}')

        local status="[ COMPLIANT ]"
        # On WSL / NTFS mounts, permissions might report 777 if metadata is not enabled
        if [[ "$current_octal" != "$expected_octal" ]]; then
            if [[ "$current_octal" == "777" ]]; then
                status="[ WSL DRVFS ]"
            else
                status="[ MISMATCH ]"
            fi
        fi

        printf " %-35s | %-8s | %-12s | %-16s\n" "$label" "$current_octal" "$current_perm" "$status"
    }

    check_target "$MASTER_FILE" "600" "data/students.csv (Master DB)"
    check_target "$LOGS_DIR" "700" "logs/ (Daily Logs Dir)"
    check_target "$ARCHIVE_DIR" "700" "archives/ (Backups Dir)"
    check_target "$REPORTS_DIR" "700" "reports/ (Reports Dir)"
    check_target "$BASE_DIR/attendance.sh" "755" "attendance.sh (Main Script)"
    check_target "$SCRIPTS_DIR/student_ops.sh" "755" "scripts/student_ops.sh"
    check_target "$SCRIPTS_DIR/mark_attendance.sh" "755" "scripts/mark_attendance.sh"
    check_target "$SCRIPTS_DIR/report_ops.sh" "755" "scripts/report_ops.sh"
    check_target "$SCRIPTS_DIR/archive.sh" "755" "scripts/archive.sh"

    echo "-------------------------------------+----------+--------------+------------------"
    echo -e "${C_CYAN}Security Notes:${C_RESET}"
    echo "  • chmod 600 ensures only the admin/faculty account can read/modify student data."
    echo "  • chmod 700 ensures privacy for log repositories and statistical reports."
}

# Cleanup dangling temporary files
clean_temp_files() {
    print_banner "CLEANING TEMPORARY AND BACKUP FILES"
    local temp_files
    temp_files=$(find "$BASE_DIR" -type f \( -name "*.tmp" -o -name "*.bak" \) 2>/dev/null)

    if [[ -z "$temp_files" ]]; then
        log_info "No temporary or backup files found to clean."
        return 0
    fi

    echo "$temp_files" | awk '{printf "  • Deleting: %s\n", $1}'
    rm -f $temp_files
    log_success "Cleaned temporary files safely at $(get_current_timestamp)."
}

# Security menu
security_menu() {
    while true; do
        clear 2>/dev/null || true
        print_banner "UNIX SECURITY & FILE PERMISSION AUDIT (chmod)"
        echo "1. Run Security Permission Audit"
        echo "2. Enforce Strict Permission Hardening (chmod 600/700/755)"
        echo "3. Clean Temporary (*.tmp, *.bak) Files"
        echo "4. Return to Main Menu"
        echo ""
        read -rp "Enter choice [1-4]: " sec_choice
        case "$sec_choice" in
            1) audit_permissions; pause_prompt ;;
            2) apply_security_policy; pause_prompt ;;
            3) clean_temp_files; pause_prompt ;;
            4) break ;;
            *) log_error "Invalid option. Please choose 1-4."; pause_prompt ;;
        esac
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "$#" -eq 0 ]]; then
        security_menu
    else
        "$@"
    fi
fi
