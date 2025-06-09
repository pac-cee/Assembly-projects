section .data
    format db "%s", 10, 0            ; format string: "%s\n"
    msg db "Hello, World!", 0        ; actual message

section .text
    default rel                      ; Add this for Windows
    global main
    extern printf

main:
    push rbp                         ; Preserve frame pointer
    mov rbp, rsp                     ; Set up new frame
    sub rsp, 32                      ; Shadow space for Windows

    lea rcx, [format]                ; 1st argument in rcx
    lea rdx, [msg]                   ; 2nd argument in rdx
    xor rax, rax                     ; clear rax for variadic calls
    call printf

    xor eax, eax                     ; Return 0
    leave                            ; Restore stack frame
    ret