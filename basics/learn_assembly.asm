section .data
    ; Menu strings
    menu db 10, "Assembly Learning Program", 10
         db "----------------------", 10
         db "1. Registers & Basic Operations", 10
         db "2. Memory & Addressing Modes", 10
         db "3. Arithmetic Operations", 10
         db "4. Control Flow & Comparisons", 10
         db "5. Stack Operations", 10
         db "6. Arrays & Loops", 10
         db "7. Function Calls", 10
         db "8. Bit Operations", 10
         db "9. Exit", 10
         db "Choose a lesson (1-9): ", 0
    
    ; Lesson headers
    reg_header db "Lesson 1: Registers & Basic Operations", 10, 0
    mem_header db "Lesson 2: Memory & Addressing Modes", 10, 0
    arith_header db "Lesson 3: Arithmetic Operations", 10, 0
    flow_header db "Lesson 4: Control Flow & Comparisons", 10, 0
    stack_header db "Lesson 5: Stack Operations", 10, 0
    array_header db "Lesson 6: Arrays & Loops", 10, 0
    func_header db "Lesson 7: Function Calls", 10, 0
    bit_header db "Lesson 8: Bit Operations", 10, 0

    ; Common formats
    format_in db "%d", 0
    format_out db "%d", 10, 0
    format_hex db "Hex: 0x%x", 10, 0
    press_key db "Press Enter to continue...", 10, 0
    
    ; Demo values
    demo_array dd 1, 2, 3, 4, 5
    demo_size dd 5

section .bss
    choice resd 1
    input resd 1
    result resd 1
    buffer resb 100

section .text
    default rel
    global main
    extern printf
    extern scanf
    extern getchar

main:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

menu_loop:
    ; Display menu
    lea     rcx, [menu]
    call    printf

    ; Get choice
    lea     rcx, [format_in]
    lea     rdx, [choice]
    call    scanf

    ; Clear input buffer
    call    getchar

    ; Switch based on choice
    mov     eax, [choice]
    
    cmp     eax, 1
    je      registers_lesson
    
    cmp     eax, 2
    je      memory_lesson
    
    cmp     eax, 3
    je      arithmetic_lesson
    
    cmp     eax, 4
    je      control_flow_lesson
    
    cmp     eax, 5
    je      stack_lesson
    
    cmp     eax, 6
    je      arrays_lesson
    
    cmp     eax, 7
    je      functions_lesson
    
    cmp     eax, 8
    je      bits_lesson
    
    cmp     eax, 9
    je      program_exit
    
    jmp     menu_loop

registers_lesson:
    ; Display header
    lea     rcx, [reg_header]
    call    printf

    ; Demonstrate register operations
    mov     eax, 42         ; Load immediate value
    mov     ebx, eax        ; Register to register move
    
    ; Show result
    lea     rcx, [format_out]
    mov     edx, ebx
    call    printf

    jmp     wait_and_return

memory_lesson:
    ; Display header
    lea     rcx, [mem_header]
    call    printf

    ; Demonstrate memory operations
    mov     dword [input], 123   ; Store to memory
    mov     eax, [input]         ; Load from memory
    
    ; Show different addressing modes
    lea     rcx, [format_out]
    mov     edx, eax
    call    printf

    jmp     wait_and_return

arithmetic_lesson:
    ; Display header
    lea     rcx, [arith_header]
    call    printf

    ; Demonstrate arithmetic
    mov     eax, 5
    add     eax, 3          ; Addition
    mov     ebx, eax
    sub     ebx, 2          ; Subtraction
    imul    ebx, 4          ; Multiplication
    
    ; Show results
    lea     rcx, [format_out]
    mov     edx, ebx
    call    printf

    jmp     wait_and_return

control_flow_lesson:
    ; Display header
    lea     rcx, [flow_header]
    call    printf

    ; Demonstrate comparisons
    mov     eax, 10
    cmp     eax, 5
    jg      .greater
    
.less:
    mov     ebx, 0
    jmp     .done
    
.greater:
    mov     ebx, 1

.done:
    lea     rcx, [format_out]
    mov     edx, ebx
    call    printf

    jmp     wait_and_return

stack_lesson:
    ; Display header
    lea     rcx, [stack_header]
    call    printf

    ; Demonstrate stack operations
    push    1234
    push    5678
    pop     rax
    pop     rbx
    
    lea     rcx, [format_out]
    mov     edx, eax
    call    printf

    jmp     wait_and_return

arrays_lesson:
    ; Display header
    lea     rcx, [array_header]
    call    printf

    ; Demonstrate array operations
    mov     ecx, [demo_size]    ; Loop counter
    xor     eax, eax            ; Sum
    xor     edx, edx            ; Index
    
.sum_loop:
    add     eax, [demo_array + edx*4]
    inc     edx
    loop    .sum_loop
    
    ; Show sum
    lea     rcx, [format_out]
    mov     edx, eax
    call    printf

    jmp     wait_and_return

functions_lesson:
    ; Display header
    lea     rcx, [func_header]
    call    printf

    ; Call a function
    mov     ecx, 5
    call    factorial
    
    ; Show result
    lea     rcx, [format_out]
    mov     edx, eax
    call    printf

    jmp     wait_and_return

bits_lesson:
    ; Display header
    lea     rcx, [bit_header]
    call    printf

    ; Demonstrate bit operations
    mov     eax, 5          ; 0101 binary
    shl     eax, 1          ; Shift left (multiply by 2)
    shr     eax, 1          ; Shift right (divide by 2)
    not     eax             ; Bitwise NOT
    mov     ebx, 3          ; 0011 binary
    and     eax, ebx        ; Bitwise AND
    
    ; Show result
    lea     rcx, [format_hex]
    mov     edx, eax
    call    printf

    jmp     wait_and_return

wait_and_return:
    ; Display press key message
    lea     rcx, [press_key]
    call    printf
    
    ; Wait for Enter
    call    getchar
    
    jmp     menu_loop

program_exit:
    xor     eax, eax
    leave
    ret

; Helper function for factorial calculation
factorial:
    push    rbp
    mov     rbp, rsp
    
    cmp     ecx, 1
    jle     .base_case
    
    push    rcx
    dec     ecx
    call    factorial
    pop     rcx
    imul    eax, ecx
    jmp     .done
    
.base_case:
    mov     eax, 1
    
.done:
    leave
    ret