module decode_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] instr_i,
    input  wire [31:0] pc_i,
    input  wire [31:0] rs1_data_i,
    input  wire [31:0] rs2_data_i,
    output wire [31:0] imm_o,
    output wire [4:0]  rs1_addr_o,
    output wire [4:0]  rs2_addr_o,
    output wire [4:0]  rd_addr_o,
    output wire        reg_write_o,
    output wire        mem_read_o,
    output wire        mem_write_o,
    output wire [3:0]  alu_op_o,
    output wire [1:0]  alu_src_a_o,
    output wire [1:0]  alu_src_b_o,
    output wire        branch_o,
    output wire        jump_o,
    output wire        jump_reg_o,
    output wire [2:0]  branch_op_o,
    output wire [2:0]  imm_type_o
);

    wire        reg_write, mem_read, mem_write;
    wire [3:0]  alu_op;
    wire [1:0]  alu_src_a, alu_src_b;
    wire [2:0]  imm_type;
    wire        branch, jump, jump_reg;
    wire [2:0]  branch_op;
    
    immediate_gen imm_gen (
        .instr      (instr_i),
        .imm_type   (imm_type),
        .imm        (imm_o)
    );
    
    control_unit ctrl (
        .opcode     (instr_i[6:0]),
        .funct3     (instr_i[14:12]),
        .funct7     (instr_i[31:25]),
        .reg_write  (reg_write),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .alu_op     (alu_op),
        .alu_src_a  (alu_src_a),
        .alu_src_b  (alu_src_b),
        .imm_type   (imm_type),
        .branch     (branch),
        .jump       (jump),
        .jump_reg   (jump_reg),
        .branch_op  (branch_op)
    );
    
    assign rs1_addr_o = instr_i[19:15];
    assign rs2_addr_o = instr_i[24:20];
    assign rd_addr_o = instr_i[11:7];
    assign reg_write_o = reg_write;
    assign mem_read_o = mem_read;
    assign mem_write_o = mem_write;
    assign alu_op_o = alu_op;
    assign alu_src_a_o = alu_src_a;
    assign alu_src_b_o = alu_src_b;
    assign branch_o = branch;
    assign jump_o = jump;
    assign jump_reg_o = jump_reg;
    assign branch_op_o = branch_op;
    assign imm_type_o = imm_type;

endmodule