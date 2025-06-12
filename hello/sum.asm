section .data
    prompt_count db "How many numbers do you want to add? ", 0
    prompt_num db "Enter number %d: ", 0
    result_msg db "Sum is: %d", 0ah, 0
    format_in db "%d", 0

section .bss
    count resd 1    ; Space for count of numbers
    number resd 1   ; Space for each input number
    sum resd 1      ; Space for running sum

section .text
    default rel
    global main
    extern printf
    extern scanf

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32            ; Shadow space

    ; Initialize sum to 0
    mov     dword [sum], 0

    ; Ask for count of numbers
    lea     rcx, [prompt_count]
    call    printf

    ; Get count
    lea     rcx, [format_in]
    lea     rdx, [count]
    call    scanf

    ; Initialize loop counter
    mov     r12d, 0           ; i = 0

input_loop:
    ; Check if we've processed all numbers
    cmp     r12d, [count]
    jge     print_result

    ; Print prompt for number
    lea     rcx, [prompt_num]
    mov     edx, r12d
    inc     edx               ; i + 1
    call    printf

    ; Get number
    lea     rcx, [format_in]
    lea     rdx, [number]
    call    scanf

    ; Add to sum
    mov     eax, [number]
    add     [sum], eax

    ; Increment counter
    inc     r12d
    jmp     input_loop

print_result:
    ; Print sum
    lea     rcx, [result_msg]
    mov     edx, [sum]
    call    printf

    xor     eax, eax
    leave
    ret