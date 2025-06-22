# 6. System Calls and I/O in x86-64

## Understanding System Calls

System calls (syscalls) are the interface between user programs and the operating system kernel. They allow programs to request services like file I/O, process management, and memory allocation.

## Syscall Mechanism

### Linux x86-64 Syscall
- Syscall number in RAX
- Arguments in RDI, RSI, RDX, R10, R8, R9
- Use `syscall` instruction
- Return value in RAX

### Windows x64 Syscall
- Different calling convention
- Typically use Windows API instead of direct syscalls
- Arguments in RCX, RDX, R8, R9, then stack
- Use `syscall` instruction (Windows 10+)

## Common Linux System Calls

| Name | RAX | RDI | RSI | RDX | R10 | R8 | R9 |
|------|-----|-----|-----|-----|-----|----|----|
| read | 0 | fd | buf | count | - | - | - |
| write | 1 | fd | buf | count | - | - | - |
| open | 2 | filename | flags | mode | - | - | - |
| close | 3 | fd | - | - | - | - | - |
| exit | 60 | status | - | - | - | - | - |

## File I/O Example (Linux)

```assembly
; File: file_io.asm
; Demonstrates file I/O using system calls (Linux)

section .data
    ; File names and data
    filename db "example.txt", 0
    text db "Hello, File I/O!", 10
    text_len equ $ - text
    
    ; Messages
    success_msg db "File written successfully!", 10
    success_len equ $ - success_msg
    
    error_msg db "Error occurred!", 10
    error_len equ $ - error_msg

section .bss
    fd resq 1    ; File descriptor

section .text
    global _start

_start:
    ; Open file (create if not exists, write-only, truncate)
    mov rax, 2              ; sys_open
    lea rdi, [filename]      ; filename
    mov rsi, 0x241           ; O_WRONLY|O_CREAT|O_TRUNC
    mov rdx, 0o644          ; rw-r--r--
    syscall
    
    ; Check for errors
    cmp rax, 0
    jl error
    mov [fd], rax            ; Save file descriptor
    
    ; Write to file
    mov rax, 1              ; sys_write
    mov rdi, [fd]           ; file descriptor
    lea rsi, [text]         ; buffer
    mov rdx, text_len       ; count
    syscall
    
    ; Check for errors
    cmp rax, 0
    jl error
    
    ; Close file
    mov rax, 3              ; sys_close
    mov rdi, [fd]
    syscall
    
    ; Print success message
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    lea rsi, [success_msg]
    mov rdx, success_len
    syscall
    
    ; Exit successfully
    jmp exit
    
error:
    ; Print error message
    mov rax, 1              ; sys_write
    mov rdi, 2              ; stderr
    lea rsi, [error_msg]
    mov rdx, error_len
    syscall
    
    ; Exit with error
    mov rax, 60             ; sys_exit
    mov rdi, 1              ; status = 1
    syscall

exit:
    ; Exit successfully
    mov rax, 60             ; sys_exit
    xor rdi, rdi            ; status = 0
    syscall
```

## Console I/O Example (Linux)

```assembly
; File: console_io.asm
; Demonstrates console I/O using system calls (Linux)

section .data
    prompt db "Enter your name: ", 0
    prompt_len equ $ - prompt
    
    greeting db "Hello, ", 0
    greeting_len equ $ - greeting
    
    newline db 10          ; Newline character
    
section .bss
    name resb 32          ; Buffer for name (31 chars + null)
    name_len equ 32

section .text
    global _start

_start:
    ; Print prompt
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    lea rsi, [prompt]
    mov rdx, prompt_len
    syscall
    
    ; Read name
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    lea rsi, [name]
    mov rdx, name_len
    syscall
    
    ; Remove newline from input
    lea rdi, [name + rax - 1]  ; Point to last character read
    cmp byte [rdi], 10         ; Is it a newline?
    jne print_greeting
    mov byte [rdi], 0          ; Replace newline with null
    
print_greeting:
    ; Print greeting
    mov rax, 1                 ; sys_write
    mov rdi, 1                 ; stdout
    lea rsi, [greeting]
    mov rdx, greeting_len
    syscall
    
    ; Print name
    mov rax, 1                 ; sys_write
    lea rsi, [name]
    
    ; Calculate name length
    mov rdi, rsi
    call strlen
    
    mov rdx, rax              ; Length from strlen
    mov rax, 1                 ; sys_write
    mov rdi, 1                 ; stdout
    lea rsi, [name]
    syscall
    
    ; Print newline
    mov rax, 1                 ; sys_write
    mov rdi, 1                 ; stdout
    lea rsi, [newline]
    mov rdx, 1
    syscall
    
    ; Exit
    mov rax, 60                ; sys_exit
    xor rdi, rdi               ; status = 0
    syscall

; strlen function
; Input: RDI = string address
; Output: RAX = string length
strlen:
    xor rcx, rcx              ; Counter = 0
    not rcx                    ; RCX = -1
    xor al, al                ; AL = 0 (null terminator)
    cld                       ; Clear direction flag (forward)
    repne scasb               ; Scan string until null byte
    not rcx                   ; Two's complement negation
    lea rax, [rcx - 1]        ; Subtract 1 to get length
    ret
```

## Windows API Example

