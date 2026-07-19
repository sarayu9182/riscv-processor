module riscv_core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] instr_i,
    input  wire [31:0] data_i,
    output wire [31:0] pc_o,
    output wire [31:0] addr_o,
    output wire [31:0] data_o,
    output wire        mem_write_o,
    output wire        mem_read_o,
    output wire        halt_o
);

    // ========================================================================
    // Cache Instances
    // ========================================================================
    wire [31:0] icache_data;
    wire        icache_hit, icache_miss;
    wire [31:0] dcache_data;
    wire        dcache_hit, dcache_miss;
    
    // Instruction Cache
    cache icache (
        .clk      (clk),
        .rst_n    (rst_n),
        .addr     (pc),
        .data_in  (32'h0),
        .write_en (1'b0),
        .read_en  (1'b1),
        .data_out (icache_data),
        .hit      (icache_hit),
        .miss     (icache_miss)
    );
    
    // Data Cache
    cache dcache (
        .clk      (clk),
        .rst_n    (rst_n),
        .addr     (addr_o),
        .data_in  (data_o),
        .write_en (mem_write_o),
        .read_en  (mem_read_o),
        .data_out (dcache_data),
        .hit      (dcache_hit),
        .miss     (dcache_miss)
    );
    
    // ========================================================================
    // PC
    // ========================================================================
    reg [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    
    assign pc_plus_4 = pc + 32'h4;
    assign pc_o = pc;
    
    // ========================================================================
    // Register File
    // ========================================================================
    reg [31:0] reg_file [0:31];
    wire [31:0] rs1_data, rs2_data;
    
    // ========================================================================
    // IF/ID Pipeline
    // ========================================================================
    wire [31:0] if_pc, if_instr;
    wire        stall, flush;
    
    // ========================================================================
    // ID/EX Pipeline
    // ========================================================================
    wire [31:0] id_imm, id_rs1_data, id_rs2_data, id_pc;
    wire [4:0]  id_rd;
    wire        id_reg_write, id_mem_read, id_mem_write;
    wire [4:0]  id_alu_op;
    wire [1:0]  id_alu_src_a, id_alu_src_b;
    wire        id_branch, id_jump;
    wire [2:0]  id_branch_op;
    
    // ========================================================================
    // EX/MEM Pipeline
    // ========================================================================
    wire [31:0] ex_alu_result, ex_rs2_data;
    wire [4:0]  ex_rd;
    wire        ex_reg_write, ex_mem_read, ex_mem_write;
    
    // ========================================================================
    // MEM/WB Pipeline
    // ========================================================================
    wire [31:0] mem_alu_result, mem_read_data;
    wire [4:0]  mem_rd;
    wire        mem_reg_write;
    
    // ========================================================================
    // WB Stage
    // ========================================================================
    wire [31:0] wb_data;
    wire [4:0]  wb_rd;
    wire        wb_reg_write;
    
    // ========================================================================
    // Forwarding
    // ========================================================================
    wire [1:0] forward_a, forward_b;
    wire [31:0] forward_rs1, forward_rs2;
    
    // ========================================================================
    // Fetch Stage
    // ========================================================================
    fetch_stage fetch (
        .clk     (clk),
        .rst_n   (rst_n),
        .stall   (stall),
        .flush   (flush),
        .pc_i    (pc),
        .pc_next (pc_next),
        .pc_o    (if_pc),
        .instr_o (if_instr)
    );
    
    // ========================================================================
    // Decode Stage
    // ========================================================================
    decode_stage decode (
        .clk         (clk),
        .rst_n       (rst_n),
        .stall       (stall),
        .flush       (flush),
        .instr_i     (icache_data),  // Changed from if_instr to icache_data
        .pc_i        (if_pc),
        .rs1_data_i  (rs1_data),
        .rs2_data_i  (rs2_data),
        .imm_o       (id_imm),
        .rd_o        (id_rd),
        .reg_write_o (id_reg_write),
        .mem_read_o  (id_mem_read),
        .mem_write_o (id_mem_write),
        .alu_op_o    (id_alu_op),
        .alu_src_a_o (id_alu_src_a),
        .alu_src_b_o (id_alu_src_b),
        .branch_o    (id_branch),
        .jump_o      (id_jump),
        .branch_op_o (id_branch_op),
        .rs1_data_o  (id_rs1_data),
        .rs2_data_o  (id_rs2_data),
        .pc_o        (id_pc)
    );
    
    // ========================================================================
    // Hazard Unit
    // ========================================================================
    hazard_unit hazard (
        .id_rs1      (icache_data[19:15]),  // Changed from if_instr to icache_data
        .id_rs2      (icache_data[24:20]),  // Changed from if_instr to icache_data
        .ex_rd       (ex_rd),
        .ex_mem_read (ex_mem_read),
        .stall       (stall),
        .flush       (flush)
    );
    
    // ========================================================================
    // Forwarding Unit
    // ========================================================================
    forwarding_unit fwd (
        .ex_rs1      (icache_data[19:15]),  // Changed from if_instr to icache_data
        .ex_rs2      (icache_data[24:20]),  // Changed from if_instr to icache_data
        .mem_rd      (mem_rd),
        .mem_reg_write(mem_reg_write),
        .wb_rd       (wb_rd),
        .wb_reg_write(wb_reg_write),
        .forward_a   (forward_a),
        .forward_b   (forward_b)
    );
    
    // Forwarding Muxes
    assign forward_rs1 = (forward_a == 2'b10) ? mem_alu_result :
                         (forward_a == 2'b01) ? wb_data :
                         id_rs1_data;
    
    assign forward_rs2 = (forward_b == 2'b10) ? mem_alu_result :
                         (forward_b == 2'b01) ? wb_data :
                         id_rs2_data;
    
    // ========================================================================
    // Branch Predictor
    // ========================================================================
    wire predict_taken;
    wire branch_mispredict;
    wire update_branch;
    wire [31:0] branch_pc;
    wire id_branch_ex;
    
    branch_predictor bp (
        .clk          (clk),
        .rst_n        (rst_n),
        .pc           (branch_pc),
        .branch_taken (branch_taken),
        .update       (update_branch),
        .predict_taken(predict_taken)
    );
    
    assign branch_pc = pc;
    assign update_branch = id_branch_ex; // Update when branch is in EX stage
    
    // ========================================================================
    // Execute Stage
    // ========================================================================
    wire [31:0] ex_alu_result_wire, ex_rs2_data_wire;
    wire [4:0]  ex_rd_wire;
    wire        ex_reg_write_wire, ex_mem_read_wire, ex_mem_write_wire;
    wire        branch_taken;
    wire [31:0] pc_next_wire;
    wire        branch_mispredict_wire;
    
    execute_stage execute (
        .clk           (clk),
        .rst_n         (rst_n),
        .rs1_data      (id_rs1_data),
        .rs2_data      (id_rs2_data),
        .imm           (id_imm),
        .pc_i          (id_pc),
        .rd_i          (id_rd),
        .reg_write_i   (id_reg_write),
        .mem_read_i    (id_mem_read),
        .mem_write_i   (id_mem_write),
        .alu_op_i      (id_alu_op),
        .alu_src_a_i   (id_alu_src_a),
        .alu_src_b_i   (id_alu_src_b),
        .branch_i      (id_branch),
        .jump_i        (id_jump),
        .branch_op_i   (id_branch_op),
        .forward_rs1   (forward_rs1),
        .forward_rs2   (forward_rs2),
        .predict_taken (predict_taken),
        .branch_mispredict_o (branch_mispredict_wire),
        .alu_result_o  (ex_alu_result_wire),
        .zero_o        (),
        .rs2_data_o    (ex_rs2_data_wire),
        .rd_o          (ex_rd_wire),
        .reg_write_o   (ex_reg_write_wire),
        .mem_read_o    (ex_mem_read_wire),
        .mem_write_o   (ex_mem_write_wire),
        .branch_taken_o(branch_taken),
        .pc_next_o     (pc_next_wire)
    );
    
    // Store EX/MEM results
    reg [31:0] ex_mem_alu_result, ex_mem_rs2_data;
    reg [4:0]  ex_mem_rd;
    reg        ex_mem_reg_write, ex_mem_mem_read, ex_mem_mem_write;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_mem_alu_result <= 32'h0;
            ex_mem_rs2_data <= 32'h0;
            ex_mem_rd <= 5'h0;
            ex_mem_reg_write <= 1'b0;
            ex_mem_mem_read <= 1'b0;
            ex_mem_mem_write <= 1'b0;
        end else begin
            ex_mem_alu_result <= ex_alu_result_wire;
            ex_mem_rs2_data <= ex_rs2_data_wire;
            ex_mem_rd <= ex_rd_wire;
            ex_mem_reg_write <= ex_reg_write_wire;
            ex_mem_mem_read <= ex_mem_read_wire;
            ex_mem_mem_write <= ex_mem_write_wire;
        end
    end
    
    assign ex_alu_result = ex_mem_alu_result;
    assign ex_rs2_data = ex_mem_rs2_data;
    assign ex_rd = ex_mem_rd;
    assign ex_reg_write = ex_mem_reg_write;
    assign ex_mem_read = ex_mem_mem_read;
    assign ex_mem_write = ex_mem_mem_write;
    
    // PC Update with branch prediction
    wire pc_sel_branch;
    assign pc_sel_branch = predict_taken; // Use prediction for PC selection
    assign pc_next = (branch_taken || (predict_taken && !branch_taken)) ? 
                     pc_next_wire : pc_plus_4;
    
    // Update branch predictor with actual branch result
    wire branch_resolved;
    assign branch_resolved = branch_taken;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= 32'h0;
        else if (!stall) begin
            if (branch_taken || (predict_taken && !branch_taken)) begin
                // Use branch target when taken or mispredicted
                pc <= pc_next_wire;
            end else begin
                pc <= pc_plus_4;
            end
        end
    end
    
    // Capture branch info for predictor update
    reg id_branch_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            id_branch_reg <= 1'b0;
        else
            id_branch_reg <= id_branch;
    end
    assign id_branch_ex = id_branch_reg;
    
    // ========================================================================
    // Memory Stage
    // ========================================================================
    memory_stage memory (
        .clk         (clk),
        .rst_n       (rst_n),
        .alu_result_i(ex_alu_result),
        .rs2_data_i  (ex_rs2_data),
        .rd_i        (ex_rd),
        .reg_write_i (ex_reg_write),
        .mem_read_i  (ex_mem_read),
        .mem_write_i (ex_mem_write),
        .addr_o      (addr_o),
        .data_o      (data_o),
        .data_i      (dcache_data),  // Changed from data_i to dcache_data
        .read_data_o (mem_read_data),
        .alu_result_o(mem_alu_result),
        .rd_o        (mem_rd),
        .reg_write_o (mem_reg_write),
        .mem_read_o  (mem_read_o),
        .mem_write_o (mem_write_o)
    );
    
    // ========================================================================
    // Writeback Stage
    // ========================================================================
    writeback_stage writeback (
        .clk         (clk),
        .rst_n       (rst_n),
        .alu_result_i(mem_alu_result),
        .mem_data_i  (mem_read_data),
        .rd_i        (mem_rd),
        .reg_write_i (mem_reg_write),
        .wb_data_o   (wb_data),
        .rd_o        (wb_rd),
        .reg_write_o (wb_reg_write)
    );
    
    // ========================================================================
    // Register File Write
    // ========================================================================
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                reg_file[i] <= 32'h0;
        end else begin
            if (wb_reg_write && wb_rd != 5'h0) begin
                reg_file[wb_rd] <= wb_data;
            end
        end
    end
    
    // Read ports
    assign rs1_data = (icache_data[19:15] == 5'h0) ? 32'h0 : reg_file[icache_data[19:15]];
    assign rs2_data = (icache_data[24:20] == 5'h0) ? 32'h0 : reg_file[icache_data[24:20]];
    
    // ========================================================================
    // Outputs
    // ========================================================================
    assign halt_o = 1'b0;

endmodule