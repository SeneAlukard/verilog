#!/bin/bash
# run.sh - Main script for Verilog workflow
# This script serves as the entry point for all Verilog-related operations

# Define color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed. Please install it first.${NC}"
        exit 1
    fi
}

# Function to check for required directories
check_directories() {
    # Check if Makefile exists in each directory with Verilog files
    local directories=$(find . -name "*.v" | xargs -n1 dirname | sort -u)
    local missing_makefiles=0
    
    for dir in $directories; do
        if [ ! -f "$dir/Makefile" ]; then
            echo -e "${YELLOW}Warning: Makefile not found in $dir${NC}"
            missing_makefiles=1
        fi
    done
    
    if [ $missing_makefiles -eq 1 ]; then
        echo -e "${BLUE}Do you want to copy the Makefile to all directories with Verilog files? (y/n)${NC}"
        read answer
        if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
            for dir in $directories; do
                if [ ! -f "$dir/Makefile" ]; then
                    cp ./Makefile "$dir/"
                    echo -e "${GREEN}Copied Makefile to $dir${NC}"
                fi
            done
        fi
    fi
}

# Function to browse and run modules
browse_and_run_modules() {
    echo -e "${BLUE}Browsing Verilog Project Directories${NC}"
    
    # Get all available directories with Verilog files
    local dirs=$(find . -name "*.v" | xargs -n1 dirname | sort -u)
    
    if [ -z "$dirs" ]; then
        echo -e "${RED}No Verilog files found in any directory.${NC}"
        return
    fi
    
    # Allow user to select a directory
    local selected_dir=$(printf "%s\n" "${dirs[@]}" | fzf --height=40% --border --header="Select a project directory:")
    
    if [ -z "$selected_dir" ]; then
        echo -e "${RED}No directory selected.${NC}"
        return
    fi
    
    # Extract directory name (basename) which should match the module name
    local dir_basename=$(basename "$selected_dir")
    
    # Change to the selected directory
    cd "$selected_dir"
    
    # Check if module file exists with same name as directory
    if [ ! -f "${dir_basename}.v" ]; then
        echo -e "${YELLOW}Warning: No module named ${dir_basename}.v found in directory.${NC}"
        echo -e "${BLUE}Checking for available modules...${NC}"
        make -s list
        
        # Find main modules (not submodules or testbenches)
        local all_modules=$(make -s list | grep "^  [a-zA-Z0-9]\+" | cut -d ' ' -f3 | cut -d ' ' -f1 | grep -v "_")
        
        if [ -z "$all_modules" ]; then
            echo -e "${RED}No modules found in $selected_dir.${NC}"
            cd - > /dev/null # Return to previous directory
            return
        fi
        
        # Use the first available module
        local selected_module=$(echo "$all_modules" | head -1)
        echo -e "${BLUE}Using module: $selected_module${NC}"
    else
        # Use directory name as module name
        local selected_module="$dir_basename"
        echo -e "${BLUE}Using module: $selected_module${NC}"
    fi
    
    # Show options for the selected module
    echo -e "${BLUE}Options for module $selected_module:${NC}"
    local module_options=(
        "Compile, simulate, and view waveform"
        "Compile only"
        "Run simulation only"
        "View waveform only"
        "Cancel"
    )
    
    local selected_option=$(printf "%s\n" "${module_options[@]}" | fzf --height=40% --border --header="Select an action for $selected_module:")
    
    case "$selected_option" in
        "Compile, simulate, and view waveform")
            echo -e "${GREEN}Running: make $selected_module${NC}"
            make "$selected_module"
            ;;
        "Compile only")
            echo -e "${GREEN}Running: make compile_$selected_module${NC}"
            make "compile_$selected_module"
            ;;
        "Run simulation only")
            echo -e "${GREEN}Running: make run_$selected_module${NC}"
            make "run_$selected_module"
            ;;
        "View waveform only")
            echo -e "${GREEN}Running: make wave_$selected_module${NC}"
            make "wave_$selected_module"
            ;;
        "Cancel" | "")
            echo -e "${YELLOW}Action cancelled.${NC}"
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            ;;
    esac
    
    # Return to the previous directory
    cd - > /dev/null
}

# Check for required tools
check_command "make"
check_command "iverilog"
check_command "vvp"
check_command "gtkwave"
check_command "fzf"

# Check directory setup
check_directories

# Main menu
echo -e "${BLUE}Verilog Development Environment${NC}"
echo -e "${BLUE}=============================${NC}"

options=(
    "Browse and Run Modules"
    "Create New Module"
    "Create New Project Directory"
    "Copy Makefile to All Directories"
    "Exit"
)

select_option() {
    local selected=$(printf "%s\n" "${options[@]}" | fzf --height=40% --border --header="Select an action:")
    echo "$selected"
}

