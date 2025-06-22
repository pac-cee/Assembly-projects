# 12. Modern x86 Extensions

## AVX and AVX2 (Advanced Vector Extensions)

### AVX Overview
- 256-bit vector registers (YMM0-YMM15)
- Three-operand non-destructive operations
- New VEX encoding scheme
- Floating-point operations on 256-bit vectors

### Basic AVX Operations
```assembly
; Load 8 single-precision floats
vmovaps ymm0, [rdi]     ; Aligned packed single
vmovups ymm1, [rsi]     ; Unaligned packed single

; Arithmetic operations
vaddps ymm2, ymm0, ymm1  ; Packed single add
vmulps ymm3, ymm0, ymm1  ; Packed single multiply
vsqrtps ymm4, ymm0       ; Packed square root

; Horizontal operations
vhaddps ymm5, ymm0, ymm1  ; Horizontal add

; Fused multiply-add
vfmadd132ps ymm0, ymm1, ymm2  ; ymm0 = ymm0 * ymm2 + ymm1
```

### AVX2 Enhancements
- 256-bit integer operations
- Vector shifts and rotates
- Gather operations
- Fused multiply-add (FMA)

```assembly
; AVX2 integer operations
vpmulld ymm0, ymm1, ymm2    ; 32-bit multiply
vpsllvd ymm1, ymm2, ymm3    ; Variable left shift

; Gather operations
; vpgatherdd ymm0, [rdi + ymm1*4], ymm2
; ymm0[i] = [rdi + ymm1[i]*4] if ymm2[i] < 0
```

## AVX-512 (Advanced Vector Extensions 512)

### Key Features
- 512-bit vector registers (ZMM0-ZMM31)
- 8 additional 64-bit mask registers (k0-k7)
- New instructions for complex operations
- Better support for 64-bit integers

### AVX-512 Code Example
```assembly
; Check for AVX-512 support
mov eax, 7
xor ecx, ecx
cpuid
and ebx, 1<<16  ; Check AVX-512F
jz no_avx512

; AVX-512 operations
vmovaps zmm0, [rdi]            ; Load 16 floats
vaddps zmm1, zmm0, [rsi]       ; Add 16 floats
vsqrtps zmm2, zmm1{k1}{z}      ; Conditional sqrt with mask k1
vscatterdps [r8 + zmm3*4]{k2}, zmm2  ; Scatter with mask k2
```

### AVX-512 Mask Registers
```assembly
; Set mask register k1 where elements > 0
vpcmpgtd k1, zmm0, [zero_vector]

; Zero elements where k1 is not set
vmovaps zmm1{k1}{z}, zmm0

; Merge with destination
vaddps zmm2 {k1}, zmm0, [rsi]  ; Only update where k1 is set
```

## BMI1/BMI2 (Bit Manipulation Instructions)

### BMI1 Instructions
```assembly
; Bit manipulation extensions
blsi rax, rbx      ; Extract lowest set bit: rax = rbx & -rbx
blsmsk rax, rbx    ; Mask from lowest set bit: rax = rbx ^ (rbx - 1)
blsr rax, rbx      ; Reset lowest set bit: rax = rbx & (rbx - 1)

; Population count
popcnt rax, rbx    ; Count set bits in rbx
```

### BMI2 Instructions
```assembly
; Bit field manipulation
pdep rax, rbx, rcx    ; Parallel bits deposit
pext rax, rbx, rcx    ; Parallel bits extract

; Advanced bit manipulation
bzhi rax, rbx, rcx    ; Zero high bits starting at rcx
rorx rax, rbx, 8      ; Rotate right with immediate
```

## TSX (Transactional Synchronization Extensions)

### Hardware Transactional Memory
```assembly
; Transactional region
xbegin .fallback
; Transactional code
mov rax, [shared_var1]
add rax, [shared_var2]
mov [shared_var1], rax
xend
jmp .done

.fallback:
; Fallback path if transaction fails
lock xadd [shared_var1], rdx

.done:
```

## MPX (Memory Protection Extensions)

### Bounds Checking
```assembly
; Initialize bounds
bndmk bnd0, [rdi]      ; Create bounds [rdi, rdi+rsi]
bndstx [bounds], bnd0  ; Store bounds

; Check bounds
bndldx bnd1, [bounds]  ; Load bounds
bndcl bnd1, [r8]       ; Check lower bound
bndcu bnd1, [r8+15]    ; Check upper bound
```

## SHA Extensions

### Hardware-Accelerated Hashing
```assembly
; SHA-1 operations
sha1rnds4 xmm0, xmm1, 0     ; SHA1 round
sha1nexte xmm0, xmm1        ; SHA1 message scheduling
sha1msg1 xmm0, xmm1         ; SHA1 message scheduling
sha1msg2 xmm0, xmm1         ; SHA1 message scheduling

; SHA-256 operations
sha256rnds2 xmm0, xmm1      ; SHA256 round
sha256msg1 xmm0, xmm1       ; SHA256 message scheduling
sha256msg2 xmm0, xmm1       ; SHA256 message scheduling
```

## CLMUL (Carry-Less Multiplication)

### Polynomial Arithmetic
```assembly
; Carry-less multiplication (for cryptography, CRC)
pclmulqdq xmm0, xmm1, 0x00  ; xmm0 = xmm0 * xmm1 (low 64 bits)
pclmulqdq xmm0, xmm1, 0x11  ; xmm0 = xmm0 * xmm1 (high 64 bits)
```

## RDRAND and RDSEED

### Hardware Random Number Generation
```assembly
; Generate random number
mov ecx, 100    ; Maximum retry count
.retry:
    rdrand eax    ; Generate random number in eax
    jc .success   ; CF=1 if random number available
    loop .retry
    ; Fallback to software RNG
.success:
    ; eax contains random number

; RDSEED (higher entropy)
rdseed eax
```

## UMONITOR/UMWAIT/TPAUSE

### Power Management and Waiting
```assembly
; Monitor address for write
lea rdi, [monitor_addr]
xor eax, eax
xor ecx, ecx
xor edx, edx
umonitor rdi

; Wait for write with timeout
mov eax, 1000  ; Timeout in TSC cycles
xor ecx, ecx
xor edx, edx
umwait ecx

; Pause with timeout
tpause ecx, eax, 0  ; ecx=0 (C0.2), eax=timeout
```

## CET (Control-flow Enforcement Technology)

### Shadow Stack and Indirect Branch Tracking
```assembly
; Control-flow enforcement
endbr64           ; Valid indirect branch target

; Shadow stack operations
saveprevssp       ; Save previous shadow stack pointer
rstorssp          // Restore shadow stack pointer
```

## Exercises

1. **SIMD Matrix Multiplication**
   - Implement 4x4 matrix multiplication using AVX2
   - Compare performance with scalar version

2. **String Search with AVX-512**
   - Create a fast string search using AVX-512 mask registers
   - Handle different string lengths and alignments

3. **Bit Manipulation**
   - Implement various bit manipulation algorithms using BMI1/2
   - Create a bitset with fast population count

4. **Cryptographic Hash**
   - Implement SHA-256 using the SHA extensions
   - Compare performance with software implementation

## Best Practices

1. **Feature Detection**
   - Always check CPU features before using extensions
   - Provide fallback implementations

2. **Performance Considerations**
   - Be aware of frequency scaling with wide vector units
   - Consider memory bandwidth limitations

3. **Compatibility**
   - Document required CPU features
   - Use runtime dispatch when possible

4. **Debugging**
   - Test with different CPU models
   - Use performance counters to identify bottlenecks

In the next lesson, we'll explore real-world projects and applications of assembly programming.
