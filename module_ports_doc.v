module cp0_reg (
    input   wire                    clk,                    // 时钟
    input   wire                    rst,                    // 复位

    input   wire                    we_i,                   // CP0写使能
    input   wire[4:0]               waddr_i,                // CP0写地址
    input   wire[4:0]               raddr_i,                // CP0读地址
    input   wire[`RegBus]           data_i,                 // CP0写数据

    input   wire[5:0]               int_i,                  // 外部中断输入

    input   wire[31:0]              excepttype_i,           // 异常类型
    input   wire[`RegBus]           current_inst_addr_i,    // 当前指令地址
    input   wire                    is_in_delayslot_i,      // 是否延迟槽

    output  reg[`RegBus]            data_o,                 // CP0读数据

    output  reg[`RegBus]            count_o,                // COUNT寄存器
    output  reg[`RegBus]            compare_o,              // COMPARE寄存器
    output  reg[`RegBus]            status_o,               // STATUS寄存器
    output  reg[`RegBus]            cause_o,                // CAUSE寄存器
    output  reg[`RegBus]            epc_o,                  // EPC寄存器
    output  reg[`RegBus]            config_o,               // CONFIG寄存器
    output  reg[`RegBus]            prid_o,                 // PRID寄存器

    output  reg                     timer_int_o             // 定时器中断输出
);

module ctrl (
    input   wire            rst,                            // 复位
    input   wire            stallreq_from_id,               // ID暂停请求
    input   wire            stallreq_from_ex,               // EX暂停请求

    input   wire[31:0]      excepttype_i,                   // 异常类型输入
    input   wire[`RegBus]   cp0_epc_i,                      // 异常返回地址

    output  reg[`RegBus]    new_pc,                         // 刷新后PC
    output  reg             flush,                          // 流水线刷新

    output  reg[5:0]        stall                           // 流水线暂停位
);

module data_ram (
    input   wire                clk,                        // 时钟
    input   wire                ce,                         // RAM片选
    input   wire                we,                         // RAM写使能
    input   wire[`DataAddrBus]  addr,                       // RAM地址
    input   wire[3:0]           sel,                        // 字节写掩码
    input   wire[`DataBus]      data_i,                     // 写入数据
    output  reg[`DataBus]       data_o,                     // 读出数据
    output  wire[`DataBus]      front_o                     // 前面板观察口
);

module div (
    input   wire                clk,                        // 时钟
    input   wire                rst,                        // 复位

    input   wire                signed_div_i,               // 有符号除法选择
    input   wire[31:0]          opdata1_i,                  // 被除数
    input   wire[31:0]          opdata2_i,                  // 除数
    input   wire                start_i,                    // 启动除法
    input   wire                annul_i,                    // 取消本次除法

    output  reg[63:0]           result_o,                   // 商余结果
    output  reg                 ready_o                     // 结果就绪
);

