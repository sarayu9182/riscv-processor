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

    // ============ PC ============
    reg [31:0] pc;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0;
        end else begin
            pc <= pc + 32'h4;
        end
    end
    
    assign pc_o = pc;
    
    // ============ DECODE ============
    wire [6:0] opcode = instr_i[6:0];
    wire [2:0] funct3 = instr_i[14:12];
    wire [6:0] funct7 = instr_i[31:25];
    wire [4:0] rs1 = instr_i[19:15];
    wire [4:0] rs2 = instr_i[24:20];
    wire [4:0] rd = instr_i[11:7];
    
    // ============ IMMEDIATE ============
    wire [31:0] imm_i = {{20{instr_i[31]}}, instr_i[31:20]};
    wire [31:0] imm_s = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
    wire [31:0] imm_b = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
    wire [31:0] imm_u = {instr_i[31:12], 12'h0};
    wire [31:0] imm_j = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
    
    reg [31:0] imm;
    
    always @(*) begin
        case (opcode)
            7'b0000011: imm = imm_i; // LOAD
            7'b0100011: imm = imm_s; // STORE
            7'b0010011: imm = imm_i; // OP-IMM
            7'b0110011: imm = 32'h0; // OP
            7'b1100011: imm = imm_b; // BRANCH
            7'b1101111: imm = imm_j; // JAL
            7'b0110111: imm = imm_u; // LUI
            default: imm = 32'h0;
        endcase
    end
    
    // ============ CONTROL ============
    reg reg_write, mem_read, mem_write;
    reg [3:0] alu_op;
    reg [1:0] alu_src_a, alu_src_b;
    
    always @(*) begin
        reg_write = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        alu_op = 4'h0;
        alu_src_a = 2'b00;
        alu_src_b = 2'b00;
        
        case (opcode)
            7'b0000011: begin // LOAD
                reg_write = 1'b1;
                mem_read = 1'b1;
                alu_src_a = 2'b00;
                alu_src_b = 2'b01;
                alu_op = 4'h0;
            end
            
            7'b0100011: begin // STORE
                mem_write = 1'b1;
                alu_src_a = 2'b00;
                alu_src_b = 2'b01;
                alu_op = 4'h0;
            end
            
            7'b0010011: begin // OP-IMM
                reg_write = 1'b1;
                alu_src_a = 2'b00;
                alu_src_b = 2'b01;
                alu_op = 4'h0;
            end
            
            7'b0110011: begin // OP
                reg_write = 1'b1;
                alu_src_a = 2'b00;
                alu_src_b = 2'b00;
                alu_op = 4'h0;
            end
        endcase
    end
    
    // ============ REGISTER FILE ============
    reg [31:0] reg_file [0:31];
    wire [31:0] rs1_data, rs2_data;
    
    assign rs1_data = (rs1 == 5'h0) ? 32'h0 : reg_file[rs1];
    assign rs2_data = (rs2 == 5'h0) ? 32'h0 : reg_file[rs2];
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (integer i = 0; i < 32; i = i + 1)
                reg_file[i] <= 32'h0;
        end else begin
            if (reg_write && rd != 5'h0) begin
                reg_file[rd] <= alu_result;
            end
        end
    end
    
    // ============ ALU ============
    wire [31:0] alu_a, alu_b;
    reg [31:0] alu_result;
    
    assign alu_a = (alu_src_a == 2'b01) ? pc :
                   (alu_src_a == 2'b10) ? imm :
                   rs1_data;
                   
    assign alu_b = (alu_src_b == 2'b01) ? imm : rs2_data;
    
    always @(*) begin
        case (alu_op)
            4'h0: alu_result = alu_a + alu_b;
            4'h1: alu_result = alu_a - alu_b;
            4'h2: alu_result = alu_a & alu_b;
            4'h3: alu_result = alu_a | alu_b;
            4'h4: alu_result = alu_a ^ alu_b;
            default: alu_result = alu_a + alu_b;
        endcase
    end
    
    // ============ MEMORY ============
    assign addr_o = alu_result;
    assign data_o = rs2_data;
    assign mem_write_o = mem_write;
    assign mem_read_o = mem_read;
    assign halt_o = 1'b0;

endmodule