module cache (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] addr,
    input  wire [31:0] data_in,
    input  wire        write_en,
    input  wire        read_en,
    output wire [31:0] data_out,
    output wire        hit,
    output wire        miss
);

    // Cache parameters: 8 lines, 4 words per line
    localparam CACHE_LINES = 8;
    localparam WORDS_PER_LINE = 4;
    localparam OFFSET_BITS = 2;
    localparam INDEX_BITS = 3;
    
    // Cache storage
    reg [31:0] cache_data [0:CACHE_LINES-1][0:WORDS_PER_LINE-1];
    reg [31:0] cache_tag [0:CACHE_LINES-1];
    reg        cache_valid [0:CACHE_LINES-1];
    reg        cache_dirty [0:CACHE_LINES-1];
    
    // Address decoding
    wire [2:0] index;
    wire [1:0] offset;
    wire [26:0] tag;
    
    assign index = addr[4:2];
    assign offset = addr[1:0];
    assign tag = addr[31:5];
    
    // Hit detection
    wire hit_detected;
    assign hit_detected = cache_valid[index] && (cache_tag[index] == tag);
    
    // Outputs
    assign hit = hit_detected;
    assign miss = !hit_detected;
    assign data_out = hit_detected ? cache_data[index][offset] : 32'h0;
    
    // Cache write
    always @(posedge clk or negedge rst_n) begin
        integer i, j;
        if (!rst_n) begin
            for (i = 0; i < CACHE_LINES; i = i + 1) begin
                cache_valid[i] <= 1'b0;
                cache_dirty[i] <= 1'b0;
                cache_tag[i] <= 32'h0;
                for (j = 0; j < WORDS_PER_LINE; j = j + 1)
                    cache_data[i][j] <= 32'h0;
            end
        end else begin
            if (write_en && hit_detected) begin
                // Write hit: update cache
                cache_data[index][offset] <= data_in;
                cache_dirty[index] <= 1'b1;
            end else if (write_en && !hit_detected) begin
                // Write miss: allocate line
                cache_tag[index] <= tag;
                cache_valid[index] <= 1'b1;
                cache_dirty[index] <= 1'b1;
                cache_data[index][offset] <= data_in;
            end
        end
    end

endmodule