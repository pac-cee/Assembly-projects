section .data
    format db "%s", 10, 0            ; format string: "%s\n"
    msg db "Hello, World!", 0        ; actual message

section .text
    global main
    extern printf

main:
    sub rsp, 40
    mov rdi, format                  ; 1st argument: format string
    mov rsi, msg                    ; 2nd argument: actual string
    xor rax, rax                    ; clear rax for variadic calls
    call printf
    add rsp, 40
    ret
; Exit the program