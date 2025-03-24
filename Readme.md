# Verilog Development Environment

A streamlined CLI-based workflow for Verilog HDL development with interactive project management, module creation, and simulation tools.

## Features

- Interactive project navigation with fuzzy finding
- Automatic module detection and compilation
- Easy-to-use simulation and waveform viewing
- Hierarchical design support with submodules
- Automatic testbench generation
- Project directory management

## Prerequisites

The following tools must be installed on your system:

- **iverilog**: Icarus Verilog compiler
- **vvp**: Icarus Verilog simulation runtime
- **gtkwave**: Digital waveform viewer
- **fzf**: Command-line fuzzy finder
- **make**: Build automation tool

### Installation of Prerequisites

#### On Debian/Ubuntu:
```bash
sudo apt update
sudo apt install iverilog gtkwave make
sudo apt install fzf
```

#### On Fedora/RHEL:
```bash
sudo dnf install iverilog gtkwave make
sudo dnf install fzf
```

#### On macOS (with Homebrew):
```bash
brew install icarus-verilog
brew install gtkwave
brew install fzf
brew install make
```

## Installation

1. Clone this repository to your local machine:

```bash
git clone https://github.com/yourusername/verilog-dev-environment.git
cd verilog-dev-environment
```

2. Make the script executable:

```bash
chmod +x run.sh
```

## File Structure

The environment follows a specific naming convention:

- **Top modules**: `module.v` (e.g., `adder.v`)
- **Submodules**: `module_submodule.v` (e.g., `adder_halfadder.v`)
- **Testbenches**: `tb_module.v` (e.g., `tb_adder.v`)

Ideally, each project should be in its own directory, with the directory name matching the main module name.

## Usage

### Starting the Environment

```bash
./run.sh
```

This will launch the interactive menu with several options:

### Main Menu Options

1. **Browse and Run Modules**: Navigate to project directories and run simulations
2. **Create New Module**: Create a new Verilog module with optional testbench
3. **Create New Project Directory**: Set up a new project directory with necessary files
4. **Copy Makefile to All Directories**: Ensure all project directories have the required Makefile
5. **Exit**: Quit the application

### Working with Modules

When selecting "Browse and Run Modules":

1. You'll be prompted to select a project directory
2. The script will automatically identify the main module in that directory
   - By default, it looks for a module with the same name as the directory
   - If not found, it will use the first available top-level module
3. You can choose from these actions:
   - Compile, simulate, and view waveform
   - Compile only
   - Run simulation only
   - View waveform only

### Creating a New Module

When selecting "Create New Module":

1. You'll be prompted to select a target directory
2. Enter a name for your new module
3. A basic module template will be created
4. You can optionally create a matching testbench

### Creating a New Project

When selecting "Create New Project Directory":

1. Enter a name for the new project directory
2. A directory will be created with a Makefile
3. You can optionally create an initial module
4. You can optionally create a matching testbench

## Makefile Functionality

The included Makefile provides several targets for each module:

- `make <module_name>`: Compile, simulate, and view waveform
- `make compile_<module_name>`: Compile only
- `make run_<module_name>`: Run simulation only
- `make wave_<module_name>`: View waveform only
- `make list`: List all available modules
- `make clean`: Remove all generated files

## Examples

### Example Directory Structure

```
project/
├── Makefile
├── adder/
│   ├── Makefile
│   ├── adder.v
│   ├── adder_halfadder.v
│   └── tb_adder.v
└── counter/
    ├── Makefile
    ├── counter.v
    └── tb_counter.v
```

### Creating and Testing a Simple Module

1. Start the environment: `./run.sh`
2. Select "Create New Project Directory"
3. Enter "counter" as the directory name
4. Answer "y" to create a module
5. Enter "counter" as the module name
6. Answer "y" to create a testbench
7. Edit the generated files with your implementation
8. Use "Browse and Run Modules" to compile and test

## Troubleshooting

### Missing Tools

If you see an error about missing commands, install the required tools mentioned in the Prerequisites section.

### Makefile Not Found

If you see warnings about missing Makefiles:

1. Select "Copy Makefile to All Directories" from the main menu
2. Alternatively, answer "y" when prompted to copy the Makefile

### Simulation Errors

If your simulation fails:

1. Check for syntax errors in your Verilog code
2. Verify that inputs and outputs are connected correctly in your testbench
3. Make sure your module follows the naming convention

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
