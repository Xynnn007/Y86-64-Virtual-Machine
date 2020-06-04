`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:49:36 05/27/2020 
// Design Name: 
// Module Name:    registerFile 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module cenrreg(in,out,set,reset,reVal,clock);//同步清零的寄存器
    parameter width = 8;//寄存器宽度
    input[width-1:0] in;//更新寄存器的输入
    input set;//更新寄存器的使能信号
    input reset;//复位信号
    input clock;//时钟
    output[width-1:0] out;//寄存器输出
    reg [width-1:0] out;
    input [width-1:0] reVal;
    always@(posedge clock)//时钟上升沿更新
    begin
        if(set)//如果设置为1
            out <= in;
        if(reset)//如果复位为1
            out <= reVal;
     end            
endmodule
//寄存器文件
module registerFile(srcA,srcB,valA,valB,dstE,valE,dstM,valM,reset,clock,rax,rcx,rdx,rbx,rsp,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14);
    //寄存器的id位宽，和寄存器的位宽
    parameter valSize = 64;
    parameter regAddr = 4;
    //规定寄存器参数
    parameter IRAX = 4'h0;
    parameter IRCX = 4'h1;
    parameter IRDX = 4'h2;
    parameter IRBX = 4'h3;
    parameter IRSP = 4'h4;
    parameter IRBP = 4'h5;
    parameter IRSI = 4'h6;
    parameter IRDI = 4'h7;
    parameter IR8 = 4'h8;
    parameter IR9 = 4'h9;
    parameter IRA = 4'ha;
    parameter IRB = 4'hb;
    parameter IRC = 4'hc;
    parameter IRD = 4'hd;
    parameter IRE = 4'he;
    parameter RNONE = 4'hf;
    //端口声明
    output[valSize-1:0]rax,rcx,rdx,rbx,rsp,rbp,rdi,rsi,r8,r9,r10,r11,r12,r13,r14;
    input[regAddr-1:0] srcA;
    input[regAddr-1:0] srcB;
    output[valSize-1:0]valA;
    output[valSize-1:0]valB;
    input[regAddr-1:0]dstE;
    input[regAddr-1:0]dstM;
    input[valSize-1:0]valE;
    input[valSize-1:0]valM;
    input reset;
    input clock;
    //声明寄存器输入数据端
    wire[valSize-1:0]raxData,rbxData,rcxData,rdxData,rspData,rbpData,rsiData,rdiData,r8Data,r9Data,r11Data,r12Data,r13Data,r14Data,r10Data;
    //声明寄存器写信号
    wire raxW,rbxW,rcxW,rdxW,rspW,rbpW,rsiW,rdiW,r8W,r9W,r10W,r11W,r12W,r13W,r14W;
    //调用cenrreg模块声明15个寄存器
    cenrreg #(64) raxReg(raxData,rax,raxW,reset,64'b0,clock);
    cenrreg #(64) rbxReg(rbxData,rbx,rbxW,reset,64'b0,clock);
    cenrreg #(64) rcxReg(rcxData,rcx,rcxW,reset,64'b0,clock);
    cenrreg #(64) rdxReg(rdxData,rdx,rdxW,reset,64'b0,clock);
    cenrreg #(64) rspReg(rspData,rsp,rspW,reset,64'b1000,clock);
    cenrreg #(64) rbpReg(rbpData,rbp,rbpW,reset,64'b0,clock);
    cenrreg #(64) rsiReg(rsiData,rsi,rsiW,reset,64'b0,clock);
    cenrreg #(64) rdiReg(rdiData,rdi,rdiW,reset,64'b0,clock);
    cenrreg #(64) r8Reg(r8Data,r8,r8W,reset,64'b0,clock);
    cenrreg #(64) r9Reg(r9Data,r9,r9W,reset,64'b0,clock);
    cenrreg #(64) raReg(r10Data,r10,r10W,reset,64'b0,clock);
    cenrreg #(64) rbReg(r11Data,r11,r11W,reset,64'b0,clock);
    cenrreg #(64) rcReg(r12Data,r12,r12W,reset,64'b0,clock);
    cenrreg #(64) rdReg(r13Data,r13,r13W,reset,64'b0,clock);
    cenrreg #(64) reReg(r14Data,r14,r14W,reset,64'b0,clock);
    //选择valA的值
    assign valA = srcA==IRAX ? rax:
                  srcA==IRDX ? rdx:
                  srcA==IRCX ? rcx:
                  srcA==IRBX ? rbx:
                  srcA==IRSP ? rsp:
                  srcA==IRBP ? rbp:
                  srcA==IRSI ? rsi:
                  srcA==IRDI ? rdi:
                  srcA==IR8 ? r8:
                  srcA==IR9 ? r9:
                  srcA==IRA ? r10:
                  srcA==IRB ? r11:
                  srcA==IRC ? r12:
                  srcA==IRD ? r13:
                  srcA==IRE ? r14:
                  0;
    //选择valB的值
    assign valB = srcB==IRAX ? rax:
                  srcB==IRDX ? rdx:
                  srcB==IRCX ? rcx:
                  srcB==IRBX ? rbx:
                  srcB==IRSP ? rsp:
                  srcB==IRBP ? rbp:
                  srcB==IRSI ? rsi:
                  srcB==IRDI ? rdi:
                  srcB==IR8 ? r8:
                  srcB==IR9 ? r9:
                  srcB==IRA ? r10:
                  srcB==IRB ? r11:
                  srcB==IRC ? r12:
                  srcB==IRD ? r13:
                  srcB==IRE ? r14:
                  0;
    //对寄存器写的输入端赋值
    assign raxData = dstM == IRAX ? valM:valE;
    assign rdxData = dstM == IRDX ? valM:valE;
    assign rcxData = dstM == IRCX ? valM:valE;
    assign rbxData = dstM == IRBX ? valM:valE;
    assign rspData = dstM == IRSP ? valM : valE;
    assign rbpData = dstM == IRBP ? valM : valE;
    assign rsiData = dstM == IRSI ? valM : valE;
    assign rdiData = dstM == IRDI ? valM : valE;
    assign r8Data = dstM == IR8 ? valM : valE;
    assign r9Data = dstM == IR9 ? valM : valE;
    assign r10Data = dstM == IRA ? valM : valE;
    assign r11Data = dstM == IRB ? valM : valE;
    assign r12Data = dstM == IRC ? valM : valE;
    assign r13Data = dstM == IRD ? valM : valE;
    assign r14Data = dstM == IRE ? valM : valE;
    //对寄存器写的使能端赋值
    assign raxW = dstM == IRAX | dstE == IRAX;
    assign rcxW = dstM == IRCX | dstE == IRCX;
    assign rdxW = dstM == IRDX | dstE == IRDX;
    assign rbxW = dstM == IRBX | dstE == IRBX;
    assign rspW = dstM == IRSP | dstE == IRSP;
    assign rbpW = dstM == IRBP | dstE == IRBP;
    assign rsiW = dstM == IRSI | dstE == IRSI;
    assign rdiW = dstM == IRDI | dstE == IRDI;
    assign r8W = dstM == IR8 | dstE == IR8;
    assign r9W = dstM == IR9 | dstE == IR9;
    assign r10W = dstM == IRA | dstE == IRA;
    assign r11W = dstM == IRB | dstE == IRB;
    assign r12W = dstM == IRC | dstE == IRC;
    assign r13W = dstM == IRD | dstE == IRD;
    assign r14W = dstM == IRE | dstE == IRE;
endmodule
