module execute_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,
    input  wire [31:0] imm,
    input  wire [31:0] pc_i,
    input  wire [4:0]  rd_i,
    input  wire        reg_write_i,
    input  wire        mem_read_i,
    input  wire        mem_write_i,
    input  wire [4:0]  alu_op_i,
    input  wire [1:0]  alu_src_a_i,
    input  wire [1:0]  alu_src_b_i,
    input  wire        branch_i,
    input  wire        jump_i,
    input  wire [2:0]  branch_op_i,
    input  wire [31:0] forward_rs1,
    input  wire [31:0] forward_rs2,
    input  wire        predict_taken,
    output wire [31:0] alu_result_o,
    output wire        zero_o,
    output wire [31:0] rs2_data_o,
    output wire [4:0]  rd_o,
    output wire        reg_write_o,
    output wire        mem_read_o,
    output wire        mem_write_o,
    output wire        branch_taken_o,
    output wire        branch_mispredict_o,
    output wire [31:0] pc_next_o
);

    wire [31:0] alu_a, alu_b;
    wire [31:0] alu_result;
    wire        alu_zero;
    
    // ALU Input Muxes
    assign alu_a = (alu_src_a_i == 2'b01) ? pc_i :
                   (alu_src_a_i == 2'b10) ? imm :
                   forward_rs1;
                   
    assign alu_b = (alu_src_b_i == 2'b01) ? imm : forward_rs2;
    
    // ALU
    alu alu_inst (
        .a      (alu_a),
        .b      (alu_b),
        .op     (alu_op_i),
        .result (alu_result),
        .zero   (alu_zero),
        .carry_out(),
        .overflow()
    );
    
    // Actual Branch Decision
    wire branch_taken;
    assign branch_taken = branch_i && (
        (branch_op_i == 3'b000 && alu_zero) ||
        (branch_op_i == 3'b001 && ~alu_zero)
    );
    
    // Branch Misprediction Detection
    assign branch_mispredict_o = branch_i && (predict_taken != branch_taken);
    
    // Outputs
    assign alu_result_o = alu_result;
    assign zero_o = alu_zero;
    assign rs2_data_o = forward_rs2;
    assign rd_o = rd_i;
    assign reg_write_o = reg_write_i;
    assign mem_read_o = mem_read_i;
    assign mem_write_o = mem_write_i;
    assign branch_taken_o = branch_taken;
    
    // PC Next: Use prediction for fetch, actual for resolution
    assign pc_next_o = branch_taken ? (pc_i + imm) : (pc_i + 32'h4);

endmodule