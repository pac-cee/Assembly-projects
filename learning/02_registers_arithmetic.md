# 2. Registers and Basic Arithmetic in x86-64

## Understanding Registers

Registers are small storage locations directly on the CPU. In x86-64, we have:

### General-Purpose Registers (64-bit)
```
RAX, RBX, RCX, RDX, RSI, RDI, RBP, RSP, R8-R15
```

### 32-bit, 16-bit, and 8-bit Views
```
64-bit      32-bit    16-bit   8-bit (high)  8-bit (low)
--------------------------------------------------------
RAX         EAX       AX       AH            AL
RBX         EBX       BX       BH            BL
RCX         ECX       CX       CH            CL
RDX         EDX       DX       DH            DL
RSI         ESI       SI       -             SIL
RDI         EDI       DI       -             DIL
RBP         EBP       BP       -             BPL
RSP         ESP       SP       -             SPL
R8          R8D       R8W      -             R8B
...         ...       ...      ...           ...
R15         R15D      R15W     -             R15B
```

## Basic Arithmetic Instructions

### 1. Addition and Subtraction
```assembly
add  dest, src     ; dest = dest + src
sub  dest, src     ; dest = dest - src
inc  dest          ; dest = dest + 1
dec  dest          ; dest = dest - 1
neg  dest          ; dest = -dest (two's complement)
```

### 2. Multiplication and Division
```assembly
; Signed multiplication
imul dest, src     ; dest = dest * src (signed)

; Unsigned multiplication
mul  src           ; RAX = RAX * src (unsigned)

; Division
idiv divisor       ; Signed division: RDX:RAX / divisor → RAX (quotient), RDX (remainder)
div  divisor       ; Unsigned division
```

## Example: Simple Calculator

```assembly
; File: calculator.asm
; A simple calculator that adds, subtracts, multiplies, and divides

section .data
    num1    dq 30
    num2    dq 7
    result  dq 0
    
    ; Format strings for printf
    fmt_add db "%ld + %ld = %ld", 10, 0
    fmt_sub db "%ld - %ld = %ld", 10, 0
    fmt_mul db "%ld * %ld = %ld", 10, 0
    fmt_div db "%ld / %ld = %ld, remainder %ld", 10, 0

section .text
    global main
    extern printf

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32        ; Shadow space
    
    ; Load numbers
    mov rax, [num1]
    mov rbx, [num2]
    
    ; 1. Addition
    mov rcx, rax
    add rcx, rbx       ; rcx = rax + rbx
    
    ; Print addition result
    mov rdx, rax       ; First number
    mov r8, rbx        ; Second number
    mov r9, rcx        ; Result
    lea rcx, [fmt_add]
    call printf
    
    ; 2. Subtraction
    mov rcx, rax
    sub rcx, rbx       ; rcx = rax - rbx
    
    ; Print subtraction result
    mov rdx, rax
    mov r8, rbx
    mov r9, rcx
    lea rcx, [fmt_sub]
    call printf
    
    ; 3. Multiplication
    mov rcx, rax
    imul rcx, rbx      ; rcx = rax * rbx
    
    ; Print multiplication result
    mov rdx, rax
    mov r8, rbx
    mov r9, rcx
    lea rcx, [fmt_mul]
    call printf
    
    ; 4. Division
    mov rax, [num1]    ; Dividend (low 64 bits)
    cqo                ; Sign-extend RAX into RDX:RAX
    idiv qword [num2]  ; RDX:RAX / num2 → RAX (quotient), RDX (remainder)
    
    ; Print division result
    mov rdx, [num1]    ; First number
    mov r8, [num2]     ; Second number
    mov r9, rax        ; Quotient
    mov qword [rsp + 32], rdx  ; Remainder (5th argument on stack)
    lea rcx, [fmt_div]
    call printf
    
    ; Clean up and return
    xor eax, eax       ; Return 0
    leave
    ret
```

## Bitwise Operations

```assembly
and  dest, src    ; Bitwise AND
or   dest, src    ; Bitwise OR
xor  dest, src    ; Bitwise XOR
not  dest         ; Bitwise NOT
shl  dest, count  ; Shift left
shr  dest, count  ; Shift right (logical)
sar  dest, count  ; Shift right (arithmetic)
```

## Exercises

1. **Register Operations**
   - Write a program that:
     1. Loads 0x12345678 into RAX
     2. Swaps the high and low 32 bits of RAX
     3. Rotates the result right by 4 bits

2. **Factorial Calculation**
   - Write a function that calculates the factorial of a number using a loop
   - Input: Number in RAX
   - Output: Factorial in RAX

3. **Bit Counting**
   - Write a function that counts the number of set bits (1s) in a 64-bit number
   - Input: Number in RAX
   - Output: Count in RBX

## Common Mistakes

1. **Forgetting to zero/sign extend**
   - Use `movsx` (sign extend) or `movzx` (zero extend) when moving between different-sized registers
   - Example: `movsx eax, byte [mem]`

2. **Incorrect operand sizes**
   - Ensure source and destination sizes match
   - Example: `add al, 5` (byte), not `add al, 500` (too large for byte)

3. **Forgetting to save registers**
   - Some registers are preserved across function calls (RBX, RBP, R12-R15)
   - Others can be modified by called functions

## Practice Problem

Write a program that implements the following C function in assembly:

```c
// Returns (a * b) + (c / d) - e
int64_t calculate(int64_t a, int64_t b, int64_t c, int64_t d, int64_t e) {
    return (a * b) + (c / d) - e;
}
```

In the next lesson, we'll learn about memory addressing modes and how to work with arrays and data structures.

## Quick Reference

| Instruction | Description                    | Example                  |
|-------------|--------------------------------|--------------------------|
| `mov`       | Move data                      | `mov rax, 5`            |
| `add`       | Add                            | `add rax, rbx`           |
| `sub`       | Subtract                       | `sub rax, 10`            |
| `imul`      | Signed multiply                | `imul rax, rbx`          |
| `idiv`      | Signed divide                  | `idiv rbx`               |
| `and/or/xor` | Bitwise operations             | `and rax, rbx`           |
| `shl/shr`   | Shift left/right               | `shl rax, 3`             |
| `inc/dec`   | Increment/Decrement            | `inc rax`                |
| `neg`       | Two's complement negation      | `neg rax`                |
