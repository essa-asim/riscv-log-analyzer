# Command Reference: riscv-log-analyzer

The main analysis script is located in the `scripts/` directory. 

### **Basic Syntax**
`./scripts/analyze.sh <logfile> [options]`

---

### **Available Options / Flags**

| Option | Description | Default |
| :--- | :--- | :--- |
| `--format text|csv` | Specifies the output format of the report. | `text` |
| `--output <file>` | Saves the generated report to the specified file path instead of printing it to the terminal. | `None` (prints to stdout) |
| `--verbose` | Enables detailed, step-by-step logging during execution. Useful for debugging. | `Disabled` |
| `--help` | Displays the built-in help menu and exits. | N/A |

---

### **Usage Examples**

**1. Basic Text Output**
Run the analyzer on a log file and print the formatted text report directly to the terminal:
```bash
./scripts/analyze.sh test_data/sample_sim.log 