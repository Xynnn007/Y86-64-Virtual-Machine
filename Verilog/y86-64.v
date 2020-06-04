module y86_64
#(

////////////////////////////////////////////////////
//
//	数据宽度定义
//
////////////////////////////////////////////////////

parameter	ICODE_WIDTH		= 4,
parameter	IFUN_WIDTH		= 4,
parameter	ALUOP_WIDTH		= 4,
parameter	REGS_WIDTH		= 4,
parameter	STATUS_WIDTH 	= 4,
parameter	CC_WIDTH 		= 3,

parameter 	MEM_DATA_WIDTH	= 64,	//主存数据宽度
parameter	MEM_ADDR_WIDTH	= 64,	//主存地址宽度
parameter 	PC_WIDTH 		= 80	//指令读取长度

)
(
//输入输出

	input 	wire 				clk,  			//时钟
	input 	wire 				rst,			//0位重置

/* 内存接口 */
    output wire [MEM_ADDR_WIDTH - 1 : 0]  		instr_addr,
    input wire [PC_WIDTH - 1 : 0]           	instr_din,

    output reg [MEM_ADDR_WIDTH - 1 : 0]   		data_addr,
    input wire [MEM_DATA_WIDTH - 1 : 0]         data_din,
    output wire [MEM_DATA_WIDTH - 1 : 0]        data_dout,
    output wire                         		data_we,
    output wire 								data_re,
    input  wire 								imem_ok,
	input  wire 								dmem_ok;						


/* ALU 接口 */
    output wire [MEM_DATA_WIDTH - 1 : 0]        alu_a,
    output wire [MEM_DATA_WIDTH - 1 : 0]        alu_b,
    input  wire [MEM_DATA_WIDTH - 1 : 0]        alu_e,
    output wire [IFUN_WIDTH - 1 : 0] 			alu_fun,

/* Cond 接口 */
	output wire [IFUN_WIDTH - 1 : 0]			cond_ifun,
	output wire 								cond_set,
	input  wire 								cond_cnd,

//外部总共定义的时候，需要单独定义cond，并将它和ALU对应的接口相连接

/* 寄存器文件接口 */
    output wire [REGS_WIDTH - 1 : 0]     		rf_srcA,
    output wire [REGS_WIDTH - 1 : 0]     		rf_srcB,
    input wire [MEM_DATA_WIDTH - 1 : 0]         rf_rvalA,
    input wire [MEM_DATA_WIDTH - 1 : 0]         rf_rvalB,
    output wire [REGS_WIDTH - 1 : 0]     		rf_dstM,
    output wire [REGS_WIDTH - 1 : 0]     		rf_dstE,
    output wire [MEM_DATA_WIDTH - 1 : 0]        rf_valM,
    output wire [MEM_DATA_WIDTH - 1 : 0]        rf_valE

);


////////////////////////////////////////////////////
//
//	局部变量定义
//
////////////////////////////////////////////////////


/* instructions */
localparam 	IHALT 	= 4'h0,	//停机
			INOP  	= 4'h1,	//nop
			IRRMOVQ	= 4'h2,	//rrmovq
			IIRMOVQ = 4'h3,	//irmovq
			IRMMOVQ = 4'h4,	//rmmovq
			IMRMOVQ = 4'h5,	//mrmovq
			IOPL	= 4'h6,	//op
			IJXX    = 4'h7,	//跳转
			ICALL   = 4'h8,	//call
			IRET	= 4'h9,	//ret
			IPUSHQ  = 4'hA,	//pushq
			IPOPQ 	= 4'hB;	//popq

/* function codes */
localparam FNONE	= 4'h0; //空

/* Registers */
localparam	RRAX	= 4'h0,
			RRCX	= 4'h1,
			RRDX	= 4'h2,
			RRBX	= 4'h3,
			RRSP	= 4'h4,	//栈地址基址寄存器
			RRBP	= 4'h5,
			RRSI	= 4'h6,
			RRDI	= 4'h7,
			RR8		= 4'h8,
			RR9		= 4'h9,
			RR10	= 4'hA,
			RR11	= 4'hB,
			RR12	= 4'hC,
			RR13	= 4'hD,
			RR14	= 4'hE,
			RNONE	= 4'hF;	//无寄存器

/* Int operations */
localparam	OPADDQ	= 4'h0,
			OPSUBQ	= 4'h1,
			OPANDQ	= 4'h2,
			OPXORQ	= 4'h3;

