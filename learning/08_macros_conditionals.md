# 8. Macros and Conditional Assembly in NASM

## Introduction to Macros

Macros in NASM allow you to define reusable code blocks that are expanded during assembly. They help reduce code duplication and improve readability.

### Basic Macro Definition

```assembly
%macro mymacro 2    ; Macro with 2 parameters
    mov eax, %1     ; First parameter
    add eax, %2     ; Second parameter
%endmacro

; Usage
mymacro 10, 20      ; Expands to: mov eax, 10; add eax, 20
```

### Multi-line Macros

```assembly
%macro print_string 2
    push rdi
    push rsi
    push rax
    
    mov rdi, %1    ; String address
    mov rsi, %2    ; Length
    mov rax, 0x2000004  ; sys_write
    mov rdi, 1          ; stdout
    syscall
    
    pop rax
    pop rsi
    pop rdi
%endmacro
```

## Advanced Macro Features

### Default Parameters

```assembly
%macro mymacro 1-3 10, 20  ; 1 required, 2 optional parameters
    mov eax, %1
    add eax, %2
    add eax, %3
%endmacro

mymacro 5        ; Uses 5, 10, 20
mymacro 1, 2, 3   ; Uses 1, 2, 3
```

### Variable Number of Parameters

```assembly
%macro varmacro 1-*  ; 1+ parameters
    %rep %0          ; Number of parameters
        push %1       ; Push each parameter
        %rotate 1     ; Move to next parameter
    %endrep
%endmacro
```

## Conditional Assembly

### %ifdef, %ifndef, %else, %endif

```assembly
%define DEBUG 1

%ifdef DEBUG
    %define LOG(msg) write_log msg
    %macro write_log 1
        ; Implementation for debug logging
    %endmacro
%else
    %define LOG(msg) ; No-op in release
%endif
```

### %if with Expressions

```assembly
%if ($ - $$) > 100h
    %error "Code section too large!"
%endif
```

## Macro Libraries

Create a file `macros.inc`:

```assembly
; macros.inc
%ifndef MACROS_INC
%define MACROS_INC

%macro prologue 0
    push rbp
    mov rbp, rsp
%endmacro

%macro epilogue 0
    mov rsp, rbp
    pop rbp
    ret
%endmacro

%endif ; MACROS_INC
```

## String Manipulation Macros

```assembly
%macro str_len 2
    ; Input: %1 = string address
    ; Output: %2 = length in RAX
    push rdi
    push rcx
    
    mov rdi, %1
    xor rcx, rcx
    not rcx
    xor al, al
    cld
    repne scasb
    not rcx
    dec rcx
    mov %2, rcx
    
    pop rcx
    pop rdi
%endmacro
```

## Debugging Macros

```assembly
%macro debug_print 1
    %ifdef DEBUG
        push rdi
        push rsi
        push rdx
        push rax
        
        mov rdi, %1
        call print_string
        
        pop rax
        pop rdx
        pop rsi
        pop rdi
    %endif
%endmacro
```

## Exercises

1. **Macro Practice**
   - Create a macro that pushes all general-purpose registers
   - Create a matching macro to pop them back
   - Use these in a function prologue/epilogue

2. **Conditional Assembly**
   - Create a build configuration that includes debug code only in debug builds
   - Implement different versions of a function based on a compile-time constant

3. **String Library**
   - Create a set of string manipulation macros (copy, compare, concatenate)
   - Use these macros to implement a simple string formatter

## Best Practices

1. **Naming Conventions**
   - Use uppercase for macro names to distinguish them from other symbols
   - Add a prefix to avoid naming conflicts (e.g., `MYLIB_MACRO`)

2. **Documentation**
   - Always document macro parameters and their purposes
   - Include examples of macro usage

3. **Error Checking**
   - Validate macro parameters
   - Use `%error` for compile-time errors

## Advanced Example: Loop Unrolling

```assembly
%macro unrolled_loop 3
    ; %1 = counter register
    ; %2 = number of unrolls
    ; %3 = code block (use %$ for local labels)
    
    mov rcx, %1
    shr rcx, %2
    jz %%skip_loop
    
%%loop_start:
    %rep (1 << %2)
        %3
    %endrep
    
    dec rcx
    jnz %%loop_start
    
%%skip_loop:
%endmacro
```

In the next lesson, we'll dive into interrupts and exception handling in x86-64 assembly.
