# RISC-V Processor Architecture

## 5-Stage Pipeline Design

### Stage 1: IF (Instruction Fetch)
- PC → Instruction Memory → Instruction
- PC = PC + 4

### Stage 2: ID (Instruction Decode)
- Decode Instruction → Control Signals
- Read Register File (rs1, rs2)
- Generate Immediate

### Stage 3: EX (Execute)
- ALU Operations (ADD, SUB, MUL, DIV, etc.)
- Branch/Jump Target Calculation

### Stage 4: MEM (Memory)
- Load/Store Operations
- Data Memory Access

### Stage 5: WB (Writeback)
- Write Result to Register File

## Features
- 32-bit RISC-V RV32I + M Extension
- MUL, DIV, ADD, SUB, AND, OR, XOR
- 32 x 32-bit Register File
- Self-Checking Testbench