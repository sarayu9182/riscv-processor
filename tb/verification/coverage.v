// Simple Coverage Collection Module

module coverage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] instr,
    input  wire [31:0] pc,
    input  wire        mem_read,
    input  wire        mem_write
);

    // Simple counters
    integer add_count;
    integer sub_count;
    integer load_count;
    integer store_count;
    integer branch_count;
    integer jump_count;
    integer total_instr;
    
    initial begin
        add_count = 0;
        sub_count = 0;
        load_count = 0;
        store_count = 0;
        branch_count = 0;
        jump_count = 0;
        total_instr = 0;
    end
    
    // Count instructions
    always @(posedge clk) begin
        if (!rst_n) begin
            // Reset counters on reset
            add_count <= 0;
            sub_count <= 0;
            load_count <= 0;
            store_count <= 0;
            branch_count <= 0;
            jump_count <= 0;
            total_instr <= 0;
        end else if (instr != 32'h0 && instr != 32'h00000013) begin
            // Count by opcode
            case (instr[6:0])
                7'b0110011: add_count = add_count + 1;  // R-type
                7'b0010011: add_count = add_count + 1;  // I-type
                7'b0000011: load_count = load_count + 1; // Load
                7'b0100011: store_count = store_count + 1; // Store
                7'b1100011: branch_count = branch_count + 1; // Branch
                7'b1101111: jump_count = jump_count + 1; // JAL
                7'b1100111: jump_count = jump_count + 1; // JALR
                default: ; // Do nothing
            endcase
            total_instr = total_instr + 1;
            
            // Print progress every 100 instructions
            if (total_instr % 100 == 0) begin
                $display("Coverage: %0d instructions executed", total_instr);
            end
        end
    end
    
endmodule