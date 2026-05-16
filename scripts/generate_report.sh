#!/bin/bash

set -euo pipefail

# Define paths using variables 
ANALYZER="./scripts/analyze.sh"
LOG_FILE="test_data/sample_fail.log"
REPORT_TXT="output/summary_report.txt"
REPORT_CSV="output/summary_report.csv"

echo "Generating automated reports..."

# Run the analyzer for text output 
$ANALYZER "$LOG_FILE" --format text --output "$REPORT_TXT"
echo "Text report generated: $REPORT_TXT"

# Run the analyzer for CSV output 
$ANALYZER "$LOG_FILE" --format csv --output "$REPORT_CSV"
echo "CSV report generated: $REPORT_CSV"

echo "All reports generated successfully."
exit 0