module ex (
    input   wire                    rst,                    // 复位

    input   wire[`AluOpBus]         aluop_i,                // ALU操作码
    input   wire[`AluSelBus]        alusel_i,               // ALU结果类型
    input   wire[`RegBus]           reg1_i,                 // 源操作数1
    input   wire[`RegBus]           reg2_i,                 // 源操作数2
    input   wire[`RegAddrBus]       wd_i,                   // 写回目的寄存器
    input   wire                    wreg_i,                 // 写回使能

    input   wire[`RegBus]           hi_i,                   // HI当前值
    input   wire[`RegBus]           lo_i,                   // LO当前值

    input   wire[`RegBus]           wb_hi_i,                // WB阶段HI
    input   wire[`RegBus]           wb_lo_i,                // WB阶段LO
    input   wire                    wb_whilo_i,             // WB写HI/LO使能

    input   wire[`RegBus]           mem_hi_i,               // MEM阶段HI
    input   wire[`RegBus]           mem_lo_i,               // MEM阶段LO
    input   wire                    mem_whilo_i,            // MEM写HI/LO使能

    input   wire[`DoubleRegBus]     hilo_temp_i,            // 乘除临时结果
    input   wire[1:0]               cnt_i,                  // 多周期计数

    input   wire[`DoubleRegBus]     div_result_i,           // 除法器结果
    input   wire                    div_ready_i,            // 除法器就绪

    input   wire[`RegBus]           link_address_i,         // 链接返回地址
    input   wire                    is_in_delayslot_i,      // 是否延迟槽
    input   wire[`RegBus]           inst_i,                 // 当前指令

    input   wire                    mem_cp0_reg_we,         // MEM写CP0使能
    input   wire[4:0]               mem_cp0_reg_write_addr, // MEM写CP0地址
    input   wire[`RegBus]           mem_cp0_reg_data,       // MEM写CP0数据

    input   wire                    wb_cp0_reg_we,          // WB写CP0使能
    input   wire[4:0]               wb_cp0_reg_write_addr,  // WB写CP0地址
    input   wire[`RegBus]           wb_cp0_reg_data,        // WB写CP0数据

    input   wire[31:0]              excepttype_i,           // 异常类型输入
    input   wire[`RegBus]           current_inst_address_i, // 当前指令地址

    output  reg[`RegAddrBus]        wd_o,                   // 写回目的寄存器
    output  reg                     wreg_o,                 // 写回使能
    output  reg[`RegBus]            wdata_o,                // 写回数据

    output  reg[`RegBus]            hi_o,                   // HI写数据
    output  reg[`RegBus]            lo_o,                   // LO写数据
    output  reg                     whilo_o,                // HI/LO写使能

    output  reg[`DoubleRegBus]      hilo_temp_o,            // 临时HILO输出
    output  reg[1:0]                cnt_o,                  // 多周期计数输出

    output  reg[`RegBus]            div_opdata1_o,          // 除法器被除数
    output  reg[`RegBus]            div_opdata2_o,          // 除法器除数
    output  reg                     div_start_o,            // 除法器启动
    output  reg                     signed_div_o,           // 除法器有符号选择

    output  wire[`AluOpBus]         aluop_o,                // 访存操作码
    output  wire[`RegBus]           mem_addr_o,             // 访存地址
    output  wire[`RegBus]           reg2_o,                 // 存储写数据源

    input   wire[`RegBus]           cp0_reg_data_i,         // CP0读数据
    output  reg[4:0]                cp0_reg_read_addr_o,    // CP0读地址

    output  reg                     cp0_reg_we_o,           // CP0写使能
    output  reg[4:0]                cp0_reg_write_addr_o,   // CP0写地址
    output  reg[`RegBus]            cp0_reg_data_o,         // CP0写数据

    output  wire[31:0]              excepttype_o,           // 异常类型输出
    output  wire                    is_in_delayslot_o,      // 延迟槽标记输出
    output  wire[`RegBus]           current_inst_address_o, // 指令地址输出

    output  reg                     stallreq                // EX暂停请求
);

module ex_mem (
    input   wire                    clk,                    // 时钟
    input   wire                    rst,                    // 复位

    input   wire[5:0]               stall,                  // 流水线暂停位
    input   wire                    flush,                  // 流水线刷新

    input   wire[`RegAddrBus]       ex_wd,                  // EX目的寄存器
    input   wire                    ex_wreg,                // EX写使能
    input   wire[`RegBus]           ex_wdata,               // EX写回数据
    input   wire[`RegBus]           ex_hi,                  // EX HI数据
    input   wire[`RegBus]           ex_lo,                  // EX LO数据
    input   wire                    ex_whilo,               // EX HI/LO写使能

    input   wire[`DoubleRegBus]     hilo_i,                 // EX临时HILO
    input   wire[1:0]               cnt_i,                  // EX多周期计数

    input   wire[`AluOpBus]         ex_aluop,               // EX访存操作码
    input   wire[`RegBus]           ex_mem_addr,            // EX访存地址
    input   wire[`RegBus]           ex_reg2,                // EX存储数据源

    input   wire                    ex_cp0_reg_we,          // EX写CP0使能
    input   wire[4:0]               ex_cp0_reg_write_addr,  // EX写CP0地址
    input   wire[`RegBus]           ex_cp0_reg_data,        // EX写CP0数据

    input   wire[31:0]              ex_excepttype,          // EX异常类型
    input   wire                    ex_is_in_delayslot,     // EX延迟槽标记
    input   wire[`RegBus]           ex_current_inst_address,// EX指令地址

    output  reg[`RegAddrBus]        mem_wd,                 // MEM目的寄存器
    output  reg                     mem_wreg,               // MEM写使能
    output  reg[`RegBus]            mem_wdata,              // MEM写回数据
    output  reg[`RegBus]            mem_hi,                 // MEM HI数据
    output  reg[`RegBus]            mem_lo,                 // MEM LO数据
    output  reg                     mem_whilo,              // MEM HI/LO写使能

    output  reg[`AluOpBus]          mem_aluop,              // MEM访存操作码
    output  reg[`RegBus]            mem_mem_addr,           // MEM访存地址
    output  reg[`RegBus]            mem_reg2,               // MEM存储数据源

    output  reg[`DoubleRegBus]      hilo_o,                 // MEM临时HILO
    output  reg[1:0]                cnt_o,                  // MEM多周期计数

    output  reg                     mem_cp0_reg_we,         // MEM写CP0使能
    output  reg[4:0]                mem_cp0_reg_write_addr, // MEM写CP0地址
    output  reg[`RegBus]            mem_cp0_reg_data,       // MEM写CP0数据

    output  reg[31:0]               mem_excepttype,         // MEM异常类型
    output  reg                     mem_is_in_delay_slot,   // MEM延迟槽标记
    output  reg[`RegBus]            mem_current_inst_address// MEM指令地址
);

module hilo_reg (
    input   wire                    clk,                    // 时钟
    input   wire                    rst,                    // 复位

    input   wire                    we,                     // HI/LO写使能
    input   wire[`RegBus]           hi_i,                   // HI写入值
    input   wire[`RegBus]           lo_i,                   // LO写入值

    output  reg[`RegBus]            hi_o,                   // HI读出值
    output  reg[`RegBus]            lo_o                    // LO读出值
);

module id (
    input   wire                    rst,                    // 复位
    input   wire[`InstAddrBus]      pc_i,                   // 当前PC
    input   wire[`InstBus]          inst_i,                 // 当前指令

    input   wire[`AluOpBus]         ex_aluop_i,             // EX操作码(冒险判断)
    input   wire                    is_in_delayslot_i,      // 当前是否延迟槽

    input   wire[`RegBus]           reg1_data_i,            // Regfile读口1数据
    input   wire[`RegBus]           reg2_data_i,            // Regfile读口2数据

    input   wire                    ex_wreg_i,              // EX写使能
    input   wire[`RegBus]           ex_wdata_i,             // EX写回数据
    input   wire[`RegAddrBus]       ex_wd_i,                // EX写回地址

    input   wire                    mem_wreg_i,             // MEM写使能
    input   wire[`RegBus]           mem_wdata_i,            // MEM写回数据
    input   wire[`RegAddrBus]       mem_wd_i,               // MEM写回地址

    output  reg                     reg1_read_o,            // Regfile读口1使能
    output  reg                     reg2_read_o,            // Regfile读口2使能
    output  reg[`RegAddrBus]        reg1_addr_o,            // Regfile读口1地址
    output  reg[`RegAddrBus]        reg2_addr_o,            // Regfile读口2地址

    output  reg[`AluOpBus]          aluop_o,                // 送EX操作码
    output  reg[`AluSelBus]         alusel_o,               // 送EX结果类型
    output  reg[`RegBus]            reg1_o,                 // 送EX操作数1
    output  reg[`RegBus]            reg2_o,                 // 送EX操作数2
    output  reg[`RegAddrBus]        wd_o,                   // 送EX写回地址
    output  reg                     wreg_o,                 // 送EX写使能

    output  reg                     next_inst_in_delayslot_o,// 下一条延迟槽标记

    output  reg                     branch_flag_o,          // 分支发生标记
    output  reg[`RegBus]            branch_target_address_o,// 分支目标地址
    output  reg[`RegBus]            link_addr_o,            // 链接地址
    output  reg                     is_in_delayslot_o,      // 本条延迟槽标记

    output  wire[`RegBus]           inst_o,                 // 透传指令

    output  wire[31:0]              excepttype_o,           // 异常类型输出
    output  wire[`RegBus]           current_inst_address_o, // 当前指令地址输出

    output  wire                    stallreq                // ID暂停请求
);

module id_ex (
    input   wire                    clk,                    // 时钟
    input   wire                    rst,                    // 复位

    input   wire                    flush,                  // 流水线刷新
    input   wire[5:0]               stall,                  // 流水线暂停位

    input   wire[`AluOpBus]         id_aluop,               // ID操作码
    input   wire[`AluSelBus]        id_alusel,              // ID结果类型
    input   wire[`RegBus]           id_reg1,                // ID操作数1
    input   wire[`RegBus]           id_reg2,                // ID操作数2
    input   wire[`RegAddrBus]       id_wd,                  // ID写回地址
    input   wire                    id_wreg,                // ID写使能

    input   wire[`RegBus]           id_link_address,        // ID链接地址
    input   wire                    id_is_in_delayslot,     // ID延迟槽标记
    input   wire                    next_inst_in_delayslot_i,// 下一条延迟槽输入

    input   wire[`RegBus]           id_inst,                // ID指令
    input   wire[`RegBus]           id_current_inst_address,// ID指令地址
    input   wire[31:0]              id_excepttype,          // ID异常类型

    output  reg[`AluOpBus]          ex_aluop,               // EX操作码
    output  reg[`AluSelBus]         ex_alusel,              // EX结果类型
    output  reg[`RegBus]            ex_reg1,                // EX操作数1
    output  reg[`RegBus]            ex_reg2,                // EX操作数2
    output  reg[`RegAddrBus]        ex_wd,                  // EX写回地址
    output  reg                     ex_wreg,                // EX写使能

    output  reg[`RegBus]            ex_link_address,        // EX链接地址
    output  reg                     ex_is_in_delayslot,     // EX延迟槽标记
    output  reg                     is_in_delayslot_o,      // 延迟槽透传输出

    output  reg[`RegBus]            ex_inst,                // EX指令
    output  reg[`RegBus]            ex_current_inst_address,// EX指令地址
    output  reg[31:0]               ex_excepttype           // EX异常类型
);

module if_id (
    input       wire                    clk,                // 时钟
    input       wire                    rst,                // 复位

    input       wire                    flush,              // 流水线刷新
    input       wire[5:0]               stall,              // 流水线暂停位

    input       wire[`InstAddrBus]      if_pc,              // IF阶段PC
    input       wire[`InstBus]          if_inst,            // IF阶段指令

    output      reg[`InstAddrBus]       id_pc,              // ID阶段PC
    output      reg[`InstBus]           id_inst             // ID阶段指令
);

module inst_rom (
    input   wire                    ce,                     // ROM片选
    input   wire[`InstAddrBus]      addr,                   // ROM地址
    output  reg[`InstBus]           inst                    // ROM指令输出
);

module LLbit_reg (
    input   wire            clk,                            // 时钟
    input   wire            rst,                            // 复位

    input   wire            flush,                          // 异常刷新清零
    input   wire            LLbit_i,                        // LLbit写入值
    input   wire            we,                             // LLbit写使能

    output  reg             LLbit_o                         // LLbit当前值
);

module mem (
    input   wire                        rst,                // 复位

    input   wire[`RegAddrBus]           wd_i,               // 写回目的寄存器
    input   wire                        wreg_i,             // 写回使能
    input   wire[`RegBus]               wdata_i,            // 写回数据
    input   wire[`RegBus]               hi_i,               // HI输入
    input   wire[`RegBus]               lo_i,               // LO输入
    input   wire                        whilo_i,            // HI/LO写使能

    input   wire[`AluOpBus]             aluop_i,            // 访存操作码
    input   wire[`RegBus]               mem_addr_i,         // 访存地址
    input   wire[`RegBus]               reg2_i,             // 存储写数据源
    input   wire[`RegBus]               mem_data_i,         // RAM读回数据

    input   wire                        LLbit_i,            // 当前LLbit
    input   wire                        wb_LLbit_we_i,      // WB写LLbit使能
    input   wire                        wb_LLbit_value_i,   // WB写LLbit值

    input   wire                        cp0_reg_we_i,       // MEM写CP0使能
    input   wire[4:0]                   cp0_reg_write_addr_i,// MEM写CP0地址
    input   wire[`RegBus]               cp0_reg_data_i,     // MEM写CP0数据

    input   wire[31:0]                  excepttype_i,       // 异常类型输入
    input   wire                        is_in_delayslot_i,  // 延迟槽标记输入
    input   wire[`RegBus]               current_inst_address_i,// 指令地址输入

    input   wire[`RegBus]               cp0_status_i,       // CP0 Status
    input   wire[`RegBus]               cp0_cause_i,        // CP0 Cause
    input   wire[`RegBus]               cp0_epc_i,          // CP0 EPC

    input   wire                        wb_cp0_reg_we,      // WB写CP0使能
    input   wire[4:0]                   wb_cp0_reg_write_addr,// WB写CP0地址
    input   wire[`RegBus]               wb_cp0_reg_data,    // WB写CP0数据

    output  reg[`RegAddrBus]            wd_o,               // 写回目的寄存器
    output  reg                         wreg_o,             // 写回使能
    output  reg[`RegBus]                wdata_o,            // 写回数据
    output  reg[`RegBus]                hi_o,               // HI输出
    output  reg[`RegBus]                lo_o,               // LO输出
    output  reg                         whilo_o,            // HI/LO写使能输出

    output  reg[`RegBus]                mem_addr_o,         // RAM地址输出
    output  wire                        mem_we_o,           // RAM写使能
    output  reg[3:0]                    mem_sel_o,          // RAM字节使能
    output  reg[`RegBus]                mem_data_o,         // RAM写数据
    output  reg                         mem_ce_o,           // RAM片选

    output  reg                         LLbit_we_o,         // LLbit写使能输出
    output  reg                         LLbit_value_o,      // LLbit写入值输出

    output  reg                         cp0_reg_we_o,       // CP0写使能输出
    output  reg[4:0]                    cp0_reg_write_addr_o,// CP0写地址输出
    output  reg[`RegBus]                cp0_reg_data_o,     // CP0写数据输出

    output  reg[31:0]                   excepttype_o,       // 异常类型输出
    output  wire[`RegBus]               cp0_epc_o,          // 异常返回地址
    output  wire                        is_in_delayslot_o,  // 延迟槽标记输出

    output  wire[`RegBus]               current_inst_address_o// 指令地址输出
);

