section .data
    prompt_size db "Enter array size (max 10): ", 0
    prompt_num db "Enter number %d: ", 0
    sum_msg db "Sum: %d", 0ah, 0
    avg_msg db "Average: %d", 0ah, 0
    max_msg db "Maximum: %d", 0ah, 0
    format_in db "%d", 0
    array_max equ 10

section .bss
    array resd array_max
    size resd 1

section .text
    default rel
    global main
    extern printf
    extern scanf

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    ; Get array size
    lea     rcx, [prompt_size]
    call    printf
    
    lea     rcx, [format_in]
    lea     rdx, [size]
    call    scanf

    ; Input array elements
    xor     r12d, r12d        ; Counter
input_loop:
    cmp     r12d, [size]
    jge     process_array
    
    lea     rcx, [prompt_num]
    mov     edx, r12d
    inc     edx
    call    printf
    
    lea     rcx, [format_in]
    lea     rdx, [array + r12d*4]
    call    scanf
    
    inc     r12d
    jmp     input_loop

process_array:
    ; Calculate sum
    xor     eax, eax        ; Sum
    xor     r12d, r12d      ; Counter
sum_loop:
    cmp     r12d, [size]
    jge     print_sum
    add     eax, [array + r12d*4]
    inc     r12d
    jmp     sum_loop

print_sum:
    push    rax             ; Save sum
    lea     rcx, [sum_msg]
    mov     edx, eax
    call    printf
    pop     rax

    ; Calculate average
    cdq
    idiv    dword [size]
    lea     rcx, [avg_msg]
    mov     edx, eax
    call    printf

    ; Find maximum
    mov     eax, [array]    ; First element as initial max
    xor     r12d, r12d
max_loop:
    inc     r12d
    cmp     r12d, [size]
    jge     print_max
    cmp     eax, [array + r12d*4]
    jge     max_loop
    mov     eax, [array + r12d*4]
    jmp     max_loop

print_max:
    lea     rcx, [max_msg]
    mov     edx, eax
    call    printf

    xor     eax, eax
    leave
    ret