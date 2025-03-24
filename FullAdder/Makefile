# Makefile for Verilog with iverilog, vvp, and gtkwave
# This handles hierarchical designs with the naming convention:
# - Top module: module.v
# - Submodule: module_submodule.v
# - Testbench: tb_module.v

# Compiler and simulator commands
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Default flags for compilation
IVERILOG_FLAGS = -g2012 -Wall

# Get all Verilog files in the current directory
VERILOG_FILES = $(wildcard *.v)

# Extract top module names (exclude tb_ and module_submodule patterns)
MODULES = $(filter-out tb_%, $(basename $(VERILOG_FILES)))
MODULES := $(filter-out %_%, $(MODULES))

# Default target - shows help information
all: help

# Help message
help:
	@echo "Verilog Makefile Help:"
	@echo "  make <module_name>   - Compile, simulate, and view waveform for <module_name>"
	@echo "  make compile_<module_name> - Compile only"
	@echo "  make run_<module_name>     - Run simulation only"
	@echo "  make wave_<module_name>    - View waveform only"
	@echo "  make clean          - Remove all generated files"
	@echo "  make list           - List all available modules"
	@echo ""
	@echo "For hierarchical designs (with submodules):"
	@echo "  - Top module:  <module>.v  (e.g., FA.v)"
	@echo "  - Submodule:   <module>_<submodule>.v  (e.g., FA_HA.v)"
	@echo "  - Testbench:   tb_<module>.v  (e.g., tb_FA.v)"
	@echo ""
	@echo "Example: make FA        - Process FA.v with tb_FA.v (and any FA_*.v submodules)"
	@echo "         make adder     - Process adder.v with tb_adder.v"

# List available modules
list:
	@echo "Available top modules:"
	@for module in $(MODULES); do \
		submodules=$$(find . -maxdepth 1 -name "$${module}_*.v" -type f | wc -l); \
		if [ -f tb_$$module.v ]; then \
			if [ $$submodules -gt 0 ]; then \
				echo "  $$module (with testbench and $$submodules submodules)"; \
			else \
				echo "  $$module (with testbench)"; \
			fi; \
		else \
			if [ $$submodules -gt 0 ]; then \
				echo "  $$module (no testbench, has $$submodules submodules)"; \
			else \
				echo "  $$module (no testbench)"; \
			fi; \
		fi; \
	done

# Function to find submodules for a given module
find_submodules = $(wildcard $(1)_*.v)

# Generic rule for making VVP files from Verilog source files
# This includes both the module and its submodules
%.vvp: %.v tb_%.v
	@echo "Compiling $*.v with tb_$*.v..."
	@if [ -n "$(SUBMODULES)" ]; then \
		echo "Including explicitly specified submodules: $(SUBMODULES)"; \
		$(IVERILOG) $(IVERILOG_FLAGS) -o $@ $*.v $(SUBMODULES) tb_$*.v; \
	else \
		submodules=$$(find . -maxdepth 1 -name "$*_*.v" -type f | tr '\n' ' '); \
		if [ -n "$$submodules" ]; then \
			echo "Auto-detected submodules: $$submodules"; \
			$(IVERILOG) $(IVERILOG_FLAGS) -o $@ $*.v $$submodules tb_$*.v; \
		else \
			echo "No submodules found."; \
			$(IVERILOG) $(IVERILOG_FLAGS) -o $@ $*.v tb_$*.v; \
		fi; \
	fi

# Generic rule for producing VCD from VVP
%.vcd: %.vvp
	@echo "Running simulation for $*.v..."
	$(VVP) $<

# Main target for each module - forces rebuild
define module_rule
$(1): force $(1).vvp $(1).vcd
	@echo "Opening waveform for $(1)..."
	$(GTKWAVE) $(1).vcd &

compile_$(1): force $(1).vvp

run_$(1): force
	@echo "Running simulation for $(1)..."
	@if [ ! -f $(1).vvp ]; then \
		echo "Compile first..."; \
		$(MAKE) -f $(MAKEFILE_LIST) compile_$(1); \
	fi
	$(VVP) $(1).vvp

wave_$(1): force
	@echo "Opening waveform for $(1)..."
	@if [ ! -f $(1).vcd ]; then \
		echo "Need to run simulation first..."; \
		$(MAKE) -f $(MAKEFILE_LIST) run_$(1); \
	fi
	$(GTKWAVE) $(1).vcd &
endef

# Apply the module rule to each detected module
$(foreach module,$(MODULES),$(eval $(call module_rule,$(module))))

# Force target - used to force rebuilding of targets
force:
	@true

# Clean rule
clean:
	@echo "Cleaning up generated files..."
	rm -f *.vvp *.vcd

# Tell make that these targets are not files
.PHONY: all help clean list force $(MODULES) $(addprefix compile_, $(MODULES)) $(addprefix run_, $(MODULES)) $(addprefix wave_, $(MODULES))