/* Condition flags */
localparam	CF_NONE 	= 4'h0, //无条件
			CF_LE		= 4'h1,
			CF_L 		= 4'h2,
			CF_E 		= 4'h3,
			CF_NE 		= 4'h4,
			CF_GE 		= 4'h5,
			CF_G 		= 4'h6;

/* Status register */
localparam	SAOK		= 4'h1,
			SADR		= 4'h2,
			SINS		= 4'h3,
			SHLT		= 4'h4;

/* CC param */
localparam 	ZF	=	0,
			SF	=	1,
			OF	=	2;

////////////////////////////////////////////////////
//
//	流水线寄存器
//
////////////////////////////////////////////////////
/* 全局寄存器 */

reg 	[STATUS_WIDTH - 1 : 0] 		Stutas;

/* 取指阶段  F */

reg 	[MEM_ADDR_WIDTH - 1 : 0]	F_predPC;

/* 译码阶段  D */

reg 	[STATUS_WIDTH - 1 : 0]		D_stat;
reg 	[ICODE_WIDTH - 1 : 0]		D_icode;
reg 	[IFUN_WIDTH - 1 : 0]		D_ifun;
reg 	[REGS_WIDTH - 1 : 0]		D_rA;
reg 	[REGS_WIDTH - 1 : 0]		D_rB;
reg 	[MEM_DATA_WIDTH - 1 : 0]	D_valC;
reg 	[MEM_DATA_WIDTH - 1 : 0]	D_valP;

/* 执行阶段 E */

reg 	[STATUS_WIDTH - 1 : 0]		E_stat;
reg 	[ICODE_WIDTH - 1 : 0]		E_icode;
reg 	[IFUN_WIDTH - 1 : 0]		E_ifun;
reg 	[MEM_DATA_WIDTH - 1 : 0]	E_valA;
reg 	[MEM_DATA_WIDTH - 1 : 0]	E_valB;
reg 	[MEM_DATA_WIDTH - 1 : 0]	E_valC;
reg 	[REGS_WIDTH - 1 : 0]		E_dstE;
reg 	[REGS_WIDTH - 1 : 0]		E_dstM;
reg 	[REGS_WIDTH - 1 : 0]		E_srcA;
reg 	[REGS_WIDTH - 1 : 0]		E_srcB;

/* 访存阶段 M */

reg 	[STATUS_WIDTH - 1 : 0]		M_stat;
reg 	[ICODE_WIDTH - 1 : 0]		M_icode;
reg 								M_cnd;
reg 	[MEM_DATA_WIDTH - 1 : 0]	M_valE;
reg 	[MEM_DATA_WIDTH - 1 : 0]	M_valA;
reg 	[REGS_WIDTH - 1 : 0]		M_dstE;
reg 	[REGS_WIDTH - 1 : 0]		M_dstM;

/* 写回阶段 W */

reg 	[STATUS_WIDTH - 1 : 0]		W_stat;
reg 	[ICODE_WIDTH - 1 : 0]		W_icode;
reg 	[MEM_DATA_WIDTH - 1 : 0]	W_valE;
reg 	[MEM_DATA_WIDTH - 1 : 0]	W_valM;
reg 	[REGS_WIDTH - 1 : 0]		W_dstE;
reg 	[REGS_WIDTH - 1 : 0]		W_dstM;

////////////////////////////////////////////////////
//
//	流水线控制逻辑
//
////////////////////////////////////////////////////

wire 								F_stall;
wire 								D_bubble;
wire 								D_stall;
wire 								E_bubble;
wire 								M_bubble;
wire 								W_stall;

assign 	F_stall 	= 	(E_icode == IMRMOVQ || E_icode == IPOPQ) && (E_dstM == d_srcA || E_dstM == d_srcB) ||
						D_icode == IRET || E_icode == IRET || M_icode == IRET;

assign 	D_bubble 	= 	(E_icode == IJXX && !e_cnd)	|| 
						!((E_icode == IMRMOVQ || E_icode == IPOPQ) && (E_dstM == d_srcA || E_dstM == d_srcB)) && 
						(D_icode == IRET || E_icode == IRET || M_icode == IRET);
assign 	D_stall 	= 	(E_icode == IMRMOVQ || E_icode == IPOPQ) && (E_dstM == d_srcA || E_dstM == d_srcB);
assign 	E_bubble 	= 	(E_icode == IJXX && !e_cnd) || (E_icode == IMRMOVQ || E_icode == IPOPQ) && (E_dstM == d_srcA || E_dstM == d_srcB);
assign 	M_bubble 	=	(m_stat == SADR || m_stat == SINS || m_stat == SHLT) ||  (W_stat == SADR || W_stat == SINS || W_stat == SHLT);
assign 	W_stall 	= 	W_stat == SADR || W_stat == SINS || W_stat == SHLT;

