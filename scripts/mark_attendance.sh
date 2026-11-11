#!/usr/bin/env bash
# ==============================================================================
# mark_attendance.sh - Daily Attendance Recording and Logging Controller
# Course: Unix Programming Lab (24B15CS214) | JIIT Noida-62
# Project: UNIX-Based Student Attendance Tracker
# Utilizes UNIX utilities: awk, date, ln, grep, cut, tr
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
init_system

mark_daily_attendance() {
    local target_date="$1"
    local mode="$2"       # "step", "rapid", or "batch_file"

    if [[ -z "$target_date" ]]; then
        target_date="$(date +%Y%m%d)"
    fi

    # Validate date format (YYYYMMDD)
    if [[ ! "$target_date" =~ ^[0-9]{8}$ ]]; then
        log_error "Invalid date format: '$target_date'. Must be YYYYMMDD (e.g., 20261111)."
        return 1
    fi

    local log_file="$LOGS_DIR/att_${target_date}.log"
    print_banner "DAILY ATTENDANCE MARKER - DATE: $target_date"

    # Check if log already exists
    if [[ -f "$log_file" ]]; then
        local existing_count
        existing_count=$(wc -l < "$log_file")
        log_warn "Attendance log for $target_date already exists with $existing_count records."
        
        if [[ -t 0 && -z "$mode" ]]; then
            echo "1. View existing attendance log"
            echo "2. Re-record / Overwrite today's attendance"
            echo "3. Cancel operation"
            read -rp "Enter choice [1-3]: " log_choice
            case "$log_choice" in
                1) view_attendance_file "$log_file"; return 0 ;;
                2) log_warn "Overwriting existing log for $target_date..." ;;
                *) log_info "Operation cancelled."; return 0 ;;
            esac
        fi
    fi

    local total_students
    total_students=$(tail -n +2 "$MASTER_FILE" | wc -l)
    if [[ "$total_students" -eq 0 ]]; then
        log_error "No students in master directory! Please add students first."
        return 1
    fi

    # Choose workflow mode if not provided
    if [[ -z "$mode" && -t 0 ]]; then
        echo -e "${C_CYAN}Select Marking Mode:${C_RESET}"
        echo "1. Rapid Exception Marking (Default: All Present, specify absent Roll numbers)"
        echo "2. Sequential Step-by-Step Marking (Prompt for each student)"
        read -rp "Enter mode [1-2] (Default 1): " mode_choice
        if [[ "$mode_choice" == "2" ]]; then
            mode="step"
        else
            mode="rapid"
        fi
    elif [[ -z "$mode" ]]; then
        mode="rapid"
    fi

    # Temporary file to collect attendance before atomic commit
    local temp_log="$log_file.tmp"
    rm -f "$temp_log"

    local current_time
    current_time="$(date +"%Y-%m-%d %H:%M:%S")"

    if [[ "$mode" == "step" ]]; then
        echo -e "${C_CYAN}Starting Step-by-Step marking (Press Enter for Present [P], or type 'A' for Absent):${C_RESET}\n"
        local idx=1
        while IFS=',' read -r roll name batch email; do
            [[ "$roll" == "RollNo" ]] && continue
            local status_input=""
            read -rp "[$idx/$total_students] $roll - $name [P/a]: " status_input
            status_input="$(echo "$status_input" | tr '[:lower:]' '[:upper:]')"
            if [[ "$status_input" == "A" ]]; then
                echo "${roll},${name},A,${current_time}" >> "$temp_log"
                echo -e "   -> Marked: ${C_RED}ABSENT${C_RESET}"
            else
                echo "${roll},${name},P,${current_time}" >> "$temp_log"
                echo -e "   -> Marked: ${C_GREEN}PRESENT${C_RESET}"
            fi
            ((idx++))
        done < "$MASTER_FILE"

    else
        # Rapid exception mode
        local absent_input=""
        if [[ -t 0 && "$#" -lt 3 ]]; then
            echo -e "${C_YELLOW}Rapid Marking Mode: All students default to PRESENT.${C_RESET}"
            echo -e "Enter Roll Numbers of ${C_RED}ABSENT${C_RESET} students separated by space/comma (or leave blank if all present):"
            read -rp "Absent Roll(s): " absent_input
        else
            absent_input="$3"
        fi

        # Normalize absent list into an associative lookup pattern
        absent_input="$(echo "$absent_input" | tr ',' ' ')"

        while IFS=',' read -r roll name batch email; do
            [[ "$roll" == "RollNo" ]] && continue
            local is_absent=0
            for abs_roll in $absent_input; do
                if [[ "$abs_roll" == "$roll" ]]; then
                    is_absent=1
                    break
                fi
            done

            if [[ "$is_absent" -eq 1 ]]; then
                echo "${roll},${name},A,${current_time}" >> "$temp_log"
            else
                echo "${roll},${name},P,${current_time}" >> "$temp_log"
            fi
        done < "$MASTER_FILE"
    fi

    # Atomically move temp log to real log
    mv "$temp_log" "$log_file"

    # Create/update symbolic link: data/current_day.log -> logs/att_YYYYMMDD.log
    # Uses UNIX 'ln -sf' as defined in Synopsis
    ln -sf "$log_file" "$SYMLINK_FILE"

    log_success "Attendance saved to: $log_file"
    log_success "Symbolic link updated: $SYMLINK_FILE -> $log_file"

    # Display session metrics
    view_attendance_file "$log_file"
    return 0
}

