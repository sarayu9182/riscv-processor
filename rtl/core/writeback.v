// Writeback Stage

module writeback_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] alu_result,
    input  wire [31:0] mem_data,
    input  wire [31:0] pc_plus_4,
    input  wire        reg_write,
    input  wire [4:0]  rd_addr,
    output reg  [31:0] wb_data,
    output reg  [4:0]  wb_addr
);

    always @(*) begin
        wb_addr = rd_addr;
        // In a full implementation, this would select between
        // ALU result, memory data, or PC+4 for JAL/JALR
        wb_data = alu_result;
    end

endmodule