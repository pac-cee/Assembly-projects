# x86-64 Assembly Learning Path

Welcome to your journey into x86-64 Assembly programming! This structured learning path will take you from absolute beginner to proficient in assembly language programming.

## Learning Path

1. [Getting Started with x86-64 Assembly](./01_getting_started.md)
2. [Registers and Basic Arithmetic](./02_registers_arithmetic.md)
3. [Memory Access and Data Movement](./03_memory_access.md)
4. [Control Flow and Loops](./04_control_flow.md)
5. [Functions and the Stack](./05_functions_stack.md)
6. [System Calls and I/O](./06_system_calls.md)
7. [Advanced Topics and Optimization](./07_advanced_topics.md)

## Prerequisites

- Basic understanding of programming concepts
- NASM (Netwide Assembler)
- A text editor (VS Code, Sublime Text, etc.)
- A terminal/command prompt

## Setup Instructions

1. **Install NASM**:
   - Windows: Download from [nasm.us](https://www.nasm.us/)
   - macOS: `brew install nasm`
   - Linux: `sudo apt-get install nasm`

2. **Verify Installation**:
   ```bash
   nasm -v
   ```

3. **Assemble and Link**:
   ```bash
   nasm -f win64 program.asm -o program.obj
   gcc program.obj -o program.exe
   ```
   (Use `-f elf64` for Linux instead of `-f win64`)

## Resources

- [NASM Documentation](https://www.nasm.us/xdoc/2.15.05/html/)
- [x86-64 Assembly Guide](https://cs.lmu.edu/~ray/notes/x86assembly/)
- [Godbolt Compiler Explorer](https://godbolt.org/) - See assembly output from C/C++ code

## Practice Exercises

Each lesson comes with exercises. Try to solve them without looking at the solutions first!

Happy coding! 🚀
