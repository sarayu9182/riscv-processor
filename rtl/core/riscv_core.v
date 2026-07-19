module riscv_core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] instr_i,
    input  wire [31:0] data_i,
    output wire [31:0] pc_o,
    output wire [31:0] addr_o,
    output wire [31:0] data_o,
    output wire        mem_write_o,
    output wire        mem_read_o,
    output wire        halt_o
);

    reg [31:0] pc;
    reg [31:0] instr_reg;
    
    wire [31:0] pc_plus_4;
    wire [31:0] imm;
    wire [2:0]  imm_type;
    
    wire        reg_write;
    wire        mem_read;
    wire        mem_write;
    wire [4:0]  alu_op;
    wire [1:0]  alu_src_a;
    wire [1:0]  alu_src_b;
    wire        branch;
    wire        jump;
    wire        jump_reg;
    wire [2:0]  branch_op;
    
    wire [4:0]  rs1 = instr_reg[19:15];
    wire [4:0]  rs2 = instr_reg[24:20];
    wire [4:0]  rd = instr_reg[11:7];
    wire [6:0]  opcode = instr_reg[6:0];
    wire [2:0]  funct3 = instr_reg[14:12];
    wire [6:0]  funct7 = instr_reg[31:25];
    
    reg [31:0] reg_file [0:31];
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] alu_result;
    wire        alu_zero;
    wire        branch_taken;
    wire [31:0] next_pc;
    
    assign pc_plus_4 = pc + 32'h4;
    assign pc_o = pc;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0;
            instr_reg <= 32'h0;
        end else begin
            pc <= next_pc;
            instr_reg <= instr_i;
        end
    end
    
    wire [31:0] imm_i = {{20{instr_reg[31]}}, instr_reg[31:20]};
    wire [31:0] imm_s = {{20{instr_reg[31]}}, instr_reg[31:25], instr_reg[11:7]};
    wire [31:0] imm_b = {{20{instr_reg[31]}}, instr_reg[7], instr_reg[30:25], instr_reg[11:8], 1'b0};
    wire [31:0] imm_u = {instr_reg[31:12], 12'h0};
    wire [31:0] imm_j = {{12{instr_reg[31]}}, instr_reg[19:12], instr_reg[20], instr_reg[30:21], 1'b0};
    
    assign imm = (opcode == 7'b0000011 || opcode == 7'b0010011 || opcode == 7'b1100111) ? imm_i :
                 (opcode == 7'b0100011) ? imm_s :
                 (opcode == 7'b1100011) ? imm_b :
                 (opcode == 7'b0110111 || opcode == 7'b0010111) ? imm_u :
                 (opcode == 7'b1101111) ? imm_j :
                 32'h0;
    
    assign imm_type = (opcode == 7'b0000011 || opcode == 7'b0010011) ? 3'b000 :
                      (opcode == 7'b0100011) ? 3'b001 :
                      (opcode == 7'b1100011) ? 3'b010 :
                      (opcode == 7'b0110111 || opcode == 7'b0010111) ? 3'b011 :
                      (opcode == 7'b1101111) ? 3'b100 :
                      3'b000;
    
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
        .jump_reg   (jump_reg),
        .branch_op  (branch_op)
    );
    
    assign rs1_data = (rs1 == 5'h0) ? 32'h0 : reg_file[rs1];
    assign rs2_data = (rs2 == 5'h0) ? 32'h0 : reg_file[rs2];
    
    wire [31:0] alu_a = (alu_src_a == 2'b01) ? pc :
                        (alu_src_a == 2'b10) ? imm :
                        rs1_data;
    wire [31:0] alu_b = (alu_src_b == 2'b01) ? imm : rs2_data;
    
    alu alu_inst (
        .a      (alu_a),
        .b      (alu_b),
        .op     (alu_op),
        .result (alu_result),
        .zero   (alu_zero),
        .carry_out(),
        .overflow()
    );
    
    assign branch_taken = branch && (
        (branch_op == 3'b000 && alu_zero) ||
        (branch_op == 3'b001 && ~alu_zero)
    );
    
    assign next_pc = branch_taken ? (pc + imm) : pc_plus_4;
    
    assign addr_o = alu_result;
    assign data_o = rs2_data;
    assign mem_write_o = mem_write;
    assign mem_read_o = mem_read;
    assign halt_o = 1'b0;
    
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                reg_file[i] <= 32'h0;
        end else begin
            if (reg_write && rd != 5'h0) begin
                reg_file[rd] <= alu_result;
            end
        end
    end

endmodule