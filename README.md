# RISC-V Log Analyzer - Main Version

## Description
The **RISC-V Log Analyzer** is a terminal-based tool developed for the MEDS Module 1 Capstone project. It automates the processing of RISC-V simulation logs to extract test results, calculate performance percentages, and analyze execution timing statistics.

## Repository Structure
This repository follows the strict organizational requirements of the MEDS training program:
* **scripts/**: Core logic including `analyze.sh`, `setup_env.sh`, and `generate_report.sh`.
* **test_data/**: Contains sample logs for passing, failing, and skipped test scenarios.
* **docs/**: Includes the `USAGE.md` detailed command reference.
* **output/**: Destination for generated reports (excluded from version control via `.gitignore`).

## Installation
Before running the analyzer, ensure that the scripts have the necessary execution permissions:
```bash
chmod +x scripts/*.sh