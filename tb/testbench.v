`timescale 1ns/1ps

module testbench;

    reg clk;
    reg rst_n;
    
    wire [31:0] pc;
    wire [31:0] addr;
    wire [31:0] data_o;
    wire        mem_write;
    wire        mem_read;
    wire        halt;
    
    reg [31:0] instr_mem [0:1023];
    reg [31:0] data_mem [0:1023];
    wire [31:0] instr_data;
    wire [31:0] mem_data;
    
    integer test_passed;
    integer test_failed;
    integer cycle_count;
    
    riscv_core dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .instr_i    (instr_data),
        .data_i     (mem_data),
        .pc_o       (pc),
        .addr_o     (addr),
        .data_o     (data_o),
        .mem_write_o(mem_write),
        .mem_read_o (mem_read),
        .halt_o     (halt)
    );
    
    assign instr_data = instr_mem[pc[11:2]];
    assign mem_data = data_mem[addr[11:2]];
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        for (integer i = 0; i < 1024; i = i + 1) begin
            instr_mem[i] = 32'h0;
            data_mem[i] = 32'h0;
        end
        
        $readmemh("tb/tests/rv32ui-p-add.hex", instr_mem);
        
        test_passed = 0;
        test_failed = 0;
        cycle_count = 0;
        
        $display("Instructions loaded:");
        $display("  [0] 0x%08h", instr_mem[0]);
        $display("  [1] 0x%08h", instr_mem[1]);
        $display("  [2] 0x%08h", instr_mem[2]);
        
        rst_n = 0;
        #100;
        rst_n = 1;
        $display("Reset released at time %0t", $time);
        
        while (cycle_count < 100) begin
            @(negedge clk);
            cycle_count = cycle_count + 1;
            
            if (mem_write) begin
                $display("CYCLE %0d: WRITE at addr=0x%08h data=0x%08h pc=0x%08h", 
                         cycle_count, addr, data_o, pc);
                data_mem[addr[11:2]] = data_o;
            end
            
            if (cycle_count < 20) begin
                $display("CYCLE %0d: pc=0x%08h instr=0x%08h mem_write=%0d", 
                         cycle_count, pc, instr_data, mem_write);
            end
        end
        
        #10;
        $display("========================================");
        $display("Final data_mem[0] = 0x%08h", data_mem[0]);
        $display("Expected = 0x0000000A");
        
        if (data_mem[0] == 32'h0000000A) begin
            $display("✅ TEST PASSED!");
            test_passed = 1;
        end else begin
            $display("❌ TEST FAILED!");
            test_failed = 1;
        end
        
        $display("========================================");
        $finish;
    end
    
    initial begin
        $dumpfile("sim/waveforms.vcd");
        $dumpvars(0, testbench);
    end

endmodule