# Display a single attendance log file in formatted table
view_attendance_file() {
    local target_file="$1"
    if [[ -z "$target_file" || ! -f "$target_file" ]]; then
        log_error "Attendance file '$target_file' not found."
        return 1
    fi

    local real_path
    real_path="$(readlink -f "$target_file" 2>/dev/null || echo "$target_file")"
    local date_label
    date_label="$(basename "$real_path" | sed 's/att_//;s/\.log//')"

    print_banner "ATTENDANCE RECORD FOR DATE: $date_label"

    awk -F',' '
    BEGIN {
        p_count = 0;
        a_count = 0;
        printf "%-5s | %-12s | %-24s | %-8s | %-19s\n", "S.NO", "ROLL NO", "STUDENT NAME", "STATUS", "TIMESTAMP"
        print "------+--------------+--------------------------+----------+--------------------"
    }
    {
        if ($3 == "P") {
            p_count++;
            status_str = "[ PRESENT ]";
        } else {
            a_count++;
            status_str = "[ ABSENT  ]";
        }
        printf "%-5d | %-12s | %-24s | %-8s | %-19s\n", NR, $1, $2, status_str, $4
    }
    END {
        print "------+--------------+--------------------------+----------+--------------------"
        total = p_count + a_count;
        pct = (total > 0) ? (p_count / total) * 100 : 0;
        printf "Session Summary: Total Students: %d | Present: %d | Absent: %d | Turnout: %.2f%%\n", total, p_count, a_count, pct
    }
    ' "$target_file"
}

# View today's attendance via the active symbolic link
view_today_symlink() {
    print_banner "INSPECT ACTIVE LOG (VIA SYMLINK data/current_day.log)"
    if [[ ! -L "$SYMLINK_FILE" && ! -f "$SYMLINK_FILE" ]]; then
        log_warn "Symbolic link $SYMLINK_FILE does not exist yet. Please mark attendance first."
        return 1
    fi

    local target_path
    target_path="$(readlink -f "$SYMLINK_FILE" 2>/dev/null || readlink "$SYMLINK_FILE")"
    log_info "Symbolic link resolution: $SYMLINK_FILE points to -> $target_path"
    view_attendance_file "$SYMLINK_FILE"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "$#" -eq 0 ]]; then
        mark_daily_attendance
    else
        "$@"
    fi
fi
