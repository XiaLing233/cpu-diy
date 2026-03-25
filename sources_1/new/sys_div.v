module sys_div(
    input   wire    i_clk,      // 100MHz 的输入
    input   wire    i_rst,      // 复位信号
    output  wire    o_clk       // 分频后的 CPU 时钟输出
);

parameter integer INPUT_FREQ  = 100_000_000;
parameter integer OUTPUT_FREQ = 512;
localparam integer HALF_PERIOD = INPUT_FREQ / (2 * OUTPUT_FREQ);

reg [31:0] div_cnt;
reg        o_clk_r;

always @ (posedge i_clk) begin
    if (i_rst) begin
        div_cnt <= 32'b0;
        o_clk_r <= 1'b0;
    end else if (div_cnt == HALF_PERIOD - 1) begin
        div_cnt <= 32'b0;
        o_clk_r <= ~o_clk_r;
    end else begin
        div_cnt <= div_cnt + 1'b1;
    end
end

assign o_clk = o_clk_r;
endmodule