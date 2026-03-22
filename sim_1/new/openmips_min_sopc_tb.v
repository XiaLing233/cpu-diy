// 时间单位是 1ns，精度是 1ps
`timescale 1ns/1ps

module openmips_min_sopc_tb();

    reg     CLOCK_50;
    reg     rst;

    integer file_output;

    // 每隔 10ns，CLOCK_50 信号翻转一次，所以一个周期是 20ns，对应 50MHz
    initial begin
        CLOCK_50 = 1'b0;
        forever begin
            #10 CLOCK_50 = ~CLOCK_50;
            if ((rst == `RstDisable) && (CLOCK_50 == 1'b1)) begin
                $fdisplay(file_output, "pc: %h", openmips_min_sopc_tb.openmips_min_sopc0.openmips0.if_id0.if_pc);
                $fdisplay(file_output, "instr: %h", openmips_min_sopc_tb.openmips_min_sopc0.openmips0.if_id0.if_inst);
                $fdisplay(file_output, "regfile0: %h", openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[0]);
                $fdisplay(file_output, "regfile1: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[1]);
                $fdisplay(file_output, "regfile2: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[2]);
                $fdisplay(file_output, "regfile3: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[3]);
                $fdisplay(file_output, "regfile4: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[4]);
                $fdisplay(file_output, "regfile5: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[5]);
                $fdisplay(file_output, "regfile6: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[6]);
                $fdisplay(file_output, "regfile7: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[7]);
                $fdisplay(file_output, "regfile8: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[8]);
                $fdisplay(file_output, "regfile9: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[9]);
                $fdisplay(file_output, "regfile10: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[10]);
                $fdisplay(file_output, "regfile11: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[11]);
                $fdisplay(file_output, "regfile12: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[12]);
                $fdisplay(file_output, "regfile13: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[13]);
                $fdisplay(file_output, "regfile14: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[14]);
                $fdisplay(file_output, "regfile15: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[15]);
                $fdisplay(file_output, "regfile16: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[16]);
                $fdisplay(file_output, "regfile17: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[17]);
                $fdisplay(file_output, "regfile18: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[18]);
                $fdisplay(file_output, "regfile19: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[19]);
                $fdisplay(file_output, "regfile20: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[20]);
                $fdisplay(file_output, "regfile21: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[21]);
                $fdisplay(file_output, "regfile22: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[22]);
                $fdisplay(file_output, "regfile23: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[23]);
                $fdisplay(file_output, "regfile24: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[24]);
                $fdisplay(file_output, "regfile25: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[25]);
                $fdisplay(file_output, "regfile26: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[26]);
                $fdisplay(file_output, "regfile27: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[27]);
                $fdisplay(file_output, "regfile28: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[28]);
                $fdisplay(file_output, "regfile29: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[29]);
                $fdisplay(file_output, "regfile30: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[30]);
                $fdisplay(file_output, "regfile31: %h",openmips_min_sopc_tb.openmips_min_sopc0.openmips0.regfile1.regs[31]);
            end
        end
    end

    // 最初时刻，复位信号有效，在第 195ns，复位信号无效，最小 SOPC 开始运行
    // 运行 1000ns 后，暂停仿真
    initial begin
        rst = `RstEnable;
        #195 rst = `RstDisable;
        #100000 $stop;
    end

    initial begin
        file_output = $fopen("89_diy_out.txt");
    end

    // 实例化最小 SOPC
    openmips_min_sopc openmips_min_sopc0(
        .clk(CLOCK_50),
        .rst(rst)
    );

endmodule