```assembly
; File: win32_hello.asm
; Demonstrates Windows API calls

; Windows x64 calling convention:
; RCX, RDX, R8, R9, then stack (right to left)
; Caller must allocate 32 bytes of shadow space

format PE64 console
entry start

include 'win64a.inc'

section '.data' data readable writeable
    msg db 'Hello, Windows!', 13, 10, 0
    msg_len = $ - msg
    
    stdout dq 0
    bytes_written dq 0

section '.text' code readable executable

start:
    ; Get standard output handle
    sub rsp, 40        ; Shadow space (32) + align stack (8)
    
    ; GetStdHandle(STD_OUTPUT_HANDLE)
    mov rcx, -11       ; STD_OUTPUT_HANDLE = -11
    call [GetStdHandle]
    mov [stdout], rax
    
    ; Write to console
    ; WriteFile(hConsoleOutput, lpBuffer, nNumberOfCharsToWrite, 
    ;           lpNumberOfCharsWritten, lpReserved)
    mov rcx, [stdout]           ; hConsoleOutput
    lea rdx, [msg]              ; lpBuffer
    mov r8d, msg_len            ; nNumberOfCharsToWrite
    lea r9, [bytes_written]     ; lpNumberOfCharsWritten
    mov qword [rsp + 32], 0     ; lpReserved (5th arg on stack)
    call [WriteFile]
    
    ; ExitProcess(0)
    xor ecx, ecx
    call [ExitProcess]

section '.idata' import data readable writeable
    library kernel32, 'KERNEL32.DLL',\
            msvcrt, 'MSVCRT.DLL'
    
    import kernel32,\ 
           GetStdHandle, 'GetStdHandle',\
           WriteFile, 'WriteFile',\
           ExitProcess, 'ExitProcess'
    
    import msvcrt,\ 
           printf, 'printf',\
           scanf, 'scanf'
```

## Exercises

1. **File Copy Utility**
   - Write a program that copies the contents of one file to another
   - Take source and destination filenames as command-line arguments
   - Handle errors appropriately

2. **Simple Shell**
   - Create a basic shell that can execute simple commands
   - Use `fork()` and `execve()` system calls
   - Support basic commands like `cd`, `ls`, `pwd`

3. **Process Information**
   - Write a program that displays information about the current process
   - Show process ID, parent process ID, and user ID
   - Use `getpid()`, `getppid()`, and `getuid()` system calls

## Common Pitfalls

1. **Forgetting to Check Return Values**
   - Always check system call return values for errors
   - Example:
     ```assembly
     mov rax, 2        ; sys_open
     ; ...
     syscall
     cmp rax, 0         ; Check for error
     jl error_handler   ; Handle error
     ```

2. **Buffer Overflows**
   - Always validate input lengths
   - Use bounded operations when reading input
   - Example:
     ```assembly
     ; Safe read with length check
     mov rax, 0        ; sys_read
     mov rdi, 0        ; stdin
     lea rsi, [buffer]
     mov rdx, buffer_size
     syscall
     
     ; Check if input is too long
     cmp rax, buffer_size
     jae input_too_long
     ```

3. **Resource Leaks**
   - Always close files and free resources
   - Example:
     ```assembly
     ; Open file
     mov rax, 2        ; sys_open
     ; ...
     syscall
     mov [fd], rax
     
     ; ... use file ...
     
     ; Close file when done
     mov rax, 3        ; sys_close
     mov rdi, [fd]
     syscall
     ```

## Practice Problem

Write a program that counts the number of lines in a text file:

```assembly
; Input: RDI = filename (null-terminated string)
; Output: RAX = number of lines in file (or -1 on error)
count_lines:
    ; Your implementation here
    ret
```

In the next lesson, we'll explore advanced topics like SIMD instructions, optimization techniques, and interfacing with C code.

## Quick Reference

### Common Linux System Calls
| Syscall | RAX | Arguments | Description |
|---------|-----|-----------|-------------|
| read | 0 | RDI=fd, RSI=buf, RDX=count | Read from file |
| write | 1 | RDI=fd, RSI=buf, RDX=count | Write to file |
| open | 2 | RDI=filename, RSI=flags, RDX=mode | Open file |
| close | 3 | RDI=fd | Close file |
| exit | 60 | RDI=status | Terminate process |
| fork | 57 | - | Create child process |
| execve | 59 | RDI=filename, RSI=argv, RDX=envp | Execute program |
| mmap | 9 | RDI=addr, RSI=length, RDX=prot, R10=flags, R8=fd, R9=offset | Map file/memory |
| munmap | 11 | RDI=addr, RSI=length | Unmap memory |

### File Open Flags (OR these together)
| Flag | Value | Description |
|------|-------|-------------|
| O_RDONLY | 0 | Read only |
| O_WRONLY | 1 | Write only |
| O_RDWR | 2 | Read/write |
| O_CREAT | 0x40 | Create if not exists |
| O_TRUNC | 0x200 | Truncate file |
| O_APPEND | 0x400 | Append to file |

### File Permissions (octal)
| Permission | Value | Description |
|-----------|-------|-------------|
| S_IRUSR | 0400 | User read |
| S_IWUSR | 0200 | User write |
| S_IXUSR | 0100 | User execute |
| S_IRGRP | 0040 | Group read |
| S_IWGRP | 0020 | Group write |
| S_IXGRP | 0010 | Group execute |
| S_IROTH | 0004 | Others read |
| S_IWOTH | 0002 | Others write |
| S_IXOTH | 0001 | Others execute |
