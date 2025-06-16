section .data
    ; Menu strings
    menu db 10, "Choose an operation:", 10
         db "1. Count from 1 to N", 10
         db "2. Find factorial of N", 10
         db "3. Check if number is prime", 10
         db "4. Print first N Fibonacci numbers", 10
         db "5. Exit", 10
         db "Enter choice (1-5): ", 0
    
    prompt_n db "Enter N: ", 0
    format_in db "%d", 0
    format_out db "%d ", 0
    newline db 10, 0
    result_msg db "Result: %d", 10, 0
    prime_yes db "Number is prime!", 10, 0
    prime_no db "Number is not prime.", 10, 0

section .bss
    choice resd 1    ; User's menu choice
    number resd 1    ; Input number N
    temp resd 1      ; Temporary storage

section .text
    default rel
    global main
    extern printf
    extern scanf

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32        ; Shadow space

menu_loop:
    ; Display menu
    lea     rcx, [menu]
    call    printf

    ; Get choice
    lea     rcx, [format_in]
    lea     rdx, [choice]
    call    scanf

    ; Switch-like structure using comparisons
    mov     eax, [choice]
    
    cmp     eax, 1
    je      do_counting
    
    cmp     eax, 2
    je      do_factorial
    
    cmp     eax, 3
    je      do_prime_check
    
    cmp     eax, 4
    je      do_fibonacci
    
    cmp     eax, 5
    je      program_exit
    
    jmp     menu_loop     ; Invalid choice, show menu again

do_counting:
    ; Get N
    lea     rcx, [prompt_n]
    call    printf
    
    lea     rcx, [format_in]
    lea     rdx, [number]
    call    scanf

    ; While loop to count from 1 to N
    mov     r12d, 1           ; Counter = 1
count_loop:
    cmp     r12d, [number]
    jg      count_done

    ; Print current number
    lea     rcx, [format_out]
    mov     edx, r12d
    call    printf

    inc     r12d
    jmp     count_loop
count_done:
    lea     rcx, [newline]
    call    printf
    jmp     menu_loop

do_factorial:
    ; Get N
    lea     rcx, [prompt_n]
    call    printf
    
    lea     rcx, [format_in]
    lea     rdx, [number]
    call    scanf

    ; Calculate factorial using a loop
    mov     eax, 1           ; Result = 1
    mov     r12d, 1          ; Counter = 1
fact_loop:
    cmp     r12d, [number]
    jg      fact_done

    imul    eax, r12d        ; Result *= counter
    inc     r12d
    jmp     fact_loop
fact_done:
    ; Print result
    lea     rcx, [result_msg]
    mov     edx, eax
    call    printf
    jmp     menu_loop

do_prime_check:
    ; Get N
    lea     rcx, [prompt_n]
    call    printf
    
    lea     rcx, [format_in]
    lea     rdx, [number]
    call    scanf

    ; Check if prime
    mov     eax, [number]
    cmp     eax, 1          ; If N <= 1, not prime
    jle     not_prime
    
    mov     r12d, 2         ; Divisor = 2
prime_loop:
    mov     eax, [number]
    cmp     r12d, eax      ; If divisor >= N, it's prime
    jge     is_prime

    mov     eax, [number]
    xor     edx, edx       ; Clear edx for division
    div     r12d           ; Divide N by divisor
    
    cmp     edx, 0         ; If remainder is 0, not prime
    je      not_prime

    inc     r12d           ; Try next divisor
    jmp     prime_loop

is_prime:
    lea     rcx, [prime_yes]
    call    printf
    jmp     menu_loop

not_prime:
    lea     rcx, [prime_no]
    call    printf
    jmp     menu_loop

do_fibonacci:
    ; Get N
    lea     rcx, [prompt_n]
    call    printf
    
    lea     rcx, [format_in]
    lea     rdx, [number]
    call    scanf

    ; Print first two Fibonacci numbers
    mov     r12d, 0        ; First number
    mov     r13d, 1        ; Second number
    mov     r14d, 0        ; Counter
    
fib_loop:
    cmp     r14d, [number]
    jge     fib_done

    ; Print current number
    lea     rcx, [format_out]
    mov     edx, r12d
    call    printf

    ; Calculate next Fibonacci number
    mov     eax, r12d      ; Save first number
    mov     r12d, r13d     ; First = second
    add     r13d, eax      ; Second = first + second
    
    inc     r14d
    jmp     fib_loop
fib_done:
    lea     rcx, [newline]
    call    printf
    jmp     menu_loop

program_exit:
    xor     eax, eax
    leave
    ret