always @(posedge clk)
begin
	if(!rst)
	begin
		Status <= SAOK;
	end
	else
	begin
		Status <= W_stat;
	end
end

////////////////////////////////////////////////////
//
//	PC选择和取指阶段
//
////////////////////////////////////////////////////

wire 	[MEM_ADDR_WIDTH - 1 : 0]	f_pc;
wire 	[MEM_ADDR_WIDTH - 1 : 0]	f_predPC;
wire 	[STATUS_WIDTH - 1 : 0]		f_stat;
wire 								need_regids;
wire 								need_valC;
wire 								need_regids;
wire 	[ICODE_WIDTH - 1 : 0]		f_icode;
wire 	[IFUN_WIDTH - 1 : 0]		f_ifun;
wire 	[REGS_WIDTH - 1 : 0] 		f_rA;
wire 	[REGS_WIDTH - 1 : 0] 		f_rB;
wire 	[MEM_DATA_WIDTH - 1 : 0] 	f_valC;
wire 	[MEM_ADDR_WIDTH - 1 : 0] 	f_valP;
wire 								instr_valid;
wire 								imem_error;

always @(f_icode, f_ifun)
begin
	case(f_icode)
		IOPQ   :
            begin
                case(f_ifun)
                    ALUADD : instr_valid = 1'b1;
                    ALUSUB : instr_valid = 1'b1;
                    ALUAND : instr_valid = 1'b1;
                    ALUXOR : instr_valid = 1'b1;
                    default: instr_valid = 1'b0;
                endcase
            end
            IJXX   :
            begin
                case(f_ifun)
                    FNONE  : instr_valid = 1'b1;
                    FLE    : instr_valid = 1'b1;
                    FL     : instr_valid = 1'b1;
                    FE     : instr_valid = 1'b1;
                    FNE    : instr_valid = 1'b1;
                    FGE    : instr_valid = 1'b1;
                    FG     : instr_valid = 1'b1;
                    default: instr_valid = 1'b0;
                endcase
            end
            IHALT  : instr_valid = 1'b1;
            4'hD   : instr_valid = 1'b0;
            4'hE   : instr_valid = 1'b0;
            4'hF   : instr_valid = 1'b0;
            default: instr_valid = 1'b1;
        endcase
end

assign 	imem_error = !imem_ok;

assign	f_pc = M_icode == IJXX  && !M_cnd ? M_valA :
				W_icode == IRET ? 			W_valM :
				F_predPC;

assign	f_predPC = f_icode == IJXX || f_icode == ICALL ? f_valC : f_valP;

assign	f_stat	 = imem_error ? SADR :
					!instr_valid ? SINS :
					f_icode == IHALT ?	SHLT :
					SAOK;

assign 	need_regids = f_icode == IRRMOVQ || f_icode == IOPQ || f_icode == IPUSHQ || f_icode == IPOPQ 
								|| f_icode == IIRMOVQ || f_icode == IRMMOVQ || f_icode == IMRMOVQ;

assign 	need_valC 	= f_icode == IIRMOVQ || f_icode == IRMMOVQ || f_icode == IMRMOVQ || f_icode == IJXX || f_icode == ICALL;

assign 	f_ifun	 	= instr_din[3 : 0]; 
assign 	f_icode	 	= instr_din[7 : 4]; 
assign 	f_rA 		= need_regids ? instr_din[11 : 8] : RNONE; 
assign 	f_rB 		= need_regids ? instr_din[15 : 12] : RNONE; 
assign 	f_valC 		= need_regids ? instr_din[79 : 16] : instr_din[71 : 8]; 
assign  f_valP 		= f_pc + 1 + need_regids + 8 * need_valC;
assign  instr_addr 	= f_pc;

always @(posedge clk)
begin
	if( !rst )
		begin
			F_predPC <= 0;
		end
	else
		begin
			F_predPC <= f_predPC;
		end
end