module mem_wb (
    input   wire                    clk,                    // 时钟
    input   wire                    rst,                    // 复位

    input   wire[5:0]               stall,                  // 流水线暂停位
    input   wire                    flush,                  // 流水线刷新

    input   wire[`RegAddrBus]       mem_wd,                 // MEM目的寄存器
    input   wire                    mem_wreg,               // MEM写使能
    input   wire[`RegBus]           mem_wdata,              // MEM写回数据
    input   wire[`RegBus]           mem_hi,                 // MEM HI数据
    input   wire[`RegBus]           mem_lo,                 // MEM LO数据
    input   wire                    mem_whilo,              // MEM HI/LO写使能

    input   wire                    mem_LLbit_we,           // MEM写LLbit使能
    input   wire                    mem_LLbit_value,        // MEM写LLbit值

    input   wire                    mem_cp0_reg_we,         // MEM写CP0使能
    input   wire[4:0]               mem_cp0_reg_write_addr, // MEM写CP0地址
    input   wire[`RegBus]           mem_cp0_reg_data,       // MEM写CP0数据

    output  reg[`RegAddrBus]        wb_wd,                  // WB目的寄存器
    output  reg                     wb_wreg,                // WB写使能
    output  reg[`RegBus]            wb_wdata,               // WB写回数据
    output  reg[`RegBus]            wb_hi,                  // WB HI数据
    output  reg[`RegBus]            wb_lo,                  // WB LO数据
    output  reg                     wb_whilo,               // WB HI/LO写使能

    output  reg                     wb_LLbit_we,            // WB写LLbit使能
    output  reg                     wb_LLbit_value,         // WB写LLbit值

    output  reg                     wb_cp0_reg_we,          // WB写CP0使能
    output  reg[4:0]                wb_cp0_reg_write_addr,  // WB写CP0地址
    output  reg[`RegBus]            wb_cp0_reg_data         // WB写CP0数据
);

