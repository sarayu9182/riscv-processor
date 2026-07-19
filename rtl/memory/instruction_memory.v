// Instruction Memory
// Simple ROM for RISC-V instructions

module instruction_memory (
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    // 1KB instruction memory
    reg [31:0] mem [0:255];
    
    // Initialize with default (NOP instructions)
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'h00000013;  // NOP
    end
    
    // Read instruction
    assign instr = mem[addr[9:2]];
    
endmodule