always @(posedge clk)
begin
	if(!rst || D_bubble)
	begin
		D_stat 	<= SAOK;
		D_icode <= INOP;
		D_ifun 	<= FNONE;
		D_rA 	<= RNONE;
		D_rB 	<= RNONE;
		D_valC 	<= 0;
		D_valP 	<= 0;
	end
	else if(D_stall)
	begin
		D_stat 	<= D_stat;
		D_icode <= D_icode;
		D_ifun 	<= D_ifun;
		D_rA 	<= D_rA;
		D_rA 	<= D_rA;
		D_valC 	<= D_valC;
		D_valP 	<= D_valP;
	end
	else
	begin
		D_stat 	<= f_stat;
		D_icode <= f_icode;
		D_ifun 	<= f_ifun;
		D_rA 	<= f_rA;
		D_rB 	<= f_rB;
		D_valC 	<= f_valC;
		D_valP 	<= f_valP;
	end
end

////////////////////////////////////////////////////
//
//	译码和写回阶段
//
////////////////////////////////////////////////////

wire    [MEM_DATA_WIDTH - 1 : 0]		d_valA;
wire    [MEM_DATA_WIDTH - 1 : 0]		d_valB;
wire 	[REGS_WIDTH - 1 : 0]			d_dstE;
wire 	[MEM_ADDR_WIDTH - 1 : 0]		d_dstM;
wire 	[REGS_WIDTH - 1 : 0] 			d_srcA;
wire 	[REGS_WIDTH - 1 : 0] 			d_srcB;
wire    [MEM_DATA_WIDTH - 1 : 0]		d_rvalA;
wire    [MEM_DATA_WIDTH - 1 : 0]		d_rvalB;

assign 	d_srcA 		= 	D_icode == IRRMOVQ || D_icode == IRMMOVQ || D_icode == IOPQ || D_icode == IPUSHQ ? 	D_rA:
						D_icode == IPOPQ || D_icode == IRET ?	RRSP:
						RNONE;

assign 	d_srcB 		= 	D_icode == IOPQ || D_icode == IRMMOVQ || D_icode == IMRMOVQ ? 	D_rB:
						D_icode == IPOPQ || D_icode == IPUSHQ || D_icode == ICALL || D_icode == IRET ?	RRSP:
						RNONE;					

assign  d_rvalA 	=   rf_rvalA;

assign  d_rvalB 	=   rf_rvalB;

assign  rf_dstM 	=   W_dstM;

assign  rf_valM 	=   W_valM;

assign  rf_dstE		=   W_dstE;

assign  rf_valE		= 	W_valE;

assign 	d_dstE 		= 	D_icode == IRRMOVQ || D_icode == IIRMOVQ || D_icode == IOPQ ?	D_rB:
						D_icode == IPUSHQ || D_icode == IPOPQ || D_icode == ICALL || D_icode == IRET ?	RRSP:
						RNONE;

assign 	d_dstM 		= 	D_icode == IMRMOVQ || D_icode == IPOPQ ?	D_rA:
						RNONE;

assign 	d_valA		= 	D_icode == ICALL || D_icode == IJXX ? D_valP :
						d_srcA 	== e_dstE ? e_valE	:
						d_srcA  == M_dstM ? m_valM 	:
						d_srcA  == M_dstE ? M_valE  :
						d_srcA  == W_dstM ? W_valM  :
						d_srcA  == W_dstE ? W_valE  :
						d_rvalA;

assign  d_valB		=   d_srcB == e_dstE ? e_valE	:
						d_srcB == M_dstM ? m_valM	:
						d_srcB == M_dstE ? M_valE   :
						d_srcB == W_dstM ? W_valM   :
						d_srcB == W_dstE ? W_valE   :
						d_rvalB;
always @(posedge clk)
begin
	if(!rst || E_bubble)
	begin
		E_valC 	<= 	0;
		E_stat 	<= 	SAOK;
		E_icode <= 	INOP;
		E_ifun 	<= 	FNONE;
		E_valA 	<=	0;
		E_valB	<= 	0;
		E_dstE 	<= 	RNONE;
		E_dstM 	<= 	RNONE;
		E_srcA 	<= 	0;
		E_srcB 	<= 	0;
	end
	else
	begin
		E_valC 	<= 	D_valC;
		E_stat 	<= 	D_stat;
		E_icode <= 	D_icode;
		E_ifun 	<= 	D_ifun;
		E_valA 	<=	d_valA;
		E_valB	<= 	d_valB;
		E_dstE 	<= 	d_dstE;
		E_dstM 	<= 	d_dstM;
		E_srcA 	<= 	d_srcA;
		E_srcB 	<= 	d_srcB;
	end
	
end

assign cond_set 	= 	E_icode == IOPQ && m_stat == SAOK && W_stat == SAOK;


////////////////////////////////////////////////////
//
//	译码和写回阶段
//
////////////////////////////////////////////////////

