# RISC-V Processor Architecture Documentation

## Overview
32-bit RISC-V processor implementing RV32I base instruction set with 5-stage pipeline.

## Pipeline Stages

### 1. Fetch Stage
- Fetches instruction from instruction memory
- Updates Program Counter (PC)
- Handles branch and jump target addresses

### 2. Decode Stage
- Decodes instruction fields
- Reads register file (rs1, rs2)
- Generates immediate values
- Control unit generates control signals

### 3. Execute Stage
- ALU performs arithmetic/logic operations
- Calculates branch targets
- Determines branch conditions
- Hazard detection and forwarding

### 4. Memory Stage
- Accesses data memory for load/store
- Handles memory alignment

### 5. Writeback Stage
- Writes result back to register file
- Selects between ALU result and memory data

## Control Signals

| Signal | Description |
|--------|-------------|
| reg_write | Enable register write |
| mem_read | Enable memory read |
| mem_write | Enable memory write |
| alu_op | ALU operation select |
| alu_src_a | ALU source A select |
| alu_src_b | ALU source B select |
| imm_type | Immediate type (I/S/B/U/J) |
| branch | Branch instruction |
| jump | Jump instruction |
| jump_reg | Register jump |

## Instruction Support

### R-Type (Register)
- ADD, SUB, AND, OR, XOR
- SLL, SRL, SRA
- SLT, SLTU

### I-Type (Immediate)
- ADDI, ORI, XORI, ANDI
- SLLI, SRLI, SRAI
- SLTI, SLTIU
- LW, LH, LHU, LB, LBU
- JALR

### S-Type (Store)
- SW, SH, SB

### B-Type (Branch)
- BEQ, BNE, BLT, BGE, BLTU, BGEU

### U-Type (Upper Immediate)
- LUI, AUIPC

### J-Type (Jump)
- JAL

## Memory Map

| Address Range | Size | Description |
|---------------|------|-------------|
| 0x0000_0000 - 0x0000_0FFF | 4KB | Instruction Memory |
| 0x0000_1000 - 0x0000_1FFF | 4KB | Data Memory |
| 0x0000_2000 - 0xFFFF_FFFF | - | Reserved |

## Verification Strategy

1. **Directed Tests**: Specific instruction tests
2. **Random Tests**: Random instruction sequences
3. **Formal Verification**: Property checking
4. **Coverage Metrics**: Code and functional coverage
5. **Self-Checking**: Automatic result verification

## Performance

- **Clock Speed**: 100MHz (synthesizable)
- **Pipeline Stages**: 5
- **CPI**: ~1.0 (ideal)
- **Area**: ~10K gates

## Future Enhancements

- [ ] Multiply/Divide extension (M)
- [ ] Atomic operations (A)
- [ ] Single-precision FP (F)
- [ ] Double-precision FP (D)
- [ ] Caches (I/D)
- [ ] MMU
- [ ] Debug support