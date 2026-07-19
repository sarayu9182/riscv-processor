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
    
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [4:0] rs1, rs2, rd;
    wire [31:0] imm;
    wire [2:0] imm_type;
    
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
    
    reg [31:0] reg_file [0:31];
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] alu_result;
    wire [31:0] alu_a, alu_b;
    wire        alu_zero;
    
    wire [31:0] wb_data;
    wire [4:0]  wb_rd;
    wire        wb_reg_write;
    
    assign pc_o = pc;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0;
            instr_reg <= 32'h0;
        end else begin
            pc <= pc + 32'h4;
            instr_reg <= instr_i;
        end
    end
    
    assign opcode = instr_reg[6:0];
    assign funct3 = instr_reg[14:12];
    assign funct7 = instr_reg[31:25];
    assign rs1 = instr_reg[19:15];
    assign rs2 = instr_reg[24:20];
    assign rd = instr_reg[11:7];
    
    assign imm = (opcode == 7'b0000011 || opcode == 7'b0010011 || opcode == 7'b1100111) ? {{20{instr_reg[31]}}, instr_reg[31:20]} :
                 (opcode == 7'b0100011) ? {{20{instr_reg[31]}}, instr_reg[31:25], instr_reg[11:7]} :
                 (opcode == 7'b1100011) ? {{20{instr_reg[31]}}, instr_reg[7], instr_reg[30:25], instr_reg[11:8], 1'b0} :
                 (opcode == 7'b0110111 || opcode == 7'b0010111) ? {instr_reg[31:12], 12'h0} :
                 (opcode == 7'b1101111) ? {{12{instr_reg[31]}}, instr_reg[19:12], instr_reg[20], instr_reg[30:21], 1'b0} :
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
    
    assign alu_a = (alu_src_a == 2'b01) ? pc :
                   (alu_src_a == 2'b10) ? imm :
                   rs1_data;
    assign alu_b = (alu_src_b == 2'b01) ? imm : rs2_data;
    
    alu alu_inst (
        .a      (alu_a),
        .b      (alu_b),
        .op     (alu_op),
        .result (alu_result),
        .zero   (alu_zero),
        .carry_out(),
        .overflow()
    );
    
    assign addr_o = alu_result;
    assign data_o = rs2_data;
    assign mem_write_o = mem_write;
    assign mem_read_o = mem_read;
    assign halt_o = 1'b0;
    
    assign wb_data = alu_result;
    assign wb_rd = rd;
    assign wb_reg_write = reg_write;
    
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                reg_file[i] <= 32'h0;
        end else begin
            if (wb_reg_write && wb_rd != 5'h0) begin
                reg_file[wb_rd] <= wb_data;
            end
        end
    end

endmodule