module y86_64_top
(
    input wire clk,
    input wire rst
);

////////////////////////////////////////////////////////////////////////
//
// 数据宽度常量定义
//
////////////////////////////////////////////////////////////////////////

localparam   ICODE_WIDTH     = 4,
localparam   IFUN_WIDTH      = 4,
localparam   ALUOP_WIDTH     = 4,
localparam   REGS_WIDTH      = 4,
localparam   STATUS_WIDTH    = 4,
localparam   CC_WIDTH        = 3,

localparam   MEM_DATA_WIDTH  = 64,   //主存数据宽度
localparam   MEM_ADDR_WIDTH  = 64,    //主存地址宽度
localparam   PC_WIDTH        = 80;


////////////////////////////////////////////////////////////////////////
//
// 内部连线
//
////////////////////////////////////////////////////////////////////////

/* 内存连线 */

wire [MEM_DATA_WIDTH - 1 : 0]   mem_data_write_line;       //内存写数据线
wire [MEM_DATA_WIDTH - 1 : 0]   mem_data_read_line;        //内存读数据线
wire [MEM_ADDR_WIDTH - 1 : 0]   mem_data_addr_line;        //内存读写地址线
wire [MEM_ADDR_WIDTH - 1 : 0]   mem_instr_addr_line;       //内存指令地址线 
wire [PC_WIDTH - 1 : 0]         mem_instr_line;            //内存指令线

wire                            mem_write_en_line;         //内存写使能
wire                            mem_read_en_line;          //内存读使能

wire                            mem_instr_ok_line;      //内存指令成功状态
wire                            mem_data_ok_line;       //内存数据成功状态

/* ALU连线 */

wire [MEM_DATA_WIDTH - 1 : 0]        alu_a_line;        //alu A运算数连线
wire [MEM_DATA_WIDTH - 1 : 0]        alu_b_line;        //alu B运算数连线
wire [MEM_DATA_WIDTH - 1 : 0]        alu_e_line;        //alu 运算结果连线
wire [ALUOP_WIDTH - 1 : 0]           alu_fun_line;      //alu 运算ifun连线

/* CC和cond 连线*/

wire [IFUN_WIDTH - 1 : 0]            cc_ifun;
wire [CC_WIDTH - 1 : 0]              cc_set;            //ALU-CC CC数据线
wire [CC_WIDTH - 1 : 0]              cc;                //CC-Cond CC数据线

wire                                 cond_cnd;          //cnd运算结果，连接cond和y86-64-top
wire                                 cond_set;          //设置新的CC

/* 寄存器文件连线 */

wire [REGS_WIDTH - 1 : 0]            rf_srcA;
wire [RF_ADDR_WIDTH - 1 : 0]         rf_srcB;
wire [MEM_DATA_WIDTH - 1 : 0]        rf_rvalA;
wire [MEM_DATA_WIDTH - 1 : 0]        rf_rvalB;
wire [REGS_WIDTH - 1 : 0]            rf_dstM;
wire [REGS_WIDTH - 1 : 0]            rf_dstE;
wire [MEM_DATA_WIDTH - 1 : 0]        rf_valM;
wire [MEM_DATA_WIDTH - 1 : 0]        rf_valE;

////////////////////////////////////////////////////////////////////////
//
// 实例化模组
//
////////////////////////////////////////////////////////////////////////

/* 流水线电路 */
y86_64 #(
    .ICODE_WIDTH(ICODE_WIDTH),
    .IFUN_WIDTH(IFUN_WIDTH),
    .ALUOP_WIDTH(ALUOP_WIDTH),
    .REGS_WIDTH(REGS_WIDTH),

    .STATUS_WIDTH(STATUS_WIDTH),
    .CC_WIDTH(CC_WIDTH),

    .MEM_DATA_WIDTH(MEM_DATA_WIDTH),
    .MEM_ADDR_WIDTH(MEM_ADDR_WIDTH),
    .PC_WIDTH(PC_WIDTH)

) y86_64_pipe (
    .clk(clk),
    .rst(rst),

    .instr_addr(mem_instr_addr_line),
    .instr_din(mem_instr_line),

    .data_addr(mem_data_addr_line),
    .data_din(mem_data_read_line),
    .data_dout(mem_data_write_line),
    .data_we(mem_write_en_line),
    .data_re(mem_read_en_line),
    .imem_ok(mem_instr_ok_line),
    .dmem_ok(mem_data_ok_line),

    .alu_a(alu_a_line),
    .alu_b(alu_b_line),
    .alu_e(alu_e_line),
    .alu_fun(alu_fun_line),

    .cond_ifun(cc_ifun),
    .cond_cnd(cond_cnd),
    .cond_set(cond_set),

    .rf_srcA(rf_srcA),
    .rf_srcB(rf_srcB),
    .rf_rvalA(rf_rvalA),
    .rf_rvalB(rf_rvalB),
    .rf_dstM(rf_dstM),
    .rf_dstE(rf_dstE),
    .rf_valM(rf_valM),
    .rf_valE(rf_valE)
);

/* ALU */

alu alu(
    .aluA(alu_a_line),
    .aluB(alu_b_line),
    .valE(alu_e_line),
    .ifun(alu_fun_line),
    .newCC(cc_set)
);

/* 寄存器文件 */
registerFile rf (
    .clock(clk),
    .reset(rst),
    .srcA(rf_srcA),
    .srcB(rf_srcB),
    .valA(rf_rvalA),
    .valB(rf_rvalB),
    .dstM(rf_dstM),
    .dstE(rf_dstE),
    .valM(rf_valM),
    .valE(rf_valE)
);

/* 内存 */

Merory memory (
    .maddr(mem_data_addr_line),
    .wenable(mem_write_en_line),
    .wdata(mem_data_write_line),
    .renable(mem_read_en_line),
    .rdata(mem_data_read_line),
    .m_ok(mem_data_ok_line),
    .iaddr(mem_instr_addr_line),
    .instr(mem_instr_line),
    .i_ok(mem_instr_ok_line),
    .clock(clk)
);

/* Cond逻辑 */

cond cond(
    .ifun(cc_ifun),
    .cc(cc),
    .Cnd(cond_cnd)
)

/* CC寄存器 */

CC CC(
    .cc(cc),
    .newCC(cc_set),
    .setCC(cond_set),
    .reset(rst),
    .clock(clk)
)
endmodule