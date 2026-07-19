# RISC-V Test Program
# Test: ADD and SUB operations with data memory

.section .text
.global _start

_start:
    # Initialize registers
    li   x5, 5              # x5 = 5
    li   x6, 3              # x6 = 3
    
    # Addition test
    add  x7, x5, x6        # x7 = 8 (5 + 3)
    addi x8, x7, 2         # x8 = 10 (8 + 2)
    
    # Subtraction test
    sub  x9, x8, x5        # x9 = 5 (10 - 5)
    
    # Store results in data memory
    la   x10, test_data    # x10 = address of test_data
    sw   x8, 0(x10)        # store 10
    sw   x9, 4(x10)        # store 5
    
    # Load and verify
    lw   x11, 0(x10)       # x11 = 10
    lw   x12, 4(x10)       # x12 = 5
    
    # Branch test
    bne  x11, x8, error    # Should not branch
    beq  x12, x9, done     # Should branch to done
    
error:
    li   x13, 1            # Error flag
    j    halt

done:
    li   x13, 0            # Success flag
    halt:
    nop
    nop
    j    halt

.section .data
test_data:
    .word 0
    .word 0