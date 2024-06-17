`include "opcode.vh"
module cpu #(
    parameter CPU_CLOCK_FREQ = 50_000_000,
    parameter RESET_PC = 32'h4000_0000,
    parameter BAUD_RATE = 115200,
    parameter BIOS_MIF_HEX = ""
) (
    input clk,
    input rst,
    input bp_enable,    input serial_in,
    output serial_out
);

    localparam DWIDTH = 32;
    localparam BEWIDTH = DWIDTH / 8;

    // BIOS Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    localparam BIOS_AWIDTH = 12;
    wire [BIOS_AWIDTH-1:0] bios_addra, bios_addrb;
    wire [DWIDTH-1:0]      bios_douta, bios_doutb;
    wire                   bios_ena, bios_enb;
    assign bios_ena = 1'b1;
    assign bios_enb = 1'b1;
    SYNC_ROM_DP #(.AWIDTH(BIOS_AWIDTH),
                    .DWIDTH(DWIDTH),
                    .MIF_HEX(BIOS_MIF_HEX))
    bios_mem(.q0(bios_douta),
                .addr0(bios_addra),
                .en0(bios_ena),
                .q1(bios_doutb),
                .addr1(bios_addrb),
                .en1(bios_enb),
                .clk(clk));

    // Data Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    // Write-byte-enable: select which of the four bytes to write
    localparam DMEM_AWIDTH = 14;
    wire [DMEM_AWIDTH-1:0] dmem_addra;
    wire [DWIDTH-1:0]      dmem_dina, dmem_douta;
    wire [BEWIDTH-1:0]     dmem_wbea;
    wire                   dmem_ena;
    assign dmem_ena = 1'b1;
    SYNC_RAM_WBE #(.AWIDTH(DMEM_AWIDTH),
                    .DWIDTH(DWIDTH))
    dmem (.q(dmem_douta),
            .d(dmem_dina),
            .addr(dmem_addra),
            .wbe(dmem_wbea),
            .en(dmem_ena),
            .clk(clk));

    // Instruction Memory
    // Synchronous read: read takes one cycle
    // Synchronous write: write takes one cycle
    // Write-byte-enable: select which of the four bytes to write
    localparam IMEM_AWIDTH = 14;
    wire [IMEM_AWIDTH-1:0] imem_addra, imem_addrb;
    wire [DWIDTH-1:0]      imem_douta, imem_doutb;
    wire [DWIDTH-1:0]      imem_dina, imem_dinb;
    wire [BEWIDTH-1:0]     imem_wbea, imem_wbeb;
    wire                   imem_ena, imem_enb;
    assign imem_ena = 1'b1;
    assign imem_enb = 1'b1;
    SYNC_RAM_DP_WBE #(.AWIDTH(IMEM_AWIDTH),
                        .DWIDTH(DWIDTH))
    imem (.q0(imem_douta),
            .d0(imem_dina),
            .addr0(imem_addra),
            .wbe0(imem_wbea),
            .en0(imem_ena),
            .q1(imem_doutb),
            .d1(imem_dinb),
            .addr1(imem_addrb),
            .wbe1(imem_wbeb),
            .en1(imem_enb),
            .clk(clk));

    // Register file
    // Asynchronous read: read data is available in the same cycle
    // Synchronous write: write takes one cycle
    localparam RF_AWIDTH = 5;
    wire [RF_AWIDTH-1:0]   wa, ra1, ra2;
    wire [DWIDTH-1:0]      wd, rd1, rd2;
    wire                   we;
    ASYNC_RAM_1W2R # (.AWIDTH(RF_AWIDTH),
                        .DWIDTH(DWIDTH))
    rf (.addr0(wa),
        .d0(wd),
        .we0(we),
        .q1(rd1),
        .addr1(ra1),
        .q2(rd2),
        .addr2(ra2),
        .clk(clk));

    // On-chip UART
    //// UART Receiver
    wire [7:0]             uart_rx_data_out;
    wire                   uart_rx_data_out_valid;
    wire                   uart_rx_data_out_ready;
    //// UART Transmitter
    wire [7:0]             uart_tx_data_in;
    wire                   uart_tx_data_in_valid;
    wire                   uart_tx_data_in_ready;
    uart #(.CLOCK_FREQ(CPU_CLOCK_FREQ),
            .BAUD_RATE(BAUD_RATE))
    on_chip_uart (.clk(clk),
                    .reset(rst),
                    .serial_in(serial_in),
                    .data_out(uart_rx_data_out),
                    .data_out_valid(uart_rx_data_out_valid),
                    .data_out_ready(uart_rx_data_out_ready),
                    .serial_out(serial_out),
                    .data_in(uart_tx_data_in),
                    .data_in_valid(uart_tx_data_in_valid),
                    .data_in_ready(uart_tx_data_in_ready));

    // CSR
    wire [DWIDTH-1:0]      csr_dout, csr_din;
    wire                   csr_we;
    REGISTER_R_CE #(.N(DWIDTH))
    csr (.q(csr_dout),
            .d(csr_din),
            .rst(rst),
            .ce(csr_we),
            .clk(clk));

    /* IF Stage */
    wire                    jmp_flag;
    reg  [1:0]              pc_sel;
    wire [DWIDTH-1:0]       pc_in, pc_if, pc_plus_4;
    wire [DWIDTH-1:0]       inst, inst_if;
    wire [DWIDTH-1:0]       jmp_pc;

    assign pc_sel = {rst, jmp_flag};
    MuxKey # (
        .NR_KEY     ( 4         ),
        .KEY_LEN    ( 2         ),
        .DATA_LEN   ( DWIDTH    )
    ) u_pc_sel (
        .out        ( pc_in     ),
        .key        ( pc_sel    ),
        .lut        ({
            2'b00, pc_plus_4,
            2'b01, jmp_pc,
            2'b10, RESET_PC,
            2'b11, RESET_PC
        })
    );

    MuxKey # (
        .NR_KEY     ( 2             ),
        .KEY_LEN    ( 1             ),
        .DATA_LEN   ( DWIDTH        )
    ) ins_sel (
        .out        ( inst          ),
        .key        ( pc_if[30]     ),
        .lut        ({
            1'b0, imem_doutb,
            1'b1, bios_douta
        })
    );

    assign bios_addra = pc_in[BIOS_AWIDTH-1+2:2];
    assign imem_addrb = pc_in[IMEM_AWIDTH-1+2:2];

    REGISTER_R # (
        .N      ( DWIDTH    ),
        .INIT   ( RESET_PC  )
    ) pc (
        .q   	( pc_if     ),
        .d   	( pc_in     ),
        .rst    ( rst       ),
        .clk 	( clk       )
    );

    assign pc_plus_4 = pc_if + 4;
    assign inst_if = inst;

    /* EX Stage */
    wire [6:0] opcode = inst_if[6:0];
    wire [6:0] funct7 = inst_if[31:25];
    wire [2:0] funct3 = inst_if[14:12];
    wire [4:0] rd_ex;

    assign ra1 = inst_if[19:15];
    assign ra2 = inst_if[24:20];

    REGISTER_R # (
        .N      ( 5             )
    ) u_REGISTER (
        .q   	( rd_ex         ),
        .d   	( inst_if[11:7] ),
        .rst    ( rst           ),
        .clk 	( clk           )
    );

    wire csr_type, lui_type, auipc_type, jmp_type, br_type, st_type, ld_type, r_type, i_type;
    assign csr_type = opcode == `OPC_CSR;
    assign lui_type = opcode == `OPC_LUI;
    assign auipc_type = opcode == `OPC_AUIPC;
    assign jmp_type = opcode == `OPC_JAL || opcode == `OPC_JALR;
    assign br_type = opcode == `OPC_BRANCH;
    assign st_type = opcode == `OPC_STORE;
    assign ld_type = opcode == `OPC_LOAD;
    assign r_type = opcode == `OPC_ARI_RTYPE;
    assign i_type = opcode == `OPC_ARI_ITYPE;

    wire rf_we_ex, jmp_type_ex, ld_type_ex;
    REGISTER_R # (
        .N      ( 3                                         )
    ) decode_reg (
        .q      ( {rf_we_ex, jmp_type_ex, ld_type_ex}       ),
        .d      ( {~(st_type | br_type), jmp_type, ld_type} ),
        .rst    ( rst                                       ),
        .clk    ( clk                                       )
    );

    wire [DWIDTH-1:0] imm;
    immGen u_immGen (
        .inst       ( inst_if   ),
        .imm        ( imm       )
    );

    wire [DWIDTH-1:0] RS1, RS2;
    wire [3:0] alu_op;
    wire [DWIDTH-1:0] alu_srca, alu_srcb;
    wire [DWIDTH-1:0] alu_out, alu_sum;

    assign alu_op = i_type && funct3 == `FNC_ADD_SUB ? { 1'b0, funct3 } :
                    r_type || i_type ? { inst[30], funct3 } : { 1'b0, `FNC_ADD_SUB };

    MuxKey # (
        .NR_KEY     ( 2                                 ),
        .KEY_LEN    ( 1                                 ),
        .DATA_LEN   ( DWIDTH                            )
    ) a_sel (
        .out        ( alu_srca                          ),
        .key        ( opcode == `OPC_JAL || br_type || auipc_type ),
        .lut        ({
            1'b0, RS1,
            1'b1, pc_if
        })
    );

    MuxKey # (
        .NR_KEY     ( 2         ),
        .KEY_LEN    ( 1         ),
        .DATA_LEN   ( DWIDTH    )
    ) b_sel (
        .out        ( alu_srcb  ),
        .key        ( ~r_type   ),
        .lut        ({
            1'b0, RS2,
            1'b1, imm
        })
    );

    alu alu(
        .ina        ( alu_srca  ),
        .inb        ( alu_srcb  ),
        .as_inb     ( lui_type  ),
        .op         ( alu_op    ),
        .sum        ( alu_sum   ),
        .out        ( alu_out   ),
        .fr         (           )
    );

    wire [DWIDTH-1:0] alu_ex;
    REGISTER_R # (
        .N          ( DWIDTH    )
    ) alu_reg (
        .q          ( alu_ex    ),
        .d          ( alu_out   ),
        .rst        ( rst       ),
        .clk        ( clk       )
    );

    wire br_taken;

    brCond brCond (
        .ina        ( RS1       ),
        .inb        ( RS2       ),
        .br_type    ( funct3    ),
        .br_taken   ( br_taken  )
    );

    assign jmp_flag = jmp_type || (br_type && br_taken);

    assign jmp_pc = alu_sum;

    assign csr_we = csr_type;

    MuxKey # (
        .NR_KEY     ( 2         ),
        .KEY_LEN    ( 1         ),
        .DATA_LEN   ( DWIDTH    )
    ) imm_sel (
        .out        ( csr_din   ),
        .key        ( funct3[2] ),
        .lut        ({
            1'b0, RS1,
            1'b1, imm
        })
    );

    wire [3:0] wbe;
    wire [DWIDTH-1:0] wdata;
    storeControl u_storeControl (
        .sum_low    ( alu_sum[1:0]  ),
        .st_type    ( funct3        ),
        .din        ( RS2           ),
        .wbe        ( wbe           ),
        .dout       ( wdata         )
    );

    wire counterRst;
    assign counterRst = rst | (st_type & alu_out == 32'h80000018);
    wire [31:0] 	instCount;

    instCounter u_instCounter(
        .clk       	( clk        ),
        .rst       	( counterRst ),
        .valid     	( 1          ),
        .instCount 	( instCount  )
    );

    wire [31:0] 	cycleCount;

    cycleCounter u_cycleCounter(
        .clk        	( clk         ),
        .rst        	( counterRst  ),
        .cycleCount 	( cycleCount  )
    );

    wire [64:0]     usCount;

    timer # (
        .CPU_CLOCK_FREQ ( CPU_CLOCK_FREQ    )
    ) u_timer (
        .clk            ( clk               ),
        .rst            ( rst               ),
        .usCount        ( usCount           )
    );

    assign uart_tx_data_in = wdata[7:0];
    assign uart_tx_data_in_valid = st_type && (alu_out == 32'h80000008);

    assign bios_addrb = alu_out[BIOS_AWIDTH-1+2:2];

    assign dmem_addra = alu_out[DMEM_AWIDTH-1+2:2];
    assign dmem_dina = wdata;
    assign dmem_wbea = st_type & (~alu_out[31] & ~alu_out[30] & alu_out[28]) ? wbe : 4'b0000;

    assign imem_addra = alu_out[IMEM_AWIDTH-1+2:2];
    assign imem_dina = wdata;
    assign imem_wbea = st_type & (~alu_out[31] & ~alu_out[30] & alu_out[29]) & pc_if[30] ? wbe : 4'b0000;

    wire [DWIDTH-1:0] pc_ex;
    REGISTER_R # (
        .N      ( DWIDTH    )
    ) pc_reg_ex (
        .q      ( pc_ex     ),
        .d      ( pc_if     ),
        .rst    ( rst       ),
        .clk    ( clk       )
    );

    wire [2:0] funct3_ex;
    REGISTER_R # (
        .N      ( 3         )
    ) funct3_reg_ex (
        .q      ( funct3_ex ),
        .d      ( funct3    ),
        .rst    ( rst       ),
        .clk    ( clk       )
    );

    /* WB Stage */
    reg [DWIDTH-1:0] io_out;
    always @(*) begin
        case (alu_ex[27:0])
        28'h0000000: io_out = { 30'b0, uart_rx_data_out_valid, uart_tx_data_in_ready };
        28'h0000004: io_out = { 24'b0, uart_rx_data_out };
        28'h0000010: io_out = cycleCount;
        28'h0000014: io_out = instCount;
        28'h0000018: io_out = usCount[31:0];
        28'h000001C: io_out = usCount[63:32];
        default: io_out = 32'b0;
        endcase
    end
    assign uart_rx_data_out_ready = ld_type_ex && (alu_ex == 32'h80000004);

    wire [DWIDTH-1:0] pc_plus_4_wb;
    assign pc_plus_4_wb = pc_ex + 4;

    wire [DWIDTH-1:0] mem_out, ld_out;

    MuxKeyWithDefault# (
        .NR_KEY         ( 4             ),
        .KEY_LEN        ( 4             ),
        .DATA_LEN       ( DWIDTH        )
    ) mem_sel (
        .out            ( mem_out       ),
        .key            ( alu_ex[31:28] ),
        .default_out    ( 32'b0         ),
        .lut            ({
            4'b0001, dmem_douta,
            4'b0011, dmem_douta,
            4'b0100, bios_doutb,
            4'b1000, io_out
        })
    );

    loadControl loadControl (
        .sum_low    ( alu_ex[1:0]   ),
        .ld_type    ( funct3_ex     ),
        .din        ( mem_out       ),
        .dout       ( ld_out        )
    );

    assign pc_plus_4_wb = pc_ex + 4;

    MuxKey # (
        .NR_KEY     ( 4                         ),
        .KEY_LEN    ( 2                         ),
        .DATA_LEN   ( DWIDTH                    )
    ) wb_sel (
        .out        ( wd                        ),
        .key        ( {jmp_type_ex, ld_type_ex} ),
        .lut        ({
            2'b00,  alu_ex,
            2'b01,  ld_out,
            2'b10,  pc_plus_4_wb,
            2'b11,  pc_plus_4_wb
        })
    );

    assign wa = rd_ex;
    assign we = rf_we_ex && wa != 0;

    wire fw_taken;
    assign fw_taken = we;
    MuxKey # (
        .NR_KEY(2),
        .KEY_LEN(1),
        .DATA_LEN(DWIDTH)
    ) fwd1 (
        .out(RS1),
        .key(fw_taken && wa == ra1),
        .lut({
            1'b0, rd1,
            1'b1, wd
        })
    );

    MuxKey # (
        .NR_KEY(2),
        .KEY_LEN(1),
        .DATA_LEN(DWIDTH)
    ) fwd2 (
        .out(RS2),
        .key(fw_taken && wa == ra2),
        .lut({
            1'b0, rd2,
            1'b1, wd
        })
    );

endmodule
