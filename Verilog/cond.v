`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:13:54 05/27/2020 
// Design Name: 
// Module Name:    CC 
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
//条件码寄存器，用于更新条件码
module CC(newCC,cc,setCC,reset,clock);
    output[2:0] cc;
    input[2:0] newCC;
    input setCC;
    input reset;
    input clock;
    
    cenrreg #(3)ccReg(newCC,cc,setCC,reset,3'b100,clock);
endmodule
// 计算Cnd，用于判断JXX和OMVXX
module cond(ifun,cc,Cnd);
    //设定功能的编码
    parameter C_YES = 4'h0;
    parameter C_LE = 4'h1;
    parameter C_L = 4'h2;
    parameter C_E = 4'h3;
    parameter C_NE = 4'h4;
    parameter C_GE = 4'h5;
    parameter C_G = 4'h6;
    input[3:0] ifun;
    input[2:0] cc;
    output Cnd;
    //将条件码分开
    wire zf = cc[2];
    wire sf = cc[1];
    wire of = cc[0];
    //计算Cnd
    assign Cnd = (ifun==C_YES)|
                 ifun==C_LE &((sf^of)|zf)|
                 (ifun == C_L & (sf^of)) |
                 ifun==C_E & zf|
                 ifun==C_NE & ~zf|
                 ifun==C_GE & (~sf^of)|
                 ifun==C_G & ((~sf^of)&~zf);
endmodule