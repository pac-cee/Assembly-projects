section .data
    prompt1 db "Enter first number: ", 0
    prompt2 db "Enter second number: ", 0
    result_msg db "The sum is: %d", 0ah, 0
    format_in db "%d", 0

section .bss
    num1 resd 1    ; Reserve space for first number
    num2 resd 1    ; Reserve space for second number

section .text
    default rel
    global main
    extern printf
    extern scanf

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32        ; Reserve shadow space

    ; Print first prompt
    lea     rcx, [prompt1]
    call    printf

    ; Get first number
    lea     rcx, [format_in]
    lea     rdx, [num1]
    call    scanf

    ; Print second prompt
    lea     rcx, [prompt2]
    call    printf

    ; Get second number
    lea     rcx, [format_in]
    lea     rdx, [num2]
    call    scanf

    ; Add the numbers
    mov     eax, [num1]
    add     eax, [num2]

    ; Print result
    lea     rcx, [result_msg]
    mov     edx, eax
    call    printf

    xor     eax, eax
    leave
    ret