module cp0_reg (
    input   wire                    clk,
    input   wire                    rst,

    input   wire                    we_i,
    input   wire[4:0]               waddr_i,
    input   wire[4:0]               raddr_i,
    input   wire[`RegBus]           data_i,

    input   wire[5:0]               int_i,

    output  reg[`RegBus]            data_o,

    output  reg                     timer_int_o
);

    reg[`RegBus]    count_o;
    reg[`RegBus]    compare_o;
    reg[`RegBus]    status_o;
    reg[`RegBus]    cause_o;
    reg[`RegBus]    epc_o;
    reg[`RegBus]    config_o;
    reg[`RegBus]    prid_o;

    // 写操作
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            count_o         <=  `ZeroWord;      // count == 0
            compare_o       <=  `ZeroWord;      // compare == 0
            status_o        <=  32'b0001_0000_0000_0000_0000_0000_0000_0000;
            cause_o         <=  `ZeroWord;
            epc_o           <=  `ZeroWord;
            config_o        <=  32'b0000_0000_0000_0000_1000_0000_0000_0000;        // MSB
            prid_o          <=  32'b0000_0000_0100_1100_0000_0001_0000_0010;
            timer_int_o     <=  `InterruptNotAssert;
        end else begin
            count_o         <=  count_o + 1;        // 每个时钟周期 + 1
            cause_o[15:10]  <=  int_i;              // cause 的 10 ~ 15bit 保存外部中断声明

            if (compare_o != `ZeroWord && count_o == compare_o) begin
                timer_int_o <=  `InterruptAssert;       // 时钟中断发生
            end

            if (we_i == `WriteEnable) begin
                case (waddr_i)
                    `CP0_REG_COUNT: begin
                        count_o <= data_i;     // 写 Count
                    end
                    `CP0_REG_COMPARE: begin
                        compare_o <= data_i;     // 写 Compare
                        timer_int_o <= `InterruptNotAssert;
                    end
                    `CP0_REG_STATUS: begin
                        status_o <= data_i;     // 写 Status
                    end
                    `CP0_REG_EPC: begin
                        epc_o <= data_i;     // 写 EPC
                    end
                    `CP0_REG_CAUSE: begin
                        cause_o[9:8] <= data_i[9:8];     // Cause 只有 IP[1:0], IV, WP 可写
                        cause_o[23] <= data_i[23];
                        cause_o[22] <= data_i[22];
                    end 
                endcase
            end
        end
    end

    // 读操作
    always @(*) begin
        if (rst == `RstEnable) begin
            data_o <= `ZeroWord;
        end else begin
            case (raddr_i)
                `CP0_REG_COUNT: begin       // 读 Count
                    data_o <= count_o;
                end
                `CP0_REG_COMPARE: begin     // 读 Compare
                    data_o <= compare_o;
                end
                `CP0_REG_STATUS: begin      // 读 Status
                    data_o <= status_o;
                end
                `CP0_REG_CAUSE: begin       // 读 Cause
                    data_o <= cause_o;
                end
                `CP0_REG_EPC: begin         // 读 EPC
                    data_o <= epc_o;
                end
                `CP0_REG_PRId: begin        // 读 PRId
                    data_o <= prid_o;
                end
                `CP0_REG_CONFIG: begin      // 读 Config
                    data_o <= config_o;
                end
                default: begin
                    
                end
            endcase
        end
    end
endmodule