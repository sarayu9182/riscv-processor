module fetch_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,
    input  wire        flush,
    input  wire [31:0] pc_i,
    input  wire [31:0] pc_next,
    output wire [31:0] pc_o,
    output wire [31:0] instr_o
);

    reg [31:0] pc_reg;
    reg [31:0] instr_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_reg <= 32'h0;
            instr_reg <= 32'h0;
        end else if (flush) begin
            pc_reg <= 32'h0;
            instr_reg <= 32'h0;
        end else if (!stall) begin
            pc_reg <= pc_i;
            instr_reg <= 32'h00000013; // NOP
        end
    end
    
    assign pc_o = pc_reg;
    assign instr_o = instr_reg;

endmodule