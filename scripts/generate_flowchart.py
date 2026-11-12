#!/usr/bin/env python3
"""
Generate a Publication-Quality, Zero-Collision, Mathematically Aligned,
ANSI/ISO Standard Flowchart for the JIIT Unix-Based Student Attendance Tracker PBL.
"""

import os
import subprocess
import shutil

def create_flowchart_svg():
    width = 1950
    height = 1860

    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}">
  <defs>
    <!-- Modern Shadows -->
    <filter id="shadow" x="-5%" y="-5%" width="115%" height="115%" filterUnits="userSpaceOnUse">
      <feDropShadow dx="0" dy="3" stdDeviation="4" flood-color="#0F172A" flood-opacity="0.10" />
    </filter>
    <filter id="shadow-lg" x="-8%" y="-8%" width="120%" height="120%" filterUnits="userSpaceOnUse">
      <feDropShadow dx="0" dy="5" stdDeviation="6" flood-color="#0F172A" flood-opacity="0.14" />
    </filter>

    <!-- Gradients -->
    <linearGradient id="startGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#10B981" />
      <stop offset="100%" stop-color="#047857" />
    </linearGradient>

    <linearGradient id="stopGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#F43F5E" />
      <stop offset="100%" stop-color="#BE123C" />
    </linearGradient>

    <linearGradient id="procBlue" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#3B82F6" />
      <stop offset="100%" stop-color="#1D4ED8" />
    </linearGradient>

    <linearGradient id="procEmerald" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#10B981" />
      <stop offset="100%" stop-color="#047857" />
    </linearGradient>

    <linearGradient id="procPurple" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#8B5CF6" />
      <stop offset="100%" stop-color="#6D28D9" />
    </linearGradient>

    <linearGradient id="procAmber" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#F59E0B" />
      <stop offset="100%" stop-color="#B45309" />
    </linearGradient>

    <linearGradient id="procSlate" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#64748B" />
      <stop offset="100%" stop-color="#334155" />
    </linearGradient>

    <linearGradient id="decAmber" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#F59E0B" />
      <stop offset="100%" stop-color="#D97706" />
    </linearGradient>

    <linearGradient id="ioCyan" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#06B6D4" />
      <stop offset="100%" stop-color="#0284C7" />
    </linearGradient>

    <!-- Arrow Markers -->
    <marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 10 5 L 0 9 z" fill="#475569" />
    </marker>
    <marker id="arrow-blue" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 10 5 L 0 9 z" fill="#2563EB" />
    </marker>
    <marker id="arrow-red" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1 L 10 5 L 0 9 z" fill="#E11D48" />
    </marker>
  </defs>

  <!-- Typography & Styling -->
  <style>
    .title-inst {{ font-family: 'Segoe UI', Arial, sans-serif; font-size: 13.5px; font-weight: 700; fill: #475569; letter-spacing: 2px; text-anchor: middle; }}
    .title-main {{ font-family: 'Segoe UI', Arial, sans-serif; font-size: 22px; font-weight: 800; fill: #0F172A; text-anchor: middle; }}
    .title-sub {{ font-family: 'Segoe UI', Arial, sans-serif; font-size: 12.5px; font-weight: 600; fill: #64748B; text-anchor: middle; }}
    
    .col-header-box {{ rx: 6px; }}
    .col-header-title {{ font-family: 'Segoe UI', Arial, sans-serif; font-size: 12.5px; font-weight: 800; fill: #FFFFFF; text-anchor: middle; }}
    
    .node-title {{ font-family: 'Segoe UI', Arial, sans-serif; font-size: 12.5px; font-weight: 700; fill: #FFFFFF; text-anchor: middle; }}
    .node-desc {{ font-family: 'Segoe UI', Arial, sans-serif; font-size: 10.5px; font-weight: 500; fill: #F1F5F9; text-anchor: middle; }}
    
    .node-title-dark {{ font-family: 'Segoe UI', Arial, sans-serif; font-size: 12.5px; font-weight: 700; fill: #0F172A; text-anchor: middle; }}
    .node-desc-dark {{ font-family: 'Segoe UI', Arial, sans-serif; font-size: 10.5px; font-weight: 600; fill: #334155; text-anchor: middle; }}

    .flow-line {{ stroke: #475569; stroke-width: 2.2px; fill: none; marker-end: url(#arrow); stroke-linejoin: round; stroke-linecap: round; }}
    .flow-bus {{ stroke: #475569; stroke-width: 2.5px; fill: none; stroke-linejoin: round; stroke-linecap: round; }}
    .return-line {{ stroke: #2563EB; stroke-width: 2.2px; stroke-dasharray: 6 4; fill: none; marker-end: url(#arrow-blue); stroke-linejoin: round; stroke-linecap: round; }}
    .exit-line {{ stroke: #E11D48; stroke-width: 2.2px; fill: none; marker-end: url(#arrow-red); stroke-linejoin: round; stroke-linecap: round; }}

    .badge-label {{ font-family: 'Segoe UI', Arial, sans-serif; font-size: 11px; font-weight: 700; fill: #1E293B; }}
    .badge-yes {{ font-family: 'Segoe UI', Arial, sans-serif; font-size: 11px; font-weight: 800; fill: #047857; }}
    .badge-no {{ font-family: 'Segoe UI', Arial, sans-serif; font-size: 11px; font-weight: 800; fill: #B91C1C; }}

    .legend-text {{ font-family: 'Segoe UI', Arial, sans-serif; font-size: 11.5px; font-weight: 600; fill: #334155; }}
  </style>

  <!-- Canvas Background -->
  <rect width="{width}" height="{height}" fill="#F8FAFC" />

  <!-- ==================== HEADER SECTION ==================== -->
  <text x="{width/2}" y="36" class="title-inst">JAYPEE INSTITUTE OF INFORMATION TECHNOLOGY, NOIDA-62</text>
  <text x="{width/2}" y="66" class="title-main">UNIX-BASED STUDENT ATTENDANCE TRACKER — EXECUTION &amp; ARCHITECTURE FLOWCHART</text>
  <text x="{width/2}" y="91" class="title-sub">Course: Unix Programming Lab (24B15CS214) | Batch: B2 | Team: Pragya (121), Ronak (128), Rishabh (130), Shobhit (144)</text>

  <!-- ==================== HORIZONTAL LEGEND BAR ==================== -->
  <g transform="translate(135, 110)">
    <rect x="0" y="0" width="1680" height="52" rx="8" fill="#FFFFFF" stroke="#CBD5E1" stroke-width="1.5" filter="url(#shadow)" />
    
    <!-- Legend 1: Terminator (Oval) -->
    <g transform="translate(45, 12)">
      <rect x="0" y="0" width="76" height="28" rx="14" fill="url(#startGrad)" />
      <text x="38" y="18" font-family="'Segoe UI', Arial" font-size="10" font-weight="700" fill="#FFF" text-anchor="middle">Oval</text>
      <text x="88" y="19" class="legend-text">Terminator (Start / Exit)</text>
    </g>

    <!-- Legend 2: Process (Rectangle) -->
    <g transform="translate(375, 12)">
      <rect x="0" y="0" width="76" height="28" rx="4" fill="url(#procBlue)" />
      <text x="38" y="18" font-family="'Segoe UI', Arial" font-size="10" font-weight="700" fill="#FFF" text-anchor="middle">Rectangle</text>
      <text x="88" y="19" class="legend-text">Process (Script / POSIX Command)</text>
    </g>

    <!-- Legend 3: Decision (Diamond) -->
    <g transform="translate(745, 12)">
      <polygon points="38,0 76,14 38,28 0,14" fill="url(#decAmber)" />
      <text x="38" y="18" font-family="'Segoe UI', Arial" font-size="10" font-weight="700" fill="#FFF" text-anchor="middle">Diamond</text>
      <text x="88" y="19" class="legend-text">Decision (Condition / Logic Gate)</text>
    </g>

    <!-- Legend 4: Input / Output (Parallelogram) -->
    <g transform="translate(1105, 12)">
      <polygon points="12,0 76,0 64,28 0,28" fill="url(#ioCyan)" />
      <text x="38" y="18" font-family="'Segoe UI', Arial" font-size="9" font-weight="700" fill="#FFF" text-anchor="middle">Parallelogram</text>
      <text x="88" y="19" class="legend-text">Input / Output (Terminal I/O)</text>
    </g>

    <!-- Legend 5: Data Store (Cylinder) -->
    <g transform="translate(1445, 12)">
      <ellipse cx="34" cy="5" rx="34" ry="4" fill="#64748B" />
      <rect x="0" y="5" width="68" height="18" fill="#475569" />
      <ellipse cx="34" cy="23" rx="34" ry="4" fill="#334155" />
      <text x="34" y="18" font-family="'Segoe UI', Arial" font-size="9.5" font-weight="700" fill="#FFF" text-anchor="middle">Cylinder</text>
      <text x="80" y="19" class="legend-text">Data Store (CSV / Tar / Log)</text>
    </g>
  </g>

  <!-- ==================== PHASE 1: SYSTEM INVOCATION & INIT (Center X = 940) ==================== -->
  <!-- 1. START NODE (Oval) -->
  <rect x="825" y="185" width="230" height="52" rx="26" fill="url(#startGrad)" filter="url(#shadow)" />
  <text x="940" y="209" class="node-title">START</text>
  <text x="940" y="225" class="node-desc">Invoke ./attendance.sh</text>

  <!-- Arrow down to Env Init -->
  <path d="M 940 237 L 940 265" class="flow-line" />

  <!-- 2. ENVIRONMENT INITIALIZATION (Rectangle) -->
  <rect x="760" y="265" width="360" height="60" rx="6" fill="url(#procBlue)" filter="url(#shadow)" />
  <text x="940" y="289" class="node-title">Dynamic Environment Discovery &amp; Init</text>
  <text x="940" y="307" class="node-desc">common.sh: Resolve BASE_DIR, verify data/, logs/, archives/, reports/</text>

  <!-- Arrow down to CLI Decision -->
  <path d="M 940 325 L 940 355" class="flow-line" />

  <!-- 3. DECISION: CLI ARGUMENTS PASSED? (Diamond) -->
  <polygon points="940,355 1060,395 940,435 820,395" fill="url(#decAmber)" filter="url(#shadow)" />
  <text x="940" y="391" class="node-title-dark">CLI Flags Passed?</text>
  <text x="940" y="408" class="node-desc-dark">($# &gt; 0 check)</text>

  <!-- Branch Right: YES -> Headless CLI Pipeline (Self-Contained in Upper-Right) -->
  <path d="M 1060 395 L 1260 395" class="flow-line" />
  <text x="1080" y="385" class="badge-yes">[YES: --report / --test / --defaulters]</text>

  <!-- Process: Headless CLI Dispatcher -->
  <rect x="1260" y="365" width="220" height="60" rx="6" fill="url(#procPurple)" filter="url(#shadow)" />
  <text x="1370" y="389" class="node-title">Headless CLI Dispatcher</text>
  <text x="1370" y="407" class="node-desc">Direct case branch without TUI</text>

  <path d="M 1480 395 L 1530 395" class="flow-line" />

  <!-- Parallelogram: Render stdout Table -->
  <polygon points="1545,365 1745,365 1725,425 1525,425" fill="url(#ioCyan)" filter="url(#shadow)" />
  <text x="1635" y="390" class="node-title">Render stdout Table</text>
  <text x="1635" y="407" class="node-desc">Stream results to console</text>

  <path d="M 1635 425 L 1635 455" class="flow-line" />

  <!-- Oval: CLI STOP -->
  <rect x="1565" y="455" width="140" height="40" rx="20" fill="url(#stopGrad)" filter="url(#shadow)" />
  <text x="1635" y="480" class="node-title">STOP (0)</text>

  <!-- ==================== PHASE 2: INTERACTIVE DASHBOARD ==================== -->
  <!-- Branch Down: NO -> Interactive Menu -->
  <path d="M 940 435 L 940 475" class="flow-line" />
  <text x="948" y="458" class="badge-no">[NO: Interactive Mode]</text>

  <!-- 4. DISPLAY DASHBOARD (Symmetric Parallelogram around X=940) -->
  <polygon points="770,475 1130,475 1090,535 730,535" fill="url(#ioCyan)" filter="url(#shadow)" />
  <text x="930" y="500" class="node-title">Render ANSI Interactive Dashboard</text>
  <text x="930" y="518" class="node-desc">98-character border, live ISO timestamp, options [1 - 8]</text>

  <!-- Arrow down to Read Choice -->
  <path d="M 930 535 L 930 565" class="flow-line" />

  <!-- 5. READ USER SELECTION (Symmetric Parallelogram) -->
  <polygon points="805,565 1075,565 1045,615 775,615" fill="url(#ioCyan)" filter="url(#shadow)" />
  <text x="925" y="587" class="node-title">Read User Selection</text>
  <text x="925" y="603" class="node-desc">Capture variable: choice (1..8)</text>

  <!-- Arrow down to Evaluate Choice -->
  <path d="M 925 615 L 925 645" class="flow-line" />

  <!-- 6. EVALUATE CHOICE SWITCH (Diamond centered at X=925) -->
  <polygon points="925,645 1065,690 925,735 785,690" fill="url(#decAmber)" filter="url(#shadow)" />
  <text x="925" y="685" class="node-title-dark">Evaluate Choice?</text>
  <text x="925" y="702" class="node-desc-dark">case $choice in [1..8]</text>

  <!-- ==================== HORIZONTAL DISPATCH BUS ==================== -->
  <!-- Left Bus to Columns 1 & 2 -->
  <path d="M 785 690 L 170 690 L 170 750" class="flow-bus" />
  <path d="M 555 690 L 555 750" class="flow-line" />
  
  <!-- Center Drop directly to Column 3 -->
  <path d="M 925 735 L 925 750" class="flow-line" />

  <!-- Right Bus to Columns 4 & 5 and Exit Corridor -->
  <path d="M 1065 690 L 1890 690" class="flow-bus" />
  <path d="M 1325 690 L 1325 750" class="flow-line" />
  <path d="M 1710 690 L 1710 750" class="flow-line" />
  
  <!-- Option 8 Exit Highway down Right Margin Corridor -->
  <path d="M 1890 690 L 1890 1630 L 1150 1630" class="exit-line" />
  <text x="1830" y="680" class="badge-label" fill="#E11D48">[Opt 8: Exit]</text>

  <!-- Option Labels along Dispatch Bus -->
  <text x="180" y="735" class="badge-label">[Opt 1]</text>
  <text x="565" y="735" class="badge-label">[Opt 2]</text>
  <text x="935" y="745" class="badge-label">[Opt 3]</text>
  <text x="1335" y="735" class="badge-label">[Opt 5]</text>
  <text x="1720" y="735" class="badge-label">[Opt 4,6,7]</text>

  <!-- ==================== 5 FUNCTIONAL COLUMNS ==================== -->

  <!-- ==================== COLUMN 1: DAILY ATTENDANCE (Center X = 170) ==================== -->
  <!-- Col 1 Header -->
  <rect x="50" y="750" width="240" height="32" fill="#047857" class="col-header-box" />
  <text x="170" y="771" class="col-header-title">1. DAILY ATTENDANCE</text>

  <!-- Parallelogram: Input Date & Mode -->
  <polygon points="65,800 285,800 265,855 45,855" fill="url(#ioCyan)" filter="url(#shadow)" />
  <text x="165" y="823" class="node-title">Input Date &amp; Mode</text>
  <text x="165" y="841" class="node-desc">Default: YYYY-MM-DD | Rapid/Step</text>

  <path d="M 165 855 L 165 885" class="flow-line" />

  <!-- Decision: Session Exists? (Diamond) -->
  <polygon points="165,885 260,920 165,955 70,920" fill="url(#decAmber)" filter="url(#shadow)" />
  <text x="165" y="916" class="node-title-dark">Log Exists?</text>
  <text x="165" y="931" class="node-desc-dark">att_YYYY-MM-DD.log</text>

  <path d="M 165 955 L 165 985" class="flow-line" />

  <!-- Process: Record Daily Attendance (Rectangle) -->
  <rect x="50" y="985" width="230" height="85" rx="6" fill="url(#procEmerald)" filter="url(#shadow)" />
  <text x="165" y="1008" class="node-title">Record Attendance Turnout</text>
  <text x="165" y="1027" class="node-desc">• Rapid: All P, enter absents</text>
  <text x="165" y="1042" class="node-desc">• Step: Read [P/a] per roll</text>
  <text x="165" y="1057" class="node-desc">• Log: YYYY-MM-DD HH:MM:SS</text>

  <path d="M 165 1070 L 165 1100" class="flow-line" />

  <!-- Data Store: Daily Log (Cylinder) -->
  <g transform="translate(50, 1100)">
    <ellipse cx="115" cy="10" rx="115" ry="10" fill="#64748B" />
    <rect x="0" y="10" width="230" height="50" fill="#475569" />
    <ellipse cx="115" cy="60" rx="115" ry="10" fill="#334155" />
    <text x="115" y="32" class="node-title" font-size="12">logs/att_YYYY-MM-DD.log</text>
    <text x="115" y="48" class="node-desc">Daily Ledger (chmod 600)</text>
  </g>

  <path d="M 165 1170 L 165 1200" class="flow-line" />

  <!-- Process: Update Symlink (Rectangle) -->
  <rect x="50" y="1200" width="230" height="60" rx="6" fill="url(#procEmerald)" filter="url(#shadow)" />
  <text x="165" y="1225" class="node-title">Update Symbolic Link</text>
  <text x="165" y="1243" class="node-desc">ln -sf logs/att_... data/current_day.log</text>

  <path d="M 165 1260 L 165 1290" class="flow-line" />

  <!-- Parallelogram: Display Session Summary -->
  <polygon points="65,1290 285,1290 265,1345 45,1345" fill="url(#ioCyan)" filter="url(#shadow)" />
  <text x="165" y="1313" class="node-title">Display Turnout Summary</text>
  <text x="165" y="1331" class="node-desc">Total, Present, Absent, %</text>

  <!-- Route to Return Bus -->
  <path d="M 165 1345 L 165 1520" class="flow-line" />

  <!-- ==================== COLUMN 2: STUDENT MANAGEMENT (Center X = 555) ==================== -->
  <!-- Col 2 Header -->
  <rect x="435" y="750" width="240" height="32" fill="#1D4ED8" class="col-header-box" />
  <text x="555" y="771" class="col-header-title">2. STUDENT DIRECTORY (CRUD)</text>

  <!-- Parallelogram: Input Action -->
  <polygon points="450,800 670,800 650,855 430,855" fill="url(#ioCyan)" filter="url(#shadow)" />
  <text x="550" y="823" class="node-title">Select Student Action</text>
  <text x="550" y="841" class="node-desc">1:List  2:Add  3:Search  4:Delete</text>

  <path d="M 550 855 L 550 885" class="flow-line" />

  <!-- Decision: Operation Type (Diamond) -->
  <polygon points="550,885 645,920 550,955 455,920" fill="url(#decAmber)" filter="url(#shadow)" />
  <text x="550" y="916" class="node-title-dark">Action Choice?</text>
  <text x="550" y="931" class="node-desc-dark">Add / Delete / Search / List</text>

  <path d="M 550 955 L 550 985" class="flow-line" />

  <!-- Process: Student Logic (Rectangle) -->
  <rect x="435" y="985" width="230" height="85" rx="6" fill="url(#procBlue)" filter="url(#shadow)" />
  <text x="550" y="1008" class="node-title">Execute Student Logic</text>
  <text x="550" y="1027" class="node-desc">• Add: Validate &amp; grep -q duplicate</text>
  <text x="550" y="1042" class="node-desc">• Del: Atomic sed -i with .bak</text>
  <text x="550" y="1057" class="node-desc">• Sort: sort -t',' -k1,1n students.csv</text>

  <path d="M 550 1070 L 550 1100" class="flow-line" />

  <!-- Data Store: Master CSV (Cylinder) -->
  <g transform="translate(435, 1100)">
    <ellipse cx="115" cy="10" rx="115" ry="10" fill="#64748B" />
    <rect x="0" y="10" width="230" height="50" fill="#475569" />
    <ellipse cx="115" cy="60" rx="115" ry="10" fill="#334155" />
    <text x="115" y="32" class="node-title" font-size="12">data/students.csv</text>
    <text x="115" y="48" class="node-desc">Master Directory (chmod 600)</text>
  </g>

  <path d="M 550 1170 L 550 1200" class="flow-line" />

  <!-- Process: Align Directory Table (Rectangle) -->
  <rect x="435" y="1200" width="230" height="60" rx="6" fill="url(#procBlue)" filter="url(#shadow)" />
  <text x="550" y="1225" class="node-title">Tabular Formatting</text>
  <text x="550" y="1243" class="node-desc">awk directory formatter with headers</text>

  <path d="M 550 1260 L 550 1290" class="flow-line" />

  <!-- Parallelogram: Display Directory Table -->
  <polygon points="450,1290 670,1290 650,1345 430,1345" fill="url(#ioCyan)" filter="url(#shadow)" />
  <text x="550" y="1313" class="node-title">Display Student Directory</text>
  <text x="550" y="1331" class="node-desc">Output aligned table to terminal</text>

  <!-- Route to Return Bus -->
  <path d="M 550 1345 L 550 1520" class="flow-line" />

  <!-- ==================== COLUMN 3: AWK ANALYTICS (Center X = 925) ==================== -->
  <!-- Col 3 Header -->
  <rect x="805" y="750" width="240" height="32" fill="#6D28D9" class="col-header-box" />
  <text x="925" y="771" class="col-header-title">3. ANALYTICS &amp; AWK ENGINE</text>

  <!-- Process: Invoke AWK (Rectangle) -->
  <rect x="805" y="800" width="240" height="60" rx="6" fill="url(#procPurple)" filter="url(#shadow)" />
  <text x="925" y="824" class="node-title">Invoke Analytics Engine</text>
  <text x="925" y="842" class="node-desc">gawk: Load students.csv + logs/*.log</text>

  <path d="M 925 860 L 925 890" class="flow-line" />

  <!-- Process: Cross-Referencing Math (Rectangle) -->
  <rect x="805" y="890" width="240" height="65" rx="6" fill="url(#procPurple)" filter="url(#shadow)" />
  <text x="925" y="913" class="node-title">Multi-Log Cross-Referencing</text>
  <text x="925" y="931" class="node-desc">Compute Held, Present, Absent</text>
  <text x="925" y="945" class="node-desc">% = (Attended / Total) * 100</text>

  <path d="M 925 955 L 925 980" class="flow-line" />

  <!-- Decision: Attendance < 75%? (Diamond) -->
  <polygon points="925,980 1025,1015 925,1050 825,1015" fill="url(#decAmber)" filter="url(#shadow)" />
  <text x="925" y="1011" class="node-title-dark">Turnout &lt; 75%?</text>
  <text x="925" y="1027" class="node-desc-dark">(Threshold Check)</text>

  <!-- Clean Sub-Branches completely within Column 3 (x=805 to 1045) -->
  <path d="M 825 1015 L 860 1015 L 860 1065" class="flow-line" />
  <path d="M 1025 1015 L 990 1015 L 990 1065" class="flow-line" />

  <!-- Left: YES -> Defaulter -->
  <rect x="805" y="1065" width="112" height="65" rx="6" fill="url(#stopGrad)" filter="url(#shadow)" />
  <text x="861" y="1088" class="node-title" font-size="11">[YES] Defaulter</text>
  <text x="861" y="1106" class="node-desc" font-size="9.5">Exam Detention</text>
  <text x="861" y="1120" class="node-desc" font-size="9.5">Warning Flag</text>

  <!-- Right: NO -> Eligible -->
  <rect x="933" y="1065" width="112" height="65" rx="6" fill="url(#procEmerald)" filter="url(#shadow)" />
  <text x="989" y="1088" class="node-title" font-size="11">[NO] Eligible</text>
  <text x="989" y="1106" class="node-desc" font-size="9.5">Good Standing</text>
  <text x="989" y="1120" class="node-desc" font-size="9.5">Verified Status</text>

  <!-- Merge Branches into Parallelogram -->
  <path d="M 861 1130 L 861 1155 L 925 1155 L 925 1180" class="flow-line" />
  <path d="M 989 1130 L 989 1155 L 925 1155" />

  <!-- Parallelogram: Display Report Table -->
  <polygon points="815,1180 1035,1180 1015,1235 795,1235" fill="url(#ioCyan)" filter="url(#shadow)" />
  <text x="915" y="1203" class="node-title">Render Performance Audit</text>
  <text x="915" y="1221" class="node-desc">Full table &amp; Defaulter alerts</text>

  <path d="M 915 1235 L 915 1265" class="flow-line" />

  <!-- Process: Export Reports to Disk -->
  <rect x="805" y="1265" width="240" height="65" rx="6" fill="url(#procPurple)" filter="url(#shadow)" />
  <text x="925" y="1288" class="node-title">Export Analytics to Disk</text>
  <text x="925" y="1306" class="node-desc">Save reports/*.txt &amp; reports/*.csv</text>
  <text x="925" y="1320" class="node-desc">with generation timestamps</text>

  <!-- Route to Return Bus -->
  <path d="M 925 1330 L 925 1520" class="flow-line" />

  <!-- ==================== COLUMN 4: LOG ARCHIVING (Center X = 1325) ==================== -->
  <!-- Col 4 Header -->
  <rect x="1205" y="750" width="240" height="32" fill="#B45309" class="col-header-box" />
  <text x="1325" y="771" class="col-header-title">5. MONTHLY ARCHIVAL</text>

  <!-- Parallelogram: Input Target Month -->
  <polygon points="1220,800 1440,800 1420,855 1200,855" fill="url(#ioCyan)" filter="url(#shadow)" />
  <text x="1320" y="823" class="node-title">Input Target Month</text>
  <text x="1320" y="841" class="node-desc">Format: YYYY-MM</text>

  <path d="M 1320 855 L 1320 885" class="flow-line" />

  <!-- Decision: Month Logs Found? (Diamond) -->
  <polygon points="1320,885 1415,920 1320,955 1225,920" fill="url(#decAmber)" filter="url(#shadow)" />
  <text x="1320" y="916" class="node-title-dark">Logs Found?</text>
  <text x="1320" y="931" class="node-desc-dark">att_YYYY-MM-*.log</text>

  <path d="M 1320 955 L 1320 985" class="flow-line" />

  <!-- Process: tar + gzip (Rectangle) -->
  <rect x="1205" y="985" width="230" height="75" rx="6" fill="url(#procAmber)" filter="url(#shadow)" />
  <text x="1320" y="1008" class="node-title">Compress with tar &amp; gzip</text>
  <text x="1320" y="1027" class="node-desc">tar -czvf attendance_archive_</text>
  <text x="1320" y="1042" class="node-desc">YYYY-MM.tar.gz</text>

  <path d="M 1320 1060 L 1320 1090" class="flow-line" />

  <!-- Process: Verify Integrity (Rectangle) -->
  <rect x="1205" y="1090" width="230" height="60" rx="6" fill="url(#procAmber)" filter="url(#shadow)" />
  <text x="1320" y="1114" class="node-title">Verify Archive Integrity</text>
  <text x="1320" y="1132" class="node-desc">tar -tzf (Test table of contents)</text>

  <path d="M 1320 1150 L 1320 1180" class="flow-line" />

  <!-- Data Store: Archive Tarball (Cylinder) -->
  <g transform="translate(1205, 1180)">
    <ellipse cx="115" cy="10" rx="115" ry="10" fill="#64748B" />
    <rect x="0" y="10" width="230" height="50" fill="#475569" />
    <ellipse cx="115" cy="60" rx="115" ry="10" fill="#334155" />
    <text x="115" y="32" class="node-title" font-size="12">archives/*.tar.gz</text>
    <text x="115" y="48" class="node-desc">Compressed Backups</text>
  </g>

  <path d="M 1320 1250 L 1320 1280" class="flow-line" />

  <!-- Decision: Purge Raw Logs? (Diamond) -->
  <polygon points="1320,1280 1415,1312 1320,1345 1225,1312" fill="url(#decAmber)" filter="url(#shadow)" />
  <text x="1320" y="1308" class="node-title-dark">Purge Raw Logs?</text>
  <text x="1320" y="1323" class="node-desc-dark">(Disk optimization)</text>

  <!-- Route to Return Bus -->
  <path d="M 1320 1345 L 1320 1520" class="flow-line" />

  <!-- ==================== COLUMN 5: UTILITIES, SECURITY & TESTS (Center X = 1710) ==================== -->
  <!-- Col 5 Header -->
  <rect x="1590" y="750" width="240" height="32" fill="#334155" class="col-header-box" />
  <text x="1710" y="771" class="col-header-title">4, 6, 7. UTILITIES &amp; TESTS</text>

  <!-- Process: Option 4 Symlink Inspector (Rectangle) -->
  <rect x="1590" y="800" width="240" height="70" rx="6" fill="url(#procSlate)" filter="url(#shadow)" />
  <text x="1710" y="824" class="node-title">[4] Active Session Inspector</text>
  <text x="1710" y="842" class="node-desc">readlink -f data/current_day.log</text>
  <text x="1710" y="856" class="node-desc">Display today's active session table</text>

  <path d="M 1710 870 L 1710 900" class="flow-line" />

  <!-- Process: Option 6 Security Hardening (Rectangle) -->
  <rect x="1590" y="900" width="240" height="75" rx="6" fill="url(#procSlate)" filter="url(#shadow)" />
  <text x="1710" y="924" class="node-title">[6] Security &amp; Permissions</text>
  <text x="1710" y="943" class="node-desc">Enforce chmod 600 (DB &amp; logs)</text>
  <text x="1710" y="958" class="node-desc">chmod 700 (dirs), chmod 755 (scripts)</text>

  <path d="M 1710 975 L 1710 1005" class="flow-line" />

  <!-- Process: Option 7 Automated Test Suite (Rectangle) -->
  <rect x="1590" y="1005" width="240" height="80" rx="6" fill="url(#procPurple)" filter="url(#shadow)" />
  <text x="1710" y="1029" class="node-title">[7] Automated Test Suite</text>
  <text x="1710" y="1048" class="node-desc">Execute tests/run_tests.sh</text>
  <text x="1710" y="1063" class="node-desc">35/35 Full Regression Harness</text>
  <text x="1710" y="1077" class="node-desc">Verifies All 7 Modules (100% Pass)</text>

  <path d="M 1710 1085 L 1710 1115" class="flow-line" />

  <!-- Parallelogram: Display Test & Compliance Summary -->
  <polygon points="1600,1115 1820,1115 1800,1170 1580,1170" fill="url(#ioCyan)" filter="url(#shadow)" />
  <text x="1700" y="1138" class="node-title">Display Compliance / Metrics</text>
  <text x="1700" y="1156" class="node-desc">DAC audit table &amp; Test report</text>

  <!-- Route to Return Bus -->
  <path d="M 1700 1170 L 1700 1520" class="flow-line" />

  <!-- ==================== PHASE 5: RETURN BUS & EXIT TERMINATION ==================== -->
  <!-- Horizontal Return Collection Bus at y=1520 -->
  <path d="M 165 1520 L 1700 1520" class="flow-bus" />

  <!-- Return Highway up Left Margin Corridor (x=22) to Interactive Menu (y=505) -->
  <path d="M 165 1520 L 22 1520 L 22 505 L 730 505" class="return-line" />
  <text x="30" y="1050" class="badge-label" fill="#2563EB" transform="rotate(-90 30 1050)">Return to Main Menu Loop (Options 1 - 7)</text>

  <!-- Node: Signal Trap & Safe Cleanup (Rectangle) -->
  <!-- Receives Option 8 from Right Highway at (1150, 1630) -->
  <rect x="725" y="1600" width="425" height="65" rx="6" fill="url(#procBlue)" filter="url(#shadow)" />
  <text x="937" y="1625" class="node-title">Signal Trap &amp; Safe Cleanup</text>
  <text x="937" y="1644" class="node-desc">trap SIGINT / SIGTERM: Purge temp buffers (*.tmp, *.bak)</text>
  <text x="937" y="1658" class="node-desc">Close file descriptors &amp; reset ANSI terminal state</text>

  <!-- Arrow down to STOP -->
  <path d="M 937 1665 L 937 1705" class="flow-line" />

  <!-- Final Terminator: STOP / EXIT (Oval) -->
  <rect x="812" y="1705" width="250" height="55" rx="27.5" fill="url(#stopGrad)" filter="url(#shadow)" />
  <text x="937" y="1731" class="node-title" font-size="14">STOP / EXIT</text>
  <text x="937" y="1748" class="node-desc">Graceful session close (Code 0)</text>

  <!-- Flowchart Footer Note -->
  <text x="{width/2}" y="1810" class="title-sub">JIIT B.Tech CSE Unix Programming Lab (24B15CS214) | ANSI/ISO Standard Flowchart Geometry | Zero-Collision Architecture</text>
</svg>'''
    return svg

def main():
    svg_content = create_flowchart_svg()
    
    docs_dir = r'C:\Users\Ronak Jain\.gemini\antigravity\scratch\unix-attendance-tracker\docs'
    downloads_dir = r'C:\Users\Ronak Jain\Downloads'
    os.makedirs(docs_dir, exist_ok=True)
    
    # Save SVG
    svg_docs = os.path.join(docs_dir, 'standard_flowchart.svg')
    svg_dl = os.path.join(downloads_dir, 'unix_attendance_tracker_flowchart.svg')
    with open(svg_docs, 'w', encoding='utf-8') as f:
        f.write(svg_content)
    with open(svg_dl, 'w', encoding='utf-8') as f:
        f.write(svg_content)
    print(f'Saved SVG to: {svg_docs} & {svg_dl}')

    # Save HTML wrapper for pixel-perfect browser rendering
    html_file = os.path.join(docs_dir, 'render_flowchart.html')
    html_content = f'''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body, html {{
      margin: 0;
      padding: 0;
      background: #F8FAFC;
      display: flex;
      justify-content: center;
      align-items: center;
    }}
    svg {{
      width: 1950px;
      height: 1860px;
    }}
  </style>
</head>
<body>
  {svg_content}
</body>
</html>'''
    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(html_content)

    # Render PNG using Microsoft Edge
    out_png = os.path.join(downloads_dir, 'unix_attendance_tracker_flowchart.png')
    docs_png = os.path.join(docs_dir, 'unix_attendance_tracker_flowchart.png')
    
    browsers = [
        r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
        r'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
        r'C:\Program Files\Google\Chrome\Application\chrome.exe'
    ]
    browser_exe = None
    for b in browsers:
        if os.path.exists(b):
            browser_exe = b
            break
            
    if browser_exe:
        print(f'Rendering PNG with {browser_exe}...')
        cmd = [
            browser_exe,
            '--headless=new',
            '--disable-gpu',
            '--hide-scrollbars',
            f'--screenshot={out_png}',
            f'--window-size=1970,1880',
            os.path.abspath(html_file)
        ]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if os.path.exists(out_png) and os.path.getsize(out_png) > 1000:
            print(f'SUCCESS! High-Res Flowchart PNG rendered: {out_png}')
            print(f'File Size: {os.path.getsize(out_png):,} bytes')
            shutil.copyfile(out_png, docs_png)
            print(f'Copied PNG to repo docs: {docs_png}')
        else:
            print(f'Render error: {res.stderr}')

if __name__ == '__main__':
    main()
