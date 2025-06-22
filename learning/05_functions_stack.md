# 5. Functions and the Stack in x86-64

## Understanding the Stack

The stack is a Last-In-First-Out (LIFO) data structure that grows downward in memory. Key registers:
- `RSP`: Stack Pointer (points to the top of the stack)
- `RBP`: Base Pointer (points to the base of the current stack frame)

## Stack Operations

### Basic Stack Instructions
```assembly
push rax    ; Equivalent to: sub rsp, 8; mov [rsp], rax
pop rax     ; Equivalent to: mov rax, [rsp]; add rsp, 8
```

### Function Prologue and Epilogue
```assembly
my_function:
    ; Prologue
    push rbp            ; Save old base pointer
    mov rbp, rsp        ; Set new base pointer
    sub rsp, N          ; Allocate space for local variables
    
    ; Function body
    
    ; Epilogue
    mov rsp, rbp        ; Deallocate locals
    pop rbp             ; Restore old base pointer
    ret                 ; Return to caller
```

## Calling Conventions

### Windows x64 Calling Convention
- First 4 integer/pointer args: RCX, RDX, R8, R9
- First 4 floating-point args: XMM0, XMM1, XMM2, XMM3
- Additional args: Right to left on the stack
- Caller must allocate 32 bytes of "shadow space"
- RAX, RCX, RDX, R8, R9, R10, R11 are volatile
- RBX, RBP, RDI, RSI, R12-R15 are non-volatile

### System V AMD64 ABI (Linux/macOS)
- First 6 integer/pointer args: RDI, RSI, RDX, RCX, R8, R9
- First 8 floating-point args: XMM0-XMM7
- Additional args: Right to left on the stack
- No shadow space required
- RAX, RCX, RDX, RSI, RDI, R8-R11 are volatile
- RBX, RBP, R12-R15 are non-volatile

## Function Example

```assembly
; File: functions.asm
; Demonstrates function calls and stack usage

section .data
    msg db "Result: %d", 10, 0

section .text
    global main
    extern printf

; int add(int a, int b)
; Input: a = RCX, b = RDX (Windows)
;        a = RDI, b = RSI (System V)
; Output: RAX = a + b
add_numbers:
    push rbp
    mov rbp, rsp
    
    ; Windows: a=RCX, b=RDX
    ; System V: a=RDI, b=RSI
    
    ; For Windows, move to System V registers
    %ifidn __OUTPUT_FORMAT__, win64
    mov rdi, rcx
    mov rsi, rdx
    %endif
    
    ; Add the numbers
    mov rax, rdi
    add rax, rsi
    
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32        ; Shadow space (Windows) or alignment (System V)
    
    ; Call add_numbers(5, 3)
    %ifidn __OUTPUT_FORMAT__, win64
    mov rcx, 5         ; First argument
    mov rdx, 3         ; Second argument
    %else
    mov rdi, 5         ; First argument
    mov rsi, 3         ; Second argument
    %endif
    
    call add_numbers
    
    ; Print the result
    mov rdx, rax       ; Result from add_numbers
    lea rcx, [rel msg] ; Format string
    %ifidn __OUTPUT_FORMAT__, win64
    call printf
    %else
    ; On System V, we need to align the stack before calling printf
    push rdx           ; Save result
    mov rdi, rcx       ; Format string
    mov rsi, rdx       ; Result
    xor eax, eax       ; 0 floating point args
    call printf wrt ..plt
    pop rdx            ; Restore result
    %endif
    
    ; Return 0
    xor eax, eax
    leave
    ret
```

## Recursion Example

