module decode_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,
    input  wire        flush,
    input  wire [31:0] instr_i,
    input  wire [31:0] pc_i,
    input  wire [31:0] rs1_data_i,
    input  wire [31:0] rs2_data_i,
    output wire [31:0] imm_o,
    output wire [4:0]  rd_o,
    output wire        reg_write_o,
    output wire        mem_read_o,
    output wire        mem_write_o,
    output wire [4:0]  alu_op_o,
    output wire [1:0]  alu_src_a_o,
    output wire [1:0]  alu_src_b_o,
    output wire        branch_o,
    output wire        jump_o,
    output wire [2:0]  branch_op_o,
    output wire [31:0] rs1_data_o,
    output wire [31:0] rs2_data_o,
    output wire [31:0] pc_o
);

    // Pipeline registers
    reg [31:0] imm_reg, rs1_reg, rs2_reg, pc_reg;
    reg [4:0]  rd_reg;
    reg        reg_write_reg, mem_read_reg, mem_write_reg;
    reg [4:0]  alu_op_reg;
    reg [1:0]  alu_src_a_reg, alu_src_b_reg;
    reg        branch_reg, jump_reg;
    reg [2:0]  branch_op_reg;
    
    // Internal wires
    wire [31:0] imm;
    wire [4:0]  rd;
    wire        reg_write, mem_read, mem_write;
    wire [4:0]  alu_op;
    wire [1:0]  alu_src_a, alu_src_b;
    wire        branch, jump;
    wire [2:0]  branch_op;
    wire [2:0]  imm_type;
    
    // Immediate Generation
    wire [31:0] imm_i = {{20{instr_i[31]}}, instr_i[31:20]};
    wire [31:0] imm_s = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
    wire [31:0] imm_b = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
    wire [31:0] imm_u = {instr_i[31:12], 12'h0};
    wire [31:0] imm_j = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
    
    wire [6:0] opcode = instr_i[6:0];
    wire [2:0] funct3 = instr_i[14:12];
    wire [6:0] funct7 = instr_i[31:25];
    wire [4:0] rs1 = instr_i[19:15];
    wire [4:0] rs2 = instr_i[24:20];
    assign rd = instr_i[11:7];
    
    // Immediate selection
    always @(*) begin
        case (opcode)
            7'b0000011: imm = imm_i;
            7'b0100011: imm = imm_s;
            7'b0010011: imm = imm_i;
            7'b0110011: imm = 32'h0;
            7'b1100011: imm = imm_b;
            7'b1101111: imm = imm_j;
            7'b0110111: imm = imm_u;
            7'b0010111: imm = imm_u;
            default: imm = 32'h0;
        endcase
    end
    
    assign imm_type = (opcode == 7'b0000011 || opcode == 7'b0010011 || opcode == 7'b1100111) ? 3'b000 :
                      (opcode == 7'b0100011) ? 3'b001 :
                      (opcode == 7'b1100011) ? 3'b010 :
                      (opcode == 7'b0110111 || opcode == 7'b0010111) ? 3'b011 :
                      (opcode == 7'b1101111) ? 3'b100 :
                      3'b000;
    
    // Control Unit
    control_unit ctrl (
        .opcode     (opcode),
        .funct3     (funct3),
        .funct7     (funct7),
        .reg_write  (reg_write),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .alu_op     (alu_op),
        .alu_src_a  (alu_src_a),
        .alu_src_b  (alu_src_b),
        .imm_type   (imm_type),
        .branch     (branch),
        .jump       (jump),
        .jump_reg   (),
        .branch_op  (branch_op)
    );
    
    // Pipeline registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            imm_reg <= 32'h0;
            rs1_reg <= 32'h0;
            rs2_reg <= 32'h0;
            pc_reg <= 32'h0;
            rd_reg <= 5'h0;
            reg_write_reg <= 1'b0;
            mem_read_reg <= 1'b0;
            mem_write_reg <= 1'b0;
            alu_op_reg <= 5'h0;
            alu_src_a_reg <= 2'h0;
            alu_src_b_reg <= 2'h0;
            branch_reg <= 1'b0;
            jump_reg <= 1'b0;
            branch_op_reg <= 3'h0;
        end else if (!stall) begin
            imm_reg <= imm;
            rs1_reg <= rs1_data_i;
            rs2_reg <= rs2_data_i;
            pc_reg <= pc_i;
            rd_reg <= rd;
            reg_write_reg <= reg_write;
            mem_read_reg <= mem_read;
            mem_write_reg <= mem_write;
            alu_op_reg <= alu_op;
            alu_src_a_reg <= alu_src_a;
            alu_src_b_reg <= alu_src_b;
            branch_reg <= branch;
            jump_reg <= jump;
            branch_op_reg <= branch_op;
        end
    end
    
    // Outputs
    assign imm_o = imm_reg;
    assign rd_o = rd_reg;
    assign reg_write_o = reg_write_reg;
    assign mem_read_o = mem_read_reg;
    assign mem_write_o = mem_write_reg;
    assign alu_op_o = alu_op_reg;
    assign alu_src_a_o = alu_src_a_reg;
    assign alu_src_b_o = alu_src_b_reg;
    assign branch_o = branch_reg;
    assign jump_o = jump_reg;
    assign branch_op_o = branch_op_reg;
    assign rs1_data_o = rs1_reg;
    assign rs2_data_o = rs2_reg;
    assign pc_o = pc_reg;

endmodule