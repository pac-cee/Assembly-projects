# 7. Advanced x86-64 Assembly Topics

## SIMD (Single Instruction, Multiple Data)

### SSE/AVX Registers
- XMM0-XMM15 (128-bit)
- YMM0-YMM15 (256-bit with AVX)
- ZMM0-ZMM31 (512-bit with AVX-512)

### Common SIMD Instructions
```assembly
; Packed single-precision floating-point operations
addps xmm0, xmm1       ; Packed add
subps xmm0, xmm1       ; Packed subtract
mulps xmm0, xmm1       ; Packed multiply
divps xmm0, xmm1       ; Packed divide

; Data movement
movaps xmm0, [mem]     ; Aligned move
movups xmm0, [mem]     ; Unaligned move

; Shuffling and blending
shufps xmm0, xmm1, imm8  ; Shuffle packed singles
blendvps xmm0, xmm1, xmm2 ; Blend packed singles

; AVX instructions (VEX-encoded)
vmulps ymm0, ymm1, ymm2  ; 256-bit packed multiply
vfmadd132ps ymm0, ymm1, ymm2 ; Fused multiply-add
```

## Inline Assembly in C

### Basic Syntax
```c
#include <stdio.h>

int main() {
    int a = 10, b = 20, result;
    
    __asm__ volatile (
        "addl %%ebx, %%eax"  // Assembly template
        : "=a" (result)       // Output operands
        : "a" (a), "b" (b)    // Input operands
        :                     // Clobbered registers
    );
    
    printf("Result: %d\n", result);
    return 0;
}
```

### Extended Asm with Memory Operands
```c
void memcpy_asm(void *dest, const void *src, size_t n) {
    __asm__ volatile (
        "rep movsb"
        : "+D" (dest), "+S" (src), "+c" (n)
        : 
        : "memory"
    );
}
```

## Performance Optimization

### 1. Loop Unrolling
```assembly
; Before unrolling
mov rcx, 1000
loop_start:
    ; Loop body
    dec rcx
    jnz loop_start

; After unrolling by 4
mov rcx, 250  ; 1000 / 4
loop_start:
    ; Loop body (x4)
    ; ...
    dec rcx
    jnz loop_start
```

### 2. Data Alignment
```assembly
section .data
    align 16         ; Align to 16-byte boundary
    my_data dd 1.0, 2.0, 3.0, 4.0

section .text
    movaps xmm0, [my_data]  ; Requires 16-byte alignment
```

### 3. Avoiding Pipeline Stalls
```assembly
; Bad - RAW (Read After Write) hazard
mov eax, [mem1]
add eax, [mem2]  ; Stall - waiting for previous mov to complete

; Better - Interleave independent operations
mov eax, [mem1]
mov ebx, [mem3]  ; Independent operation
add eax, [mem2]
add ebx, [mem4]  ; Independent operation
```

## Interfacing with C

### Calling Conventions
- **Linux/macOS**: System V AMD64 ABI
  - Integer args: RDI, RSI, RDX, RCX, R8, R9
  - Floating-point: XMM0-XMM7
  - Return: RAX (and RDX for 128-bit)

- **Windows x64**
  - Integer args: RCX, RDX, R8, R9
  - Floating-point: XMM0-XMM3
  - Return: RAX (and XMM0 for floating-point)

### Example: Calling C from Assembly

```assembly
; File: call_c.asm
; Demonstrates calling C functions from assembly

extern printf

data_section:
    fmt db "The result is: %d", 10, 0
    number dq 42

text_section:
    global main

main:
    push rbp
    mov rbp, rsp
    
    ; Call printf("The result is: %d\n", number)
    mov rdi, fmt          ; Format string
    mov rsi, [number]     ; First argument
    xor eax, eax          ; 0 floating-point args
    call printf
    
    ; Return 0
    xor eax, eax
    pop rbp
    ret
```

## Advanced Instructions

### 1. Bit Manipulation
```assembly
; Bit test and set
bts rax, rbx    ; Set bit RBX in RAX and store old bit in CF

; Bit scan forward/backward
bsf rax, rbx    ; Find first set bit in RBX, store index in RAX
bsr rax, rbx    ; Find last set bit in RBX, store index in RAX

; Population count
popcnt rax, rbx ; Count number of set bits in RBX
```

### 2. Atomic Operations
```assembly
; Atomic compare and exchange
lock cmpxchg [mem], rbx  ; if (RAX == [mem]) { [mem] = RBX; ZF=1 } else { RAX = [mem]; ZF=0 }

; Atomic add
lock xadd [mem], rax     ; temp = [mem]; [mem] += RAX; RAX = temp
```

### 3. String Operations
```assembly
; Compare strings
cld                 ; Clear direction flag (forward)
mov rdi, str1
mov rsi, str2
mov rcx, len
repe cmpsb          ; Compare while equal

; Find character in string
mov rdi, str
mov al, 'x'
mov rcx, max_len
repne scasb         ; Find AL in [RDI++]
```

## Debugging Assembly

### Using GDB
```bash
gdb ./your_program
(gdb) break *main     # Set breakpoint at main
(gdb) run            # Start program
(gdb) info registers # Show all registers
(gdb) x/10i $rip     # Show next 10 instructions
(gdb) stepi          # Step one instruction
(gdb) nexti          # Step over function calls
(gdb) display/x $rax # Always show RAX in hex
```

### Common GDB Commands
- `layout asm` - Switch to assembly layout
- `tui reg general` - Show registers
- `x/10xg $rsp` - Examine stack (10 quadwords)
- `watch *0x1234` - Watch memory location
- `info frame` - Show current stack frame

## Optimization Guidelines

1. **Minimize Memory Access**
   - Use registers whenever possible
   - Cache-friendly data structures
   - Sequential memory access patterns

2. **Branch Prediction**
   - Make the common case the fall-through
   - Use `likely()`/`unlikely()` macros in C
   - Minimize branches in tight loops

3. **Instruction Selection**
   - Use specialized instructions (e.g., `lea` for arithmetic)
   - Prefer 32-bit operands (smaller encoding)
   - Avoid partial register stalls

4. **Loop Optimization**
   - Unroll small loops
   - Move invariants out of loops
   - Use count-down loops with `dec/jnz`

## Final Project

Implement a simple image processing function in assembly:
1. Load a grayscale image (PGM format)
2. Apply a 3x3 convolution filter (e.g., blur, sharpen)
3. Save the result to a new file

## Further Reading

1. **Intel 64 and IA-32 Architectures Software Developer Manuals**
2. **AMD64 Architecture Programmer's Manual**
3. **Agner Fog's Optimization Manuals**
4. **x86-64 Machine-Level Programming** by David A. Patterson and John L. Hennessy
5. **Computer Systems: A Programmer's Perspective** by Randal E. Bryant and David R. O'Hallaron

## Complete Learning Path

1. **Basic Concepts**
   - Registers and memory
   - Basic arithmetic and logic
   - Control flow

2. **Intermediate Topics**
   - Functions and stack
   - System calls and I/O
   - Data structures

3. **Advanced Topics**
   - SIMD programming
   - Performance optimization
   - Interfacing with high-level languages

4. **Specialized Areas**
   - Reverse engineering
   - Exploit development
   - Performance analysis
   - Compiler internals

## Final Words

You've now completed a comprehensive journey through x86-64 assembly language! Remember that mastery comes with practice. Try implementing algorithms from scratch, optimizing critical code paths, and studying compiler output to see how high-level constructs map to assembly.

Keep exploring, and happy coding in assembly! 🚀
