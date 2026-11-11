#!/usr/bin/env bash
# ==============================================================================
# archive.sh - Attendance Log Archival and Compression Engine
# Course: Unix Programming Lab (24B15CS214) | JIIT Noida-62
# Project: UNIX-Based Student Attendance Tracker
# Utilizes UNIX utilities: tar, gzip, ls, find, awk, du
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
init_system

# Archive logs for a specific month (YYYYMM) using tar and gzip
archive_logs() {
    local target_month="$1"
    local purge_originals="$2"

    if [[ -z "$target_month" ]]; then
        print_banner "ARCHIVE HISTORICAL ATTENDANCE LOGS"
        # Find available months in logs directory
        local available_months
        available_months=$(find "$LOGS_DIR" -name "att_*.log" -exec basename {} \; 2>/dev/null | \
                           sed -E 's/att_([0-9]{6})[0-9]{2}\.log/\1/' | sort -u)

        if [[ -z "$available_months" ]]; then
            log_warn "No daily logs found in $LOGS_DIR to archive."
            return 1
        fi

        echo -e "${C_CYAN}Available Months with Logged Sessions:${C_RESET}"
        echo "$available_months" | awk '{printf "  • %s\n", $1}'
        echo ""
        read -rp "Enter Month to Archive (Format: YYYYMM, e.g. $(date +%Y%m)): " target_month
    fi

    # Validate target month format (YYYYMM)
    if [[ ! "$target_month" =~ ^[0-9]{6}$ ]]; then
        log_error "Invalid month format: '$target_month'. Must be YYYYMM (e.g. 202611)."
        return 1
    fi

    # Locate matching files
    cd "$LOGS_DIR" || return 1
    local matching_files
    matching_files=$(ls att_${target_month}*.log 2>/dev/null)

    if [[ -z "$matching_files" ]]; then
        log_warn "No logs found matching month '$target_month' (att_${target_month}*.log)."
        cd "$BASE_DIR" || true
        return 1
    fi

    local count
    count=$(echo "$matching_files" | wc -w)
    local archive_name="attendance_archive_${target_month}.tar.gz"
    local archive_path="$ARCHIVE_DIR/$archive_name"

    log_info "Found $count log files for month $target_month. Compressing with tar and gzip..."

    # Create compressed archive using tar -czvf
    tar -czvf "$archive_path" $matching_files >/dev/null

    if [[ ! -f "$archive_path" ]]; then
        log_error "Failed to create archive: $archive_path"
        cd "$BASE_DIR" || true
        return 1
    fi

    # Verify integrity using tar -tzf
    log_info "Verifying archive integrity with tar -tzf..."
    if ! tar -tzf "$archive_path" >/dev/null 2>&1; then
        log_error "Archive integrity verification failed!"
        rm -f "$archive_path"
        cd "$BASE_DIR" || true
        return 1
    fi

    local archive_size
    archive_size=$(du -h "$archive_path" | cut -f1)
    log_success "Archive created successfully: $archive_path ($archive_size)"

    # Purge original raw files if requested or prompt
    if [[ "$purge_originals" == "purge" ]]; then
        rm -f $matching_files
        log_success "Purged $count archived raw log files to optimize filesystem storage."
    elif [[ -t 0 && -z "$purge_originals" ]]; then
        read -rp "Do you want to purge the original daily log files now? (y/N): " confirm_purge
        if [[ "$confirm_purge" =~ ^[Yy]$ ]]; then
            rm -f $matching_files
            log_success "Purged original raw log files."
        else
            log_info "Original log files retained in $LOGS_DIR."
        fi
    fi

    cd "$BASE_DIR" || true
    return 0
}

# List all existing archives
list_archives() {
    print_banner "COMPRESSED ARCHIVES REPOSITORY ($ARCHIVE_DIR)"
    local archives
    archives=$(ls "$ARCHIVE_DIR"/*.tar.gz 2>/dev/null)

    if [[ -z "$archives" ]]; then
        log_warn "No compressed archives found in $ARCHIVE_DIR."
        return 0
    fi

    echo -e "${C_CYAN}Archive File Details:${C_RESET}"
    ls -lh "$ARCHIVE_DIR"/*.tar.gz | awk '{printf "%-10s %-5s %-12s %s\n", $1, $5, $6" "$7, $9}'
    echo ""
    echo -e "${C_CYAN}Archive Content Inspections:${C_RESET}"
    for arch in "$ARCHIVE_DIR"/*.tar.gz; do
        echo -e "${C_YELLOW}>>> $(basename "$arch"):${C_RESET}"
        tar -tzf "$arch" | awk '{printf "   - %s\n", $1}'
    done
}

# Restore / Decompress an archive back into logs directory
restore_archive() {
    local target_archive="$1"
    if [[ -z "$target_archive" ]]; then
        print_banner "RESTORE COMPRESSED ARCHIVE"
        local archives
        archives=$(ls "$ARCHIVE_DIR"/*.tar.gz 2>/dev/null)
        if [[ -z "$archives" ]]; then
            log_warn "No archives available to restore."
            return 1
        fi
        echo "$archives" | awk -F'/' '{printf "  • %s\n", $NF}'
        echo ""
        read -rp "Enter archive file name (e.g., attendance_archive_202611.tar.gz): " target_archive
        target_archive="$ARCHIVE_DIR/$target_archive"
    fi

    if [[ ! -f "$target_archive" ]]; then
        log_error "Archive file not found: $target_archive"
        return 1
    fi

    log_info "Decompressing and extracting $(basename "$target_archive") into $LOGS_DIR..."
    tar -xzvf "$target_archive" -C "$LOGS_DIR"
    log_success "Archive successfully restored to $LOGS_DIR."
}

# Interactive Submenu
archive_menu() {
    while true; do
        clear 2>/dev/null || true
        print_banner "LOG ARCHIVING & COMPRESSION UTILITY (tar + gzip)"
        echo "1. List Existing Archives & Inspect Contents"
        echo "2. Compress Monthly Logs to tar.gz"
        echo "3. Restore / Decompress an Archive"
        echo "4. Return to Main Menu"
        echo ""
        read -rp "Enter your choice [1-4]: " arch_choice
        case "$arch_choice" in
            1) list_archives; pause_prompt ;;
            2) archive_logs; pause_prompt ;;
            3) restore_archive; pause_prompt ;;
            4) break ;;
            *) log_error "Invalid option. Please choose 1-4."; pause_prompt ;;
        esac
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "$#" -eq 0 ]]; then
        archive_menu
    else
        "$@"
    fi
fi

