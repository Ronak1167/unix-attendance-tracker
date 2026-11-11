# ==============================================================================
# report_generator.awk - Analytical Engine for Attendance Evaluation
# Course: Unix Programming Lab (24B15CS214) | JIIT Noida-62
# Project: UNIX-Based Student Attendance Tracker
# Authors: Pragya Ahlawat (2501030121), Ronak Jain (2501030128),
#          Rishabh Tyagi (2501030130), Shobhit Khatana (2501030144)
# ==============================================================================

BEGIN {
    FS = ","
    if (threshold == "") threshold = 75.0
    if (report_type == "") report_type = "summary"
    total_students = 0
    total_sessions_count = 0
}

# 1. Process Master File (students.csv)
FILENAME ~ /students\.csv$/ {
    if (FNR > 1 && $1 != "") {
        roll = $1
        name = $2
        batch = $3
        email = $4
        
        student_order[++total_students] = roll
        student_name[roll] = name
        student_batch[roll] = batch
        student_email[roll] = email
        p_count[roll] = 0
        a_count[roll] = 0
        total_classes[roll] = 0
    }
    next
}

# 2. Process Daily Log Files (att_*.log)
FILENAME ~ /att_[0-9]{8}\.log$/ {
    if ($1 != "" && $3 != "") {
        roll = $1
        status = toupper($3)
        timestamp = $4
        
        # Track unique session dates
        if (!(FILENAME in session_files)) {
            session_files[FILENAME] = 1
            session_order[++total_sessions_count] = FILENAME
        }
        
        if (status == "P") {
            p_count[roll]++
            total_classes[roll]++
        } else if (status == "A") {
            a_count[roll]++
            total_classes[roll]++
        }
        
        # Save individual record for transcript breakdown
        record_history[roll, FILENAME] = status
        record_time[roll, FILENAME] = timestamp
    }
}

