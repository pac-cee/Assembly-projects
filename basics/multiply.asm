section .data
    prompt  db "Enter a number for multiplication table: ", 0
    format  db "%d x %2d = %2d", 0ah, 0
    scanfmt db "%d", 0
    
section .bss
    number resd 1     ; Reserve space for user's number

section .text
    default rel
    global main
    extern printf
    extern scanf

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32            ; Shadow space

    ; Print prompt
    lea     rcx, [prompt]
    xor     rax, rax
    call    printf

    ; Read user input
    lea     rcx, [scanfmt]     ; First argument for scanf
    lea     rdx, [number]      ; Second argument - address to store number
    xor     rax, rax
    call    scanf

    mov     r12d, 1           ; Counter (1 to 10)
    
print_loop:
    ; Calculate number * counter
    mov     eax, [number]      ; Get user's number
    imul    eax, r12d         ; Multiply by counter
    
    ; Print result
    lea     rcx, [format]      ; First argument for printf
    mov     edx, [number]      ; Second argument (user's number)
    mov     r8d, r12d         ; Third argument (counter)
    mov     r9d, eax          ; Fourth argument (result)
    xor     rax, rax
    call    printf
    
    inc     r12d
    cmp     r12d, 11
    jl      print_loop
    
    xor     eax, eax
    leave
    ret