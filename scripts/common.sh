#!/usr/bin/env bash
# ==============================================================================
# common.sh - Global Configuration, Constants, and Helper Utilities
# Course: Unix Programming Lab (24B15CS214) | JIIT Noida-62
# Project: UNIX-Based Student Attendance Tracker
# Authors: Pragya Ahlawat (2501030121), Ronak Jain (2501030128),
#          Rishabh Tyagi (2501030130), Shobhit Khatana (2501030144)
# ==============================================================================

# Determine base directory dynamically based on script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$(basename "$SCRIPT_DIR")" == "scripts" || "$(basename "$SCRIPT_DIR")" == "tests" ]]; then
    BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
    BASE_DIR="$SCRIPT_DIR"
fi

DATA_DIR="$BASE_DIR/data"
LOGS_DIR="$BASE_DIR/logs"
ARCHIVE_DIR="$BASE_DIR/archives"
REPORTS_DIR="$BASE_DIR/reports"
SCRIPTS_DIR="$BASE_DIR/scripts"

MASTER_FILE="$DATA_DIR/students.csv"
SYMLINK_FILE="$DATA_DIR/current_day.log"
DEFAULT_THRESHOLD=75

# Color Palettes for Terminal Output
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_RED="\033[31m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_BLUE="\033[34m"
C_MAGENTA="\033[35m"
C_CYAN="\033[36m"
C_GRAY="\033[90m"

# Print colored status messages
log_info() {
    echo -e "${C_CYAN}[INFO]${C_RESET} $*"
}

log_success() {
    echo -e "${C_GREEN}[SUCCESS]${C_RESET} $*"
}

log_warn() {
    echo -e "${C_YELLOW}[WARNING]${C_RESET} $*"
}

log_error() {
    echo -e "${C_RED}[ERROR]${C_RESET} $*" >&2
}

# Print visual header banner
print_banner() {
    local title="$1"
    echo -e "${C_BLUE}================================================================================${C_RESET}"
    echo -e "${C_BOLD}${C_CYAN}  $title${C_RESET}"
    echo -e "${C_BLUE}================================================================================${C_RESET}"
}

# Ensure all essential directories and files exist
init_system() {
    mkdir -p "$DATA_DIR" "$LOGS_DIR" "$ARCHIVE_DIR" "$REPORTS_DIR" "$SCRIPTS_DIR"
    
    if [[ ! -f "$MASTER_FILE" ]]; then
        echo "RollNo,Name,Batch,Email" > "$MASTER_FILE"
        chmod 600 "$MASTER_FILE" 2>/dev/null || true
    fi
}

# Input validation helpers
validate_roll_number() {
    local roll="$1"
    if [[ -z "$roll" || ! "$roll" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    return 0
}

validate_non_empty() {
    local val="$1"
    if [[ -z "${val// }" ]]; then
        return 1
    fi
    return 0
}

pause_prompt() {
    echo ""
    read -rp "Press [Enter] to continue..." _
}

