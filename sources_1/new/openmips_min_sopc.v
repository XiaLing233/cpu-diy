module openmips_min_sopc (
    input   wire    clk,
    input   wire    rst
);
    // 连接指令存储器
    wire[`InstAddrBus]  inst_addr;
    wire[`InstBus]      inst;
    wire[`InstBus]      inst_from_ip;
    wire                rom_ce;

    wire                mem_we_i;
    wire[`RegBus]       mem_addr_i;
    wire[`RegBus]       mem_data_i;
    wire[`RegBus]       mem_data_o;
    wire[3:0]           mem_sel_i;
    wire                mem_ce_i;

    wire[5:0]           int;
    wire                timer_int;

    assign int = {5'b00000, timer_int};

    // 实例化处理器 OpenMIPS
    openmips openmips0(
        .clk(clk),                  .rst(rst),
        .rom_addr_o(inst_addr),     .rom_data_i(inst),
        .rom_ce_o(rom_ce),

        .int_i(int),

        .ram_we_o(mem_we_i),        .ram_addr_o(mem_addr_i),
        .ram_sel_o(mem_sel_i),      .ram_data_o(mem_data_i),
        .ram_data_i(mem_data_o),    .ram_ce_o(mem_ce_i),

        .timer_int_o(timer_int)
    );

    // 实例化处理器 ROM
    // inst_rom inst_rom0(
    //     .ce(rom_ce),
    //     .addr(inst_addr),           .inst(inst)
    // );

    ip_inst_rom ip_inst_rom0(
        .a(inst_addr[12:2]),
        .spo(inst_from_ip)
    );

    // IP 核无 CE 端口，使用外部门控保持与原 inst_rom 一致的行为
    assign inst = (rom_ce == `ChipEnable) ? inst_from_ip : `ZeroWord;

    data_ram data_ram0(
        .clk(clk),                  .we(mem_we_i),
        .addr(mem_addr_i),          .sel(mem_sel_i),
        .data_i(mem_data_i),        .data_o(mem_data_o),
        .ce(mem_ce_i)
    );
endmodule