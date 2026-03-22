module if_id (
    input       wire                    clk,
    input       wire                    rst,

    input       wire                    flush,

    input       wire[5:0]               stall,

    // 来自取指阶段的信号，其中宏定义 InstBus 表示指令宽度，为 32
    input       wire[`InstAddrBus]      if_pc,
    input       wire[`InstBus]          if_inst,

    // 对应译码阶段的信号
    output      reg[`InstAddrBus]       id_pc,
    output      reg[`InstBus]           id_inst
);
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc   <=  `ZeroWord;          // 复位的时候 pc 为 0
            id_inst <=  `ZeroWord;          // 复位的时候指令也为 0，实际就是空指令
        end else if (flush == 1'b1) begin
            // flush == 1 说明异常发生，要清除流水线
            id_pc   <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else if (stall[1] == `Stop && stall[2] == `NoStop) begin        // if 暂停，id 不暂停
            id_pc   <=  `ZeroWord;
            id_inst <=  `ZeroWord;
        end else if (stall[1] == `NoStop) begin                             // if 不暂停
            id_pc   <=  if_pc;
            id_inst <=  if_inst;
        end                                 // 其余情况保持值不变
    end
endmodule