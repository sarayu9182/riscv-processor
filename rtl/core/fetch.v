// Fetch Stage

module fetch_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] pc_i,
    input  wire [31:0] pc_next,
    output wire [31:0] instr_o,
    output wire [31:0] pc_o
);
    assign instr_o = 32'h00000013;  // NOP
    assign pc_o = pc_i;
endmodule