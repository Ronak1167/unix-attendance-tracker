#!/usr/bin/env bash
# ==============================================================================
# student_ops.sh - Student Master Record Operations (CRUD)
# Course: Unix Programming Lab (24B15CS214) | JIIT Noida-62
# Project: UNIX-Based Student Attendance Tracker
# Utilizes UNIX utilities: awk, sed, grep, cut, sort
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
init_system

# Add a student record
add_student() {
    local roll="$1"
    local name="$2"
    local batch="$3"
    local email="$4"

    # Interactive input if arguments are missing
    if [[ -z "$roll" ]]; then
        print_banner "ADD NEW STUDENT RECORD"
        read -rp "Enter Roll Number (e.g., 2501030199): " roll
        read -rp "Enter Full Name: " name
        read -rp "Enter Batch (e.g., B2): " batch
        read -rp "Enter Institute Email: " email
    fi

    # Validation
    if ! validate_roll_number "$roll"; then
        log_error "Invalid roll number: '$roll'. Must be a positive integer."
        return 1
    fi

    if ! validate_non_empty "$name"; then
        log_error "Student name cannot be empty."
        return 1
    fi

    # Clean inputs (strip trailing/leading whitespace and any stray commas)
    roll="${roll// /}"
    name="$(echo "$name" | sed 's/,//g' | sed 's/^[ \t]*//;s/[ \t]*$//')"
    batch="$(echo "$batch" | sed 's/,//g' | tr -d ' ' | tr '[:lower:]' '[:upper:]')"
    email="$(echo "$email" | sed 's/,//g' | tr -d ' ')"

    [[ -z "$batch" ]] && batch="B2"
    [[ -z "$email" ]] && email="${roll}@mail.jiit.ac.in"

    # Check for duplicate roll number using grep
    if grep -q "^${roll}," "$MASTER_FILE"; then
        log_warn "Student with Roll Number $roll already exists in master file."
        grep "^${roll}," "$MASTER_FILE" | awk -F',' '{printf "Existing Record -> Roll: %s | Name: %s | Batch: %s\n", $1, $2, $3}'
        return 1
    fi

    # Append record
    echo "${roll},${name},${batch},${email}" >> "$MASTER_FILE"

    # Maintain sorted order by Roll No (preserving header)
    head -n 1 "$MASTER_FILE" > "$MASTER_FILE.tmp"
    tail -n +2 "$MASTER_FILE" | sort -t',' -k1,1n >> "$MASTER_FILE.tmp"
    mv "$MASTER_FILE.tmp" "$MASTER_FILE"
    chmod 600 "$MASTER_FILE" 2>/dev/null || true

    log_success "Student '$name' ($roll) added successfully to Batch $batch."
    return 0
}

# Remove a student record using sed
remove_student() {
    local roll="$1"

    if [[ -z "$roll" ]]; then
        print_banner "REMOVE STUDENT RECORD"
        read -rp "Enter Roll Number to delete: " roll
    fi

    if ! validate_roll_number "$roll"; then
        log_error "Invalid roll number: '$roll'."
        return 1
    fi

    # Verify student exists
    if ! grep -q "^${roll}," "$MASTER_FILE"; then
        log_error "Student with Roll Number '$roll' not found in $MASTER_FILE."
        return 1
    fi

    # Display record to be removed
    local student_info
    student_info=$(grep "^${roll}," "$MASTER_FILE")
    echo -e "${C_YELLOW}Record to delete:${C_RESET} $student_info"

    # If running interactively, confirm deletion
    if [[ -t 0 && -z "$2" ]]; then
        read -rp "Are you sure you want to permanently delete this student? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "Operation cancelled by user."
            return 0
        fi
    fi

    # Create safety backup before editing
    cp "$MASTER_FILE" "$MASTER_FILE.bak"

    # Delete record using sed
    sed -i "/^${roll},/d" "$MASTER_FILE"

    log_success "Student with Roll Number $roll has been removed."
    return 0
}

# List all student records using awk
list_students() {
    print_banner "MASTER STUDENT DIRECTORY (JIIT BATCH B2)"
    local total_count
    total_count=$(tail -n +2 "$MASTER_FILE" | wc -l)

    if [[ "$total_count" -eq 0 ]]; then
        log_warn "No student records found in $MASTER_FILE."
        return 0
    fi

    awk -F',' '
    BEGIN {
        printf "%-5s | %-12s | %-24s | %-7s | %-28s\n", "S.NO", "ROLL NO", "STUDENT NAME", "BATCH", "EMAIL ID"
        print "------+--------------+--------------------------+---------+------------------------------"
    }
    NR > 1 {
        printf "%-5d | %-12s | %-24s | %-7s | %-28s\n", (NR - 1), $1, $2, $3, $4
    }
    END {
        print "------+--------------+--------------------------+---------+------------------------------"
        printf "Total Registered Students: %d\n", (NR - 1)
    }
    ' "$MASTER_FILE"
}

# Search student by Roll No or Name
search_student() {
    local query="$1"

    if [[ -z "$query" ]]; then
        print_banner "SEARCH STUDENT RECORD"
        read -rp "Enter Roll Number or Name query: " query
    fi

    if [[ -z "$query" ]]; then
        log_error "Search query cannot be empty."
        return 1
    fi

    log_info "Searching for records matching: '$query'..."
    
    # Use grep to find matches, ignoring case
    local matches
    matches=$(grep -i "$query" "$MASTER_FILE" | grep -v "^RollNo,")

    if [[ -z "$matches" ]]; then
        log_warn "No matching student records found for: '$query'."
        return 1
    fi

    echo "$matches" | awk -F',' '
    BEGIN {
        printf "%-12s | %-24s | %-7s | %-28s\n", "ROLL NO", "STUDENT NAME", "BATCH", "EMAIL ID"
        print "-------------+--------------------------+---------+------------------------------"
    }
    {
        printf "%-12s | %-24s | %-7s | %-28s\n", $1, $2, $3, $4
    }
    '
    return 0
}

# Submenu router when executed directly
student_menu() {
    while true; do
        clear 2>/dev/null || true
        print_banner "STUDENT RECORD MANAGEMENT SYSTEM"
        echo "1. List All Registered Students"
        echo "2. Add New Student Record"
        echo "3. Search Student by Roll No / Name"
        echo "4. Remove Student Record"
        echo "5. Return to Main Menu"
        echo ""
        read -rp "Enter your choice [1-5]: " subchoice
        case "$subchoice" in
            1) list_students; pause_prompt ;;
            2) add_student; pause_prompt ;;
            3) search_student; pause_prompt ;;
            4) remove_student; pause_prompt ;;
            5) break ;;
            *) log_error "Invalid option. Please choose 1-5."; pause_prompt ;;
        esac
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "$#" -eq 0 ]]; then
        student_menu
    else
        "$@"
    fi
fi

