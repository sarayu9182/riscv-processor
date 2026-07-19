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

    // PC
    reg [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    
    assign pc_plus_4 = pc + 32'h4;
    assign pc_o = pc;
    
    // IF/ID signals
    wire [31:0] if_pc, if_instr;
    wire [31:0] id_pc, id_instr;
    
    // ID/EX signals
    wire [31:0] id_imm, id_rs1, id_rs2;
    wire [4:0]  id_rd;
    wire        id_reg_write, id_mem_read, id_mem_write;
    wire [4:0]  id_alu_op;
    wire [1:0]  id_alu_src_a, id_alu_src_b;
    wire        id_branch, id_jump;
    wire [2:0]  id_branch_op;
    
    wire [31:0] ex_rs1, ex_rs2, ex_imm;
    wire [4:0]  ex_rd;
    wire        ex_reg_write, ex_mem_read, ex_mem_write;
    wire [4:0]  ex_alu_op;
    wire [1:0]  ex_alu_src_a, ex_alu_src_b;
    
    // EX/MEM signals
    wire [31:0] mem_alu_result, mem_rs2;
    wire [4:0]  mem_rd;
    wire        mem_reg_write, mem_mem_read, mem_mem_write;
    wire [31:0] mem_data;
    
    // MEM/WB signals
    wire [31:0] wb_data, wb_alu_result, wb_mem_data;
    wire [4:0]  wb_rd;
    wire        wb_reg_write;
    
    // Control signals
    wire reg_write, mem_read, mem_write;
    wire [4:0] alu_op;
    wire [1:0] alu_src_a, alu_src_b;
    wire branch, jump;
    wire [2:0] branch_op;
    wire [2:0] imm_type;
    
    // Stall and flush
    wire stall, flush;
    
    // Decode signals
    wire [6:0] opcode = id_instr[6:0];
    wire [2:0] funct3 = id_instr[14:12];
    wire [6:0] funct7 = id_instr[31:25];
    wire [4:0] rs1 = id_instr[19:15];
    wire [4:0] rs2 = id_instr[24:20];
    wire [4:0] rd = id_instr[11:7];
    
    // Immediate
    wire [31:0] imm_i = {{20{id_instr[31]}}, id_instr[31:20]};
    wire [31:0] imm_s = {{20{id_instr[31]}}, id_instr[31:25], id_instr[11:7]};
    wire [31:0] imm_b = {{20{id_instr[31]}}, id_instr[7], id_instr[30:25], id_instr[11:8], 1'b0};
    wire [31:0] imm_u = {id_instr[31:12], 12'h0};
    wire [31:0] imm_j = {{12{id_instr[31]}}, id_instr[19:12], id_instr[20], id_instr[30:21], 1'b0};
    
    wire [31:0] imm;
    assign imm = (opcode == 7'b0000011 || opcode == 7'b0010011 || opcode == 7'b1100111) ? imm_i :
                 (opcode == 7'b0100011) ? imm_s :
                 (opcode == 7'b1100011) ? imm_b :
                 (opcode == 7'b0110111 || opcode == 7'b0010111) ? imm_u :
                 (opcode == 7'b1101111) ? imm_j :
                 32'h0;
    
    assign imm_type = (opcode == 7'b0000011 || opcode == 7'b0010011) ? 3'b000 :
                      (opcode == 7'b0100011) ? 3'b001 :
                      (opcode == 7'b1100011) ? 3'b010 :
                      (opcode == 7'b0110111 || opcode == 7'b0010111) ? 3'b011 :
                      (opcode == 7'b1101111) ? 3'b100 :
                      3'b000;
    
    // Register File
    reg [31:0] reg_file [0:31];
    wire [31:0] rs1_data, rs2_data;
    assign rs1_data = (rs1 == 5'h0) ? 32'h0 : reg_file[rs1];
    assign rs2_data = (rs2 == 5'h0) ? 32'h0 : reg_file[rs2];
    
    // Control Unit
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
    
    // Pipeline Registers
    pipeline_registers pipe (
        .clk            (clk),
        .rst_n          (rst_n),
        .stall          (stall),
        .flush          (flush),
        .if_pc          (pc),
        .if_instr       (instr_i),
        .id_pc          (if_pc),
        .id_instr       (if_instr),
        .id_rs1         (rs1_data),
        .id_rs2         (rs2_data),
        .id_imm         (imm),
        .id_rd          (rd),
        .id_reg_write   (reg_write),
        .id_mem_read    (mem_read),
        .id_mem_write   (mem_write),
        .id_alu_op      (alu_op),
        .id_alu_src_a   (alu_src_a),
        .id_alu_src_b   (alu_src_b),
        .ex_rs1         (ex_rs1),
        .ex_rs2         (ex_rs2),
        .ex_imm         (ex_imm),
        .ex_rd          (ex_rd),
        .ex_reg_write   (ex_reg_write),
        .ex_mem_read    (ex_mem_read),
        .ex_mem_write   (ex_mem_write),
        .ex_alu_op      (ex_alu_op),
        .ex_alu_src_a   (ex_alu_src_a),
        .ex_alu_src_b   (ex_alu_src_b),
        .ex_alu_result  (ex_alu_result),
        .ex_rs2_mem     (ex_rs2),
        .ex_rd_mem      (ex_rd),
        .ex_mem_read_mem(ex_mem_read),
        .ex_mem_write_mem(ex_mem_write),
        .ex_reg_write_mem(ex_reg_write),
        .mem_alu_result (mem_alu_result),
        .mem_rs2        (mem_rs2),
        .mem_rd         (mem_rd),
        .mem_mem_read   (mem_mem_read),
        .mem_mem_write  (mem_mem_write),
        .mem_reg_write  (mem_reg_write),
        .mem_read_data  (mem_data),
        .mem_alu_wb     (mem_alu_result),
        .mem_rd_wb      (mem_rd),
        .mem_reg_write_wb(mem_reg_write),
        .wb_read_data   (wb_mem_data),
        .wb_alu_result  (wb_alu_result),
        .wb_rd          (wb_rd),
        .wb_reg_write   (wb_reg_write)
    );
    
    // ========================================================================
    // Hazard Detection
    // ========================================================================
    assign stall = ex_mem_read && (ex_rd == rs1 || ex_rd == rs2) && (ex_rd != 5'h0);
    assign flush = stall;
    
    // ========================================================================
    // EX Stage - ALU
    // ========================================================================
    wire [31:0] alu_a, alu_b;
    wire [31:0] alu_result;
    wire        alu_zero;
    
    assign alu_a = (ex_alu_src_a == 2'b01) ? id_pc :
                   (ex_alu_src_a == 2'b10) ? ex_imm :
                   ex_rs1;
    assign alu_b = (ex_alu_src_b == 2'b01) ? ex_imm : ex_rs2;
    
    alu alu_inst (
        .a      (alu_a),
        .b      (alu_b),
        .op     (ex_alu_op),
        .result (alu_result),
        .zero   (alu_zero),
        .carry_out(),
        .overflow()
    );
    
    assign ex_alu_result = alu_result;
    assign ex_rs2 = ex_rs2;
    
    // ========================================================================
    // Branch Logic
    // ========================================================================
    wire branch_taken;
    assign branch_taken = ex_branch && (
        (ex_branch_op == 3'b000 && alu_zero) ||
        (ex_branch_op == 3'b001 && ~alu_zero)
    );
    
    // ========================================================================
    // PC Update
    // ========================================================================
    assign pc_next = branch_taken ? (ex_pc + ex_imm) : pc_plus_4;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= 32'h0;
        else if (!stall)
            pc <= pc_next;
    end
    
    // ========================================================================
    // Memory Stage
    // ========================================================================
    memory_stage memory (
        .clk        (clk),
        .rst_n      (rst_n),
        .alu_result (mem_alu_result),
        .rs2_data   (mem_rs2),
        .mem_read   (mem_mem_read),
        .mem_write  (mem_mem_write),
        .addr_o     (addr_o),
        .data_o     (data_o),
        .data_i     (data_i),
        .read_data  (mem_data)
    );
    
    // ========================================================================
    // Writeback Stage
    // ========================================================================
    assign wb_data = wb_mem_data ? wb_mem_data : wb_alu_result;
    
    // Register File Write
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
    
    // ========================================================================
    // Outputs
    // ========================================================================
    assign mem_write_o = mem_mem_write;
    assign mem_read_o = mem_mem_read;
    assign halt_o = 1'b0;

endmodule