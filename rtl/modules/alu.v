// ============================================================================
// ALU for RISC-V RV32I with M Extension (Multiplication)
// ============================================================================
// Description: 32-bit Arithmetic Logic Unit supporting all RV32I operations
//              plus M extension (MUL, MULH, MULHU, MULHSU)
// ============================================================================
// Author: [Your Name]
// Date: 2026
// Company: Intel Corporation (Application)
// ============================================================================

module alu (
    // Inputs
    input  wire [31:0] a,           // Operand A (RS1)
    input  wire [31:0] b,           // Operand B (RS2)
    input  wire [4:0]  op,          // ALU Operation Code
    
    // Outputs
    output reg  [31:0] result,      // ALU Result
    output wire        zero,        // Zero Flag (result == 0)
    output wire        carry_out,   // Carry Out
    output wire        overflow,    // Overflow Flag
    output wire        sign         // Sign Flag (result[31])
);

    // ========================================================================
    // ALU Operation Codes (5-bit for M extension)
    // ========================================================================
    localparam OP_ADD    = 5'h00,   // Addition
               OP_SUB    = 5'h01,   // Subtraction
               OP_AND    = 5'h02,   // Bitwise AND
               OP_OR     = 5'h03,   // Bitwise OR
               OP_XOR    = 5'h04,   // Bitwise XOR
               OP_SLL    = 5'h05,   // Shift Left Logical
               OP_SRL    = 5'h06,   // Shift Right Logical
               OP_SRA    = 5'h07,   // Shift Right Arithmetic
               OP_SLT    = 5'h08,   // Set Less Than (signed)
               OP_SLTU   = 5'h09,   // Set Less Than (unsigned)
               OP_MUL    = 5'h0A,   // Multiply (low 32 bits)
               OP_MULH   = 5'h0B,   // Multiply (high 32 bits, signed)
               OP_MULHU  = 5'h0C,   // Multiply (high 32 bits, unsigned)
               OP_MULHSU = 5'h0D,   // Multiply (high 32 bits, signed x unsigned)
               OP_DIV    = 5'h0E,   // Division (signed)
               OP_DIVU   = 5'h0F,   // Division (unsigned)
               OP_REM    = 5'h10,   // Remainder (signed)
               OP_REMU   = 5'h11,   // Remainder (unsigned)
               OP_COPY_A = 5'h12,   // Copy Operand A
               OP_COPY_B = 5'h13;   // Copy Operand B

    // ========================================================================
    // Internal Signals
    // ========================================================================
    reg [32:0] extended_result;     // Extended result for carry
    reg [31:0] b_shift;              // Shift amount
    reg [63:0] mult_result;          // 64-bit multiplication result
    reg [31:0] dividend, divisor;    // For division
    reg [31:0] quotient, remainder;  // Division results
    
    // ========================================================================
    // ALU Operation Logic
    // ========================================================================
    always @(*) begin
        // Default assignments
        result = 32'h0;
        mult_result = 64'h0;
        quotient = 32'h0;
        remainder = 32'h0;
        
        case (op)
            // =================================================================
            // Arithmetic Operations
            // =================================================================
            OP_ADD: begin
                extended_result = {1'b0, a} + {1'b0, b};
                result = extended_result[31:0];
            end
            
            OP_SUB: begin
                extended_result = {1'b0, a} - {1'b0, b};
                result = extended_result[31:0];
            end
            
            // =================================================================
            // Logical Operations
            // =================================================================
            OP_AND: begin
                result = a & b;
            end
            
            OP_OR: begin
                result = a | b;
            end
            
            OP_XOR: begin
                result = a ^ b;
            end
            
            // =================================================================
            // Shift Operations
            // =================================================================
            OP_SLL: begin
                b_shift = b[4:0];
                result = a << b_shift;
            end
            
            OP_SRL: begin
                b_shift = b[4:0];
                result = a >> b_shift;
            end
            
            OP_SRA: begin
                b_shift = b[4:0];
                result = $signed(a) >>> b_shift;
            end
            
            // =================================================================
            // Compare Operations
            // =================================================================
            OP_SLT: begin
                result = ($signed(a) < $signed(b)) ? 32'h1 : 32'h0;
            end
            
            OP_SLTU: begin
                result = (a < b) ? 32'h1 : 32'h0;
            end
            
            // =================================================================
            // M Extension - Multiplication Operations
            // =================================================================
            OP_MUL: begin
                mult_result = $signed(a) * $signed(b);
                result = mult_result[31:0];    // Low 32 bits
            end
            
            OP_MULH: begin
                mult_result = $signed(a) * $signed(b);
                result = mult_result[63:32];   // High 32 bits (signed)
            end
            
            OP_MULHU: begin
                mult_result = a * b;            // Unsigned multiply
                result = mult_result[63:32];   // High 32 bits (unsigned)
            end
            
            OP_MULHSU: begin
                mult_result = $signed(a) * b;   // Signed x Unsigned
                result = mult_result[63:32];   // High 32 bits
            end
            
            // =================================================================
            // M Extension - Division Operations
            // =================================================================
            OP_DIV: begin
                if (b != 32'h0) begin
                    dividend = $signed(a);
                    divisor = $signed(b);
                    quotient = $signed(dividend) / $signed(divisor);
                    result = quotient;
                end else begin
                    result = 32'hFFFFFFFF;      // Division by zero
                end
            end
            
            OP_DIVU: begin
                if (b != 32'h0) begin
                    quotient = a / b;
                    result = quotient;
                end else begin
                    result = 32'hFFFFFFFF;      // Division by zero
                end
            end
            
            OP_REM: begin
                if (b != 32'h0) begin
                    dividend = $signed(a);
                    divisor = $signed(b);
                    remainder = $signed(dividend) % $signed(divisor);
                    result = remainder;
                end else begin
                    result = a;                 // Remainder = dividend
                end
            end
            
            OP_REMU: begin
                if (b != 32'h0) begin
                    remainder = a % b;
                    result = remainder;
                end else begin
                    result = a;                 // Remainder = dividend
                end
            end
            
            // =================================================================
            // Copy Operations (for pipeline forwarding)
            // =================================================================
            OP_COPY_A: begin
                result = a;
            end
            
            OP_COPY_B: begin
                result = b;
            end
            
            // =================================================================
            // Default
            // =================================================================
            default: begin
                result = 32'h0;
            end
        endcase
    end
    
    // ========================================================================
    // Status Flags
    // ========================================================================
    assign zero    = (result == 32'h0);
    assign sign    = result[31];
    assign carry_out = extended_result[32];
    
    assign overflow = ((op == OP_ADD) && (a[31] == b[31]) && (result[31] != a[31])) ||
                      ((op == OP_SUB) && (a[31] != b[31]) && (result[31] != a[31]));
    
endmodule
// ============================================================================
// End of ALU Module
// ============================================================================