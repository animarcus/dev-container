# C Development Environment

Development environment configured for CS-202 C Bootcamp. Provides essential tools for learning C programming in a Linux environment.

## Overview

This environment provides the core tools needed for the C programming bootcamp:

- C compilation and building
- Basic debugging
- Memory checking
- Standard Linux manual pages

## Installed Tools

### Core Development

- `gcc` - GNU C Compiler
  - Primary compiler used in the course
  - Provides helpful warning flags for learning
- `clang` - LLVM C Compiler
  - Alternative compiler with clearer error messages
  - Available as needed

### Debugging Tools

- `gdb` - GNU Debugger
  - Essential for understanding program behavior
  - Helps track down segmentation faults
- `valgrind` - Memory Checker
  - Detects memory leaks
  - Finds common memory errors

### Documentation

- `man` pages
  - Linux manual pages
  - C function documentation

## Basic Usage

### Compilation

```bash
# Basic compilation
gcc -o program program.c

# Recommended: compile with warnings
gcc -Wall -pedantic -o program program.c

# Run your program
./program
```

### Debugging

```bash
# Compile with debug information
gcc -g -o program program.c

# Start debugger
gdb ./program

# Check for memory issues
valgrind ./program
```

## Workflow Tips

1. **Always compile with warnings enabled**

   ```bash
   gcc -Wall -pedantic -o program program.c
   ```

   - `-Wall`: Enables important warning messages
   - `-pedantic`: Ensures strict standard compliance

2. **When your program crashes:**
   - First, compile with debug info (`-g` flag)
   - Use `gdb` to find where it crashed
   - Use `valgrind` to check for memory issues

3. **Check documentation**

   ```bash
   # Read about C functions
   man printf
   man malloc
   ```

## Course Directory Structure

```files
workspace/
    └── c_projects/
        └── cs202/        # Your course work here
```

## Getting Started

1. Start the environment:

   ```bash
   ./scripts/cli.sh start c
   ```

2. Open a shell in the container:

   ```bash
   ./scripts/cli.sh shell
   ```

3. Navigate to your course directory:

   ```bash
   cd ~/workspace/c_projects/cs202
   ```
