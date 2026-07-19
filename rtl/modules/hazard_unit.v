module hazard_unit (
    input  wire [4:0]  id_rs1,
    input  wire [4:0]  id_rs2,
    input  wire [4:0]  ex_rd,
    input  wire        ex_mem_read,
    output reg         stall,
    output reg         flush
);

    always @(*) begin
        stall = 1'b0;
        flush = 1'b0;
        
        // Load-Use Hazard: if EX stage is a load and rd matches rs1 or rs2 in ID
        if (ex_mem_read && (ex_rd == id_rs1 || ex_rd == id_rs2) && ex_rd != 5'h0) begin
            stall = 1'b1;
            flush = 1'b1;
        end
    end

endmodule