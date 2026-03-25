module top (
    input   wire        clk,
    input   wire        rst,
    input   wire[`SegShowSelBus]   sel,

    output  wire[7:0]   o_seg,
    output  wire[7:0]   o_sel,
    output  wire        clk_indicator
);

    wire[`DataBus]  dram_front;
    wire[`DataBus]  dbg_pc;
    wire[`DataBus]  dbg_inst;
    wire            cpu_clk;
    wire            rst_cpu;
    reg             rst_sync_ff1;
    reg             rst_sync_ff2;
    reg [25:0]      clk_led_cnt;
    reg             clk_indicator_r;
    reg[`DataBus]   seg_data_sel;

    // 外部复位异步置位，释放同步到 CPU 时钟域
    always @(posedge cpu_clk or posedge rst) begin
        if (rst) begin
            rst_sync_ff1 <= 1'b1;
            rst_sync_ff2 <= 1'b1;
        end else begin
            rst_sync_ff1 <= 1'b0;
            rst_sync_ff2 <= rst_sync_ff1;
        end
    end

    assign rst_cpu = rst_sync_ff2;

    // 使用系统时钟驱动指示灯，输出 1s 周期（0.5s 翻转一次）
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            clk_led_cnt <= 26'd0;
            clk_indicator_r <= 1'b0;
        end else if (clk_led_cnt == 26'd49_999_999) begin
            clk_led_cnt <= 26'd0;
            clk_indicator_r <= ~clk_indicator_r;
        end else begin
            clk_led_cnt <= clk_led_cnt + 1'b1;
        end
    end

    assign clk_indicator = clk_indicator_r;

    always @(*) begin
        case (sel)
            `SegShowPC: begin
                seg_data_sel = dbg_pc;
            end
            `SegShowInst: begin
                seg_data_sel = dbg_inst;
            end
            `SegShowDram0: begin
                seg_data_sel = dram_front;
            end
            default: begin
                seg_data_sel = dram_front;
            end
        endcase
    end

    openmips_min_sopc openmips_min_sopc0(
        .clk(cpu_clk),
        .rst(rst_cpu),
        .dram_front_o(dram_front),
        .pc_o(dbg_pc),
        .inst_o(dbg_inst)
    );

    sys_div sys_div0(
        .i_clk(clk),
        .i_rst(rst),
        .o_clk(cpu_clk)
    );

    seg7x16 seg7x160(
        .clk(clk),              .rst(rst),
        .cs(1'b1),              .i_data(seg_data_sel),
        .o_seg(o_seg),          .o_sel(o_sel)
    );

endmodule