```assembly
; File: factorial.asm
; Recursive factorial function

section .data
    n dq 5
    msg db "%d! = %d", 10, 0

section .text
    global main
    extern printf

; int64_t factorial(int64_t n)
; Input: n in RDI (System V) or RCX (Windows)
; Output: n! in RAX
factorial:
    push rbp
    mov rbp, rsp
    
    ; Handle Windows calling convention
    %ifidn __OUTPUT_FORMAT__, win64
    mov rdi, rcx
    %endif
    
    ; Base case: 0! = 1
    cmp rdi, 0
    jne .recurse
    mov rax, 1
    jmp .done
    
.recurse:
    ; Save n and the return address
    push rdi
    
    ; Compute factorial(n-1)
    dec rdi
    call factorial
    
    ; Multiply by n: rax = n * factorial(n-1)
    pop rdi
    imul rax, rdi
    
.done:
    leave
    ret

main:
    push rbp
    mov rbp, rsp
    
    ; Compute factorial(5)
    mov rdi, [n]        ; Load n
    %ifidn __OUTPUT_FORMAT__, win64
    mov rcx, rdi
    %endif
    call factorial
    
    ; Print the result
    mov rdx, rax        ; Result
    mov r8, [n]         ; n
    lea rcx, [rel msg]  ; Format string
    %ifidn __OUTPUT_FORMAT__, win64
    call printf
    %else
    ; System V calling convention
    mov rdi, rcx        ; Format string
    mov rsi, r8         ; n
    mov rdx, rax        ; Result
    xor eax, eax        ; 0 floating point args
    call printf wrt ..plt
    %endif
    
    ; Return 0
    xor eax, eax
    leave
    ret
```

## Exercises

1. **Fibonacci Sequence**
   - Implement a recursive function to compute the nth Fibonacci number
   - Input: n in RDI (System V) or RCX (Windows)
   - Output: nth Fibonacci number in RAX

2. **String Reverse**
   - Write a function that reverses a string in-place
   - Input: RDI = string address (null-terminated)
   - No return value (modifies string in place)

3. **Stack Frame Analysis**
   - Draw the stack frame for a function with 3 local variables and 2 parameters
   - Show the values of RBP and RSP at each point

## Common Pitfalls

1. **Stack Alignment**
   - The stack must be 16-byte aligned before function calls
   - Always allocate stack space in multiples of 16 bytes
   - Example:
     ```assembly
     ; Correct
     sub rsp, 32     ; 32 is a multiple of 16
     
     ; Potentially incorrect
     sub rsp, 20     ; Not a multiple of 16
     ```

2. **Register Preservation**
   - Non-volatile registers must be preserved across function calls
   - Example:
     ```assembly
     my_function:
         push rbx        ; Save non-volatile register
         
         ; Function body
         
         pop rbx         ; Restore non-volatile register
         ret
     ```

## Practice Problem

Implement a function that converts a 64-bit integer to a null-terminated string in a given base (2-16):

```assembly
; Input: RDI = number, RSI = buffer, RDX = base (2-16)
; Output: RAX = pointer to the resulting string (same as input buffer)
int_to_string:
    ; Your implementation here
    ret
```

In the next lesson, we'll explore system calls and input/output operations in assembly.

## Quick Reference

### Stack Operations
| Instruction | Description                    | Effect                            |
|-------------|--------------------------------|-----------------------------------|
| `push reg`  | Push register onto stack       | RSP -= 8; [RSP] = reg            |
| `pop reg`   | Pop from stack to register     | reg = [RSP]; RSP += 8            |
| `enter`     | Create stack frame             | push rbp; mov rbp, rsp; sub rsp, N |
| `leave`     | Destroy stack frame           | mov rsp, rbp; pop rbp            |
| `call addr` | Call function                 | push rip; jmp addr               |
| `ret`       | Return from function          | pop rip; jmp rip                  |

### Common Function Prologues/Epilogues

**Windows x64 Prologue:**
```assembly
my_function:
    push rbp
    mov rbp, rsp
    sub rsp, 32        ; Shadow space + locals
    push rsi           ; Save non-volatile regs if used
    push rdi
    push rbx
    ; Function body
```

**Windows x64 Epilogue:**
```assembly
    pop rbx
    pop rdi
    pop rsi
    mov rsp, rbp
    pop rbp
    ret
```

**System V ABI Prologue:**
```assembly
my_function:
    push rbp
    mov rbp, rsp
    push rbx           ; Save non-volatile regs if used
    push r12
    ; Function body
```

**System V ABI Epilogue:**
```assembly
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
```
