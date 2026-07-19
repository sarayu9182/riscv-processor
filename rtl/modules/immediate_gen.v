// ============================================================================
// Immediate Generator for RISC-V RV32I
// ============================================================================
// Description: Generates sign-extended immediates for all RISC-V formats
//              Supports I, S, B, U, J-type instructions
// ============================================================================
// Features:
//   - I-type: 12-bit immediate (ADDI, LW, etc.)
//   - S-type: 12-bit immediate (SW, etc.)
//   - B-type: 13-bit immediate with LSB=0 (Branch)
//   - U-type: 20-bit immediate shifted by 12 (LUI, AUIPC)
//   - J-type: 21-bit immediate with LSB=0 (JAL)
// ============================================================================
// Author: [Your Name]
// Date: 2026
// Company: Intel Corporation (Application)
// ============================================================================

module immediate_gen (
    input  wire [31:0] instr,      // 32-bit instruction
    input  wire [2:0]  imm_type,   // Immediate format type
    output wire [31:0] imm         // 32-bit sign-extended immediate
);

    // ========================================================================
    // Immediate Type Definitions
    // ========================================================================
    localparam IMM_I = 3'b000;     // I-type (ADDI, LW, etc.)
    localparam IMM_S = 3'b001;     // S-type (SW, etc.)
    localparam IMM_B = 3'b010;     // B-type (BEQ, BNE, etc.)
    localparam IMM_U = 3'b011;     // U-type (LUI, AUIPC)
    localparam IMM_J = 3'b100;     // J-type (JAL)
    
    // ========================================================================
    // Internal Signal
    // ========================================================================
    reg [31:0] imm_ext;            // Sign-extended immediate
    
    // ========================================================================
    // Immediate Generation Logic
    // ========================================================================
    always @(*) begin
        case (imm_type)
            // ================================================================
            // I-Type Immediate (12-bit sign-extended)
            // Bits: [31:20] = immediate
            // Example: ADDI x1, x2, 5
            // ================================================================
            IMM_I: begin
                imm_ext = {{20{instr[31]}}, instr[31:20]};
            end
            
            // ================================================================
            // S-Type Immediate (12-bit sign-extended)
            // Bits: [31:25] = imm[11:5], [11:7] = imm[4:0]
            // Example: SW x1, 8(x2)
            // ================================================================
            IMM_S: begin
                imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end
            
            // ================================================================
            // B-Type Immediate (13-bit sign-extended, LSB=0)
            // Bits: [7] = imm[11], [30:25] = imm[10:5], 
            //       [11:8] = imm[4:1], LSB = 0
            // Example: BEQ x1, x2, label
            // ================================================================
            IMM_B: begin
                imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            end
            
            // ================================================================
            // U-Type Immediate (20-bit, shifted by 12)
            // Bits: [31:12] = immediate
            // Example: LUI x1, 0x12345
            // ================================================================
            IMM_U: begin
                imm_ext = {instr[31:12], 12'h000};
            end
            
            // ================================================================
            // J-Type Immediate (21-bit sign-extended, LSB=0)
            // Bits: [31] = imm[20], [19:12] = imm[19:12], 
            //       [20] = imm[11], [30:21] = imm[10:1], LSB=0
            // Example: JAL x1, label
            // ================================================================
            IMM_J: begin
                imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            end
            
            // ================================================================
            // Default
            // ================================================================
            default: begin
                imm_ext = 32'h00000000;
            end
        endcase
    end
    
    // ========================================================================
    // Output Assignment
    // ========================================================================
    assign imm = imm_ext;
    
endmodule
// ============================================================================
// End of Immediate Generator Module
// ============================================================================