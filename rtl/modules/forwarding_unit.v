module forwarding_unit (
    input  wire [4:0]  ex_rs1,
    input  wire [4:0]  ex_rs2,
    input  wire [4:0]  mem_rd,
    input  wire        mem_reg_write,
    input  wire [4:0]  wb_rd,
    input  wire        wb_reg_write,
    output reg  [1:0]  forward_a,
    output reg  [1:0]  forward_b
);

    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;
        
        // Forward from EX/MEM stage (highest priority)
        if (mem_reg_write && mem_rd != 5'h0) begin
            if (mem_rd == ex_rs1)
                forward_a = 2'b10;
            if (mem_rd == ex_rs2)
                forward_b = 2'b10;
        end
        
        // Forward from MEM/WB stage (lower priority)
        if (wb_reg_write && wb_rd != 5'h0) begin
            if (wb_rd == ex_rs1 && forward_a != 2'b10)
                forward_a = 2'b01;
            if (wb_rd == ex_rs2 && forward_b != 2'b10)
                forward_b = 2'b01;
        end
    end

endmodule