wire    [MEM_DATA_WIDTH - 1 : 0]		e_valE;
wire    [REGS_WIDTH - 1 : 0]			e_dstE;
wire 	[STATUS_WIDTH - 1 : 0]			W_stat;
wire 	[STATUS_WIDTH - 1 : 0]			m_stat;
wire 									e_cnd;


assign 	alu_a 	=	E_icode == IRRMOVQ || E_icode == IOPQ ? E_valA:
					E_icode == IIRMOVQ || E_icode == IRMMOVQ || E_icode == IMRMOVQ ? E_valC:
					E_icode == ICALL || E_icode == IPUSHQ ? -8:
					E_icode == IRET || E_icode == IPOPQ ? 8:
					0;

assign 	alu_b	=	E_icode == IRMMOVQ || E_icode == IMRMOVQ || E_icode == IOPQ || E_icode == ICALL ||
					E_icode == IPUSHQ || E_icode == IRET || E_icode == IPOPQ ? E_valB:
					E_icode == IRRMOVQ || E_icode == IIRMOVQ ? 0:
					0;

assign 	e_dstE 	= 	E_icode == IRRMOVQ && e_cnd? E_rB:
					E_icode == IIRMOVQ || E_icode == IOPQ ? E_rB:
					E_icode == IPUSHQ || E_icode == IPOPQ || E_icode == ICALL || E_icode == IRET ? RRSP:
					RNONE; 

assign  alu_fun =	E_icode == IOPQ ? E_ifun : OPADDQ;

assign 	e_cnd 	= 	cond_cnd;

assign  cond_ifun = E_ifun;

assign 	e_valE 	= 	alu_e;

always @(posedge clk)
begin
	if(!rst_n || M_bubble)
	begin
		M_stat 	<= 	SAOK;
		M_icode <= 	INOP;
		M_Cnd 	<= 	1;
		M_valE 	<=	0;
		M_valA	<= 	0;
		M_dstE 	<= 	RNONE;
		M_dstM 	<= 	RNONE;
	end
	else
	begin
		M_stat 	<= 	E_stat;
		M_icode <= 	E_icode;
		M_Cnd 	<= 	e_cnd;
		M_valE 	<=	e_valE;
		M_valA	<= 	E_valA;
		M_dstE 	<= 	e_dstE;
		M_dstM 	<= 	E_dstM;
	end
end

////////////////////////////////////////////////////
//
//	访存阶段
//
////////////////////////////////////////////////////


wire 	[STATUS_WIDTH - 1 : 0]			m_stat;
wire 	[MEM_DATA_WIDTH - 1 : 0] 		m_valM;
wire 									dmem_error;
wire 	[MEM_ADDR_WIDTH - 1 : 0] 		mem_addr;
wire 									mem_read;
wire 									mem_write;
wire 	[MEM_DATA_WIDTH - 1 : 0]		mem_data;

assign 	dmem_error= !dmem_ok;
assign 	m_stat 	=	dmem_error ? SADR : M_stat;
assign 	mem_addr= 	M_icode == IRMMOVQ || M_icode == IPUSHQ || M_icode == ICALL || M_icode == IMRMOVQ ? M_valE : M_valA;
assign 	mem_read= 	M_icode == IMRMOVQ || M_icode == IPOPQ || M_icode == IRET ;
assign 	mem_write = M_icode == IRMMOVQ || M_icode == IPUSHQ || M_icode == ICALL ;
assign 	mem_data= 	M_valA;

assign  data_re = 	mem_read;
assign 	data_we = 	mem_write;
assign 	data_addr = mem_addr;
assign 	data_dout =	mem_data;
assign 	m_valM 	= 	data_din;

always @(posedge clk)
begin
	if(!rst)
	begin
		W_stat 	<= 	SAOK;
		W_icode <= 	IOPQ;
		W_valE 	<=	0;
		W_valM	<= 	0;
		W_dstE 	<= 	RNONE;
		W_dstM 	<= 	RNONE;
	end
	else if(W_stall)
	begin
		W_stat 	<= 	W_stat;
		W_icode <= 	W_icode;
		W_valE 	<=	W_valE;
		W_valM	<= 	W_valM;
		W_dstE 	<= 	W_dstE;
		W_dstM 	<= 	W_dstM;
	end
	else
	begin
		W_stat 	<= 	m_stat;
		W_icode <= 	M_icode;
		W_valE 	<=	M_valE;
		W_valM	<= 	m_valM;
		W_dstE 	<= 	M_dstE;
		W_dstM 	<= 	M_dstM;		
	end

end
