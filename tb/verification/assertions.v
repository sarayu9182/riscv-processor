module assertions (
    input wire clk,
    input wire rst_n,
    input wire [31:0] pc,
    input wire [31:0] instr,
    input wire mem_write,
    input wire mem_read
);

    // PC should be 4-byte aligned
    assert property (@(posedge clk) (pc[1:0] == 2'b00))
        else $error("PC misaligned: pc=0x%08h", pc);

    // No simultaneous read and write
    assert property (@(posedge clk) !(mem_read && mem_write))
        else $error("Simultaneous read and write!");

endmodule