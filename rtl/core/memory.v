// Memory Stage - Complete

module memory_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] alu_result,
    input  wire [31:0] rs2_data,
    input  wire        mem_read,
    input  wire        mem_write,
    output reg  [31:0] addr_o,
    output reg  [31:0] data_o,
    input  wire [31:0] data_i,
    output reg  [31:0] read_data
);

    always @(*) begin
        addr_o = alu_result;
        data_o = rs2_data;
        
        if (mem_read) begin
            read_data = data_i;
        end else begin
            read_data = 32'h0;
        end
    end

endmodule