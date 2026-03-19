`include "defines.v"

module pc_reg (
    input   wire                clk,
    input   wire                rst,
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
            pc <= pc + 4'h4;                // 指令存储器使能的时候，PC 的值每时钟周期加
        end
    end

endmodule