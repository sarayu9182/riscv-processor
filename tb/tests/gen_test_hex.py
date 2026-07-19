#!/usr/bin/env python3
"""
RISC-V Test Program Generator
Generates hex files for processor testing
Supports RV32I Base + M Extension (MUL, DIV)
"""

def generate_add_test():
    """Generate ADD test program"""
    instructions = [
        "00000513",  # li a0, 0
        "00100613",  # li a2, 1
        "00C60633",  # add a2, a2, a2
        "00200813",  # li a6, 2
        "405008B3",  # sub a1, a0, a1
        "00102823",  # sw a1, 0(a0)
        "00102C23",  # sw a1, 4(a0)
        "00002A83",  # lw a5, 0(a0)
        "00402B03",  # lw a6, 4(a0)
        "00000013",  # nop
        "0000006F",  # j 0 (infinite loop)
    ]
    return instructions

def generate_sub_test():
    """Generate SUB test program"""
    instructions = [
        "00500513",  # li a0, 5
        "00300593",  # li a1, 3
        "40B50533",  # sub a0, a0, a1 (a0 = 2)
        "00102823",  # sw a0, 0(a0) store result at addr 0
        "00000013",  # nop
        "0000006F",  # j 0 (infinite loop)
    ]
    return instructions

def generate_mul_test():
    """Generate MUL test program (M Extension)"""
    instructions = [
        "00500513",  # li a0, 5
        "00300593",  # li a1, 3
        "00B50533",  # mul a0, a0, a1 (a0 = 15)
        "00102823",  # sw a0, 0(a0) store result at addr 0
        "00000013",  # nop
        "0000006F",  # j 0 (infinite loop)
    ]
    return instructions

def generate_div_test():
    """Generate DIV test program (M Extension)"""
    instructions = [
        "00A00513",  # li a0, 10
        "00200593",  # li a1, 2
        "02B55533",  # div a0, a0, a1 (a0 = 5)
        "00102823",  # sw a0, 0(a0) store result at addr 0
        "00000013",  # nop
        "0000006F",  # j 0 (infinite loop)
    ]
    return instructions

def generate_memory_test():
    """Generate Memory Load/Store test program"""
    instructions = [
        "00500513",  # li a0, 5
        "00A00593",  # li a1, 10
        "00B52023",  # sw a1, 0(a0) store 10 at address 5
        "00052503",  # lw a0, 0(a0) load from address 5 into a0
        "00102823",  # sw a0, 0(a0) store result at addr 0
        "00000013",  # nop
        "0000006F",  # j 0 (infinite loop)
    ]
    return instructions

def generate_branch_test():
    """Generate Branch test program"""
    instructions = [
        "00500513",  # li a0, 5
        "00500593",  # li a1, 5
        "00B50463",  # beq a0, a1, +8 (branch to label)
        "00000013",  # nop (skipped if branch taken)
        "00A00513",  # li a0, 10 (executed if branch not taken)
        "00102823",  # sw a0, 0(a0) store result at addr 0
        "00000013",  # nop
        "0000006F",  # j 0 (infinite loop)
    ]
    return instructions

def generate_alu_test():
    """Generate Comprehensive ALU test program"""
    instructions = [
        # AND test
        "00F00513",  # li a0, 15 (0x0F)
        "0FF00593",  # li a1, 255 (0xFF)
        "00B57533",  # and a0, a0, a1 (a0 = 15)
        "00102823",  # sw a0, 0(a0) store result at addr 0
        
        # OR test
        "00F00513",  # li a0, 15 (0x0F)
        "0F000593",  # li a1, 240 (0xF0)
        "00B56533",  # or a0, a0, a1 (a0 = 255)
        "00102C23",  # sw a0, 8(a0) store result at addr 8
        
        # XOR test
        "00F00513",  # li a0, 15 (0x0F)
        "0FF00593",  # li a1, 255 (0xFF)
        "00B54533",  # xor a0, a0, a1 (a0 = 240)
        "00103023",  # sw a0, 16(a0) store result at addr 16
        
        # SLT test
        "00500513",  # li a0, 5
        "00300593",  # li a1, 3
        "00B52533",  # slt a0, a0, a1 (a0 = 0, 5 < 3 is false)
        "00103423",  # sw a0, 24(a0) store result at addr 24
        
        # SLTU test
        "00500513",  # li a0, 5
        "00300593",  # li a1, 3
        "00B53533",  # sltu a0, a0, a1 (a0 = 0)
        "00103823",  # sw a0, 32(a0) store result at addr 32
        
        "00000013",  # nop
        "0000006F",  # j 0 (infinite loop)
    ]
    return instructions

