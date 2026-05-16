#!/bin/bash


set -euo pipefail

echo "Setting up environment for RISC-V Log Analyzer..."

# Create the output directory if it doesn't exist 
mkdir -p output
echo "Created output/ directory."

# Check for required tools
echo "Checking dependencies..."
which grep > /dev/null
which awk > /dev/null
which sed > /dev/null

echo "Setup complete. All tools found."
exit 0