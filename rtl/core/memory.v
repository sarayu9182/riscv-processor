module memory_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] alu_result,
    input  wire [31:0] rs2_data,
    input  wire        mem_read,
    input  wire        mem_write,
    output wire [31:0] addr_o,
    output wire [31:0] data_o,
    input  wire [31:0] data_i,
    output wire [31:0] read_data
);

    assign addr_o = alu_result;
    assign data_o = rs2_data;
    assign read_data = data_i;

endmodule