#!/bin/bash

set -euo pipefail

# --- FUNCTIONS ---

function show_help {
    echo "Usage: ./analyze.sh <logfile> [--format text|csv] [--output file] [--verbose]"
}

function print_info {
    # only print if verbose flag is on
    if [ "$verbose" == "1" ]; then
        echo "[INFO] $1"
    fi
}

# --- ARGUMENT CHECKING ---

if [ $# -lt 1 ]; then
    echo "Error: Log file missing"
    show_help
    exit 1
fi

log_file="$1"
shift

output_format="text"
out_file=""
verbose=0

# read the flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        --format)
            output_format="$2"
            shift 2
            ;;
        --output)
            out_file="$2"
            shift 2
            ;;
        --verbose)
            verbose=1
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *) 
            echo "Unknown flag: $1"
            exit 1
            ;;
    esac
done

# check if file actually exists
if [ ! -f "$log_file" ]; then
    echo "Error: Log file does not exist!"
    exit 1
fi

# --- GETTING THE COUNTS ---
print_info "Counting pass and fail..."

# using || true so grep doesn't crash the script if it finds 0 matches
all_tests=$(grep -c -E "TEST PASS:|TEST FAIL:|TEST SKIP:" "$log_file" || true)
pass_count=$(grep -c "TEST PASS:" "$log_file" || true)
fail_count=$(grep -c "TEST FAIL:" "$log_file" || true)
skip_count=$(grep -c "TEST SKIP:" "$log_file" || true)

# calculate percentages (avoiding divide by zero error)
if [ "$all_tests" -eq 0 ]; then
    pass_pct="0.0"
    fail_pct="0.0"
    skip_pct="0.0"
else
    pass_pct=$(echo | awk "{printf \"%.1f\", ($pass_count/$all_tests)*100}")
    fail_pct=$(echo | awk "{printf \"%.1f\", ($fail_count/$all_tests)*100}")
    skip_pct=$(echo | awk "{printf \"%.1f\", ($skip_count/$all_tests)*100}")
fi

# --- GETTING FAILED TESTS ---
print_info "Finding failed tests..."

failed_raw=$(grep "TEST FAIL:" "$log_file" || true)
failed_cases=""

# check if the string is empty
if [ -z "$failed_raw" ]; then
    failed_cases="    None"
else
    # basic loop to number the failed tests
    count=1
    
    # 1. Write the raw text into a temporary file
    echo "$failed_raw" > /tmp/temp_fails.txt
    
    # 2. Read from the file 
    while read -r line; do
        # get the 5th column (the name of the test)
        t_name=$(echo "$line" | cut -d' ' -f5)
        failed_cases="${failed_cases}    ${count}. ${t_name}\n"
        count=$((count + 1))
    done < /tmp/temp_fails.txt
    
    # remove the very last newline character so it prints clean
    failed_cases=$(echo -e "$failed_cases" | sed '/^$/d')
fi

# --- GETTING TIMING STATS ---
print_info "Getting times..."

if [ "$all_tests" -gt 0 ]; then
    # use tr to delete the brackets and the 's' letter, instead of complex awk
    times_clean=$(grep -E "TEST PASS:|TEST FAIL:" "$log_file" | awk '{print $6 " " $5}' | tr -d '()s' || true)

    # sort to find min and max
    min_line=$(echo "$times_clean" | sort -n | head -1)
    max_line=$(echo "$times_clean" | sort -n | tail -1)

    min_val=$(echo "$min_line" | cut -d' ' -f1)
    min_name=$(echo "$min_line" | cut -d' ' -f2)
    
    max_val=$(echo "$max_line" | cut -d' ' -f1)
    max_name=$(echo "$max_line" | cut -d' ' -f2)
    
    # calculate average
    avg_val=$(echo "$times_clean" | awk '{sum+=$1} END {printf "%.2f", sum/NR}')
else
    min_val="0"; min_name="N/A"
    max_val="0"; max_name="N/A"
    avg_val="0"
fi

# # final pass/fail check
if [ "$fail_count" -gt 0 ]; then
    verdict="FAIL"
    exit_code=1
else
    verdict="PASS"
    exit_code=0
fi

# --- PRINTING THE REPORT ---
print_info "Generating output..."
current_date=$(date "+%Y-%m-%d %H:%M:%S")

if [ "$output_format" == "csv" ]; then
    result_data="tests,pass,fail,skip,pass_pct,min_time,max_time,avg_time,verdict
$all_tests,$pass_count,$fail_count,$skip_count,$pass_pct,$min_val,$max_val,$avg_val,$verdict"
else
   
    result_data="=== RISC-V Simulation Log Analysis ===
Log file: $log_file
Analysis date: $current_date

--- Results Summary ---
Total tests: $all_tests
Passed:      $pass_count (${pass_pct}%)
Failed:      $fail_count (${fail_pct}%)
Skipped:     $skip_count (${skip_pct}%)

--- Failed Tests ---
$failed_cases

--- Timing Statistics ---
Min time:  ${min_val}s (${min_name})
Max time:  ${max_val}s (${max_name})
Avg time:  ${avg_val}s

--- Verdict: $verdict ---
Exit code: $exit_code"
fi

# --- SAVING THE FILE ---
if [ -n "$out_file" ]; then
    # Create the output directory just in case it doesn't exist
    mkdir -p output
    echo "$result_data" > "$out_file"
    print_info "Saved to $out_file"
else
    echo "$result_data"
fi

exit $exit_code 