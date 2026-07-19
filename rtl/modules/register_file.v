// ============================================================================
// Register File - 32 x 32-bit Registers
// ============================================================================
// Description: 32 general-purpose registers (x0-x31) for RISC-V
//              x0 is hardwired to zero (read-only)
//              Supports 2 read ports and 1 write port
// ============================================================================
// Features:
//   - 32 registers, each 32-bits wide
//   - Register x0 is hardwired to zero
//   - Dual read ports (combinational)
//   - Single write port (synchronous)
//   - Reset initializes all registers to zero
//   - Registered write with write enable
// ============================================================================

module register_file (
    // Clock and Reset
    input  wire        clk,
    input  wire        rst_n,
    
    // Read Port 1 (RS1)
    input  wire [4:0]  rs1_addr,
    output wire [31:0] rs1_data,
    
    // Read Port 2 (RS2)
    input  wire [4:0]  rs2_addr,
    output wire [31:0] rs2_data,
    
    // Write Port (RD)
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data,
    input  wire        reg_write
);

    // ========================================================================
    // Register Array
    // ========================================================================
    reg [31:0] reg_file [0:31];  // 32 registers, each 32-bits wide
    
    // ========================================================================
    // Read Ports (Combinational)
    // ========================================================================
    // x0 is hardwired to zero - reading from x0 returns 0
    assign rs1_data = (rs1_addr == 5'h00) ? 32'h00000000 : reg_file[rs1_addr];
    assign rs2_data = (rs2_addr == 5'h00) ? 32'h00000000 : reg_file[rs2_addr];
    
    // ========================================================================
    // Write Port (Synchronous)
    // ========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers to zero
            for (integer i = 0; i < 32; i = i + 1)
                reg_file[i] <= 32'h00000000;
        end else begin
            // Write to register file on rising edge
            // x0 (register 0) cannot be written - it's hardwired to zero
            if (reg_write && (rd_addr != 5'h00)) begin
                reg_file[rd_addr] <= rd_data;
            end
        end
    end
    
endmodule
// ============================================================================
// End of Register File Module
// ============================================================================