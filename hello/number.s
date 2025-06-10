section .data
    num1 db "5", 0ah, 0   ; "5" with newline and null terminator

section .text
    default rel
    global main
    extern printf

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32        ; Shadow space for Windows

    ; Print the number
    lea     rcx, [num1]    ; First argument for printf
    xor     rax, rax      ; No floating point arguments
    call    printf

    xor     eax, eax      ; Return 0
    leave
    ret
