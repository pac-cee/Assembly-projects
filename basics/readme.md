# Comprehensive Assembly Programming Guide (NASM on Windows)

## Table of Contents
1. [What is Assembly Language?](#what-is-assembly-language)
2. [NASM Basics and Setup](#nasm-basics-and-setup)
3. [Program Structure](#program-structure)
4. [Registers](#registers)
5. [Memory Management](#memory-management)
6. [Data Types and Storage](#data-types-and-storage)
7. [Instructions and Opcodes](#instructions-and-opcodes)
8. [Addressing Modes](#addressing-modes)
9. [Control Flow](#control-flow)
10. [Arithmetic Operations](#arithmetic-operations)
11. [Logical Operations](#logical-operations)
12. [String Operations](#string-operations)
13. [System Calls and C Library Functions](#system-calls-and-c-library-functions)
14. [Stack Management](#stack-management)
15. [Advanced Topics](#advanced-topics)
16. [Debugging and Best Practices](#debugging-and-best-practices)
17. [Common Patterns and Examples](#common-patterns-and-examples)

---

## What is Assembly Language?

Assembly language is a low-level programming language that provides direct control over the computer's hardware. Each assembly instruction typically corresponds to one machine code instruction that the processor executes.

**Why learn Assembly?**
- Understanding how computers work at the lowest level
- Performance optimization
- System programming
- Reverse engineering
- Embedded systems programming
- Better understanding of higher-level languages

---

## NASM Basics and Setup

### Installation (Windows)
```bash
# You already have NASM installed since you're using it
# To check version:
nasm -v
```

### Basic Compilation Process
```bash
# 1. Assemble (.asm → .obj)
nasm -f win64 filename.asm

# 2. Link (.obj → .exe)
# Using Microsoft's linker:
link filename.obj /subsystem:console /entry:main /defaultlib:kernel32.lib /defaultlib:msvcrt.lib

# Or using GCC linker:
gcc filename.obj -o filename.exe
```

---

## Program Structure

### Basic NASM Program Structure
```assembly
section .data
    ; Initialized data goes here
    message db 'Hello World', 0
    number dd 42

section .bss
    ; Uninitialized data goes here
    buffer resb 100    ; Reserve 100 bytes
    counter resd 1     ; Reserve 1 dword (4 bytes)

section .text
    default rel        ; Use relative addressing (Windows 64-bit)
    global main        ; Entry point for C runtime
    extern printf      ; External C library function

main:
    ; Your code goes here
    ; Function prologue
    push rbp
    mov rbp, rsp
    sub rsp, 32        ; Shadow space for Windows x64 calling convention
    
    ; Your actual code
    
    ; Function epilogue and return
    xor eax, eax       ; Return 0
    leave              ; Equivalent to: mov rsp, rbp; pop rbp
    ret
```

### Section Types
- **`.data`**: Initialized data (read-write)
- **`.rodata`**: Read-only data (constants)
- **`.bss`**: Uninitialized data (filled with zeros)
- **`.text`**: Executable code

---

## Registers

### x86-64 General Purpose Registers

#### 64-bit Registers (R prefix)
```
RAX, RBX, RCX, RDX    ; Primary registers
RSI, RDI              ; Source/Destination index
RSP, RBP              ; Stack/Base pointer
R8, R9, R10, R11      ; Additional registers
R12, R13, R14, R15    ; Additional registers
```

#### 32-bit Registers (E prefix)
```
EAX, EBX, ECX, EDX    ; Lower 32 bits of RAX, RBX, RCX, RDX
ESI, EDI, ESP, EBP    ; Lower 32 bits of RSI, RDI, RSP, RBP
R8D, R9D, R10D, R11D  ; Lower 32 bits of R8-R11
R12D, R13D, R14D, R15D ; Lower 32 bits of R12-R15
```

#### 16-bit Registers
```
AX, BX, CX, DX        ; Lower 16 bits
SI, DI, SP, BP        ; Lower 16 bits
R8W, R9W, R10W, R11W  ; Lower 16 bits of R8-R11
```

#### 8-bit Registers
```
AL, AH, BL, BH, CL, CH, DL, DH  ; Low/High bytes of AX, BX, CX, DX
SIL, DIL, SPL, BPL              ; Low bytes of SI, DI, SP, BP
R8B, R9B, R10B, R11B            ; Low bytes of R8-R11
```

### Special Purpose Registers
- **RIP**: Instruction Pointer (Program Counter)
- **RFLAGS**: Status flags register
- **Segment Registers**: CS, DS, ES, FS, GS, SS

### Register Usage Convention (Windows x64)
- **RAX**: Return value, accumulator
- **RCX**: First argument
- **RDX**: Second argument
- **R8**: Third argument
- **R9**: Fourth argument
- **RSP**: Stack pointer (never use directly for data)
- **RBP**: Base pointer (frame pointer)
- **RBX, RSI, RDI, R12-R15**: Callee-saved (preserve across function calls)

---

## Memory Management

### Memory Hierarchy
1. **Registers** (fastest, smallest)
2. **Cache** (L1, L2, L3)
3. **RAM** (main memory)
4. **Storage** (slowest, largest)

### Memory Layout (Windows)
```
High Addresses
+------------------+
|      Stack       | ← RSP points here
|        ↓         |
|                  |
|        ↑         |
|       Heap       |
+------------------+
|   .bss section   | (uninitialized data)
+------------------+
|   .data section  | (initialized data)
+------------------+
|   .text section  | (code)
+------------------+
Low Addresses
```

### Memory Sizes
- **Byte**: 8 bits (1 byte)
- **Word**: 16 bits (2 bytes)
- **Dword**: 32 bits (4 bytes) - "Double Word"
- **Qword**: 64 bits (8 bytes) - "Quad Word"

---

## Data Types and Storage

### Data Declaration Directives
```assembly
section .data
    ; Initialized data
    char_val    db 'A'           ; Define byte (8-bit)
    string_val  db 'Hello', 0    ; Null-terminated string
    word_val    dw 1234          ; Define word (16-bit)
    dword_val   dd 12345678      ; Define dword (32-bit)
    qword_val   dq 123456789012  ; Define qword (64-bit)
    float_val   dd 3.14159       ; 32-bit float
    double_val  dq 2.71828       ; 64-bit double
    
    ; Arrays
    byte_array  db 1, 2, 3, 4, 5
    word_array  dw 100, 200, 300
    
    ; Multiple of same value
    zeros       times 100 db 0   ; 100 zero bytes

section .bss
    ; Uninitialized data (reserves space)
    buffer      resb 256         ; Reserve 256 bytes
    int_var     resd 1           ; Reserve 1 dword
    long_var    resq 1           ; Reserve 1 qword
    array       resd 10          ; Reserve space for 10 dwords
```

### Constants and Equates
```assembly
; Define constants
BUFFER_SIZE equ 1024
MAX_COUNT   equ 100

; Use in code
mov eax, BUFFER_SIZE
```

---

## Instructions and Opcodes

### Data Movement Instructions
```assembly
; MOV - Move data
mov rax, rbx        ; Copy rbx to rax
mov eax, 42         ; Load immediate value
mov rax, [rbx]      ; Load from memory address in rbx
mov [rax], rbx      ; Store rbx to memory address in rax

; LEA - Load Effective Address
lea rax, [rbx + 8]  ; Load address (rbx + 8) into rax

; MOVSX/MOVZX - Move with sign/zero extension
movsx rax, bl       ; Sign-extend byte to qword
movzx eax, bl       ; Zero-extend byte to dword

; XCHG - Exchange
xchg rax, rbx       ; Swap contents of rax and rbx
```

### Stack Operations
```assembly
push rax            ; Push rax onto stack (RSP -= 8)
pop rbx             ; Pop from stack into rbx (RSP += 8)
pushf               ; Push flags register
popf                ; Pop flags register
```

---

## Addressing Modes

### Immediate Addressing
```assembly
mov eax, 42         ; Load immediate value 42
```

### Register Addressing
```assembly
mov eax, ebx        ; Copy register to register
```

### Direct Memory Addressing
```assembly
mov eax, [variable] ; Load from memory variable
mov [variable], eax ; Store to memory variable
```

### Indirect Addressing
```assembly
mov eax, [rbx]      ; Load from address stored in rbx
mov [rax], ebx      ; Store to address stored in rax
```

### Indexed Addressing
```assembly
mov eax, [rbx + 4]           ; Base + displacement
mov eax, [rbx + rsi]         ; Base + index
mov eax, [rbx + rsi * 2]     ; Base + (index * scale)
mov eax, [rbx + rsi * 4 + 8] ; Base + (index * scale) + displacement
```

### Scale Factors
Valid scale factors: 1, 2, 4, 8 (for byte, word, dword, qword)

---

## Control Flow

### Unconditional Jumps
```assembly
jmp label           ; Jump to label
jmp rax             ; Jump to address in rax
jmp [rax]           ; Jump to address stored at address in rax
```

### Conditional Jumps (after CMP instruction)
```assembly
cmp eax, ebx        ; Compare eax with ebx
je equal            ; Jump if equal (ZF = 1)
jne not_equal       ; Jump if not equal (ZF = 0)
jg greater          ; Jump if greater (signed)
jl less             ; Jump if less (signed)
jge greater_equal   ; Jump if greater or equal (signed)
jle less_equal      ; Jump if less or equal (signed)
ja above            ; Jump if above (unsigned)
jb below            ; Jump if below (unsigned)
jae above_equal     ; Jump if above or equal (unsigned)
jbe below_equal     ; Jump if below or equal (unsigned)

; Other condition jumps
jz zero             ; Jump if zero (same as je)
jnz not_zero        ; Jump if not zero (same as jne)
jc carry            ; Jump if carry flag set
jnc no_carry        ; Jump if carry flag clear
js sign             ; Jump if sign flag set (negative)
jns no_sign         ; Jump if sign flag clear (positive)
jo overflow         ; Jump if overflow flag set
jno no_overflow     ; Jump if overflow flag clear
```

### Loops
```assembly
; LOOP instruction (uses RCX as counter)
mov rcx, 10
loop_start:
    ; Loop body
    loop loop_start     ; Decrement RCX, jump if RCX != 0

; Manual loop
mov eax, 0
mov ebx, 10
manual_loop:
    ; Loop body
    inc eax
    cmp eax, ebx
    jl manual_loop
```

### Function Calls
```assembly
call function_name  ; Call function (pushes return address)
ret                 ; Return from function (pops return address)
ret 16              ; Return and clean up 16 bytes from stack
```

---

## Arithmetic Operations

### Addition and Subtraction
```assembly
add eax, ebx        ; eax = eax + ebx
add eax, 10         ; eax = eax + 10
sub eax, ebx        ; eax = eax - ebx
inc eax             ; eax = eax + 1 (faster than add eax, 1)
dec eax             ; eax = eax - 1 (faster than sub eax, 1)

; With carry
adc eax, ebx        ; eax = eax + ebx + carry_flag
sbb eax, ebx        ; eax = eax - ebx - carry_flag
```

### Multiplication
```assembly
; Unsigned multiplication
mul ebx             ; EDX:EAX = EAX * EBX (64-bit result)
imul ebx            ; EAX = EAX * EBX (32-bit result, signed)
imul eax, ebx       ; EAX = EAX * EBX (two operand form)
imul eax, ebx, 10   ; EAX = EBX * 10 (three operand form)

; Examples:
mov eax, 5
mov ebx, 3
imul eax, ebx       ; EAX = 15
```

### Division
```assembly
; Unsigned division
mov eax, 15         ; Dividend low
mov edx, 0          ; Dividend high (must be 0 for 32-bit)
mov ebx, 3          ; Divisor
div ebx             ; EAX = quotient, EDX = remainder

; Signed division
mov eax, -15
cdq                 ; Sign-extend EAX into EDX
mov ebx, 3
idiv ebx            ; EAX = quotient, EDX = remainder
```

**IMPORTANT**: Always clear/set EDX before division!

---

## Logical Operations

### Bitwise Operations
```assembly
and eax, ebx        ; Bitwise AND
or eax, ebx         ; Bitwise OR
xor eax, ebx        ; Bitwise XOR
not eax             ; Bitwise NOT (one's complement)

; Common uses:
xor eax, eax        ; Clear register (eax = 0)
and eax, 0x0F       ; Mask lower 4 bits
or eax, 0x80        ; Set bit 7
```

### Bit Shifting
```assembly
shl eax, 1          ; Shift left (multiply by 2)
shr eax, 1          ; Shift right (unsigned divide by 2)
sar eax, 1          ; Shift arithmetic right (signed divide by 2)
rol eax, 1          ; Rotate left
ror eax, 1          ; Rotate right

; Shift by register
mov cl, 3
shl eax, cl         ; Shift left by 3 (multiply by 8)
```

### Bit Testing
```assembly
test eax, eax       ; Test if eax is zero (sets flags)
test eax, 0x01      ; Test if bit 0 is set
bt eax, 5           ; Test bit 5 (sets carry flag)
bts eax, 5          ; Test and set bit 5
btr eax, 5          ; Test and reset bit 5
btc eax, 5          ; Test and complement bit 5
```

---

## String Operations

String operations work with RSI (source) and RDI (destination) registers.

```assembly
; Direction flag
cld                 ; Clear direction flag (forward)
std                 ; Set direction flag (backward)

; String move
movsb               ; Move byte from [RSI] to [RDI]
movsw               ; Move word
movsd               ; Move dword
movsq               ; Move qword

; With repeat prefix
rep movsb           ; Repeat RCX times

; String compare
cmpsb               ; Compare bytes at [RSI] and [RDI]
repe cmpsb          ; Repeat while equal
repne cmpsb         ; Repeat while not equal

; String scan
scasb               ; Compare AL with [RDI]
repne scasb         ; Find character in string

; String store
stosb               ; Store AL to [RDI]
rep stosb           ; Fill memory with value

; Example: Copy string
section .data
    source db "Hello World", 0
section .bss
    dest resb 20

section .text
    lea rsi, [source]   ; Source address
    lea rdi, [dest]     ; Destination address
    mov rcx, 12         ; Number of bytes
    cld                 ; Forward direction
    rep movsb           ; Copy string
```

---

## System Calls and C Library Functions

### Using C Library Functions (Recommended for beginners)
```assembly
; External declarations
extern printf, scanf, malloc, free, strlen

; Windows x64 calling convention:
; RCX, RDX, R8, R9 for first 4 arguments
; Additional arguments on stack
; Return value in RAX
; Shadow space: 32 bytes on stack

; Example: printf
section .data
    format db "Number: %d", 0ah, 0
    
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32         ; Shadow space
    
    lea rcx, [format]   ; First argument (format string)
    mov edx, 42         ; Second argument (number)
    call printf
    
    leave
    ret
```

### Windows System Calls (Advanced)
```assembly
; System calls are more complex on Windows
; Usually better to use C library functions
```

---

## Stack Management

### Stack Basics
- Stack grows downward (toward lower addresses)
- RSP points to top of stack
- PUSH decreases RSP, POP increases RSP

### Function Prologue and Epilogue
```assembly
function_name:
    ; Prologue
    push rbp            ; Save caller's base pointer
    mov rbp, rsp        ; Set up new base pointer
    sub rsp, 32         ; Allocate local variables + shadow space
    
    ; Function body
    ; Local variables at [rbp - offset]
    
    ; Epilogue
    leave               ; Equivalent to: mov rsp, rbp; pop rbp
    ret                 ; Return to caller
```

### Local Variables
```assembly
function_with_locals:
    push rbp
    mov rbp, rsp
    sub rsp, 48         ; 32 shadow + 16 local variables
    
    ; Local variables:
    ; [rbp - 8]  = first local variable (8 bytes)
    ; [rbp - 16] = second local variable (8 bytes)
    
    mov dword [rbp - 8], 42     ; Store value in local variable
    mov eax, [rbp - 8]          ; Load from local variable
    
    leave
    ret
```

---

## Advanced Topics

### Macros
```assembly
; Simple macro
%macro PRINT_NUMBER 1
    lea rcx, [number_format]
    mov edx, %1
    call printf
%endmacro

; Usage
PRINT_NUMBER 42
```

### Conditional Assembly
```assembly
%define DEBUG 1

%if DEBUG
    ; Debug code
%endif
```

### Include Files
```assembly
%include "macros.inc"
```

### Floating Point Operations
```assembly
; Load floating point values
fld dword [float_var]   ; Load 32-bit float to ST(0)
fld qword [double_var]  ; Load 64-bit double to ST(0)

; Arithmetic
fadd                    ; ST(0) = ST(0) + ST(1)
fsub                    ; ST(0) = ST(0) - ST(1)
fmul                    ; ST(0) = ST(0) * ST(1)
fdiv                    ; ST(0) = ST(0) / ST(1)

; Store results
fstp dword [result]     ; Store ST(0) and pop
```

### SIMD Instructions (SSE/AVX)
```assembly
; SSE (128-bit)
movaps xmm0, [data]     ; Move 4 packed single precision floats
addps xmm0, xmm1        ; Add 4 floats in parallel

; AVX (256-bit)
vmovaps ymm0, [data]    ; Move 8 packed single precision floats
vaddps ymm0, ymm1, ymm2 ; Add 8 floats in parallel
```

---

## Debugging and Best Practices

### Debugging Tips
1. **Use a debugger**: x64dbg, Visual Studio debugger
2. **Add debug prints**: Use printf to trace execution
3. **Check registers**: Verify register contents at key points
4. **Watch the stack**: Ensure proper stack management

### Best Practices
1. **Comment your code**: Assembly is hard to read
2. **Use meaningful labels**: `calculate_average` not `loop1`
3. **Follow calling conventions**: Especially for C interop
4. **Handle edge cases**: Division by zero, buffer overflows
5. **Optimize later**: Write correct code first
6. **Use constants**: Define magic numbers with `equ`
7. **Align data**: Some instructions require aligned data

### Common Mistakes
1. **Forgetting to clear EDX before division**
2. **Stack imbalance**: Not matching push/pop
3. **Wrong data sizes**: Mixing byte/word/dword operations
4. **Calling convention violations**: Wrong argument registers
5. **Uninitialized variables**: Always initialize data

---

## Common Patterns and Examples

### Pattern 1: Simple Input/Output
```assembly
section .data
    prompt db "Enter number: ", 0
    format_in db "%d", 0
    format_out db "You entered: %d", 0ah, 0
    
section .bss
    number resd 1
    
section .text
    extern printf, scanf
    global main
    
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Print prompt
    lea rcx, [prompt]
    call printf
    
    ; Read number
    lea rcx, [format_in]
    lea rdx, [number]
    call scanf
    
    ; Print result
    lea rcx, [format_out]
    mov edx, [number]
    call printf
    
    xor eax, eax
    leave
    ret
```

### Pattern 2: Array Processing
```assembly
section .data
    array dd 1, 2, 3, 4, 5
    array_size equ ($ - array) / 4  ; Calculate size
    sum_msg db "Sum: %d", 0ah, 0
    
section .text
    extern printf
    global main
    
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Calculate sum
    xor eax, eax        ; sum = 0
    xor ecx, ecx        ; index = 0
    
sum_loop:
    add eax, [array + ecx * 4]  ; sum += array[index]
    inc ecx                     ; index++
    cmp ecx, array_size         ; compare with size
    jl sum_loop                 ; continue if index < size
    
    ; Print result
    lea rcx, [sum_msg]
    mov edx, eax
    call printf
    
    xor eax, eax
    leave
    ret
```

### Pattern 3: String Length Function
```assembly
; Calculate string length
; Input: RSI = string address
; Output: RAX = length
strlen_func:
    xor rax, rax        ; length = 0
    
strlen_loop:
    cmp byte [rsi + rax], 0  ; Check for null terminator
    je strlen_done      ; Jump if found
    inc rax             ; length++
    jmp strlen_loop     ; Continue
    
strlen_done:
    ret                 ; Return length in RAX
```

### Pattern 4: Factorial Function
```assembly
; Calculate factorial recursively
; Input: RCX = number
; Output: RAX = factorial
factorial:
    push rbp
    mov rbp, rsp
    
    cmp rcx, 1          ; if n <= 1
    jle base_case       ; return 1
    
    ; Recursive case: n * factorial(n-1)
    push rcx            ; Save n
    dec rcx             ; n-1
    call factorial      ; factorial(n-1)
    pop rcx             ; Restore n
    mul rcx             ; n * factorial(n-1)
    
    leave
    ret
    
base_case:
    mov rax, 1          ; return 1
    leave
    ret
```

---

## Quick Reference Commands

### Compilation Commands
```bash
# Assemble
nasm -f win64 program.asm

# Link with GCC
gcc program.obj -o program.exe

# Link with Microsoft linker
link program.obj /subsystem:console /entry:main /defaultlib:kernel32.lib /defaultlib:msvcrt.lib

# One-liner compilation
nasm -f win64 program.asm && gcc program.obj -o program.exe
```

### Useful NASM Options
```bash
nasm -f win64           # 64-bit Windows object format
nasm -l program.lst     # Generate listing file
nasm -g                 # Include debug information
nasm -O2                # Optimize
```

---

## What's Most Important to Know?

### For Beginners:
1. **Program structure** (sections, global main)
2. **Basic instructions** (mov, add, sub, cmp, jmp)
3. **Registers** (RAX, RBX, RCX, RDX basics)
4. **Memory addressing** ([variable], [register])
5. **Function calls** (call, ret, stack management)
6. **C library integration** (printf, scanf)

### For Intermediate:
1. **All addressing modes**
2. **String operations**
3. **Multiplication and division**
4. **Bit manipulation**
5. **Advanced control flow**
6. **Proper function prologue/epilogue**

### For Advanced:
1. **SIMD instructions**
2. **Floating point operations**
3. **System calls**
4. **Optimization techniques**
5. **Inline assembly in C**
6. **Reverse engineering applications**

---

## Memory Usage Guidelines

### When to Use Different Memory Areas:

**Registers (Fastest)**
- Temporary calculations
- Loop counters
- Function arguments/return values
- Most frequently accessed data

**Stack**
- Local variables
- Function parameters (if more than 4)
- Temporary storage during function calls
- Small, short-lived data

**.data Section**
- Global variables with initial values
- String constants
- Lookup tables
- Configuration data

**.bss Section**
- Large arrays/buffers
- Global variables without initial values
- Memory that will be initialized at runtime

**Heap (via malloc/free)**
- Dynamic memory allocation
- Large data structures
- Memory whose size isn't known at compile time

---

## Performance Tips

1. **Use registers when possible** - Much faster than memory
2. **Avoid memory-to-memory operations** - Use register as intermediate
3. **Use appropriate data sizes** - Don't use 64-bit when 32-bit suffices
4. **Align data** - Aligned access is faster
5. **Use bit shifting for powers of 2** - `shl eax, 1` instead of `imul eax, 2`
6. **Clear registers efficiently** - `xor eax, eax` instead of `mov eax, 0`
7. **Use string instructions for bulk operations**
8. **Minimize function call overhead**

This guide covers the essential concepts you need to master assembly programming with NASM on Windows. Start with the basics and gradually work your way up to more advanced topics. Practice with small programs and gradually increase complexity!
