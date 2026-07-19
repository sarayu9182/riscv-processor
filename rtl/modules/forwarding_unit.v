// ============================================================================
// Forwarding Unit for 5-Stage Pipeline
// ============================================================================

module forwarding_unit (
    // EX Stage inputs
    input  wire [4:0]  ex_rs1,
    input  wire [4:0]  ex_rs2,
    
    // MEM Stage inputs
    input  wire [4:0]  mem_rd,
    input  wire        mem_reg_write,
    
    // WB Stage inputs
    input  wire [4:0]  wb_rd,
    input  wire        wb_reg_write,
    
    // Outputs
    output reg  [1:0]  forward_a,
    output reg  [1:0]  forward_b
);

    always @(*) begin
        // Default: no forwarding
        forward_a = 2'b00;
        forward_b = 2'b00;
        
        // Forward from MEM stage to EX stage
        if (mem_reg_write && mem_rd != 5'h0 && mem_rd == ex_rs1) begin
            forward_a = 2'b10;  // Forward from MEM
        end
        
        if (mem_reg_write && mem_rd != 5'h0 && mem_rd == ex_rs2) begin
            forward_b = 2'b10;  // Forward from MEM
        end
        
        // Forward from WB stage to EX stage
        if (wb_reg_write && wb_rd != 5'h0 && wb_rd == ex_rs1) begin
            forward_a = 2'b01;  // Forward from WB
        end
        
        if (wb_reg_write && wb_rd != 5'h0 && wb_rd == ex_rs2) begin
            forward_b = 2'b01;  // Forward from WB
        end
        
        // MEM has priority over WB
        if (mem_reg_write && mem_rd != 5'h0 && mem_rd == ex_rs1) begin
            forward_a = 2'b10;
        end
        
        if (mem_reg_write && mem_rd != 5'h0 && mem_rd == ex_rs2) begin
            forward_b = 2'b10;
        end
    end

endmodule