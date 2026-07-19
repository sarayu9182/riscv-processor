module control_unit (
    input  wire [6:0]  opcode,
    input  wire [2:0]  funct3,
    input  wire [6:0]  funct7,
    output reg         reg_write,
    output reg         mem_read,
    output reg         mem_write,
    output reg  [4:0]  alu_op,
    output reg  [1:0]  alu_src_a,
    output reg  [1:0]  alu_src_b,
    output reg  [2:0]  imm_type,
    output reg         branch,
    output reg         jump,
    output reg         jump_reg,
    output reg  [2:0]  branch_op
);

    localparam ALU_ADD   = 5'h00,
               ALU_SUB   = 5'h01,
               ALU_AND   = 5'h02,
               ALU_OR    = 5'h03,
               ALU_XOR   = 5'h04,
               ALU_SLL   = 5'h05,
               ALU_SRL   = 5'h06,
               ALU_SRA   = 5'h07,
               ALU_SLT   = 5'h08,
               ALU_SLTU  = 5'h09,
               ALU_MUL   = 5'h0A,
               ALU_MULH  = 5'h0B,
               ALU_MULHU = 5'h0C,
               ALU_MULHSU= 5'h0D,
               ALU_DIV   = 5'h0E,
               ALU_DIVU  = 5'h0F,
               ALU_REM   = 5'h10,
               ALU_REMU  = 5'h11;
    
    localparam IMM_I = 3'b000,
               IMM_S = 3'b001,
               IMM_B = 3'b010,
               IMM_U = 3'b011,
               IMM_J = 3'b100;
    
    always @(*) begin
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        alu_op     = ALU_ADD;
        alu_src_a  = 2'b00;
        alu_src_b  = 2'b00;
        imm_type   = IMM_I;
        branch     = 1'b0;
        jump       = 1'b0;
        jump_reg   = 1'b0;
        branch_op  = 3'b000;
        
        case (opcode)
            7'b0110111: begin
                reg_write  = 1'b1;
                imm_type   = IMM_U;
                alu_src_a  = 2'b10;
                alu_src_b  = 2'b00;
                alu_op     = ALU_ADD;
            end
            7'b0010111: begin
                reg_write  = 1'b1;
                imm_type   = IMM_U;
                alu_src_a  = 2'b01;
                alu_src_b  = 2'b01;
                alu_op     = ALU_ADD;
            end
            7'b1101111: begin
                reg_write  = 1'b1;
                jump       = 1'b1;
                imm_type   = IMM_J;
                alu_src_a  = 2'b01;
                alu_src_b  = 2'b01;
                alu_op     = ALU_ADD;
            end
            7'b1100111: begin
                reg_write  = 1'b1;
                jump       = 1'b1;
                jump_reg   = 1'b1;
                imm_type   = IMM_I;
                alu_src_a  = 2'b01;
                alu_src_b  = 2'b01;
                alu_op     = ALU_ADD;
            end
            7'b1100011: begin
                branch     = 1'b1;
                branch_op  = funct3;
                imm_type   = IMM_B;
                alu_src_a  = 2'b00;
                alu_src_b  = 2'b00;
                alu_op     = ALU_SUB;
            end
            7'b0000011: begin
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                imm_type   = IMM_I;
                alu_src_a  = 2'b00;
                alu_src_b  = 2'b01;
                alu_op     = ALU_ADD;
            end
            7'b0100011: begin
                mem_write  = 1'b1;
                imm_type   = IMM_S;
                alu_src_a  = 2'b00;
                alu_src_b  = 2'b01;
                alu_op     = ALU_ADD;
            end
            7'b0010011: begin
                reg_write  = 1'b1;
                imm_type   = IMM_I;
                alu_src_a  = 2'b00;
                alu_src_b  = 2'b01;
                case (funct3)
                    3'b000: alu_op = ALU_ADD;
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                endcase
            end
            7'b0110011: begin
                reg_write  = 1'b1;
                alu_src_a  = 2'b00;
                alu_src_b  = 2'b00;
                if (funct7 == 7'b0000001) begin
                    case (funct3)
                        3'b000: alu_op = ALU_MUL;
                        3'b001: alu_op = ALU_MULH;
                        3'b010: alu_op = ALU_MULHSU;
                        3'b011: alu_op = ALU_MULHU;
                        3'b100: alu_op = ALU_DIV;
                        3'b101: alu_op = ALU_DIVU;
                        3'b110: alu_op = ALU_REM;
                        3'b111: alu_op = ALU_REMU;
                    endcase
                end else begin
                    case (funct3)
                        3'b000: alu_op = (funct7[5]) ? ALU_SUB : ALU_ADD;
                        3'b001: alu_op = ALU_SLL;
                        3'b010: alu_op = ALU_SLT;
                        3'b011: alu_op = ALU_SLTU;
                        3'b100: alu_op = ALU_XOR;
                        3'b101: alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL;
                        3'b110: alu_op = ALU_OR;
                        3'b111: alu_op = ALU_AND;
                    endcase
                end
            end
            7'b1110011: begin
            end
        endcase
    end

endmodule