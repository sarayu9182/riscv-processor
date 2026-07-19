module memory_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] alu_result_i,
    input  wire [31:0] rs2_data_i,
    input  wire [4:0]  rd_i,
    input  wire        reg_write_i,
    input  wire        mem_read_i,
    input  wire        mem_write_i,
    output wire [31:0] addr_o,
    output wire [31:0] data_o,
    input  wire [31:0] data_i,
    output wire [31:0] read_data_o,
    output wire [31:0] alu_result_o,
    output wire [4:0]  rd_o,
    output wire        reg_write_o,
    output wire        mem_read_o,
    output wire        mem_write_o
);

    // Outputs
    assign addr_o = alu_result_i;
    assign data_o = rs2_data_i;
    assign read_data_o = data_i;
    assign alu_result_o = alu_result_i;
    assign rd_o = rd_i;
    assign reg_write_o = reg_write_i;
    assign mem_read_o = mem_read_i;
    assign mem_write_o = mem_write_i;

endmodule