module pc_reg (
    input   wire                clk,
    input   wire                rst,
    input   wire[5:0]           stall,      // 来自控制模块 CTRL

    // 来自译码阶段 ID 的信息
    input   wire                branch_flag_i,
    input   wire[`RegBus]       branch_target_address_i,
    
    input   wire                flush,
    input   wire[`RegBus]       new_pc,

    output  reg[`InstAddrBus]   pc,
    output  reg                 ce
);
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable;             // 复位的时候指令存储器禁用
        end else begin
            ce <= `ChipEnable;              // 复位结束后，指令存储器使能
        end
    end

    always @(posedge clk) begin
        if (ce == `ChipDisable) begin
            pc <= 32'h00000000;             // 指令存储器禁用的时候，PC 为 0
        end else begin
            if (flush == 1'b1) begin
                // flush == 1 说明异常发生，将从 CTRL 模块给出的 new_pc 处开始执行
                pc <= new_pc;
            end else if (stall[0] == `NoStop) begin     // 不暂停时才继续，否则保持 pc 不变
                if (branch_flag_i == `Branch) begin
                    pc <= branch_target_address_i;
                end else begin
                    pc <= pc + 4'h4;                // 指令存储器使能的时候，PC 的值每时钟周期加
                end
            end
        end 
    end
endmodule