# RISC-V 32-bit Processor Core with M Extension

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Verilog](https://img.shields.io/badge/Verilog-RTL-blue)](https://www.verilog.com/)
[![RISC-V](https://img.shields.io/badge/RISC-V-RV32IM-green)](https://riscv.org/)
[![Simulation](https://img.shields.io/badge/Simulation-Icarus-orange)](https://iverilog.icarus.com/)
[![Waveforms](https://img.shields.io/badge/Waveforms-GTKWave-red)](http://gtkwave.sourceforge.net/)

---

## 📋 Overview

A **fully functional 32-bit RISC-V processor core** implementing the **RV32I base instruction set** with **M Extension** (Multiply/Divide). Designed with a **5-stage pipeline** and comprehensive verification infrastructure.

This project demonstrates expertise in:
- ✅ **Digital Design** (Verilog RTL)
- ✅ **Computer Architecture** (5-stage pipeline)
- ✅ **Verification** (Self-checking testbench)
- ✅ **Hardware Design** (Synthesizable code)

---

## 🎯 Key Features

| Feature | Description |
|---------|-------------|
| **ISA** | RV32I Base + M Extension (MUL, DIV) |
| **Pipeline** | 5-stage (Fetch, Decode, Execute, Memory, Writeback) |
| **Hazard Handling** | Data forwarding + Stall logic |
| **Register File** | 32 x 32-bit (x0 hardwired to zero) |
| **ALU** | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU, MUL, DIV |
| **Immediate Types** | I, S, B, U, J formats |
| **Verification** | Self-checking testbench with 4+ test programs |
| **Waveform Support** | VCD output for GTKWave |

---

## 🏗️ Architecture
