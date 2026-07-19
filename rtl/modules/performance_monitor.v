module performance_monitor (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        instr_valid,
    input  wire        icache_hit,
    input  wire        icache_miss,
    input  wire        dcache_hit,
    input  wire        dcache_miss,
    input  wire        branch_mispredict,
    output wire [31:0] total_instr,
    output wire [31:0] icache_hit_count,
    output wire [31:0] icache_miss_count,
    output wire [31:0] dcache_hit_count,
    output wire [31:0] dcache_miss_count,
    output wire [31:0] branch_mispredict_count
);

    reg [31:0] instr_count;
    reg [31:0] icache_hit_cnt, icache_miss_cnt;
    reg [31:0] dcache_hit_cnt, dcache_miss_cnt;
    reg [31:0] branch_mispredict_cnt;
    
    initial begin
        instr_count = 0;
        icache_hit_cnt = 0;
        icache_miss_cnt = 0;
        dcache_hit_cnt = 0;
        dcache_miss_cnt = 0;
        branch_mispredict_cnt = 0;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instr_count <= 0;
            icache_hit_cnt <= 0;
            icache_miss_cnt <= 0;
            dcache_hit_cnt <= 0;
            dcache_miss_cnt <= 0;
            branch_mispredict_cnt <= 0;
        end else begin
            if (instr_valid) instr_count <= instr_count + 1;
            if (icache_hit) icache_hit_cnt <= icache_hit_cnt + 1;
            if (icache_miss) icache_miss_cnt <= icache_miss_cnt + 1;
            if (dcache_hit) dcache_hit_cnt <= dcache_hit_cnt + 1;
            if (dcache_miss) dcache_miss_cnt <= dcache_miss_cnt + 1;
            if (branch_mispredict) branch_mispredict_cnt <= branch_mispredict_cnt + 1;
        end
    end
    
    assign total_instr = instr_count;
    assign icache_hit_count = icache_hit_cnt;
    assign icache_miss_count = icache_miss_cnt;
    assign dcache_hit_count = dcache_hit_cnt;
    assign dcache_miss_count = dcache_miss_cnt;
    assign branch_mispredict_count = branch_mispredict_cnt;

endmodule