def generate_shift_test():
    """Generate Shift Operations test program"""
    instructions = [
        # SLL (Shift Left Logical)
        "00500513",  # li a0, 5
        "00200593",  # li a1, 2
        "00B51533",  # sll a0, a0, a1 (a0 = 20)
        "00102823",  # sw a0, 0(a0) store result at addr 0
        
        # SRL (Shift Right Logical)
        "01400513",  # li a0, 20
        "00200593",  # li a1, 2
        "00B55533",  # srl a0, a0, a1 (a0 = 5)
        "00102C23",  # sw a0, 8(a0) store result at addr 8
        
        # SRA (Shift Right Arithmetic)
        "FFE00513",  # li a0, -2 (0xFFFFFFFE)
        "00100593",  # li a1, 1
        "00B55533",  # sra a0, a0, a1 (a0 = -1)
        "00103023",  # sw a0, 16(a0) store result at addr 16
        
        "00000013",  # nop
        "0000006F",  # j 0 (infinite loop)
    ]
    return instructions

def generate_mulh_test():
    """Generate MULH (Multiply High) test program (M Extension)"""
    instructions = [
        # MULH - Signed High 32 bits
        "7FFF0513",  # li a0, 0x7FFF (large positive)
        "7FFF0593",  # li a1, 0x7FFF
        "00B51533",  # mulh a0, a0, a1 (high 32 bits)
        "00102823",  # sw a0, 0(a0) store result at addr 0
        
        # MULHU - Unsigned High 32 bits
        "FFFF0513",  # li a0, 0xFFFF
        "FFFF0593",  # li a1, 0xFFFF
        "00B53533",  # mulhu a0, a0, a1 (high 32 bits)
        "00102C23",  # sw a0, 8(a0) store result at addr 8
        
        "00000013",  # nop
        "0000006F",  # j 0 (infinite loop)
    ]
    return instructions

def generate_full_test():
    """Generate Full Comprehensive Test Program"""
    instructions = [
        # Initialize values
        "00500513",  # li a0, 5
        "00300593",  # li a1, 3
        
        # ADD: 5 + 3 = 8
        "00B50533",  # add a0, a0, a1
        "00102823",  # sw a0, 0(a0) store at addr 0
        
        # SUB: 8 - 3 = 5
        "40350533",  # sub a0, a0, a1
        "00102C23",  # sw a0, 8(a0) store at addr 8
        
        # MUL: 5 * 3 = 15
        "00300593",  # li a1, 3
        "00B50533",  # mul a0, a0, a1
        "00103023",  # sw a0, 16(a0) store at addr 16
        
        # DIV: 15 / 3 = 5
        "00300593",  # li a1, 3
        "02B55533",  # div a0, a0, a1
        "00103423",  # sw a0, 24(a0) store at addr 24
        
        # AND: 5 & 3 = 1
        "00500513",  # li a0, 5
        "00300593",  # li a1, 3
        "00B57533",  # and a0, a0, a1
        "00103823",  # sw a0, 32(a0) store at addr 32
        
        # OR: 5 | 3 = 7
        "00500513",  # li a0, 5
        "00300593",  # li a1, 3
        "00B56533",  # or a0, a0, a1
        "00103C23",  # sw a0, 40(a0) store at addr 40
        
        "00000013",  # nop
        "0000006F",  # j 0 (infinite loop)
    ]
    return instructions

def write_hex_file(filename, instructions, fill_to=1024):
    """Write instructions to hex file with padding"""
    with open(filename, 'w') as f:
        # Write instructions
        for instr in instructions:
            f.write(instr + '\n')
        
        # Fill remaining with NOPs
        current_count = len(instructions)
        if current_count < fill_to:
            for _ in range(fill_to - current_count):
                f.write("00000013\n")  # NOP instruction
    
    print(f"Generated {filename} with {len(instructions)} instructions")

def main():
    """Generate all test hex files"""
    print("\n" + "="*50)
    print("RISC-V TEST PROGRAM GENERATOR")
    print("RV32I Base + M Extension (MUL, DIV)")
    print("="*50 + "\n")
    
    # Generate all test hex files
    print("Generating test programs...\n")
    
    write_hex_file("rv32ui-p-add.hex", generate_add_test())
    write_hex_file("rv32ui-p-sub.hex", generate_sub_test())
    write_hex_file("rv32ui-p-mul.hex", generate_mul_test())
    write_hex_file("rv32ui-p-div.hex", generate_div_test())
    write_hex_file("rv32ui-p-memory.hex", generate_memory_test())
    write_hex_file("rv32ui-p-branch.hex", generate_branch_test())
    write_hex_file("rv32ui-p-alu.hex", generate_alu_test())
    write_hex_file("rv32ui-p-shift.hex", generate_shift_test())
    write_hex_file("rv32ui-p-mulh.hex", generate_mulh_test())
    write_hex_file("rv32ui-p-full.hex", generate_full_test())
    
    print("\n" + "="*50)
    print("✅ All test programs generated successfully!")
    print("📁 Location: tb/tests/")
    print("📊 Total test files: 10")
    print("="*50 + "\n")

if __name__ == "__main__":
    main()