module riscv_core_pipeline (
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
    // IF Stage - Program Counter
    // ========================================================================
    reg [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    wire        stall;
    wire        flush;
    
    assign pc_plus_4 = pc + 32'h4;
    assign pc_o = pc;
    
    // ========================================================================
    // IF/ID Pipeline Register
    // ========================================================================
    reg [31:0] if_id_pc, if_id_instr;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            if_id_pc <= 32'h0;
            if_id_instr <= 32'h0;
        end else if (!stall) begin
            if_id_pc <= pc;
            if_id_instr <= instr_i;
        end
    end
    
    // ========================================================================
    // ID Stage - Decode
    // ========================================================================
    wire [6:0] opcode = if_id_instr[6:0];
    wire [2:0] funct3 = if_id_instr[14:12];
    wire [6:0] funct7 = if_id_instr[31:25];
    wire [4:0] rs1 = if_id_instr[19:15];
    wire [4:0] rs2 = if_id_instr[24:20];
    wire [4:0] rd = if_id_instr[11:7];
    
    // Immediate
    wire [31:0] imm_i = {{20{if_id_instr[31]}}, if_id_instr[31:20]};
    wire [31:0] imm_s = {{20{if_id_instr[31]}}, if_id_instr[31:25], if_id_instr[11:7]};
    wire [31:0] imm_b = {{20{if_id_instr[31]}}, if_id_instr[7], if_id_instr[30:25], if_id_instr[11:8], 1'b0};
    wire [31:0] imm_u = {if_id_instr[31:12], 12'h0};
    wire [31:0] imm_j = {{12{if_id_instr[31]}}, if_id_instr[19:12], if_id_instr[20], if_id_instr[30:21], 1'b0};
    
    wire [31:0] imm = (opcode == 7'b0000011 || opcode == 7'b0010011 || opcode == 7'b1100111) ? imm_i :
                      (opcode == 7'b0100011) ? imm_s :
                      (opcode == 7'b1100011) ? imm_b :
                      (opcode == 7'b0110111 || opcode == 7'b0010111) ? imm_u :
                      (opcode == 7'b1101111) ? imm_j :
                      32'h0;
    
    wire [2:0] imm_type = (opcode == 7'b0000011 || opcode == 7'b0010011) ? 3'b000 :
                          (opcode == 7'b0100011) ? 3'b001 :
                          (opcode == 7'b1100011) ? 3'b010 :
                          (opcode == 7'b0110111 || opcode == 7'b0010111) ? 3'b011 :
                          (opcode == 7'b1101111) ? 3'b100 :
                          3'b000;
    
    // Control Signals
    wire reg_write, mem_read, mem_write;
    wire [4:0] alu_op;
    wire [1:0] alu_src_a, alu_src_b;
    wire branch, jump;
    wire [2:0] branch_op;
    
    control_unit ctrl (
        .opcode     (opcode),
        .funct3     (funct3),
        .funct7     (funct7),
        .reg_write  (reg_write),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .alu_op     (alu_op),
        .alu_src_a  (alu_src_a),
        .alu_src_b  (alu_src_b),
        .imm_type   (imm_type),
        .branch     (branch),
        .jump       (jump),
        .jump_reg   (),
        .branch_op  (branch_op)
    );
    
    // ========================================================================
    // Register File
    // ========================================================================
    reg [31:0] reg_file [0:31];
    wire [31:0] rs1_data, rs2_data;
    assign rs1_data = (rs1 == 5'h0) ? 32'h0 : reg_file[rs1];
    assign rs2_data = (rs2 == 5'h0) ? 32'h0 : reg_file[rs2];
    
    // ========================================================================
    // ID/EX Pipeline Register
    // ========================================================================
    reg [31:0] id_ex_rs1, id_ex_rs2, id_ex_imm, id_ex_pc;
    reg [4:0]  id_ex_rd;
    reg        id_ex_reg_write, id_ex_mem_read, id_ex_mem_write;
    reg [4:0]  id_ex_alu_op;
    reg [1:0]  id_ex_alu_src_a, id_ex_alu_src_b;
    reg        id_ex_branch;
    reg [2:0]  id_ex_branch_op;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            id_ex_rs1 <= 32'h0;
            id_ex_rs2 <= 32'h0;
            id_ex_imm <= 32'h0;
            id_ex_pc <= 32'h0;
            id_ex_rd <= 5'h0;
            id_ex_reg_write <= 1'b0;
            id_ex_mem_read <= 1'b0;
            id_ex_mem_write <= 1'b0;
            id_ex_alu_op <= 5'h0;
            id_ex_alu_src_a <= 2'h0;
            id_ex_alu_src_b <= 2'h0;
            id_ex_branch <= 1'b0;
            id_ex_branch_op <= 3'h0;
        end else if (!stall) begin
            id_ex_rs1 <= rs1_data;
            id_ex_rs2 <= rs2_data;
            id_ex_imm <= imm;
            id_ex_pc <= if_id_pc;
            id_ex_rd <= rd;
            id_ex_reg_write <= reg_write;
            id_ex_mem_read <= mem_read;
            id_ex_mem_write <= mem_write;
            id_ex_alu_op <= alu_op;
            id_ex_alu_src_a <= alu_src_a;
            id_ex_alu_src_b <= alu_src_b;
            id_ex_branch <= branch;
            id_ex_branch_op <= branch_op;
        end
    end
    
    // ========================================================================
    // Hazard Detection Unit
    // ========================================================================
    assign stall = id_ex_mem_read && (id_ex_rd == rs1 || id_ex_rd == rs2) && (id_ex_rd != 5'h0);
    assign flush = stall;
    
    // ========================================================================
    // Forwarding Unit
    // ========================================================================
    reg [31:0] ex_mem_alu_result, ex_mem_rs2;
    reg [4:0]  ex_mem_rd;
    reg        ex_mem_reg_write;
    
    reg [31:0] mem_wb_alu_result, mem_wb_mem_data;
    reg [4:0]  mem_wb_rd;
    reg        mem_wb_reg_write;
    
    wire [1:0] forward_a, forward_b;
    wire [31:0] fwd_rs1, fwd_rs2;
    
    wire fwd_a_ex_mem = ex_mem_reg_write && (ex_mem_rd != 5'h0) && (ex_mem_rd == rs1);
    wire fwd_b_ex_mem = ex_mem_reg_write && (ex_mem_rd != 5'h0) && (ex_mem_rd == rs2);
    wire fwd_a_mem_wb = mem_wb_reg_write && (mem_wb_rd != 5'h0) && (mem_wb_rd == rs1);
    wire fwd_b_mem_wb = mem_wb_reg_write && (mem_wb_rd != 5'h0) && (mem_wb_rd == rs2);
    
    assign forward_a = fwd_a_ex_mem ? 2'b10 : fwd_a_mem_wb ? 2'b01 : 2'b00;
    assign forward_b = fwd_b_ex_mem ? 2'b10 : fwd_b_mem_wb ? 2'b01 : 2'b00;
    
    assign fwd_rs1 = (forward_a == 2'b10) ? ex_mem_alu_result :
                     (forward_a == 2'b01) ? mem_wb_data :
                     id_ex_rs1;
    
    assign fwd_rs2 = (forward_b == 2'b10) ? ex_mem_alu_result :
                     (forward_b == 2'b01) ? mem_wb_data :
                     id_ex_rs2;
    
    // ========================================================================
    // EX Stage - ALU
    // ========================================================================
    wire [31:0] alu_a, alu_b;
    wire [31:0] alu_result;
    wire        alu_zero;
    
    assign alu_a = (id_ex_alu_src_a == 2'b01) ? id_ex_pc :
                   (id_ex_alu_src_a == 2'b10) ? id_ex_imm :
                   fwd_rs1;
    assign alu_b = (id_ex_alu_src_b == 2'b01) ? id_ex_imm : fwd_rs2;
    
    alu alu_inst (
        .a      (alu_a),
        .b      (alu_b),
        .op     (id_ex_alu_op),
        .result (alu_result),
        .zero   (alu_zero),
        .carry_out(),
        .overflow()
    );
    
    // Branch Logic
    wire branch_taken;
    assign branch_taken = id_ex_branch && (
        (id_ex_branch_op == 3'b000 && alu_zero) ||
        (id_ex_branch_op == 3'b001 && ~alu_zero)
    );
    
    // PC Next
    assign pc_next = branch_taken ? (id_ex_pc + id_ex_imm) : pc_plus_4;
    
    // PC Update
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= 32'h0;
        else if (!stall)
            pc <= pc_next;
    end
    
    // ========================================================================
    // EX/MEM Pipeline Register
    // ========================================================================
    reg [31:0] ex_mem_alu_result_reg, ex_mem_rs2_reg;
    reg [4:0]  ex_mem_rd_reg;
    reg        ex_mem_reg_write_reg, ex_mem_mem_read_reg, ex_mem_mem_write_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_mem_alu_result_reg <= 32'h0;
            ex_mem_rs2_reg <= 32'h0;
            ex_mem_rd_reg <= 5'h0;
            ex_mem_reg_write_reg <= 1'b0;
            ex_mem_mem_read_reg <= 1'b0;
            ex_mem_mem_write_reg <= 1'b0;
        end else begin
            ex_mem_alu_result_reg <= alu_result;
            ex_mem_rs2_reg <= fwd_rs2;
            ex_mem_rd_reg <= id_ex_rd;
            ex_mem_reg_write_reg <= id_ex_reg_write;
            ex_mem_mem_read_reg <= id_ex_mem_read;
            ex_mem_mem_write_reg <= id_ex_mem_write;
        end
    end
    
    assign ex_mem_alu_result = ex_mem_alu_result_reg;
    assign ex_mem_rs2 = ex_mem_rs2_reg;
    assign ex_mem_rd = ex_mem_rd_reg;
    assign ex_mem_reg_write = ex_mem_reg_write_reg;
    
    // ========================================================================
    // MEM Stage - Memory
    // ========================================================================
    wire [31:0] mem_data;
    
    memory_stage memory (
        .clk        (clk),
        .rst_n      (rst_n),
        .alu_result (ex_mem_alu_result_reg),
        .rs2_data   (ex_mem_rs2_reg),
        .mem_read   (ex_mem_mem_read_reg),
        .mem_write  (ex_mem_mem_write_reg),
        .addr_o     (addr_o),
        .data_o     (data_o),
        .data_i     (data_i),
        .read_data  (mem_data)
    );
    
    // ========================================================================
    // MEM/WB Pipeline Register
    // ========================================================================
    reg [31:0] mem_wb_alu_result_reg, mem_wb_mem_data_reg;
    reg [4:0]  mem_wb_rd_reg;
    reg        mem_wb_reg_write_reg;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_wb_alu_result_reg <= 32'h0;
            mem_wb_mem_data_reg <= 32'h0;
            mem_wb_rd_reg <= 5'h0;
            mem_wb_reg_write_reg <= 1'b0;
        end else begin
            mem_wb_alu_result_reg <= ex_mem_alu_result_reg;
            mem_wb_mem_data_reg <= mem_data;
            mem_wb_rd_reg <= ex_mem_rd_reg;
            mem_wb_reg_write_reg <= ex_mem_reg_write_reg;
        end
    end
    
    assign mem_wb_alu_result = mem_wb_alu_result_reg;
    assign mem_wb_mem_data = mem_wb_mem_data_reg;
    assign mem_wb_rd = mem_wb_rd_reg;
    assign mem_wb_reg_write = mem_wb_reg_write_reg;
    
    // ========================================================================
    // WB Stage - Writeback
    // ========================================================================
    wire [31:0] mem_wb_data;
    assign mem_wb_data = mem_wb_mem_data ? mem_wb_mem_data : mem_wb_alu_result;
    
    // ========================================================================
    // Register File Write
    // ========================================================================
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                reg_file[i] <= 32'h0;
        end else begin
            if (mem_wb_reg_write && mem_wb_rd != 5'h0) begin
                reg_file[mem_wb_rd] <= mem_wb_data;
            end
        end
    end
    
    // ========================================================================
    // Outputs
    // ========================================================================
    assign mem_write_o = ex_mem_mem_write_reg;
    assign mem_read_o = ex_mem_mem_read_reg;
    assign halt_o = 1'b0;

endmodule