module openmips (
    input   wire                    clk,                    // 时钟
    input   wire                    rst,                    // 复位

    input   wire[5:0]               int_i,                  // 外部中断输入

    input   wire[`RegBus]           rom_data_i,             // 指令数据输入
    output  wire[`RegBus]           rom_addr_o,             // 指令地址输出
    output  wire                    rom_ce_o,               // 指令ROM片选

    input   wire[`RegBus]           ram_data_i,             // 数据RAM读数据
    output  wire[`RegBus]           ram_addr_o,             // 数据RAM地址
    output  wire[`RegBus]           ram_data_o,             // 数据RAM写数据
    output  wire                    ram_we_o,               // 数据RAM写使能
    output  wire[3:0]               ram_sel_o,              // 数据RAM字节使能
    output  wire                    ram_ce_o,               // 数据RAM片选

    output  wire                    timer_int_o             // 定时器中断输出
);

module openmips_min_sopc (
    input   wire            clk,                            // 系统时钟
    input   wire            rst,                            // 系统复位

    output  wire[`DataBus]  dram_front_o,                   // 数据RAM观察口
    output  wire[`DataBus]  pc_o,                           // 当前PC观察口
    output  wire[`DataBus]  inst_o                          // 当前指令观察口
);

module pc_reg (
    input   wire                clk,                        // 时钟
    input   wire                rst,                        // 复位
    input   wire[5:0]           stall,                      // 流水线暂停位

    input   wire                branch_flag_i,              // 分支发生标记
    input   wire[`RegBus]       branch_target_address_i,    // 分支目标地址

    input   wire                flush,                      // 流水线刷新
    input   wire[`RegBus]       new_pc,                     // 异常/跳转新PC

    output  reg[`InstAddrBus]   pc,                         // 当前取指PC
    output  reg                 ce                          // 指令存储器使能
);

module regfile (
    input   wire                clk,                        // 时钟
    input   wire                rst,                        // 复位

    input   wire                we,                         // 写使能
    input   wire[`RegAddrBus]   waddr,                      // 写地址
    input   wire[`RegBus]       wdata,                      // 写数据

    input   wire                re1,                        // 读口1使能
    input   wire[`RegAddrBus]   raddr1,                     // 读口1地址
    output  reg[`RegBus]        rdata1,                     // 读口1数据

    input   wire                re2,                        // 读口2使能
    input   wire[`RegAddrBus]   raddr2,                     // 读口2地址
    output  reg[`RegBus]        rdata2                      // 读口2数据
);

module seg7x16(
    input clk,                                               // 时钟
    input rst,                                               // 复位
    input cs,                                                // 显示片选/使能
    input [31:0] i_data,                                     // 待显示32位数据
    output [7:0] o_seg,                                      // 段选输出
    output [7:0] o_sel                                       // 位选输出
);

module sys_div(
    input   wire    i_clk,                                   // 输入时钟
    input   wire    i_rst,                                   // 复位
    output  wire    o_clk                                    // 分频后时钟
);

module top (
    input   wire                clk,                         // 板级时钟
    input   wire                rst,                         // 板级复位
    input   wire[`SegShowSelBus] sel,                        // 数码管显示源选择

    output  wire[7:0]           o_seg,                       // 数码管段选
    output  wire[7:0]           o_sel,                       // 数码管位选
    output  wire                clk_indicator                // 时钟指示输出
);
