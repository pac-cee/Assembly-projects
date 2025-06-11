# Complete Assembly Programming Guide with NASM

## Table of Contents
1. [Introduction to Assembly](#introduction)
2. [Setting Up NASM on Windows](#setup)
3. [Basic Concepts](#basic-concepts)
4. [Registers and Memory](#registers-memory)
5. [Essential Instructions](#essential-instructions)
6. [Data Types and Declarations](#data-types)
7. [Memory Addressing Modes](#addressing-modes)
8. [Control Flow Instructions](#control-flow)
9. [Arithmetic and Logic Operations](#arithmetic-logic)
10. [String Operations](#string-operations)
11. [System Calls and Interrupts](#system-calls)
12. [Procedures and Functions](#procedures)
13. [Advanced Topics](#advanced-topics)
14. [Debugging and Optimization](#debugging)
15. [Practical Examples](#examples)

---

## 1. Introduction to Assembly {#introduction}

Assembly language is the lowest-level programming language that uses human-readable mnemonics to represent machine code instructions. Each assembly instruction corresponds directly to a machine code instruction that the CPU can execute.

### Why Learn Assembly?
- **Performance**: Direct control over hardware
- **Understanding**: Deep knowledge of how computers work
- **Debugging**: Better ability to debug high-level code
- **Embedded Systems**: Essential for low-level programming
- **Reverse Engineering**: Understanding compiled code

---

## 2. Setting Up NASM on Windows {#setup}

### Installation Steps:
1. **Download NASM**: Get from https://www.nasm.us/
2. **Install**: Extract to a folder (e.g., `C:\nasm`)
3. **Add to PATH**: Add NASM folder to system PATH
4. **Get a Linker**: Install MinGW-w64 or use Visual Studio's link.exe

### Basic Compilation Process:
```bash
# Assemble source code
nasm -f win64 program.asm -o program.obj

# Link object file (using MinGW)
gcc program.obj -o program.exe

# Or using Microsoft linker
link program.obj /subsystem:console /entry:main
```

### Alternative: Using Visual Studio
```bash
nasm -f win64 program.asm -o program.obj
link program.obj kernel32.lib /subsystem:console /entry:main
```

---

## 3. Basic Concepts {#basic-concepts}

### Program Structure
```assembly
section .data
    ; Initialized data goes here
    
section .bss
    ; Uninitialized data goes here
    
section .text
    global main
    
main:
    ; Your code goes here
    
    ; Exit program
    mov eax, 1          ; sys_exit
    mov ebx, 0          ; exit status
    int 0x80            ; Linux system call
    
    ; Windows exit
    mov rcx, 0          ; exit code
    call ExitProcess    ; Windows API call
```

### Comments
```assembly
; This is a single-line comment
mov eax, 5  ; Comment at end of line
```

### Case Sensitivity
NASM is case-sensitive by default, but you can make it case-insensitive:
```assembly
; At the top of your file
%pragma case_insensitive true
```

---

## 4. Registers and Memory {#registers-memory}

### 64-bit Registers (x86-64)
```assembly
; General Purpose Registers (64-bit)
RAX, RBX, RCX, RDX    ; Accumulator, Base, Counter, Data
RSI, RDI              ; Source Index, Destination Index
RSP, RBP              ; Stack Pointer, Base Pointer
R8, R9, R10, R11      ; Additional general-purpose
R12, R13, R14, R15    ; Additional general-purpose

; 32-bit portions
EAX, EBX, ECX, EDX    ; Lower 32 bits of RAX, RBX, RCX, RDX
ESI, EDI, ESP, EBP    ; Lower 32 bits of RSI, RDI, RSP, RBP
R8D, R9D, R10D, R11D  ; Lower 32 bits of R8-R11

; 16-bit portions
AX, BX, CX, DX        ; Lower 16 bits
SI, DI, SP, BP        ; Lower 16 bits
R8W, R9W, R10W, R11W  ; Lower 16 bits of R8-R11

; 8-bit portions
AL, AH, BL, BH        ; Low/High 8 bits of AX, BX
CL, CH, DL, DH        ; Low/High 8 bits of CX, DX
R8B, R9B, R10B, R11B  ; Low 8 bits of R8-R11
```

### Special Purpose Registers
```assembly
RIP     ; Instruction Pointer (64-bit)
RFLAGS  ; Flags Register (64-bit)
CS, DS, ES, FS, GS, SS  ; Segment Registers
```

### Register Usage Conventions (Windows x64)
```assembly
; Volatile (caller-saved) - may be modified by function calls
RAX, RCX, RDX, R8, R9, R10, R11

; Non-volatile (callee-saved) - preserved across function calls
RBX, RBP, RDI, RSI, RSP, R12, R13, R14, R15

; Parameter registers (Windows x64 calling convention)
RCX     ; 1st parameter
RDX     ; 2nd parameter
R8      ; 3rd parameter
R9      ; 4th parameter
; Additional parameters go on stack
```

---

## 5. Essential Instructions {#essential-instructions}

### Data Movement Instructions
```assembly
; MOV - Move data
mov rax, 42         ; Move immediate value 42 to RAX
mov rbx, rax        ; Copy RAX to RBX
mov [rbp-8], rax    ; Store RAX at memory location

; LEA - Load Effective Address
lea rax, [rbx+rcx*2+8]  ; Calculate address, store in RAX

; XCHG - Exchange
xchg rax, rbx       ; Swap contents of RAX and RBX

; PUSH/POP - Stack operations
push rax            ; Push RAX onto stack
pop rbx             ; Pop from stack into RBX
```

### Arithmetic Instructions
```assembly
; Addition
add rax, rbx        ; RAX = RAX + RBX
add rax, 10         ; RAX = RAX + 10
adc rax, rbx        ; Add with carry

; Subtraction
sub rax, rbx        ; RAX = RAX - RBX
sub rax, 5          ; RAX = RAX - 5
sbb rax, rbx        ; Subtract with borrow

; Multiplication
mul rbx             ; RAX = RAX * RBX (unsigned)
imul rbx            ; RAX = RAX * RBX (signed)
imul rax, rbx, 10   ; RAX = RBX * 10

; Division
div rbx             ; RAX = RDX:RAX / RBX, RDX = remainder
idiv rbx            ; Signed division

; Increment/Decrement
inc rax             ; RAX = RAX + 1
dec rax             ; RAX = RAX - 1
```

### Logical Instructions
```assembly
; Bitwise operations
and rax, rbx        ; RAX = RAX & RBX
or rax, rbx         ; RAX = RAX | RBX
xor rax, rbx        ; RAX = RAX ^ RBX
not rax             ; RAX = ~RAX

; Bit shifts
shl rax, 2          ; Shift left by 2 bits (multiply by 4)
shr rax, 1          ; Shift right by 1 bit (divide by 2)
sar rax, 1          ; Arithmetic shift right (preserves sign)
rol rax, 3          ; Rotate left by 3 bits
ror rax, 2          ; Rotate right by 2 bits
```

### Comparison Instructions
```assembly
; Compare
cmp rax, rbx        ; Compare RAX with RBX (sets flags)
cmp rax, 0          ; Compare RAX with 0

; Test
test rax, rax       ; Test if RAX is zero
test rax, rbx       ; Bitwise AND without storing result
```

---

## 6. Data Types and Declarations {#data-types}

### Data Section Declarations
```assembly
section .data
    ; Byte (8-bit)
    byte_var    db 42           ; Define byte
    char_var    db 'A'          ; Character
    string_var  db 'Hello', 0   ; Null-terminated string
    
    ; Word (16-bit)
    word_var    dw 1234         ; Define word
    
    ; Double word (32-bit)
    dword_var   dd 12345678     ; Define double word
    float_var   dd 3.14159      ; 32-bit float
    
    ; Quad word (64-bit)
    qword_var   dq 123456789012 ; Define quad word
    double_var  dq 2.71828      ; 64-bit double
    
    ; Ten bytes (80-bit)
    tword_var   dt 3.14159265358979323846  ; Extended precision
    
    ; Arrays
    array       db 1, 2, 3, 4, 5
    numbers     dd 100, 200, 300, 400
    
    ; Reserving space
    buffer      db 256 dup(0)   ; 256 bytes of zeros
    matrix      dd 10 dup(?)    ; 10 uninitialized double words
```

### BSS Section (Uninitialized Data)
```assembly
section .bss
    ; Reserve space without initializing
    temp_var    resb 1          ; Reserve 1 byte
    temp_word   resw 1          ; Reserve 1 word
    temp_dword  resd 1          ; Reserve 1 double word
    temp_qword  resq 1          ; Reserve 1 quad word
    
    ; Arrays
    input_buffer resb 1024      ; 1KB buffer
    int_array    resd 100       ; Array of 100 integers
```

---

## 7. Memory Addressing Modes {#addressing-modes}

### Addressing Modes
```assembly
; Immediate addressing
mov rax, 42             ; Direct value

; Register addressing
mov rax, rbx            ; Register to register

; Direct memory addressing
mov rax, [variable]     ; Load from memory address

; Indirect addressing
mov rax, [rbx]          ; Load from address in RBX

; Base + displacement
mov rax, [rbp-8]        ; Load from RBP minus 8
mov rax, [rbx+16]       ; Load from RBX plus 16

; Base + index
mov rax, [rbx+rcx]      ; Load from RBX+RCX

; Base + index + displacement
mov rax, [rbx+rcx+8]    ; Load from RBX+RCX+8

; Scaled index
mov rax, [rbx+rcx*2]    ; Load from RBX+(RCX*2)
mov rax, [rbx+rcx*4+8]  ; Load from RBX+(RCX*4)+8

; Valid scale factors: 1, 2, 4, 8
```

### Size Specifiers
```assembly
; When size is ambiguous, specify explicitly
mov byte [rax], 0       ; Move byte
mov word [rax], 0       ; Move word (16-bit)
mov dword [rax], 0      ; Move double word (32-bit)
mov qword [rax], 0      ; Move quad word (64-bit)
```

---

## 8. Control Flow Instructions {#control-flow}

### Unconditional Jumps
```assembly
; Jump instructions
jmp label               ; Jump to label
jmp rax                 ; Jump to address in RAX
jmp [rax]               ; Jump to address stored at RAX

; Call instructions
call function           ; Call function
call rax                ; Call function at address in RAX
ret                     ; Return from function
```

### Conditional Jumps
```assembly
; After CMP instruction, these jumps are available:

; Equality
je label                ; Jump if equal (ZF=1)
jne label               ; Jump if not equal (ZF=0)

; Unsigned comparisons
ja label                ; Jump if above (CF=0 and ZF=0)
jae label               ; Jump if above or equal (CF=0)
jb label                ; Jump if below (CF=1)
jbe label               ; Jump if below or equal (CF=1 or ZF=1)

; Signed comparisons
jg label                ; Jump if greater (ZF=0 and SF=OF)
jge label               ; Jump if greater or equal (SF=OF)
jl label                ; Jump if less (SF≠OF)
jle label               ; Jump if less or equal (ZF=1 or SF≠OF)

; Sign and zero
jz label                ; Jump if zero (ZF=1)
jnz label               ; Jump if not zero (ZF=0)
js label                ; Jump if sign (SF=1)
jns label               ; Jump if not sign (SF=0)

; Carry and overflow
jc label                ; Jump if carry (CF=1)
jnc label               ; Jump if not carry (CF=0)
jo label                ; Jump if overflow (OF=1)
jno label               ; Jump if not overflow (OF=0)
```

### Loops
```assembly
; Loop instructions (use RCX as counter)
loop label              ; Decrement RCX, jump if RCX≠0
loope label             ; Loop while equal (ZF=1)
loopne label            ; Loop while not equal (ZF=0)

; Example loop
mov rcx, 10             ; Set counter
loop_start:
    ; Loop body
    ; ... your code here ...
    loop loop_start      ; Decrement RCX, jump if not zero
```

---

## 9. Arithmetic and Logic Operations {#arithmetic-logic}

### When to Use Different Operations

#### Addition vs Increment
```assembly
; Use INC for simple increment (faster)
inc rax                 ; Preferred for +1

; Use ADD for other values
add rax, 5              ; For values other than 1
add rax, rbx            ; For register addition
```

#### Multiplication Techniques
```assembly
; For powers of 2, use left shift (fastest)
shl rax, 1              ; Multiply by 2
shl rax, 2              ; Multiply by 4
shl rax, 3              ; Multiply by 8

; For small constants, use LEA (fast)
lea rax, [rax*2+rax]    ; Multiply by 3 (2x+x)
lea rax, [rax*4+rax]    ; Multiply by 5 (4x+x)
lea rax, [rax*8+rax]    ; Multiply by 9 (8x+x)

; For general multiplication
imul rax, rbx           ; Signed multiplication
imul rax, 10            ; Multiply by constant
```

#### Division Techniques
```assembly
; For powers of 2, use right shift (fastest)
sar rax, 1              ; Divide by 2 (signed)
shr rax, 1              ; Divide by 2 (unsigned)
sar rax, 2              ; Divide by 4 (signed)

; For general division (slower)
cqo                     ; Sign extend RAX into RDX:RAX
idiv rbx                ; Signed division
```

### Bitwise Operations
```assembly
; Setting bits
or rax, 0x0F            ; Set lower 4 bits
bts rax, 5              ; Set bit 5

; Clearing bits
and rax, 0xF0           ; Clear lower 4 bits
btr rax, 5              ; Clear bit 5

; Toggling bits
xor rax, 0x0F           ; Toggle lower 4 bits
btc rax, 5              ; Complement bit 5

; Testing bits
test rax, 0x01          ; Test if bit 0 is set
bt rax, 5               ; Test bit 5
```

---

## 10. String Operations {#string-operations}

### String Instructions
```assembly
; String instructions use RSI (source) and RDI (destination)
; RCX is used as counter, AL/AX/EAX/RAX for data

; Move strings
movsb                   ; Move byte from [RSI] to [RDI]
movsw                   ; Move word
movsd                   ; Move double word
movsq                   ; Move quad word

; Compare strings
cmpsb                   ; Compare bytes
cmpsw                   ; Compare words
cmpsd                   ; Compare double words
cmpsq                   ; Compare quad words

; Scan strings
scasb                   ; Scan for byte in AL
scasw                   ; Scan for word in AX
scasd                   ; Scan for dword in EAX
scasq                   ; Scan for qword in RAX

; Store strings
stosb                   ; Store AL to [RDI]
stosw                   ; Store AX to [RDI]
stosd                   ; Store EAX to [RDI]
stosq                   ; Store RAX to [RDI]

; Load strings
lodsb                   ; Load byte from [RSI] to AL
lodsw                   ; Load word from [RSI] to AX
lodsd                   ; Load dword from [RSI] to EAX
lodsq                   ; Load qword from [RSI] to RAX
```

### Direction Flag
```assembly
cld                     ; Clear direction flag (forward)
std                     ; Set direction flag (backward)
```

### Repeat Prefixes
```assembly
rep                     ; Repeat while RCX≠0
repe/repz               ; Repeat while equal/zero
repne/repnz             ; Repeat while not equal/not zero

; Examples
rep movsb               ; Copy RCX bytes from RSI to RDI
rep stosb               ; Fill RCX bytes at RDI with AL
repe cmpsb              ; Compare strings while equal
```

---

## 11. System Calls and Interrupts {#system-calls}

### Windows System Calls
```assembly
; Windows API calls
extern ExitProcess
extern WriteConsoleA
extern ReadConsoleA
extern GetStdHandle

section .data
    msg db 'Hello, World!', 0
    msg_len equ $ - msg - 1

section .text
    global main

main:
    ; Get stdout handle
    mov rcx, -11            ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov r8, rax             ; Save handle
    
    ; Write to console
    mov rcx, r8             ; Console handle
    mov rdx, msg            ; Message
    mov r8, msg_len         ; Length
    mov r9, 0               ; Reserved
    push 0                  ; lpReserved
    call WriteConsoleA
    
    ; Exit
    mov rcx, 0              ; Exit code
    call ExitProcess
```

### Linux System Calls (for reference)
```assembly
; Linux system calls use different registers
; RAX = system call number
; RDI, RSI, RDX, R10, R8, R9 = arguments

section .data
    msg db 'Hello, World!', 10, 0
    msg_len equ $ - msg - 1

section .text
    global _start

_start:
    ; Write system call
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, msg            ; message
    mov rdx, msg_len        ; length
    syscall
    
    ; Exit system call
    mov rax, 60             ; sys_exit
    mov rdi, 0              ; exit status
    syscall
```

---

## 12. Procedures and Functions {#procedures}

### Function Definition
```assembly
; Function that adds two numbers
add_numbers:
    ; Function prologue
    push rbp                ; Save old base pointer
    mov rbp, rsp            ; Set up new base pointer
    
    ; Function body
    mov rax, rcx            ; First parameter (Windows x64)
    add rax, rdx            ; Add second parameter
    
    ; Function epilogue
    mov rsp, rbp            ; Restore stack pointer
    pop rbp                 ; Restore base pointer
    ret                     ; Return to caller

; Calling the function
main:
    mov rcx, 10             ; First argument
    mov rdx, 20             ; Second argument
    call add_numbers        ; Result in RAX
```

### Stack Frame Management
```assembly
; Complex function with local variables
complex_function:
    ; Prologue
    push rbp
    mov rbp, rsp
    sub rsp, 32             ; Allocate 32 bytes for locals
    
    ; Save non-volatile registers if used
    push rbx
    push rsi
    push rdi
    
    ; Function body
    mov [rbp-8], rcx        ; Store first parameter
    mov [rbp-16], rdx       ; Store second parameter
    
    ; Local variable usage
    mov rax, [rbp-8]        ; Load first parameter
    add rax, [rbp-16]       ; Add second parameter
    mov [rbp-24], rax       ; Store result in local variable
    
    ; Restore non-volatile registers
    pop rdi
    pop rsi
    pop rbx
    
    ; Epilogue
    mov rsp, rbp            ; Restore stack pointer
    pop rbp                 ; Restore base pointer
    ret
```

### Parameter Passing
```assembly
; Windows x64 calling convention
; First 4 parameters: RCX, RDX, R8, R9
; Additional parameters on stack (right to left)
; Return value in RAX

function_with_many_params:
    ; RCX = param1, RDX = param2, R8 = param3, R9 = param4
    ; [rbp+48] = param5, [rbp+56] = param6, etc.
    
    push rbp
    mov rbp, rsp
    
    mov rax, rcx            ; Use param1
    add rax, rdx            ; Add param2
    add rax, r8             ; Add param3
    add rax, r9             ; Add param4
    add rax, [rbp+48]       ; Add param5
    
    pop rbp
    ret
```

---

## 13. Advanced Topics {#advanced-topics}

### Macros
```assembly
; Define a macro
%macro print_newline 0
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, newline        ; newline character
    mov rdx, 1              ; length
    syscall
%endmacro

; Macro with parameters
%macro print_number 1
    mov rax, %1             ; Move parameter to RAX
    call print_int          ; Call print function
%endmacro

; Usage
print_number 42
print_newline
```

### Conditional Assembly
```assembly
%define DEBUG 1

%if DEBUG
    ; Debug code
    mov rax, debug_msg
    call print_string
%endif

; Architecture-specific code
%ifdef WIN64
    call ExitProcess
%else
    mov rax, 60             ; Linux exit
    syscall
%endif
```

### Floating Point Operations
```assembly
section .data
    float_a dd 3.14159
    float_b dd 2.71828
    result  dd 0.0

section .text
    ; Load floating point values
    fld dword [float_a]     ; Load float_a onto FPU stack
    fld dword [float_b]     ; Load float_b onto FPU stack
    
    ; Arithmetic operations
    fadd                    ; Add top two values
    fstp dword [result]     ; Store result and pop stack
    
    ; SSE operations (modern alternative)
    movss xmm0, [float_a]   ; Load into SSE register
    addss xmm0, [float_b]   ; Add
    movss [result], xmm0    ; Store result
```

### SIMD Operations
```assembly
section .data
    array1  dd 1.0, 2.0, 3.0, 4.0
    array2  dd 5.0, 6.0, 7.0, 8.0
    result  dd 0.0, 0.0, 0.0, 0.0

section .text
    ; Load 4 floats at once
    movups xmm0, [array1]   ; Load array1
    movups xmm1, [array2]   ; Load array2
    
    ; Add 4 floats simultaneously
    addps xmm0, xmm1        ; Parallel addition
    
    ; Store result
    movups [result], xmm0
```

---

## 14. Debugging and Optimization {#debugging}

### Debugging Techniques
```assembly
; Insert breakpoints (int 3 generates debug interrupt)
int 3

; Add debug output
section .data
    debug_msg db 'Debug: RAX = ', 0

debug_print:
    ; Print debug information
    push rax
    mov rax, debug_msg
    call print_string
    pop rax
    call print_hex
    ret
```

### Performance Optimization Tips

#### Use Appropriate Data Sizes
```assembly
; Use smaller data types when possible
mov al, 5               ; 8-bit operation
mov ax, 1000            ; 16-bit operation
mov eax, 100000         ; 32-bit operation (clears upper 32 bits)
mov rax, 1000000000000  ; 64-bit operation
```

#### Optimize Loops
```assembly
; Prefer decrement to zero (faster comparison)
mov rcx, 1000
loop_start:
    ; Loop body
    dec rcx
    jnz loop_start          ; Jump if not zero

; Unroll loops for better performance
mov rcx, 250              ; Process 4 elements per iteration
loop_unrolled:
    ; Process 4 elements
    mov eax, [rsi]
    mov ebx, [rsi+4]
    mov edx, [rsi+8]
    mov edi, [rsi+12]
    add rsi, 16
    ; Process elements...
    dec rcx
    jnz loop_unrolled
```

#### Use CPU Cache Effectively
```assembly
; Access memory sequentially when possible
; Avoid frequent memory access - use registers
mov rax, [memory_var]     ; Load once
inc rax                   ; Multiple operations on register
add rax, 10
shl rax, 1
mov [memory_var], rax     ; Store once
```

---

## 15. Practical Examples {#examples}

### Example 1: Hello World (Windows)
```assembly
section .data
    hello db 'Hello, World!', 13, 10, 0

section .text
    global main
    extern printf
    extern exit

main:
    ; Setup stack frame
    push rbp
    mov rbp, rsp
    sub rsp, 32             ; Shadow space for Windows
    
    ; Call printf
    lea rcx, [hello]        ; First parameter
    call printf
    
    ; Cleanup and exit
    add rsp, 32
    pop rbp
    mov rcx, 0
    call exit
```

### Example 2: Factorial Function
```assembly
section .text
    global factorial

factorial:
    ; Calculate factorial of number in RCX
    ; Returns result in RAX
    
    push rbp
    mov rbp, rsp
    
    mov rax, 1              ; Initialize result
    cmp rcx, 1              ; Check if n <= 1
    jle factorial_done
    
factorial_loop:
    mul rcx                 ; RAX = RAX * RCX
    dec rcx                 ; Decrement counter
    cmp rcx, 1
    jg factorial_loop       ; Continue if > 1
    
factorial_done:
    pop rbp
    ret
```

### Example 3: Array Sum
```assembly
section .data
    array dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    array_size equ ($ - array) / 4

section .text
    global array_sum

array_sum:
    ; Sum array elements
    ; Returns sum in RAX
    
    push rbp
    mov rbp, rsp
    
    xor rax, rax            ; Clear accumulator
    mov rcx, array_size     ; Load counter
    lea rsi, [array]        ; Load array address
    
sum_loop:
    add eax, [rsi]          ; Add current element
    add rsi, 4              ; Move to next element
    dec rcx                 ; Decrement counter
    jnz sum_loop            ; Continue if not zero
    
    pop rbp
    ret
```

### Example 4: String Length
```assembly
section .text
    global string_length

string_length:
    ; Calculate length of null-terminated string
    ; String address in RCX
    ; Returns length in RAX
    
    push rbp
    mov rbp, rsp
    
    mov rax, 0              ; Initialize counter
    mov rsi, rcx            ; Copy string address
    
strlen_loop:
    cmp byte [rsi], 0       ; Check for null terminator
    je strlen_done          ; Jump if found
    inc rax                 ; Increment counter
    inc rsi                 ; Move to next character
    jmp strlen_loop         ; Continue
    
strlen_done:
    pop rbp
    ret
```

### Example 5: Bubble Sort
```assembly
section .text
    global bubble_sort

bubble_sort:
    ; Sort array of integers
    ; RCX = array address, RDX = array size
    
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    
    mov rsi, rcx            ; Array address
    mov rdi, rdx            ; Array size
    
outer_loop:
    mov rbx, 0              ; Swapped flag
    mov rcx, 0              ; Inner loop counter
    
inner_loop:
    mov eax, [rsi + rcx*4]      ; Load current element
    mov edx, [rsi + rcx*4 + 4]  ; Load next element
    
    cmp eax, edx            ; Compare elements
    jle no_swap             ; Jump if in order
    
    ; Swap elements
    mov [rsi + rcx*4], edx
    mov [rsi + rcx*4 + 4], eax
    mov rbx, 1              ; Set swapped flag
    
no_swap:
    inc rcx                 ; Next element
    cmp rcx, rdi            ; Check if done
    jl inner_loop           ; Continue if more elements
    
    cmp rbx, 0              ; Check if any swaps occurred
    jne outer_loop          ; Continue if swaps occurred
    
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret
```

---

## Key Takeaways and Best Practices

### Most Important Things to Know:
1. **Register Usage**: Understand x86-64 registers and calling conventions
2. **Memory Addressing**: Master different addressing modes
3. **Stack Management**: Proper function prologue/epilogue
4. **Conditional Logic**: Flags and conditional jumps
5. **Performance**: When to use different instructions

### Common Pitfalls:
- Forgetting to preserve registers across function calls
- Stack misalignment (Windows x64 requires 16-byte alignment)
- Not handling signed vs unsigned operations correctly
- Forgetting to clear high bits when working with smaller data sizes
- Incorrect use of addressing modes
- Not understanding flag effects of instructions

### Memory Usage Guidelines:

#### When to Use Different Memory Types:
```assembly
; Use registers for:
; - Frequently accessed variables
; - Loop counters
; - Temporary calculations
; - Function parameters and return values

; Use stack for:
; - Local variables
; - Temporary storage
; - Function call overhead
; - Preserving registers

; Use heap/global for:
; - Large data structures
; - Persistent data
; - Shared data between functions
```

#### Memory Access Patterns:
```assembly
; Sequential access (cache-friendly)
mov rsi, array_start
mov rcx, array_size
process_loop:
    mov eax, [rsi]          ; Process current element
    add rsi, 4              ; Move to next element
    dec rcx
    jnz process_loop

; Random access (cache-unfriendly - avoid when possible)
mov eax, [array + rbx*4]    ; Random index access
```

### Advanced Memory Management:

#### Dynamic Memory Allocation (Windows)
```assembly
extern HeapAlloc
extern HeapFree
extern GetProcessHeap

allocate_memory:
    ; Allocate memory dynamically
    ; RCX = size in bytes
    ; Returns pointer in RAX
    
    push rbp
    mov rbp, rsp
    sub rsp, 32             ; Shadow space
    
    push rcx                ; Save size
    call GetProcessHeap     ; Get process heap handle
    pop rdx                 ; Restore size to RDX
    
    mov rcx, rax            ; Heap handle
    mov r8, 0               ; Flags
    ; RDX already contains size
    call HeapAlloc
    
    add rsp, 32
    pop rbp
    ret

free_memory:
    ; Free allocated memory
    ; RCX = pointer to free
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    push rcx                ; Save pointer
    call GetProcessHeap     ; Get process heap handle
    pop r8                  ; Restore pointer to R8
    
    mov rcx, rax            ; Heap handle
    mov rdx, 0              ; Flags
    ; R8 already contains pointer
    call HeapFree
    
    add rsp, 32
    pop rbp
    ret
```

#### Memory Protection and Alignment
```assembly
; Ensure proper alignment
align 16                    ; Align to 16-byte boundary
data_aligned:
    dq 1.0, 2.0, 3.0, 4.0  ; 64-bit floats

; Check alignment at runtime
test rsp, 15                ; Check if RSP is 16-byte aligned
jz stack_aligned            ; Jump if aligned
; Handle misalignment...
stack_aligned:
```

### Error Handling and Robustness:

#### Defensive Programming
```assembly
safe_divide:
    ; Safe division with error checking
    ; RCX = dividend, RDX = divisor
    ; Returns: RAX = result, RDX = remainder, CF = error flag
    
    push rbp
    mov rbp, rsp
    
    ; Check for division by zero
    test rdx, rdx
    jz divide_error
    
    ; Perform division
    mov rax, rcx            ; Move dividend to RAX
    cqo                     ; Sign extend to RDX:RAX
    idiv rdx                ; Signed division
    
    clc                     ; Clear carry flag (no error)
    jmp divide_done
    
divide_error:
    xor rax, rax            ; Set result to 0
    xor rdx, rdx            ; Set remainder to 0
    stc                     ; Set carry flag (error)
    
divide_done:
    pop rbp
    ret
```

#### Bounds Checking
```assembly
safe_array_access:
    ; Safe array element access
    ; RCX = array base, RDX = index, R8 = array size
    ; Returns: RAX = element value, CF = error flag
    
    push rbp
    mov rbp, rsp
    
    ; Check bounds
    cmp rdx, r8
    jae array_bounds_error  ; Jump if index >= size
    
    ; Access element
    mov rax, [rcx + rdx*4]  ; Assuming 4-byte elements
    clc                     ; Clear carry (success)
    jmp array_access_done
    
array_bounds_error:
    xor rax, rax            ; Return 0
    stc                     ; Set carry (error)
    
array_access_done:
    pop rbp
    ret
```

### Performance Optimization Strategies:

#### Branch Prediction Optimization
```assembly
; Arrange code so common cases fall through
process_data:
    test rax, rax
    jz rare_case            ; Rare case jumps
    
    ; Common case code here (no jump)
    ; This executes faster due to branch prediction
    ; ...
    jmp done
    
rare_case:
    ; Handle rare case
    ; ...
    
done:
    ret
```

#### Loop Optimization Techniques
```assembly
; Technique 1: Loop unrolling
unrolled_copy:
    mov rcx, 1000           ; Copy 4000 bytes
copy_loop:
    mov rax, [rsi]          ; Copy 8 bytes at once
    mov [rdi], rax
    mov rax, [rsi+8]
    mov [rdi+8], rax
    mov rax, [rsi+16]
    mov [rdi+16], rax
    mov rax, [rsi+24]
    mov [rdi+24], rax
    add rsi, 32             ; Process 32 bytes per iteration
    add rdi, 32
    dec rcx
    jnz copy_loop

; Technique 2: Strength reduction
; Replace expensive operations with cheaper ones
multiply_by_constant:
    ; Instead of: imul rax, 9
    lea rax, [rax + rax*8]  ; rax = rax + rax*8 = rax*9

; Technique 3: Use of SIMD for parallel processing
simd_array_add:
    mov rcx, 1000           ; Process 1000 elements
    
simd_loop:
    movdqu xmm0, [rsi]      ; Load 4 floats from array1
    movdqu xmm1, [rsi+16]   ; Load next 4 floats
    addps xmm0, [rdi]       ; Add 4 floats from array2
    addps xmm1, [rdi+16]    ; Add next 4 floats
    movdqu [rdx], xmm0      ; Store results
    movdqu [rdx+16], xmm1   
    
    add rsi, 32             ; Move pointers
    add rdi, 32
    add rdx, 32
    sub rcx, 8              ; Processed 8 elements
    jnz simd_loop
```

### Advanced Data Structures:

#### Linked List Implementation
```assembly
section .data
    node_size equ 16        ; 8 bytes data + 8 bytes next pointer

section .text
create_node:
    ; Create new linked list node
    ; RCX = data value
    ; Returns: RAX = node pointer
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    push rcx                ; Save data value
    mov rcx, node_size      ; Allocate memory for node
    call allocate_memory
    pop rcx                 ; Restore data value
    
    test rax, rax           ; Check if allocation succeeded
    jz create_node_fail
    
    mov [rax], rcx          ; Store data
    mov qword [rax+8], 0    ; Initialize next pointer to NULL
    
create_node_fail:
    add rsp, 32
    pop rbp
    ret

insert_at_head:
    ; Insert node at head of list
    ; RCX = head pointer address, RDX = data value
    ; Updates head pointer
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    push rcx                ; Save head pointer address
    mov rcx, rdx            ; Move data to RCX
    call create_node        ; Create new node
    pop rcx                 ; Restore head pointer address
    
    test rax, rax           ; Check if node creation succeeded
    jz insert_fail
    
    mov rdx, [rcx]          ; Load current head
    mov [rax+8], rdx        ; Set new node's next to current head
    mov [rcx], rax          ; Update head to new node
    
insert_fail:
    add rsp, 32
    pop rbp
    ret
```

#### Hash Table Implementation
```assembly
section .data
    HASH_TABLE_SIZE equ 1024
    hash_table resq HASH_TABLE_SIZE

section .text
hash_function:
    ; Simple hash function
    ; RCX = key
    ; Returns: RAX = hash value
    
    mov rax, rcx
    mov rdx, 2654435761     ; Large prime number
    mul rdx                 ; Multiply key by prime
    mov rcx, HASH_TABLE_SIZE
    xor rdx, rdx            ; Clear RDX for division
    div rcx                 ; Get remainder
    mov rax, rdx            ; Return remainder as hash
    ret

hash_insert:
    ; Insert key-value pair into hash table
    ; RCX = key, RDX = value
    
    push rbp
    mov rbp, rsp
    
    push rdx                ; Save value
    call hash_function      ; Get hash for key
    pop rdx                 ; Restore value
    
    ; Simple linear probing for collision resolution
    lea rsi, [hash_table]   ; Base address of hash table
    
probe_loop:
    cmp qword [rsi + rax*8], 0  ; Check if slot is empty
    je insert_here          ; Found empty slot
    
    inc rax                 ; Move to next slot
    cmp rax, HASH_TABLE_SIZE
    jl probe_loop
    xor rax, rax           ; Wrap around to beginning
    jmp probe_loop
    
insert_here:
    mov [rsi + rax*8], rdx  ; Store value
    mov rax, 1              ; Return success
    
    pop rbp
    ret
```

### File I/O Operations (Windows):

#### Reading Files
```assembly
extern CreateFileA
extern ReadFile
extern CloseHandle

read_file:
    ; Read file contents
    ; RCX = filename, RDX = buffer, R8 = buffer size
    ; Returns: RAX = bytes read, -1 on error
    
    push rbp
    mov rbp, rsp
    sub rsp, 64             ; Space for local variables
    
    ; Store parameters
    mov [rbp-8], rcx        ; filename
    mov [rbp-16], rdx       ; buffer
    mov [rbp-24], r8        ; buffer size
    
    ; Open file
    mov rcx, [rbp-8]        ; filename
    mov rdx, 0x80000000     ; GENERIC_READ
    mov r8, 1               ; FILE_SHARE_READ
    mov r9, 0               ; security attributes
    push 0                  ; template file
    push 0x80               ; FILE_ATTRIBUTE_NORMAL
    push 3                  ; OPEN_EXISTING
    push 0                  ; security attributes
    call CreateFileA
    
    cmp rax, -1             ; INVALID_HANDLE_VALUE
    je read_file_error
    
    mov [rbp-32], rax       ; Store file handle
    
    ; Read file
    mov rcx, rax            ; file handle
    mov rdx, [rbp-16]       ; buffer
    mov r8, [rbp-24]        ; bytes to read
    lea r9, [rbp-40]        ; bytes read
    push 0                  ; overlapped
    call ReadFile
    
    ; Close file
    mov rcx, [rbp-32]       ; file handle
    call CloseHandle
    
    ; Return bytes read
    mov rax, [rbp-40]
    jmp read_file_done
    
read_file_error:
    mov rax, -1
    
read_file_done:
    add rsp, 64
    pop rbp
    ret
```

### Threading and Synchronization:

#### Creating Threads (Windows)
```assembly
extern CreateThread
extern WaitForSingleObject

thread_function:
    ; Thread entry point
    ; RCX = parameter
    
    push rbp
    mov rbp, rsp
    
    ; Thread work here
    ; Use RCX as thread parameter
    
    mov rax, 0              ; Thread exit code
    pop rbp
    ret

create_worker_thread:
    ; Create and wait for worker thread
    ; RCX = thread parameter
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    push rcx                ; Save parameter
    
    ; Create thread
    mov rcx, 0              ; security attributes
    mov rdx, 0              ; stack size (default)
    lea r8, [thread_function] ; thread function
    pop r9                  ; thread parameter
    push 0                  ; creation flags
    push 0                  ; thread ID
    call CreateThread
    
    test rax, rax           ; Check if thread creation succeeded
    jz thread_create_fail
    
    ; Wait for thread completion
    mov rcx, rax            ; thread handle
    mov rdx, -1             ; INFINITE timeout
    call WaitForSingleObject
    
    mov rax, 1              ; Success
    jmp thread_done
    
thread_create_fail:
    mov rax, 0              ; Failure
    
thread_done:
    add rsp, 32
    pop rbp
    ret
```

### Compilation and Linking Reference:

#### Build Scripts for Different Scenarios

**Simple Console Application:**
```batch
@echo off
nasm -f win64 program.asm -o program.obj
link program.obj kernel32.lib /subsystem:console /entry:main
```

**Using C Runtime Library:**
```batch
@echo off
nasm -f win64 program.asm -o program.obj
gcc program.obj -o program.exe
```

**With External Libraries:**
```batch
@echo off
nasm -f win64 program.asm -o program.obj
link program.obj kernel32.lib user32.lib /subsystem:console /entry:main
```

**Makefile Example:**
```makefile
NASM = nasm
LINK = link

NASMFLAGS = -f win64
LINKFLAGS = /subsystem:console /entry:main

SOURCES = main.asm utils.asm
OBJECTS = $(SOURCES:.asm=.obj)
TARGET = program.exe

$(TARGET): $(OBJECTS)
    $(LINK) $(OBJECTS) kernel32.lib $(LINKFLAGS) /out:$(TARGET)

%.obj: %.asm
    $(NASM) $(NASMFLAGS) $< -o $@

clean:
    del *.obj $(TARGET)
```

### Debugging and Development Tools:

#### Assembly-Level Debugging
```assembly
; Debug macros
%macro DEBUG_PRINT 1
    section .data
    debug_msg_%1 db 'Debug %1: ', 0
    section .text
    lea rcx, [debug_msg_%1]
    call print_string
%endmacro

%macro ASSERT 2
    cmp %1, %2
    je %%assert_ok
    int 3                   ; Breakpoint
    %%assert_ok:
%endmacro

; Usage
DEBUG_PRINT checkpoint1
ASSERT rax, 42
```

#### Performance Measurement
```assembly
extern QueryPerformanceCounter
extern QueryPerformanceFrequency

measure_performance:
    ; Measure execution time of code block
    ; Returns: RAX = elapsed ticks
    
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Get start time
    lea rcx, [rbp-16]
    call QueryPerformanceCounter
    mov r8, [rbp-16]        ; Start time
    
    ; Execute code to measure here
    ; ... your code ...
    
    ; Get end time
    lea rcx, [rbp-16]
    call QueryPerformanceCounter
    mov rax, [rbp-16]       ; End time
    
    sub rax, r8             ; Calculate elapsed ticks
    
    add rsp, 32
    pop rbp
    ret
```

---

## Final Tips and Resources

### Practice Projects:
1. **Calculator**: Implement basic arithmetic operations
2. **Text Editor**: Simple file reading/writing with basic editing
3. **Sorting Algorithms**: Implement various sorting methods
4. **Data Structures**: Linked lists, stacks, queues
5. **Game**: Simple console games like Tic-Tac-Toe
6. **Cryptography**: Implement basic encryption algorithms
7. **Graphics**: Simple bitmap manipulation

### Learning Path:
1. Start with simple programs (Hello World, basic I/O)
2. Master register usage and memory addressing
3. Implement mathematical operations and algorithms
4. Learn system calls and API usage
5. Practice with data structures
6. Explore advanced topics (SIMD, threading)
7. Optimize for performance

### Essential References:
- Intel Software Developer Manuals
- AMD Architecture Programmer's Manual
- Microsoft x64 Calling Convention Documentation
- NASM Documentation
- Operating System specific API documentation

### Common Assembly Instruction Reference Card:
```
MOV  - Move data
ADD  - Addition                 SUB  - Subtraction
MUL  - Unsigned multiply        DIV  - Unsigned divide
IMUL - Signed multiply          IDIV - Signed divide
INC  - Increment               DEC  - Decrement
AND  - Bitwise AND             OR   - Bitwise OR
XOR  - Bitwise XOR             NOT  - Bitwise NOT
SHL  - Shift left              SHR  - Shift right
CMP  - Compare                 TEST - Test bits
JMP  - Unconditional jump      JE   - Jump if equal
JNE  - Jump if not equal       JL   - Jump if less
JG   - Jump if greater         CALL - Call function
RET  - Return from function    PUSH - Push to stack
POP  - Pop from stack          LEA  - Load effective address
```

Remember: Assembly programming requires patience and practice. Start with simple programs and gradually work your way up to more complex projects. Understanding the underlying hardware and system architecture is crucial for writing efficient assembly code.