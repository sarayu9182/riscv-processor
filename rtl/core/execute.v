module execute_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] pc_i,
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,
    input  wire [31:0] imm,
    input  wire [3:0]  alu_op,
    input  wire [1:0]  alu_src_a,
    input  wire [1:0]  alu_src_b,
    output wire [31:0] alu_out,
    output wire        zero,
    output wire        branch_taken,
    output wire [31:0] next_pc
);

    wire [31:0] alu_a, alu_b;
    wire [31:0] alu_result;
    wire        alu_zero;
    
    alu alu_inst (
        .a      (alu_a),
        .b      (alu_b),
        .op     ({1'b0, alu_op}),
        .result (alu_result),
        .zero   (alu_zero),
        .carry_out(),
        .overflow()
    );
    
    assign alu_a = (alu_src_a == 2'b01) ? pc_i :
                   (alu_src_a == 2'b10) ? imm :
                   rs1_data;
                   
    assign alu_b = (alu_src_b == 2'b01) ? imm : rs2_data;
    
    assign alu_out = alu_result;
    assign zero = alu_zero;
    assign next_pc = pc_i + 32'h4;
    assign branch_taken = 1'b0;

endmodule