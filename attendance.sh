#!/usr/bin/env bash
# ==============================================================================
# attendance.sh - Master Controller for UNIX Student Attendance Tracker
# Department of Computer Science & Engineering and Information Technology
# Jaypee Institute of Information Technology, Noida-62
# Course: Unix Programming Lab (24B15CS214) | Year: 2026-2027
#
# Submitted To:
#   • Hema N & Kritika Rohila
#
# Submitted By:
#   • Pragya Ahlawat (2501030121)
#   • Ronak Jain     (2501030128)
#   • Rishabh Tyagi  (2501030130)
#   • Shobhit Khatana(2501030144)
#   Batch: B2
# ==============================================================================

set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$BASE_DIR/scripts"

# Source common configuration and library
if [[ -f "$SCRIPTS_DIR/common.sh" ]]; then
    source "$SCRIPTS_DIR/common.sh"
else
    echo "Fatal Error: $SCRIPTS_DIR/common.sh not found!" >&2
    exit 1
fi

# Trap interrupts (Ctrl+C) gracefully
trap 'echo -e "\n\n${C_YELLOW}Program interrupted by user. Cleaning up and exiting safely...${C_RESET}"; exit 0' SIGINT SIGTERM

# Initialize directories and master files
init_system

# Display Project Welcome Banner with exact border width and live time
show_main_header() {
    clear 2>/dev/null || true
    print_double_line
    echo -e "${C_BOLD}${C_CYAN}                  JAYPEE INSTITUTE OF INFORMATION TECHNOLOGY, NOIDA-62                  ${C_RESET}"
    echo -e "${C_BOLD}                    Department of Computer Science & Engineering and IT                 ${C_RESET}"
    echo -e "${C_YELLOW}                    UNIX-BASED STUDENT ATTENDANCE TRACKER (PBL 2026-2027)               ${C_RESET}"
    print_double_line
    echo -e "${C_GRAY} Course: Unix Programming Lab (24B15CS214) | Batch: B2${C_RESET}"
    echo -e "${C_GRAY} Submitted By: Pragya (121) | Ronak (128) | Rishabh (130) | Shobhit (144)${C_RESET}"
    echo -e "${C_GRAY} Submitted To: Prof. Hema N & Kritika Rohila${C_RESET}"
    echo -e "${C_CYAN} Live System Clock: $(get_current_timestamp) $(date +%Z)${C_RESET}"
    print_single_line
}

# Main Application Execution Loop
main_menu() {
    while true; do
        show_main_header
        echo -e "${C_BOLD}MAIN CONTROL DASHBOARD:${C_RESET}"
        echo -e "  ${C_GREEN}1.${C_RESET} Mark Daily Attendance (Interactive & Rapid Modes)"
        echo -e "  ${C_GREEN}2.${C_RESET} Student Record Management (Add, Remove, Search, Directory)"
        echo -e "  ${C_GREEN}3.${C_RESET} Attendance Analytics & Reports (Percentage, <75% Defaulters)"
        echo -e "  ${C_GREEN}4.${C_RESET} Inspect Active Session (Symlink: data/current_day.log)"
        echo -e "  ${C_GREEN}5.${C_RESET} Historical Log Archiving & Compression (tar + gzip)"
        echo -e "  ${C_GREEN}6.${C_RESET} UNIX Security & Permission Hardening (chmod Audit)"
        echo -e "  ${C_GREEN}7.${C_RESET} Run Complete Automated Test Suite & Self-Diagnostics"
        echo -e "  ${C_RED}8.${C_RESET} Exit System"
        print_single_line
        
        read -rp "Enter choice [1-8]: " main_choice

        case "$main_choice" in
            1)
                bash "$SCRIPTS_DIR/mark_attendance.sh"
                pause_prompt
                ;;
            2)
                bash "$SCRIPTS_DIR/student_ops.sh"
                ;;
            3)
                bash "$SCRIPTS_DIR/report_ops.sh"
                ;;
            4)
                bash "$SCRIPTS_DIR/mark_attendance.sh" view_today_symlink
                pause_prompt
                ;;
            5)
                bash "$SCRIPTS_DIR/archive.sh"
                ;;
            6)
                bash "$SCRIPTS_DIR/security.sh"
                ;;
            7)
                bash "$BASE_DIR/tests/run_tests.sh"
                pause_prompt
                ;;
            8)
                echo -e "\n${C_GREEN}Thank you for using the UNIX Attendance Tracker. Goodbye!${C_RESET}\n"
                exit 0
                ;;
            *)
                log_error "Invalid selection. Please choose an option from 1 to 8."
                sleep 1
                ;;
        esac
    done
}

# Handle command-line arguments directly (headless execution for testing and CI)
if [[ "$#" -gt 0 ]]; then
    case "$1" in
        --test)
            bash "$BASE_DIR/tests/run_tests.sh"
            ;;
        --report)
            bash "$SCRIPTS_DIR/report_ops.sh" generate_full_summary "${2:-75}"
            ;;
        --defaulters)
            bash "$SCRIPTS_DIR/report_ops.sh" generate_defaulters_report "${2:-75}"
            ;;
        --students)
            bash "$SCRIPTS_DIR/student_ops.sh" list_students
            ;;
        --help|-h)
            echo "Usage: ./attendance.sh [OPTIONS]"
            echo "Options:"
            echo "  --test        Run automated verification test suite"
            echo "  --report      Generate full attendance percentage summary"
            echo "  --defaulters  Generate < 75% defaulters list"
            echo "  --students    List registered student directory"
            echo "  --help        Show this help message"
            ;;
        *)
            log_error "Unknown option: $1. Run with --help for options."
            exit 1
            ;;
    esac
else
    main_menu
fi