END {
    # Guard against empty dataset
    if (total_students == 0) {
        print "Error: No student records loaded from master file."
        exit 1
    }

    if (total_sessions_count == 0) {
        print "Warning: No attendance sessions recorded yet in logs directory."
        exit 0
    }

    # Aggregate batch statistics
    batch_total_pct = 0
    defaulter_count = 0
    highest_pct = -1
    lowest_pct = 101

    for (i = 1; i <= total_students; i++) {
        r = student_order[i]
        tot = total_classes[r]
        p = p_count[r]
        
        if (tot > 0) {
            pct[r] = (p / tot) * 100.0
        } else {
            pct[r] = 0.0
        }
        
        batch_total_pct += pct[r]
        
        if (pct[r] < threshold) {
            defaulter_count++
            is_defaulter[r] = 1
        } else {
            is_defaulter[r] = 0
        }
        
        if (pct[r] > highest_pct) highest_pct = pct[r]
        if (pct[r] < lowest_pct) lowest_pct = pct[r]
    }
    
    avg_batch_pct = (total_students > 0) ? (batch_total_pct / total_students) : 0.0

    # --------------------------------------------------------------------------
    # REPORT TYPE: INDIVIDUAL STUDENT TRANSCRIPT
    # --------------------------------------------------------------------------
    if (report_type == "student") {
        if (target_roll == "" || !(target_roll in student_name)) {
            printf "Error: Student Roll Number '%s' not found.\n", target_roll
            exit 1
        }
        
        printf "================================================================================\n"
        printf "                OFFICIAL STUDENT ATTENDANCE TRANSCRIPT                          \n"
        printf "================================================================================\n"
        printf "Roll Number : %-15s | Student Name : %-25s\n", target_roll, student_name[target_roll]
        printf "Batch       : %-15s | Email ID     : %-25s\n", student_batch[target_roll], student_email[target_roll]
        printf "Classes Held: %-15d | Attended     : %-5d | Absent: %-5d\n", total_classes[target_roll], p_count[target_roll], a_count[target_roll]
        printf "Percentage  : %6.2f%%         | Status       : %s\n", pct[target_roll], (pct[target_roll] >= threshold ? "[ ELIGIBLE ]" : "[ DEFAULTER ]")
        printf "--------------------------------------------------------------------------------\n"
        printf "%-5s | %-14s | %-10s | %-20s\n", "S.NO", "SESSION DATE", "ATTENDANCE", "LOGGED TIMESTAMP"
        printf "------+----------------+------------+---------------------\n"
        
        for (s = 1; s <= total_sessions_count; s++) {
            fn = session_order[s]
            # Extract date string
            n = split(fn, path_parts, "/")
            raw_fn = path_parts[n]
            sub(/^att_/, "", raw_fn)
            sub(/\.log$/, "", raw_fn)
            
            st = record_history[target_roll, fn]
            if (st == "") st = "N/A"
            tm = record_time[target_roll, fn]
            if (tm == "") tm = "--"
            
            st_display = (st == "P") ? "PRESENT" : ((st == "A") ? "ABSENT" : "UNRECORDED")
            printf "%-5d | %-14s | %-10s | %-20s\n", s, raw_fn, st_display, tm
        }
        printf "================================================================================\n"
        exit 0
    }

    # --------------------------------------------------------------------------
    # REPORT TYPE: DEFAULTER LIST ONLY (< threshold%)
    # --------------------------------------------------------------------------
    if (report_type == "defaulters") {
        printf "================================================================================\n"
        printf "           ATTENDANCE DEFAULTERS LIST (STRICTLY BELOW %.1f%% CRITERIA)          \n", threshold
        printf "================================================================================\n"
        printf "%-5s | %-12s | %-22s | %-6s | %-5s | %-5s | %-7s | %-14s\n", \
               "S.NO", "ROLL NO", "STUDENT NAME", "TOTAL", "PRES", "ABS", "ATT %", "ELIGIBILITY"
        printf "------+--------------+------------------------+-------+-------+-------+---------+---------------\n"
        
        printed_defaulters = 0
        for (i = 1; i <= total_students; i++) {
            r = student_order[i]
            if (is_defaulter[r]) {
                printed_defaulters++
                printf "%-5d | %-12s | %-22s | %-6d | %-5d | %-5d | %6.2f%% | [ DEFAULTER ]\n", \
                       printed_defaulters, r, student_name[r], total_classes[r], p_count[r], a_count[r], pct[r]
            }
        }
        
        if (printed_defaulters == 0) {
            printf "   *** CONGRATULATIONS! Zero students below the %.1f%% threshold. ***\n", threshold
        }
        printf "------+--------------+------------------------+-------+-------+-------+---------+---------------\n"
        printf "Total Defaulters: %d out of %d students (%.1f%% of class)\n", \
               defaulter_count, total_students, (total_students > 0 ? (defaulter_count / total_students) * 100 : 0)
        printf "================================================================================\n"
        exit 0
    }

    # --------------------------------------------------------------------------
    # REPORT TYPE: FULL BATCH SUMMARY (DEFAULT)
    # --------------------------------------------------------------------------
    printf "====================================================================================================\n"
    printf "                  ACADEMIC ATTENDANCE PERFORMANCE AUDIT REPORT (BATCH B2)                           \n"
    printf "====================================================================================================\n"
    printf "%-5s | %-12s | %-22s | %-6s | %-5s | %-5s | %-7s | %-12s\n", \
           "S.NO", "ROLL NO", "STUDENT NAME", "TOTAL", "PRES", "ABS", "ATT %", "STATUS"
    printf "------+--------------+------------------------+-------+-------+-------+---------+--------------\n"

    for (i = 1; i <= total_students; i++) {
        r = student_order[i]
        status_flag = (is_defaulter[r] == 1) ? "DEFAULTER" : "ELIGIBLE"
        printf "%-5d | %-12s | %-22s | %-6d | %-5d | %-5d | %6.2f%% | %-12s\n", \
               i, r, student_name[r], total_classes[r], p_count[r], a_count[r], pct[r], status_flag
    }

    printf "------+--------------+------------------------+-------+-------+-------+---------+--------------\n"
    printf "STATISTICAL OVERVIEW:\n"
    printf "  • Total Sessions Conducted : %d\n", total_sessions_count
    printf "  • Total Students Evaluated : %d\n", total_students
    printf "  • Class Average Attendance : %.2f%%\n", avg_batch_pct
    printf "  • Attendance Threshold     : %.1f%%\n", threshold
    printf "  • Number of Defaulters     : %d (%.1f%% of class)\n", defaulter_count, (defaulter_count / total_students) * 100
    printf "  • Highest Attendance       : %.2f%%\n", highest_pct
    printf "  • Lowest Attendance        : %.2f%%\n", lowest_pct
    printf "====================================================================================================\n"
}

