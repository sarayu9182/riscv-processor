module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [4:0]  op,
    output reg  [31:0] result,
    output wire        zero,
    output wire        carry_out,
    output wire        overflow
);

    localparam OP_ADD    = 5'h00,
               OP_SUB    = 5'h01,
               OP_AND    = 5'h02,
               OP_OR     = 5'h03,
               OP_XOR    = 5'h04,
               OP_SLL    = 5'h05,
               OP_SRL    = 5'h06,
               OP_SRA    = 5'h07,
               OP_SLT    = 5'h08,
               OP_SLTU   = 5'h09,
               OP_MUL    = 5'h0A,
               OP_MULH   = 5'h0B,
               OP_MULHU  = 5'h0C,
               OP_MULHSU = 5'h0D,
               OP_DIV    = 5'h0E,
               OP_DIVU   = 5'h0F,
               OP_REM    = 5'h10,
               OP_REMU   = 5'h11;
    
    reg [32:0] extended_result;
    reg [31:0] b_shift;
    reg [63:0] mult_result;
    reg [31:0] quotient, remainder;
    
    always @(*) begin
        result = 32'h0;
        mult_result = 64'h0;
        quotient = 32'h0;
        remainder = 32'h0;
        
        case (op)
            OP_ADD: begin
                extended_result = {1'b0, a} + {1'b0, b};
                result = extended_result[31:0];
            end
            OP_SUB: begin
                extended_result = {1'b0, a} - {1'b0, b};
                result = extended_result[31:0];
            end
            OP_AND: result = a & b;
            OP_OR:  result = a | b;
            OP_XOR: result = a ^ b;
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
            OP_SLT: result = ($signed(a) < $signed(b)) ? 32'h1 : 32'h0;
            OP_SLTU: result = (a < b) ? 32'h1 : 32'h0;
            OP_MUL: begin
                mult_result = $signed(a) * $signed(b);
                result = mult_result[31:0];
            end
            OP_MULH: begin
                mult_result = $signed(a) * $signed(b);
                result = mult_result[63:32];
            end
            OP_MULHU: begin
                mult_result = a * b;
                result = mult_result[63:32];
            end
            OP_MULHSU: begin
                mult_result = $signed(a) * b;
                result = mult_result[63:32];
            end
            OP_DIV: begin
                if (b != 32'h0) begin
                    quotient = $signed(a) / $signed(b);
                    result = quotient;
                end else begin
                    result = 32'hFFFFFFFF;
                end
            end
            OP_DIVU: begin
                if (b != 32'h0) begin
                    quotient = a / b;
                    result = quotient;
                end else begin
                    result = 32'hFFFFFFFF;
                end
            end
            OP_REM: begin
                if (b != 32'h0) begin
                    remainder = $signed(a) % $signed(b);
                    result = remainder;
                end else begin
                    result = a;
                end
            end
            OP_REMU: begin
                if (b != 32'h0) begin
                    remainder = a % b;
                    result = remainder;
                end else begin
                    result = a;
                end
            end
            default: result = 32'h0;
        endcase
    end
    
    assign zero = (result == 32'h0);
    assign carry_out = extended_result[32];
    assign overflow = ((op == OP_ADD) && (a[31] == b[31]) && (result[31] != a[31])) ||
                      ((op == OP_SUB) && (a[31] != b[31]) && (result[31] != a[31]));

endmodule