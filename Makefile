# Variables 
ANALYZER = ./scripts/analyze.sh
LOG_DIR  = test_data
OUT_DIR  = output

# Phony Targets 
.PHONY: all test report clean help setup

all: setup test report

setup:
	@echo "Checking required tools..."
	@which bash > /dev/null || (echo "bash not found"; exit 1)
	@which grep > /dev/null || (echo "grep not found"; exit 1)
	@which awk > /dev/null || (echo "awk not found"; exit 1)
	@mkdir -p $(OUT_DIR)
	@echo "Environment setup complete."

test:
	@echo "Running tests on all log files..."
	$(ANALYZER) $(LOG_DIR)/sample_pass.log
	$(ANALYZER) $(LOG_DIR)/sample_fail.log || true
	$(ANALYZER) $(LOG_DIR)/sample_sim.log || true

report:
	@echo "Generating summary report in $(OUT_DIR)/..."
	$(ANALYZER) $(LOG_DIR)/sample_sim.log --format text --output $(OUT_DIR)/summary.txt || true
	$(ANALYZER) $(LOG_DIR)/sample_sim.log --format csv --output $(OUT_DIR)/summary.csv || true

clean:
	@echo "Removing generated output files..."
	rm -rf $(OUT_DIR)

help:
	@echo "Available targets:"
	@echo "  setup  - Check dependencies and create output directory"
	@echo "  test   - Run analyzer on all sample log files"
	@echo "  report - Generate text and CSV reports"
	@echo "  clean  - Remove all generated output files"
	@echo "  all    - Run setup, test, and report"