# Function to create a new module
create_module() {
    echo -e "${BLUE}Creating a new Verilog module${NC}"
    
    # Select a directory
    local dirs=$(find . -type d -not -path "*/\.*" | sort)
    local dir=$(printf "%s\n" "${dirs[@]}" | fzf --height=40% --border --header="Select a directory for the new module:")
    
    if [ -z "$dir" ]; then
        echo -e "${RED}No directory selected.${NC}"
        return
    fi
    
    # Get module name
    echo -e "${BLUE}Enter the name for the new module:${NC}"
    read module_name
    
    if [ -z "$module_name" ]; then
        echo -e "${RED}No module name provided.${NC}"
        return
    fi
    
    # Check if file already exists
    if [ -f "$dir/$module_name.v" ]; then
        echo -e "${RED}Error: $dir/$module_name.v already exists.${NC}"
        return
    fi
    
    # Create module file
    cat > "$dir/$module_name.v" << EOF
// $module_name.v - Verilog module
// Created: $(date)

module $module_name(
    // TODO: Add ports here
);
    // TODO: Add module implementation here
endmodule
EOF
    
    echo -e "${GREEN}Created module file: $dir/$module_name.v${NC}"
    
    # Ask if testbench should be created
    echo -e "${BLUE}Do you want to create a testbench for this module? (y/n)${NC}"
    read create_tb
    
    if [[ "$create_tb" == "y" || "$create_tb" == "Y" ]]; then
        cat > "$dir/tb_$module_name.v" << EOF
\`timescale 1ns/1ps

module tb_$module_name();
    // TODO: Declare inputs and outputs
    
    // Instantiate the Unit Under Test (UUT)
    $module_name uut (
        // TODO: Connect ports
    );
    
    // VCD file generation
    initial begin
        \$dumpfile("$module_name.vcd");
        \$dumpvars(0, tb_$module_name);
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        
        // TODO: Add test cases
        
        // Finish simulation
        \$display("Simulation completed");
        \$finish;
    end
    
    // Monitor changes
    initial begin
        \$monitor("At time %t: ", \$time);
    end
endmodule
EOF
        echo -e "${GREEN}Created testbench file: $dir/tb_$module_name.v${NC}"
    fi
}

# Function to create a new project directory
create_project_dir() {
    echo -e "${BLUE}Creating a new project directory${NC}"
    echo -e "${BLUE}Enter the name for the new directory:${NC}"
    read dir_name
    
    if [ -z "$dir_name" ]; then
        echo -e "${RED}No directory name provided.${NC}"
        return
    fi
    
    # Create directory
    if [ -d "$dir_name" ]; then
        echo -e "${RED}Error: Directory $dir_name already exists.${NC}"
        return
    fi
    
    mkdir -p "$dir_name"
    
    # Copy Makefile
    cp ./Makefile "$dir_name/"
    
    echo -e "${GREEN}Created project directory: $dir_name with Makefile${NC}"
    
    # Ask if module should be created
    echo -e "${BLUE}Do you want to create a module in this directory? (y/n)${NC}"
    read create_mod
    
    if [[ "$create_mod" == "y" || "$create_mod" == "Y" ]]; then
        echo -e "${BLUE}Enter the name for the new module:${NC}"
        read module_name
        
        if [ -z "$module_name" ]; then
            echo -e "${RED}No module name provided.${NC}"
            return
        fi
        
        # Create module file
        cat > "$dir_name/$module_name.v" << EOF
// $module_name.v - Verilog module
// Created: $(date)

module $module_name(
    // TODO: Add ports here
);
    // TODO: Add module implementation here
endmodule
EOF
        
        echo -e "${GREEN}Created module file: $dir_name/$module_name.v${NC}"
        
        # Ask if testbench should be created
        echo -e "${BLUE}Do you want to create a testbench for this module? (y/n)${NC}"
        read create_tb
        
        if [[ "$create_tb" == "y" || "$create_tb" == "Y" ]]; then
            cat > "$dir_name/tb_$module_name.v" << EOF
\`timescale 1ns/1ps

module tb_$module_name();
    // TODO: Declare inputs and outputs
    
    // Instantiate the Unit Under Test (UUT)
    $module_name uut (
        // TODO: Connect ports
    );
    
    // VCD file generation
    initial begin
        \$dumpfile("$module_name.vcd");
        \$dumpvars(0, tb_$module_name);
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        
        // TODO: Add test cases
        
        // Finish simulation
        \$display("Simulation completed");
        \$finish;
    end
    
    // Monitor changes
    initial begin
        \$monitor("At time %t: ", \$time);
    end
endmodule
EOF
            echo -e "${GREEN}Created testbench file: $dir_name/tb_$module_name.v${NC}"
        fi
    fi
}

# Main loop
while true; do
    choice=$(select_option)
    
    case "$choice" in
        "Browse and Run Modules")
            browse_and_run_modules
            ;;
        "Create New Module")
            create_module
            ;;
        "Create New Project Directory")
            create_project_dir
            ;;
        "Copy Makefile to All Directories")
            dirs=$(find . -name "*.v" | xargs -n1 dirname | sort -u)
            for dir in $dirs; do
                if [ ! -f "$dir/Makefile" ]; then
                    cp ./Makefile "$dir/"
                    echo -e "${GREEN}Copied Makefile to $dir${NC}"
                fi
            done
            ;;
        "Exit")
            echo -e "${BLUE}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}Press Enter to continue...${NC}"
    read
done
