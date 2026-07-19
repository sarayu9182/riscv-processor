# Makefile for RISC-V Processor Simulation

# Toolchain
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Directories
RTL_DIR = rtl
TB_DIR = tb
SIM_DIR = sim
BUILD_DIR = build

# Files - Find all Verilog files
RTL_FILES = $(wildcard $(RTL_DIR)/core/*.v) \
            $(wildcard $(RTL_DIR)/modules/*.v) \
            $(wildcard $(RTL_DIR)/memory/*.v)
TB_FILES = $(wildcard $(TB_DIR)/*.v) \
           $(wildcard $(TB_DIR)/verification/*.v)

# All files combined
ALL_FILES = $(RTL_FILES) $(TB_FILES)

# Targets
.PHONY: all clean sim wave build help

all: build sim

# Create build directory and compile
build:
	@mkdir -p $(BUILD_DIR)
	@echo "Compiling RISC-V processor..."
	$(IVERILOG) -o $(BUILD_DIR)/sim.vvp \
		-DWAVES \
		$(ALL_FILES)
	@echo "Compilation complete!"

# Run simulation
sim: build
	@echo "Running simulation..."
	@mkdir -p $(SIM_DIR)
	$(VVP) $(BUILD_DIR)/sim.vvp
	@echo "Simulation complete! Check $(SIM_DIR)/waveforms.vcd"

# View waveforms
wave:
	@if [ -f $(SIM_DIR)/waveforms.vcd ]; then \
		$(GTKWAVE) $(SIM_DIR)/waveforms.vcd; \
	else \
		echo "Waveform file not found. Run 'make sim' first."; \
	fi

# Run specific test
test-%.hex: build
	@echo "Running test: $@"
	@cp $(TB_DIR)/tests/$@ $(BUILD_DIR)/test.hex || echo "Test file not found"
	$(VVP) $(BUILD_DIR)/sim.vvp +test=$@

# Generate test program
test-gen:
	@echo "Generating test programs..."
	@if [ -f $(TB_DIR)/tests/gen_test_hex.py ]; then \
		cd $(TB_DIR)/tests && python3 gen_test_hex.py; \
	else \
		echo "Python script not found. Creating test manually..."; \
		$(MAKE) create-test-hex; \
	fi

# Create a simple test hex file manually
create-test-hex:
	@echo "Creating simple test hex file..."
	@echo "00000513" > $(TB_DIR)/tests/rv32ui-p-add.hex
	@echo "00100613" >> $(TB_DIR)/tests/rv32ui-p-add.hex
	@echo "00C60633" >> $(TB_DIR)/tests/rv32ui-p-add.hex
	@echo "00200813" >> $(TB_DIR)/tests/rv32ui-p-add.hex
	@echo "405008B3" >> $(TB_DIR)/tests/rv32ui-p-add.hex
	@echo "00102823" >> $(TB_DIR)/tests/rv32ui-p-add.hex
	@echo "00102C23" >> $(TB_DIR)/tests/rv32ui-p-add.hex
	@echo "00002A83" >> $(TB_DIR)/tests/rv32ui-p-add.hex
	@echo "00402B03" >> $(TB_DIR)/tests/rv32ui-p-add.hex
	@echo "00000013" >> $(TB_DIR)/tests/rv32ui-p-add.hex
	@echo "0000006F" >> $(TB_DIR)/tests/rv32ui-p-add.hex

# Run all tests
sim-all: build
	@echo "========================================="
	@echo "Running all test suites..."
	@echo "========================================="
	@mkdir -p $(SIM_DIR)/results
	@for test in $(TB_DIR)/tests/*.hex; do \
		if [ -f "$$test" ]; then \
			echo "Running $$test"; \
			cp $$test $(BUILD_DIR)/test.hex; \
			$(VVP) $(BUILD_DIR)/sim.vvp > $(SIM_DIR)/results/$$(basename $$test .hex).log 2>&1; \
			if [ $$? -eq 0 ]; then \
				echo "✅ $$(basename $$test) PASSED"; \
			else \
				echo "❌ $$(basename $$test) FAILED"; \
			fi \
		fi \
	done
	@echo "========================================="
	@echo "All tests completed. Check $(SIM_DIR)/results/ for details"
	@echo "========================================="

# Clean everything
clean:
	@echo "Cleaning up..."
	rm -rf $(BUILD_DIR)
	rm -rf $(SIM_DIR)/*.vcd
	rm -rf $(SIM_DIR)/*.fst
	rm -rf $(SIM_DIR)/results
	rm -f $(TB_DIR)/tests/*.hex
	@echo "Clean complete!"

# Display help
help:
	@echo "========================================="
	@echo "RISC-V Processor Makefile Help"
	@echo "========================================="
	@echo "Available targets:"
	@echo "  make build      - Compile the design"
	@echo "  make sim        - Run simulation"
	@echo "  make wave       - View waveforms with GTKWave"
	@echo "  make clean      - Remove build artifacts"
	@echo "  make test-gen   - Generate test hex files"
	@echo "  make sim-all    - Run all tests"
	@echo "  make help       - Show this help message"
	@echo "========================================="