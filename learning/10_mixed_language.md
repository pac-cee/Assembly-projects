# 10. Mixed-Language Programming: Assembly and C

## Calling Conventions

### System V AMD64 ABI (Linux/macOS)
- Integer args: RDI, RSI, RDX, RCX, R8, R9
- Floating-point: XMM0-XMM7
- Return: RAX (and RDX for 128-bit)
- Stack alignment: 16-byte before call

### Microsoft x64 (Windows)
- Integer args: RCX, RDX, R8, R9
- Floating-point: XMM0-XMM3
- Return: RAX (XMM0 for floating-point)
- Caller must allocate 32-byte shadow space

## Calling C from Assembly

### Example: Calling printf

```assembly
; File: call_printf.asm
extern printf

data_section:
    format db "The result is: %d", 10, 0
    number dq 42

text_section:
    global main

main:
    push rbp
    mov rbp, rsp
    
    ; Call printf("The result is: %d\n", number)
    lea rdi, [format]    ; Format string
    mov rsi, [number]     ; First argument
    xor eax, eax          ; 0 floating-point args
    call printf
    
    ; Return 0
    xor eax, eax
    pop rbp
    ret
```

## Calling Assembly from C

### Assembly Function
```assembly
; File: math.asm
section .text
    global add_numbers
    global factorial

; int64_t add_numbers(int64_t a, int64_t b)
add_numbers:
    mov rax, rdi    ; First argument (a)
    add rax, rsi    ; Second argument (b)
    ret

; int64_t factorial(int64_t n)
factorial:
    cmp rdi, 1
    jle .base_case
    
    push rdi
    dec rdi
    call factorial
    pop rdi
    imul rax, rdi
    ret
    
.base_case:
    mov rax, 1
    ret
```

### C Program
```c
// File: main.c
#include <stdio.h>
#include <stdint.h>

// Declare assembly functions
int64_t add_numbers(int64_t a, int64_t b);
int64_t factorial(int64_t n);

int main() {
    int64_t sum = add_numbers(10, 20);
    printf("10 + 20 = %lld\n", sum);
    
    int64_t fact = factorial(5);
    printf("5! = %lld\n", fact);
    
    return 0;
}
```

## Inline Assembly in C

### Basic Inline Assembly
```c
#include <stdio.h>

int main() {
    int a = 10, b = 20, result;
    
    __asm__ volatile (
        "addl %%ebx, %%eax"   // Assembly template
        : "=a" (result)        // Output operands
        : "a" (a), "b" (b)     // Input operands
        :                      // Clobbered registers
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

## Handling Global Variables

### Accessing C Globals from Assembly
```assembly
; File: access_globals.asm
extern global_variable  ; Declare external global

section .text
global get_global, set_global

get_global:
    mov rax, [rel global_variable wrt ..gotpc]
    mov rax, [rax]
    ret

set_global:
    mov rax, [rel global_variable wrt ..gotpc]
    mov [rax], rdi
    ret
```

## Structs and Memory Layout

### Passing Structs
```c
// C code
struct Point {
    int x;
    int y;
};

extern void print_point(struct Point p);

// Assembly implementation
section .text
global print_point
print_point:
    ; rdi = x, rsi = y
    ; On System V: rdi = x, rsi = y
    ; On Windows: rcx = x, rdx = y
    
    ; Print the point
    mov rdx, rsi
    mov rsi, rdi
    lea rdi, [rel format]
    xor eax, eax
    call printf
    ret

section .rodata
format db "Point: (%d, %d)", 10, 0
```

## Calling C++ from Assembly

### Name Mangling
C++ uses name mangling for function overloading. Use `extern "C"` to prevent mangling:

```cpp
// C++ code
extern "C" {
    void my_function(int x);
}
```

### Virtual Functions
Accessing virtual functions requires understanding the vtable layout:

```assembly
; Assuming rdi points to a C++ object
mov rax, [rdi]        ; Get vtable pointer
call [rax + 8]        ; Call second virtual function
```

## Performance Considerations

### Register Preservation
- Callee-saved: RBX, RBP, R12-R15
- Caller-saved: RAX, RCX, RDX, RSI, RDI, R8-R11, XMM0-XMM15

### Stack Alignment
- Ensure 16-byte stack alignment before function calls
- Allocate stack space in 16-byte increments

## Advanced: SIMD Intrinsics

### Using SSE/AVX Intrinsics
```c
#include <immintrin.h>

void add_arrays(float *a, float *b, float *c, size_t n) {
    for (size_t i = 0; i < n; i += 4) {
        __m128 va = _mm_load_ps(&a[i]);
        __m128 vb = _mm_load_ps(&b[i]);
        __m128 vc = _mm_add_ps(va, vb);
        _mm_store_ps(&c[i], vc);
    }
}
```

## Exercises

1. **Mixed-Language Calculator**
   - Implement basic arithmetic operations in assembly
   - Call them from a C program with a menu interface

2. **String Library**
   - Create optimized string functions in assembly (strlen, strcpy, etc.)
   - Provide a C header for easy integration

3. **Matrix Multiplication**
   - Implement matrix multiplication in assembly
   - Compare performance with a C implementation

## Best Practices

1. **ABI Compliance**
   - Follow the calling convention for your platform
   - Handle stack alignment correctly
   - Preserve non-volatile registers

2. **Error Handling**
   - Validate pointers before dereferencing
   - Use consistent error codes
   - Document error conditions

3. **Performance**
   - Minimize register spills
   - Use SIMD instructions when appropriate
   - Consider cache locality

In the next lesson, we'll dive into advanced optimization techniques for x86-64 assembly.
