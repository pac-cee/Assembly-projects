section .data
    format db "6 x %2d = %2d", 0ah, 0
    
section .text
    default rel
    global main
    extern printf

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32            ; Shadow space
    
    mov     ecx, 1            ; Counter (1 to 10)
    
print_loop:
    ; Calculate 6 * counter
    mov     eax, 6
    imul    eax, eax, ecx
    
    ; Print result
    lea     rdx, [format]
    mov     esi, ecx          ; Current number
    mov     edx, eax          ; Result of multiplication
    xor     eax, eax
    call    printf
    
    inc     rcx
    cmp     rcx, 11
    jl      print_loop
    
    xor     eax, eax
    leave
    ret