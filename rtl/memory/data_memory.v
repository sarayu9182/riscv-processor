// Data Memory
// Simple RAM for RISC-V data

module data_memory (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] addr,
    input  wire [31:0] data_in,
    input  wire        write_en,
    input  wire        read_en,
    output wire [31:0] data_out
);

    // 1KB data memory
    reg [31:0] mem [0:255];
    integer i;
    
    // Initialize memory
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'h0;
    end
    
    // Read (combinational)
    assign data_out = (read_en) ? mem[addr[9:2]] : 32'h0;
    
    // Write (synchronous)
    always @(posedge clk) begin
        if (write_en && addr[9:2] < 256) begin
            mem[addr[9:2]] <= data_in;
        end
    end
    
    // Reset
    always @(negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 256; i = i + 1)
                mem[i] <= 32'h0;
        end
    end
    
endmodule