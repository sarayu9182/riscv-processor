// Self-checking verification module

module checker (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] pc,
    input  wire [31:0] instr,
    input  wire [31:0] addr,
    input  wire [31:0] data,
    input  wire        mem_write,
    input  wire        mem_read,
    input  wire        halt,
    output wire        error
);

    reg [31:0] expected_data;
    reg        error_reg;
    integer    test_case;
    
    // Error output
    assign error = error_reg;
    
    // Check data memory writes against expected
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            error_reg <= 1'b0;
            test_case <= 0;
        end else if (mem_write) begin
            // Check if write matches expected
            if (addr == 32'h10) begin
                expected_data = 32'h0000000A;  // Expected result
                if (data != expected_data) begin
                    $error("Data mismatch at addr 0x%08h: got 0x%08h, expected 0x%08h",
                           addr, data, expected_data);
                    error_reg <= 1'b1;
                end else begin
                    $display("Data verified at addr 0x%08h: 0x%08h", addr, data);
                end
            end
        end
    end
    
    // Coverage monitoring
    always @(posedge clk) begin
        if (instr != 32'h0) begin
            // Check for illegal instructions
            if (instr[6:0] == 7'b1111111) begin
                $warning("Illegal instruction at PC=0x%08h", pc);
            end
        end
    end
    
endmodule