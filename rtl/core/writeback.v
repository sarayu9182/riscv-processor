module writeback_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] alu_result_i,
    input  wire [31:0] mem_data_i,
    input  wire [4:0]  rd_i,
    input  wire        reg_write_i,
    output wire [31:0] wb_data_o,
    output wire [4:0]  rd_o,
    output wire        reg_write_o
);

    // Pipeline registers
    reg [31:0] wb_data_reg;
    reg [4:0]  rd_reg;
    reg        reg_write_reg;
    
    // Writeback data selection
    wire [31:0] wb_data;
    assign wb_data = mem_data_i ? mem_data_i : alu_result_i;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_data_reg <= 32'h0;
            rd_reg <= 5'h0;
            reg_write_reg <= 1'b0;
        end else begin
            wb_data_reg <= wb_data;
            rd_reg <= rd_i;
            reg_write_reg <= reg_write_i;
        end
    end
    
    // Outputs
    assign wb_data_o = wb_data_reg;
    assign rd_o = rd_reg;
    assign reg_write_o = reg_write_reg;

endmodule