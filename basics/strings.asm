section .data
    input_prompt db "Enter a string: ", 0
    length_msg db "String length: %d", 0ah, 0
    reverse_msg db "Reversed string: %s", 0ah, 0
    format_str db "%s", 0
    buffer_size equ 100

section .bss
    input_buffer resb buffer_size
    reverse_buffer resb buffer_size

section .text
    default rel
    global main
    extern printf
    extern scanf
    extern gets

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    ; Prompt for input
    lea     rcx, [input_prompt]
    call    printf

    ; Get string input
    lea     rcx, [input_buffer]
    call    gets

    ; Calculate string length
    lea     rsi, [input_buffer]
    xor     rcx, rcx      ; Length counter
count_loop:
    cmp     byte [rsi], 0
    je      count_done
    inc     rcx
    inc     rsi
    jmp     count_loop
count_done:

    ; Print length
    push    rcx           ; Save length
    lea     rcx, [length_msg]
    mov     rdx, rcx
    call    printf
    pop     rcx

    ; Reverse the string
    lea     rsi, [input_buffer]
    lea     rdi, [reverse_buffer]
    add     rdi, rcx      ; Point to end of reverse buffer
    mov     byte [rdi], 0 ; Null terminate
    dec     rdi
reverse_loop:
    mov     al, [rsi]
    mov     [rdi], al
    inc     rsi
    dec     rdi
    loop    reverse_loop

    ; Print reversed string
    lea     rcx, [reverse_msg]
    lea     rdx, [reverse_buffer]
    call    printf

    xor     eax, eax
    leave
    ret