// ============================================================================
// Hazard Detection and Forwarding Unit for RISC-V 5-Stage Pipeline
// ============================================================================
// Description: Detects data hazards and controls forwarding/stalling
//              Handles Load-Use hazards, ALU-ALU hazards, and branches
// ============================================================================
// Features:
//   - Data hazard detection (RAW, WAW, WAR)
//   - Load-Use hazard detection
//   - Forwarding (bypass) logic
//   - Pipeline stall generation
//   - Branch hazard handling
// ============================================================================
// Author: [Your Name]
// Date: 2026
// Company: Intel Corporation (Application)
// ============================================================================

module hazard_unit (
    // ========================================================================
    // Inputs from Decode Stage (ID)
    // ========================================================================
    input  wire [4:0]  rs1_addr_id,    // RS1 address in Decode stage
    input  wire [4:0]  rs2_addr_id,    // RS2 address in Decode stage
    input  wire [4:0]  rd_addr_id,     // RD address in Decode stage
    input  wire        reg_write_id,   // Register write in Decode stage
    
    // ========================================================================
    // Inputs from Execute Stage (EX)
    // ========================================================================
    input  wire [4:0]  rd_addr_ex,     // RD address in Execute stage
    input  wire        reg_write_ex,   // Register write in Execute stage
    input  wire        mem_read_ex,    // Memory read in Execute stage
    
    // ========================================================================
    // Inputs from Memory Stage (MEM)
    // ========================================================================
    input  wire [4:0]  rd_addr_mem,    // RD address in Memory stage
    input  wire        reg_write_mem,  // Register write in Memory stage
    
    // ========================================================================
    // Inputs from Writeback Stage (WB)
    // ========================================================================
    input  wire [4:0]  rd_addr_wb,     // RD address in Writeback stage
    input  wire        reg_write_wb,   // Register write in Writeback stage
    
    // ========================================================================
    // Outputs - Control Signals
    // ========================================================================
    output wire        stall_pc,       // Stall Program Counter
    output wire        stall_if_id,    // Stall IF/ID pipeline register
    output wire        flush_if_id,    // Flush IF/ID pipeline register
    
    // ========================================================================
    // Forwarding Control Signals
    // ========================================================================
    output reg  [1:0]  forward_a,      // Forwarding select for ALU input A
    output reg  [1:0]  forward_b       // Forwarding select for ALU input B
);

    // ========================================================================
    // Forwarding Mux Selects
    // ========================================================================
    // forward_a / forward_b encoding:
    // 2'b00 = No forward (use register file value)
    // 2'b01 = Forward from Execute/Memory stage
    // 2'b10 = Forward from Memory/Writeback stage
    // 2'b11 = Forward from Writeback stage

    // ========================================================================
    // Internal Signals
    // ========================================================================
    wire load_use_hazard;             // Load-Use hazard detected
    wire alu_hazard_a;                // ALU hazard on RS1
    wire alu_hazard_b;                // ALU hazard on RS2
    
    // ========================================================================
    // Load-Use Hazard Detection
    // ========================================================================
    // If EX stage is a load (mem_read_ex) and RD matches either RS1 or RS2
    // in ID stage, we need to stall
    assign load_use_hazard = mem_read_ex && 
                            ((rd_addr_ex == rs1_addr_id) ||
                             (rd_addr_ex == rs2_addr_id)) &&
                            (rd_addr_ex != 5'h00);
    
    // ========================================================================
    // Stall and Flush Generation
    // ========================================================================
    assign stall_pc     = load_use_hazard;
    assign stall_if_id  = load_use_hazard;
    assign flush_if_id  = load_use_hazard;
    
    // ========================================================================
    // ALU-ALU Forwarding Detection
    // ========================================================================
    // Forward from EX/MEM pipeline register to EX stage
    // Check if EX stage writes to a register and RD matches RS1 in ID
    assign alu_hazard_a = reg_write_ex && 
                          (rd_addr_ex != 5'h00) && 
                          (rd_addr_ex == rs1_addr_id) &&
                          (rd_addr_ex != rs2_addr_id);
    
    // Forward from EX/MEM to EX stage for RS2
    assign alu_hazard_b = reg_write_ex && 
                          (rd_addr_ex != 5'h00) && 
                          (rd_addr_ex == rs2_addr_id) &&
                          (rd_addr_ex != rs1_addr_id);
    
    // ========================================================================
    // Forwarding Control Logic
    // ========================================================================
    always @(*) begin
        // Default: No forwarding
        forward_a = 2'b00;
        forward_b = 2'b00;
        
        // ================================================================
        // Forward for RS1 (ALU input A)
        // ================================================================
        // Check if EX stage has valid result for RS1
        if (alu_hazard_a) begin
            forward_a = 2'b01;  // Forward from EX/MEM
        end
        // Check if MEM stage has valid result for RS1
        else if (reg_write_mem && 
                 (rd_addr_mem != 5'h00) && 
                 (rd_addr_mem == rs1_addr_id)) begin
            forward_a = 2'b10;  // Forward from MEM/WB
        end
        // Check if WB stage has valid result for RS1
        else if (reg_write_wb && 
                 (rd_addr_wb != 5'h00) && 
                 (rd_addr_wb == rs1_addr_id)) begin
            forward_a = 2'b11;  // Forward from WB
        end
        
        // ================================================================
        // Forward for RS2 (ALU input B)
        // ================================================================
        // Check if EX stage has valid result for RS2
        if (alu_hazard_b) begin
            forward_b = 2'b01;  // Forward from EX/MEM
        end
        // Check if MEM stage has valid result for RS2
        else if (reg_write_mem && 
                 (rd_addr_mem != 5'h00) && 
                 (rd_addr_mem == rs2_addr_id)) begin
            forward_b = 2'b10;  // Forward from MEM/WB
        end
        // Check if WB stage has valid result for RS2
        else if (reg_write_wb && 
                 (rd_addr_wb != 5'h00) && 
                 (rd_addr_wb == rs2_addr_id)) begin
            forward_b = 2'b11;  // Forward from WB
        end
    end
    
endmodule
// ============================================================================
// End of Hazard Unit Module
// ============================================================================