module pipeline_registers (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,
    input  wire        flush,
    
    input  wire [31:0] if_pc,
    input  wire [31:0] if_instr,
    output reg  [31:0] id_pc,
    output reg  [31:0] id_instr,
    
    input  wire [31:0] id_rs1,
    input  wire [31:0] id_rs2,
    input  wire [31:0] id_imm,
    input  wire [4:0]  id_rd,
    input  wire        id_reg_write,
    input  wire        id_mem_read,
    input  wire        id_mem_write,
    input  wire [4:0]  id_alu_op,
    input  wire [1:0]  id_alu_src_a,
    input  wire [1:0]  id_alu_src_b,
    output reg  [31:0] ex_rs1,
    output reg  [31:0] ex_rs2,
    output reg  [31:0] ex_imm,
    output reg  [4:0]  ex_rd,
    output reg         ex_reg_write,
    output reg         ex_mem_read,
    output reg         ex_mem_write,
    output reg  [4:0]  ex_alu_op,
    output reg  [1:0]  ex_alu_src_a,
    output reg  [1:0]  ex_alu_src_b,
    
    input  wire [31:0] ex_alu_result,
    input  wire [31:0] ex_rs2_mem,
    input  wire [4:0]  ex_rd_mem,
    input  wire        ex_mem_read_mem,
    input  wire        ex_mem_write_mem,
    input  wire        ex_reg_write_mem,
    output reg  [31:0] mem_alu_result,
    output reg  [31:0] mem_rs2,
    output reg  [4:0]  mem_rd,
    output reg         mem_mem_read,
    output reg         mem_mem_write,
    output reg         mem_reg_write,
    
    input  wire [31:0] mem_read_data,
    input  wire [31:0] mem_alu_wb,
    input  wire [4:0]  mem_rd_wb,
    input  wire        mem_reg_write_wb,
    output reg  [31:0] wb_read_data,
    output reg  [31:0] wb_alu_result,
    output reg  [4:0]  wb_rd,
    output reg         wb_reg_write
);

    // IF/ID
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            id_pc <= 32'h0;
            id_instr <= 32'h0;
        end else if (!stall) begin
            id_pc <= if_pc;
            id_instr <= if_instr;
        end
    end
    
    // ID/EX
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            ex_rs1 <= 32'h0;
            ex_rs2 <= 32'h0;
            ex_imm <= 32'h0;
            ex_rd <= 5'h0;
            ex_reg_write <= 1'b0;
            ex_mem_read <= 1'b0;
            ex_mem_write <= 1'b0;
            ex_alu_op <= 5'h0;
            ex_alu_src_a <= 2'h0;
            ex_alu_src_b <= 2'h0;
        end else if (!stall) begin
            ex_rs1 <= id_rs1;
            ex_rs2 <= id_rs2;
            ex_imm <= id_imm;
            ex_rd <= id_rd;
            ex_reg_write <= id_reg_write;
            ex_mem_read <= id_mem_read;
            ex_mem_write <= id_mem_write;
            ex_alu_op <= id_alu_op;
            ex_alu_src_a <= id_alu_src_a;
            ex_alu_src_b <= id_alu_src_b;
        end
    end
    
    // EX/MEM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_alu_result <= 32'h0;
            mem_rs2 <= 32'h0;
            mem_rd <= 5'h0;
            mem_mem_read <= 1'b0;
            mem_mem_write <= 1'b0;
            mem_reg_write <= 1'b0;
        end else begin
            mem_alu_result <= ex_alu_result;
            mem_rs2 <= ex_rs2_mem;
            mem_rd <= ex_rd_mem;
            mem_mem_read <= ex_mem_read_mem;
            mem_mem_write <= ex_mem_write_mem;
            mem_reg_write <= ex_reg_write_mem;
        end
    end
    
    // MEM/WB
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_read_data <= 32'h0;
            wb_alu_result <= 32'h0;
            wb_rd <= 5'h0;
            wb_reg_write <= 1'b0;
        end else begin
            wb_read_data <= mem_read_data;
            wb_alu_result <= mem_alu_wb;
            wb_rd <= mem_rd_wb;
            wb_reg_write <= mem_reg_write_wb;
        end
    end

endmodule