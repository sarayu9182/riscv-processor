module control_unit (
    input  wire [6:0]  opcode,
    input  wire [2:0]  funct3,
    input  wire [6:0]  funct7,
    output reg         reg_write,
    output reg         mem_read,
    output reg         mem_write,
    output reg  [3:0]  alu_op,
    output reg  [1:0]  alu_src_a,
    output reg  [1:0]  alu_src_b,
    output reg  [2:0]  imm_type,
    output reg         branch,
    output reg         jump,
    output reg         jump_reg,
    output reg  [2:0]  branch_op
);

    localparam OP_ADD  = 4'h0,
               OP_SUB  = 4'h1;
    
    always @(*) begin
        reg_write = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        alu_op = OP_ADD;
        alu_src_a = 2'b00;
        alu_src_b = 2'b00;
        imm_type = 3'b000;
        branch = 1'b0;
        jump = 1'b0;
        jump_reg = 1'b0;
        branch_op = 3'b000;
        
        case (opcode)
            7'b0100011: begin // STORE
                mem_write = 1'b1;
                imm_type = 3'b001;
                alu_src_a = 2'b00;
                alu_src_b = 2'b01;
                alu_op = OP_ADD;
            end
            
            7'b0010011: begin // OP-IMM
                reg_write = 1'b1;
                imm_type = 3'b000;
                alu_src_a = 2'b00;
                alu_src_b = 2'b01;
                alu_op = OP_ADD;
            end
            
            7'b0110011: begin // OP
                reg_write = 1'b1;
                alu_src_a = 2'b00;
                alu_src_b = 2'b00;
                alu_op = OP_ADD;
            end
            
            7'b0000011: begin // LOAD
                reg_write = 1'b1;
                mem_read = 1'b1;
                imm_type = 3'b000;
                alu_src_a = 2'b00;
                alu_src_b = 2'b01;
                alu_op = OP_ADD;
            end
        endcase
    end
    
endmodule