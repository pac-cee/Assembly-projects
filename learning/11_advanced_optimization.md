# 11. Advanced Optimization Techniques in x86-64 Assembly

## Understanding CPU Pipelines

### Pipeline Stages in Modern CPUs
1. Fetch
2. Decode
3. Rename (Register renaming)
4. Schedule
5. Execute
6. Retire

### Instruction-Level Parallelism (ILP)
- Superscalar execution
- Out-of-order execution
- Speculative execution

## Microarchitecture-Specific Optimization

### Identifying CPU Features
```assembly
; Check for CPU features using CPUID
check_avx2:
    mov eax, 7
    xor ecx, ecx
    cpuid
    test ebx, (1 << 5)  ; AVX2
    jz no_avx2
    ; AVX2 available
    
; Check for AVX-512
check_avx512:
    mov eax, 7
    xor ecx, ecx
    cpuid
    test ebx, (1 << 16)  ; AVX-512F
    jz no_avx512
    ; AVX-512 available
```

## Data Alignment

### Cache Line Alignment
```assembly
section .data
    align 64      ; Align to cache line (64 bytes)
    my_data: 
        times 64 db 0

section .bss
    align 64
    buffer: resb 4096
```

### Structure Packing
```c
// Before optimization
struct unoptimized {
    char a;     // 1 byte + 7 padding
    double b;   // 8 bytes
    int c;      // 4 bytes + 4 padding
};              // Total: 24 bytes

// After optimization
struct optimized {
    double b;   // 8 bytes
    int c;      // 4 bytes
    char a;     // 1 byte + 3 padding
};              // Total: 16 bytes
```

## Branch Optimization

### Branch Prediction Hints
```assembly
; Unlikely branch (hint to CPU)
cmp rax, rbx
jne .unlikely_branch  ; 2C (not taken) 1D (taken)

; Likely path

.unlikely_branch:
; Less frequent code
```

### Branchless Programming
```c
// Branch version
int max(int a, int b) {
    return (a > b) ? a : b;
}

// Branchless version
int max_branchless(int a, int b) {
    int diff = a - b;
    int mask = diff >> 31;
    return a + (diff & mask);
}
```

## SIMD Optimization

### AVX2 Example: Vector Addition
```assembly
; void vector_add(double *a, double *b, double *c, size_t n)
vector_add:
    test rcx, rcx
    jz .done
    
    vxorpd ymm0, ymm0, ymm0
    
.loop:
    vmovapd ymm1, [rdi]      ; Load a[0:3]
    vaddpd ymm1, ymm1, [rsi]  ; Add b[0:3]
    vmovapd [rdx], ymm1       ; Store to c[0:3]
    
    add rdi, 32
    add rsi, 32
    add rdx, 32
    sub rcx, 4
    jnz .loop
    
    vzeroupper
.done:
    ret
```

## Memory Optimization

### Prefetching
```assembly
; Prefetch data for next iteration
prefetchnta [rdi + 4096]  ; Non-temporal prefetch
prefetcht0 [rdi + 2048]   ; All cache levels
prefetcht1 [rdi + 3072]   ; Higher cache levels
prefetcht2 [rdi + 1024]   ; L2 and up
```

### Non-Temporal Stores
```assembly
; Use non-temporal stores for streaming data
movntps [rdi], xmm0  ; Bypass cache
sfence               ; Ensure visibility
```

## Loop Optimization

### Loop Unrolling
```assembly
; Before unrolling
mov rcx, 1000
.loop:
    ; Loop body
    dec rcx
    jnz .loop

; After unrolling (factor of 4)
mov rcx, 250  ; 1000/4
.unrolled_loop:
    ; Loop body
    ; Loop body
    ; Loop body
    ; Loop body
    dec rcx
    jnz .unrolled_loop
```

### Loop Blocking (Tiling)
```c
// Before blocking
for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
        C[i][j] = 0;
        for (int k = 0; k < N; k++) {
            C[i][j] += A[i][k] * B[k][j];
        }
    }
}

// After blocking (block size B)
for (int ii = 0; ii < N; ii += B) {
    for (int jj = 0; jj < N; jj += B) {
        for (int kk = 0; kk < N; kk += B) {
            for (int i = ii; i < ii + B; i++) {
                for (int j = jj; j < jj + B; j++) {
                    for (int k = kk; k < kk + B; k++) {
                        C[i][j] += A[i][k] * B[k][j];
                    }
                }
            }
        }
    }
}
```

## Instruction Selection

### Using LEA for Arithmetic
```assembly
; Less efficient
mov rax, rdx
shl rax, 2
add rax, rdx
add rax, 10

; More efficient
lea rax, [rdx + rdx*4 + 10]
```

### Avoiding Partial Register Stalls
```assembly
; Causes partial register stall
mov al, [rsi]
mov [rdi], al

; Better - use full register
movzx eax, byte [rsi]
mov [rdi], al
```

## Advanced SIMD Techniques

### Horizontal Operations
```assembly
; Horizontal sum of 4 floats in xmm0
haddps xmm0, xmm0    ; [a+b, c+d, a+b, c+d]
haddps xmm0, xmm0    ; [a+b+c+d, a+b+c+d, ...]

; AVX version
vhaddps ymm0, ymm0, ymm0
vhaddps ymm0, ymm0, ymm0
vextractf128 xmm1, ymm0, 1
addps xmm0, xmm1
```

### Fused Multiply-Add (FMA)
```assembly
; c = a * b + c
; AVX2 version
vmulpd ymm0, ymm1, ymm2
vaddpd ymm0, ymm0, ymm3

; FMA version (single instruction)
vfmadd213pd ymm0, ymm1, ymm2  ; ymm0 = ymm1 * ymm0 + ymm2
```

## Memory Access Patterns

### Structure of Arrays (SoA) vs Array of Structures (AoS)
```c
// Array of Structures (AoS)
struct Point {
    float x, y, z;
} points[1000];

// Structure of Arrays (SoA)
struct Points {
    float x[1000];
    float y[1000];
    float z[1000];
} points;
```

### Non-Temporal Hints
```assembly
; Use non-temporal stores for streaming writes
movntps [rdi], xmm0
movntps [rdi+16], xmm1
sfence  ; Ensure all non-temporal stores are visible
```

## Performance Measurement

### Using RDTSC
```assembly
; Get CPU timestamp counter
rdtsc
shl rdx, 32
or rax, rdx
mov [start_time], rax

; Code to measure

rdtsc
shl rdx, 32
or rax, rdx
sub rax, [start_time]
; rax now contains cycle count
```

### Performance Counters
- Use `perf` on Linux or VTune on Windows
- Measure:
  - Cache misses
  - Branch mispredictions
  - Instructions per cycle (IPC)

## Exercises

1. **Matrix Multiplication**
   - Implement different versions (naive, blocked, SIMD)
   - Compare performance

2. **String Search**
   - Optimize strstr() using SIMD
   - Compare with standard library

3. **Histogram**
   - Create a histogram of byte values
   - Optimize with SIMD and prefetching

## Best Practices

1. **Profile First**
   - Use profiling tools to find bottlenecks
   - Optimize the critical path

2. **Algorithm First**
   - Choose the right algorithm before micro-optimizing
   - Consider time/space complexity

3. **Readability**
   - Document optimizations
   - Keep readable versions for debugging

4. **Testing**
   - Verify optimizations don't break functionality
   - Test with various input sizes

In the next lesson, we'll explore modern x86 extensions and their applications.
