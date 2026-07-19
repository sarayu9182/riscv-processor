module branch_predictor (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] pc,
    input  wire        branch_taken,
    input  wire        update,
    output wire        predict_taken
);

    // 2-bit saturating counter for each branch
    reg [1:0] counter [0:255];
    reg [1:0] counter_out;
    
    integer i;
    
    // Initialize counters to weakly taken (2'b10)
    initial begin
        for (i = 0; i < 256; i = i + 1)
            counter[i] = 2'b10;
    end
    
    // Read counter
    always @(*) begin
        counter_out = counter[pc[9:2]];
    end
    
    // Update counter on branch resolution
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 256; i = i + 1)
                counter[i] <= 2'b10;
        end else if (update) begin
            case (counter[pc[9:2]])
                2'b00: counter[pc[9:2]] <= branch_taken ? 2'b01 : 2'b00;
                2'b01: counter[pc[9:2]] <= branch_taken ? 2'b10 : 2'b00;
                2'b10: counter[pc[9:2]] <= branch_taken ? 2'b11 : 2'b01;
                2'b11: counter[pc[9:2]] <= branch_taken ? 2'b11 : 2'b10;
            endcase
        end
    end
    
    // Prediction: taken if counter >= 2
    assign predict_taken = (counter_out >= 2'b10);

endmodule