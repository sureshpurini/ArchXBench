SHELL := /bin/bash

# Tool settings
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Design files
DUT = shift_add_mult.v
TESTBENCH = shift_add_mult_tb.v
TOP = shift_add_mult_tb

# Output files
VVP_FILE = $(TOP).vvp
VCD_FILE = $(TOP).vcd
LOG_FILE = sim_$(WIDTH)x$(PARALLEL_OPS).log

# Default parameters
WIDTH ?= 16
PARALLEL_OPS ?= 4
SIGNED ?= 1

# Compilation flags
VERILOG_FLAGS = -g2012 -Wall

# Phony targets
.PHONY: all compile sim wave clean help test_all

# Default target
all: compile sim

# Compile the design
compile:
	@echo "Compiling with WIDTH=$(WIDTH), PARALLEL_OPS=$(PARALLEL_OPS), SIGNED=$(SIGNED)"
	$(IVERILOG) $(VERILOG_FLAGS) -s $(TOP) -o $(VVP_FILE) \
		-P$(TOP).WIDTH=$(WIDTH) -P$(TOP).PARALLEL_OPS=$(PARALLEL_OPS) -P$(TOP).SIGNED=$(SIGNED) \
		$(DUT) $(TESTBENCH)

# Run simulation
sim: compile
	@echo "Running simulation..."
	$(VVP) $(VVP_FILE) | tee $(LOG_FILE)
	@echo "Simulation log saved to $(LOG_FILE)"

# View waveforms
wave: sim
	@echo "Opening waveform viewer..."
	$(GTKWAVE) $(VCD_FILE) &

# Test different configurations
test_all:
	@echo "Testing multiple configurations..."
	@for width in 8 16 32; do \
		for par in 1 2 4 8 16 32; do \
			if [ $$par -le $$width ] && [ $$(( $$width % $$par )) -eq 0 ]; then \
				echo ""; \
				echo "=== Testing WIDTH=$$width, PARALLEL_OPS=$$par ==="; \
				$(MAKE) clean > /dev/null 2>&1; \
				$(MAKE) sim WIDTH=$$width PARALLEL_OPS=$$par SIGNED=1; \
				sleep 1; \
			fi; \
		done; \
	done

# Specific test configurations
test_serial:
	$(MAKE) sim WIDTH=16 PARALLEL_OPS=1 SIGNED=1

test_parallel2:
	$(MAKE) sim WIDTH=16 PARALLEL_OPS=2 SIGNED=1

test_parallel4:
	$(MAKE) sim WIDTH=16 PARALLEL_OPS=4 SIGNED=1

test_parallel8:
	$(MAKE) sim WIDTH=16 PARALLEL_OPS=8 SIGNED=1

test_parallel16:
	$(MAKE) sim WIDTH=16 PARALLEL_OPS=16 SIGNED=1

# Clean up
clean:
	@echo "Cleaning up..."
	rm -f $(VVP_FILE) $(VCD_FILE) *.log
	rm -f *.vcd *.vvp

# Help
help:
	@echo "Configurable Parallel Shift-Add Multiplier Makefile"
	@echo "================================================="
	@echo "Targets:"
	@echo "  all         - Compile and simulate (default)"
	@echo "  compile     - Compile Verilog files"
	@echo "  sim         - Run simulation"
	@echo "  wave        - Open waveform viewer"
	@echo "  test_all    - Test multiple configurations"
	@echo "  test_serial - Test serial configuration (PARALLEL_OPS=1)"
	@echo "  test_parallel2/4/8/16 - Test specific parallel configurations"
	@echo "  clean       - Remove generated files"
	@echo "  help        - Show this help"
	@echo ""
	@echo "Parameters:"
	@echo "  WIDTH=<n>        - Operand width (default: 16)"
	@echo "  PARALLEL_OPS=<n> - Parallel operations per cycle (default: 4)"
	@echo "  SIGNED=<0|1>     - Enable signed operation (default: 1)"
	@echo ""
	@echo "Examples:"
	@echo "  make sim WIDTH=32 PARALLEL_OPS=8"
	@echo "  make test_all"
	@echo "  make wave WIDTH=16 PARALLEL_OPS=4"