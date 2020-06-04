`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:51:35 05/27/2020 
// Design Name: 
// Module Name:    Memory 
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
//随机访问存储器，模拟内存中的一个内存芯片
module ram(clock,addrA,wEnA,wDataA,rEnA,rDataA,addrB,wEnB,wDataB,rEnB,rDataB);
    //声明字长，芯片的字节数，字节的地址
    parameter WORDSIZE = 8;
    parameter WORDNUM = 512;
    parameter ADDRSIZE = 9;
    //输入输出端口声明
    //有两个既可以读又可以写的端口，地址输入分别为addrA，addrB，写的使能端分别为wEnA，wEnB，写的数据输入分别为wDataA,wDataB。
    //读的使能端分别为rEnA，rEnB，读的输出分别为rDataA，rDataB
    input clock;
    input [ADDRSIZE-1:0] addrA;
    input [WORDSIZE-1:0] wDataA;
    input wEnA;
    input rEnA;
    output reg[WORDSIZE-1:0] rDataA;
    input [ADDRSIZE-1:0] addrB;
    input [WORDSIZE-1:0] wDataB;
    input wEnB;
    input rEnB;
    output reg[WORDSIZE-1:0]rDataB;
    reg[WORDSIZE-1:0]mem[WORDNUM-1:0];
    //时钟下降沿时进行数据的读写
    always@(negedge clock)
    begin
        if(wEnA)
            begin
                mem[addrA] <= wDataA;
            end
        if(rEnA)
            begin
                rDataA <= mem[addrA];
            end
        end
    always@(negedge clock)
    begin
        if(wEnB)
            begin
                mem[addrB] <= wDataB;
            end
        if(rEnB)
            begin
                rDataB <= mem[addrB];
            end
        end
endmodule

//内存模块，用于储存数据和指令
//由16块内存芯片(bank)构成
//每次访存从部分芯片中取出一个字节
module Merory(maddr,wenable,wdata,renable,rdata,m_ok,iaddr,instr,i_ok,clock);
    //内存总大小
    parameter memsize = 8192;
    input[63:0] maddr;
    input wenable;//Write enable
    input[63:0]wdata;
    input renable;
    output[63:0]rdata;
    output m_ok;
    input[63:0]iaddr;
    output[79:0]instr;
    output i_ok;
    input clock;
    //ibx对应于指令(instr)的第x低个字节
    wire[7:0] ib0,ib1,ib2,ib3,ib4,ib5,ib6,ib7,ib8,ib9;
    //dbx对应于数据输出(rdata)的第x低字节
    wire[7:0] db0,db1,db2,db3,db4,db5,db6,db7;
    wire[3:0]ibid = iaddr[3:0];//第一个bank的id，会影响其他bank的地址
    wire[59:0] iindex = iaddr[63:4];
    wire[59:0] iipl = iindex+1;//iindex的下一个地址
    wire[3:0] mbid = maddr[3:0];//数据地址的第一个bank
    wire[59:0] mindex = maddr[63:4];//bank内的数据地址
    wire[59:0] mipl = mindex+1;//mindex的下一个地址
    //声明指令地址，对应于不同的bank
    wire[59:0] addrI0,addrI1,addrI2,addrI3,addrI4,addrI5,addrI6,addrI7,addrI8,addrI9,addrI10,addrI11,addrI12,addrI13,addrI14,addrI15;
    //声明每个bank的指令输出
    wire[7:0] outI0,outI1,outI2,outI3,outI4,outI5,outI6,outI7,outI8,outI9,outI10,outI11,outI12,outI13,outI14,outI15;
    //每个bank的数据地址
    wire[59:0] addrD0,addrD1,addrD2,addrD3,addrD4,addrD5,addrD6,addrD7,addrD8,addrD9,addrD10,addrD11,addrD12,addrD13,addrD14,addrD15;
    //每个bank的数据输出
    wire[7:0]outD0,outD1,outD2,outD3,outD4,outD5,outD6,outD7,outD8,outD9,outD10,outD11,outD12,outD13,outD14,outD15;
    //每个bank的数据输入
    wire[7:0]inD0,inD1,inD2,inD3,inD4,inD5,inD6,inD7,inD8,inD9,inD10,inD11,inD12,inD13,inD14,inD15;
    //每个bank的写使能信号
    wire dwEn0,dwEn1,dwEn2,dwEn3,dwEn4,dwEn5,dwEn6,dwEn7,dwEn8,dwEn9,dwEn10,dwEn11,dwEn12,dwEn13,dwEn14,dwEn15;
    //声明16个内存芯片(bank)
    ram #(8,memsize/16,60) bank0(clock,addrI0,1'b0,8'b0,1'b1,outI0,addrD0,dwEn0,inD0,renable,outD0);
    ram #(8,memsize/16,60) bank1(clock,addrI1,1'b0,8'b0,1'b1,outI1,addrD1,dwEn1,inD1,renable,outD1);
    ram #(8,memsize/16,60) bank2(clock,addrI2,1'b0,8'b0,1'b1,outI2,addrD2,dwEn2,inD2,renable,outD2);
    ram #(8,memsize/16,60) bank3(clock,addrI3,1'b0,8'b0,1'b1,outI3,addrD3,dwEn3,inD3,renable,outD3);
    ram #(8,memsize/16,60) bank4(clock,addrI4,1'b0,8'b0,1'b1,outI4,addrD4,dwEn4,inD4,renable,outD4);
    ram #(8,memsize/16,60) bank5(clock,addrI5,1'b0,8'b0,1'b1,outI5,addrD5,dwEn5,inD5,renable,outD5);
    ram #(8,memsize/16,60) bank6(clock,addrI6,1'b0,8'b0,1'b1,outI6,addrD6,dwEn6,inD6,renable,outD6);
    ram #(8,memsize/16,60) bank7(clock,addrI7,1'b0,8'b0,1'b1,outI7,addrD7,dwEn7,inD7,renable,outD7);
    ram #(8,memsize/16,60) bank8(clock,addrI8,1'b0,8'b0,1'b1,outI8,addrD8,dwEn8,inD8,renable,outD8);
    ram #(8,memsize/16,60) bank9(clock,addrI9,1'b0,8'b0,1'b1,outI9,addrD9,dwEn9,inD9,renable,outD9);
    ram #(8,memsize/16,60) bank10(clock,addrI10,1'b0,8'b0,1'b1,outI10,addrD10,dwEn10,inD10,renable,outD10);
    ram #(8,memsize/16,60) bank11(clock,addrI11,1'b0,8'b0,1'b1,outI11,addrD11,dwEn11,inD11,renable,outD11);
    ram #(8,memsize/16,60) bank12(clock,addrI12,1'b0,8'b0,1'b1,outI12,addrD12,dwEn12,inD12,renable,outD12);
    ram #(8,memsize/16,60) bank13(clock,addrI13,1'b0,8'b0,1'b1,outI13,addrD13,dwEn13,inD13,renable,outD13);
    ram #(8,memsize/16,60) bank14(clock,addrI14,1'b0,8'b0,1'b1,outI14,addrD14,dwEn14,inD14,renable,outD14);
    ram #(8,memsize/16,60) bank15(clock,addrI15,1'b0,8'b0,1'b1,outI15,addrD15,dwEn15,inD15,renable,outD15);
    //计算出每个bank访存地址(每个bank取出一个字节，组合在一起）
    assign addrI0 = ibid>=7 ? iipl:iindex;
    assign addrI1 = ibid>=8 ? iipl:iindex;
    assign addrI2 = ibid>=9 ? iipl:iindex;
    assign addrI3 = ibid>=10 ? iipl:iindex;
    assign addrI4 = ibid>=11 ? iipl:iindex;
    assign addrI5 = ibid>=12 ? iipl:iindex;
    assign addrI6 = ibid>=13 ? iipl:iindex;
    assign addrI7 = ibid>=14 ? iipl:iindex;
    assign addrI8 = ibid>=15 ? iipl:iindex;
    assign addrI9 = iindex;
    assign addrI10 = iindex;
    assign addrI11 = iindex;
    assign addrI12 = iindex;
    assign addrI13 = iindex;
    assign addrI14 = iindex;
    assign addrI15 = iindex;
    //判断指令访问是否越界
    assign i_ok = (iaddr+9)<memsize;
    //计算指令每个字节对应哪个bank中取出的字节
    assign	ib0 = !i_ok ? 0 :
			ibid == 0 ? outI0 :
			ibid == 1 ? outI1 :
			ibid == 2 ? outI2 :
			ibid == 3 ? outI3 :
			ibid == 4 ? outI4 :
			ibid == 5 ? outI5 :
			ibid == 6 ? outI6 :
			ibid == 7 ? outI7 :
			ibid == 8 ? outI8 :
			ibid == 9 ? outI9 :
			ibid == 10 ? outI10 :
			ibid == 11 ? outI11 :
			ibid == 12 ? outI12 :
			ibid == 13 ? outI13 :
			ibid == 14 ? outI14 :
			outI15;  
    assign	ib1 = !i_ok ? 0 :
			ibid == 0 ? outI1 :
			ibid == 1 ? outI2 :
			ibid == 2 ? outI3 :
			ibid == 3 ? outI4 :
			ibid == 4 ? outI5 :
			ibid == 5 ? outI6 :
			ibid == 6 ? outI7 :
			ibid == 7 ? outI8 :
			ibid == 8 ? outI9 :
			ibid == 9 ? outI10 :
			ibid == 10 ? outI11 :
			ibid == 11 ? outI12 :
			ibid == 12 ? outI13 :
			ibid == 13 ? outI14 :
			ibid == 14 ? outI15 :
			outI0;    
        assign	ib2 = !i_ok ? 0 :
			ibid == 0 ? outI2 :
			ibid == 1 ? outI3 :
			ibid == 2 ? outI4 :
			ibid == 3 ? outI5 :
			ibid == 4 ? outI6 :
			ibid == 5 ? outI7 :
			ibid == 6 ? outI8 :
			ibid == 7 ? outI9 :
			ibid == 8 ? outI10 :
			ibid == 9 ? outI11 :
			ibid == 10 ? outI12 :
			ibid == 11 ? outI13 :
			ibid == 12 ? outI14 :
			ibid == 13 ? outI15 :
			ibid == 14 ? outI1 :
			outI0;   
    assign	ib3 = !i_ok ? 0 :
			ibid == 0 ? outI3 :
			ibid == 1 ? outI4 :
			ibid == 2 ? outI5 :
			ibid == 3 ? outI6 :
			ibid == 4 ? outI7 :
			ibid == 5 ? outI8 :
			ibid == 6 ? outI9 :
			ibid == 7 ? outI10 :
			ibid == 8 ? outI11 :
			ibid == 9 ? outI12 :
			ibid == 10 ? outI13 :
			ibid == 11 ? outI14 :
			ibid == 12 ? outI15 :
			ibid == 13 ? outI0 :
			ibid == 14 ? outI1 :
			outI2;      
    assign	ib4 = !i_ok ? 0 :
			ibid == 0    ? outI4 :
			ibid == 1    ? outI5 :
			ibid == 2    ? outI6 :
			ibid == 3    ? outI7 :
			ibid == 4    ? outI8 :
			ibid == 5    ? outI9 :
			ibid == 6    ? outI10 :
			ibid == 7    ? outI11 :
			ibid == 8    ? outI12 :
			ibid == 9    ? outI13 :
			ibid == 10    ? outI14 :
			ibid == 11    ? outI15 :
			ibid == 12    ? outI0 :
			ibid == 13    ? outI1 :
			ibid == 14    ? outI2 :
			outI3;    
    assign	ib5 = !i_ok ? 0 :
			ibid == 0    ? outI5 :
			ibid == 1    ? outI6 :
			ibid == 2    ? outI7 :
			ibid == 3    ? outI8 :
			ibid == 4    ? outI9 :
			ibid == 5    ? outI10 :
			ibid == 6    ? outI11 :
			ibid == 7    ? outI12 :
			ibid == 8    ? outI13 :
			ibid == 9    ? outI14 :
			ibid == 10    ? outI15 :
			ibid == 11    ? outI0 :
			ibid == 12    ? outI1 :
			ibid == 13    ? outI2 :
			ibid == 14	? outI3 :
			outI4;    
    assign	ib6 = !i_ok ? 0 :
			ibid == 0    ? outI6 :
			ibid == 1    ? outI7 :
			ibid == 2    ? outI8 :
			ibid == 3    ? outI9 :
			ibid == 4    ? outI10 :
			ibid == 5    ? outI11 :
			ibid == 6    ? outI12 :
			ibid == 7    ? outI13 :
			ibid == 8    ? outI14 :
			ibid == 9    ? outI15 :
			ibid == 10    ? outI0 :
			ibid == 11    ? outI1 :
			ibid == 12    ? outI2 :
			ibid == 13    ? outI3 :
			ibid == 14    ? outI4 :
			outI5;    
    assign	ib7 = !i_ok ? 0 :
			ibid == 0    ? outI7 :
			ibid == 1    ? outI8 :
			ibid == 2    ? outI9 :
			ibid == 3    ? outI10 :
			ibid == 4    ? outI11 :
			ibid == 5    ? outI12 :
			ibid == 6    ? outI13 :
			ibid == 7    ? outI14 :
			ibid == 8    ? outI15 :
			ibid == 9    ? outI0 :
			ibid == 10    ? outI1 :
			ibid == 11    ? outI2 :
			ibid == 12    ? outI3 :
			ibid == 13    ? outI4 :
			ibid == 14    ? outI5 :
			outI6;    
    assign	ib8 = !i_ok ? 0 :
			ibid == 0    ? outI8 :
			ibid == 1    ? outI9 :
			ibid == 2    ? outI10 :
			ibid == 3    ? outI11 :
			ibid == 4    ? outI12 :
			ibid == 5    ? outI13 :
			ibid == 6    ? outI14 :
			ibid == 7    ? outI15 :
			ibid == 8    ? outI0 :
			ibid == 9    ? outI1 :
			ibid == 10    ? outI2 :
			ibid == 11    ? outI3 :
			ibid == 12    ? outI4 :
			ibid == 13	?	outI5 :
			ibid == 14    ? outI6 :
			outI7;        
    assign	ib9 = !i_ok ? 0 :
			ibid == 0    ? outI9 :
			ibid == 1    ? outI10 :
			ibid == 2    ? outI11 :
			ibid == 3    ? outI12 :
			ibid == 4    ? outI13 :
			ibid == 5    ? outI14 :
			ibid == 6    ? outI15 :
			ibid == 7    ? outI0 :
			ibid == 8    ? outI1 :
			ibid == 9    ? outI2 :
			ibid == 10    ? outI3 :
			ibid == 11    ? outI4 :
			ibid == 12    ? outI5 :
			ibid == 13    ? outI6 :
			ibid == 14    ? outI7 :
			outI8; 
    //将取出的10个字节组合成指令，icode和ifun在最低一个字节
    assign	  instr[7:0] = ib0;
    assign    instr[15:8] = ib1;
    assign    instr[23:16] = ib2;
    assign    instr[31:24] = ib3;
    assign    instr[39:32] = ib4;
    assign    instr[47:40] = ib5;
    assign    instr[55:48] = ib6;
    assign    instr[63:56] = ib7;
    assign    instr[71:64] = ib8;
    assign    instr[79:72] = ib9;    
    //判断访存是否出错  
    assign m_ok = (!renable & !wenable)|(maddr+7)<memsize;
    //计算每个bank所取出字节的地址
    assign	addrD0 = mbid >=  9 ? mipl : mindex;
    assign    addrD1 = mbid >= 10 ? mipl : mindex;
    assign    addrD2 = mbid >= 11 ? mipl : mindex;
    assign    addrD3 = mbid >= 12 ? mipl : mindex;
    assign    addrD4 = mbid >= 13 ? mipl : mindex;
    assign    addrD5 = mbid >= 14 ? mipl : mindex;
    assign    addrD6 = mbid >= 15 ? mipl : mindex;
    assign    addrD7 = mindex;
    assign    addrD8 = mindex;
    assign    addrD9 = mindex;
    assign    addrD10 =    mindex;
    assign    addrD11 =    mindex;
    assign    addrD12 =    mindex;
    assign    addrD13 =    mindex;
    assign    addrD14 =    mindex;
    assign    addrD15 =    mindex;  
    //计算数据输出的各个字节   
    assign	db0 = !m_ok ? 0	:
				mbid == 0    ? outD0    :
				mbid == 1    ? outD1    :
				mbid == 2    ? outD2    :
				mbid == 3    ? outD3    :
				mbid == 4    ? outD4    :
				mbid == 5    ? outD5    :
				mbid == 6    ? outD6    :
				mbid == 7    ? outD7    :
				mbid == 8    ? outD8    :
				mbid == 9    ? outD9    :
				mbid == 10    ? outD10 :
				mbid == 11    ? outD11 :
				mbid == 12    ? outD12 :
				mbid == 13    ? outD13 :
				mbid == 14    ? outD14    :
				outD15;        
    assign	db1 = !m_ok ? 0	:
            mbid == 0    ? outD1    :
            mbid == 1    ? outD2    :
            mbid == 2    ? outD3    :
            mbid == 3    ? outD4    :
            mbid == 4    ? outD5    :
            mbid == 5    ? outD6    :
            mbid == 6    ? outD7    :
            mbid == 7    ? outD8    :
            mbid == 8    ? outD9    :
            mbid == 9    ? outD10 :
            mbid == 10    ? outD11 :
            mbid == 11    ? outD12 :
            mbid == 12    ? outD13 :
            mbid == 13    ? outD14 :
            mbid == 14    ? outD15    :
            outD0;
    assign	db2 = !m_ok ? 0	:
				mbid == 0    ? outD2    :
				mbid == 1    ? outD3    :
				mbid == 2    ? outD4    :
				mbid == 3    ? outD5    :
				mbid == 4    ? outD6    :
				mbid == 5    ? outD7    :
				mbid == 6    ? outD8    :
				mbid == 7    ? outD9    :
				mbid == 8    ? outD10 :
				mbid == 9    ? outD11 :
				mbid == 10    ? outD12 :
				mbid == 11    ? outD13 :
				mbid == 12	? outD14 :
				mbid == 13    ? outD15    :
				mbid == 14    ? outD0    :
				outD1;        
    assign	db3 = !m_ok ? 0	:
				mbid == 0    ? outD3    :
				mbid == 1    ? outD4    :
				mbid == 2    ? outD5    :
				mbid == 3    ? outD6    :
				mbid == 4    ? outD7    :
				mbid == 5    ? outD8    :
				mbid == 6    ? outD9    :
				mbid == 7    ? outD10 :
				mbid == 8    ? outD11 :
				mbid == 9    ? outD12 :
				mbid == 10    ? outD13 :
				mbid == 11    ? outD14 :
				mbid == 12    ? outD15    :
				mbid == 13    ? outD0    :
				mbid == 14    ? outD1    :
				outD2;        
    assign	db4 = !m_ok ? 0	:
				mbid == 0    ? outD4    :
				mbid == 1    ? outD5    :
				mbid == 2    ? outD6    :
				mbid == 3    ? outD7    :
				mbid == 4    ? outD8    :
				mbid == 5    ? outD9    :
				mbid == 6    ? outD10 :
				mbid == 7    ? outD11 :
				mbid == 8    ? outD12 :
				mbid == 9    ? outD13 :
				mbid == 10    ? outD14 :
				mbid == 11    ? outD15    :
				mbid == 12    ? outD0    :
				mbid == 13    ? outD1    :
				mbid == 14    ? outD2    :
				outD3;        
    assign	db5 = !m_ok ? 0 :	
				mbid == 0    ? outD5    :
				mbid == 1    ? outD6    :
				mbid == 2    ? outD7    :
				mbid == 3    ? outD8    :
				mbid == 4    ? outD9    :
				mbid == 5    ? outD10 :
				mbid == 6    ? outD11 :
				mbid == 7    ? outD12 :
				mbid == 8    ? outD13 :
				mbid == 9    ? outD14 :
				mbid == 10    ? outD15 :
				mbid == 11	?	outD0	:
				mbid == 12    ?    outD1    :
				mbid == 13    ?    outD2    :
				mbid == 14    ? outD3    :
				outD4;            
    assign	db6 = !m_ok ? 0	:
				mbid == 0    ? outD6    :
				mbid == 1    ? outD7    :
				mbid == 2    ? outD8    :
				mbid == 3    ? outD9    :
				mbid == 4    ? outD10 :
				mbid == 5    ? outD11 :
				mbid == 6    ? outD12 :
				mbid == 7    ? outD13 :
				mbid == 8    ? outD14 :
				mbid == 9    ? outD15    :
				mbid == 10    ? outD0    :
				mbid == 11    ? outD1    :
				mbid == 12    ? outD2    :
				mbid == 13    ? outD3    :
				mbid == 14    ? outD4    :
				outD5;            
    assign	db7 = !m_ok ? 0	:
				mbid == 0    ? outD7    :
				mbid == 1    ? outD8    :
				mbid == 2    ? outD9    :
				mbid == 3    ? outD10 :
				mbid == 4    ? outD11 :
				mbid == 5    ? outD12 :
				mbid == 6    ? outD13 :
				mbid == 7    ? outD14 :
				mbid == 8    ? outD15    :
				mbid == 9    ? outD0    :
				mbid == 10    ? outD1    :
				mbid == 11    ? outD2    :
				mbid == 12    ? outD3    :
				mbid == 13    ? outD4    :
				mbid == 14    ? outD5    :
				outD6;       
    //将数据输出合并     
    assign	rdata[ 7: 0] = db0;
    assign    rdata[15: 8] = db1;
    assign    rdata[23:16] = db2;
    assign    rdata[31:24] = db3;
    assign    rdata[39:32] = db4;
    assign    rdata[47:40] = db5;
    assign    rdata[55:48] = db6;
    assign    rdata[63:56] = db7; 
    //将数据输出按字节拆分
    wire [7:0]wd0 = wdata[ 7: 0];
    wire [7:0]wd1 = wdata[ 15: 8];
    wire [7:0]wd2 = wdata[ 23: 16];
    wire [7:0]wd3 = wdata[ 31: 24];    
    wire [7:0]wd4 = wdata[39:32];
    wire [7:0]wd5 = wdata[47:40];
    wire [7:0]wd6 = wdata[55:48]; 
    wire [7:0]wd7 = wdata[63:56];
    //判断每个字节要写入哪个bank
    assign	inD0 =		
				mbid == 9    ? wd7 :
				mbid == 10 ? wd6 :
				mbid == 11 ? wd5 :
				mbid == 12 ? wd4 :
				mbid == 13 ? wd3 :
				mbid == 14 ? wd2 :
				mbid == 15 ? wd1 :
				mbid == 0 ? wd0 :
				0;        
    assign	inD1 =	
            mbid == 10 ? wd7 :
            mbid == 11 ? wd6 :
            mbid == 12 ? wd5 :
            mbid == 13 ? wd4 :
            mbid == 14 ? wd3 :
            mbid == 15    ? wd2 :
            mbid == 0    ? wd1 :
            mbid == 1    ? wd0 :
            0;    
    assign	inD2 =		
				mbid == 11 ? wd7 :
				mbid == 12 ? wd6 :
				mbid == 13 ? wd5 :
				mbid == 14 ? wd4 :
				mbid == 15    ? wd3 :
				mbid == 0    ? wd2 :
				mbid == 1    ? wd1 :
				mbid == 2    ? wd0 :
				0;        
    assign	inD3 =		
				mbid == 12 ? wd7 :
				mbid == 13 ? wd6 :
				mbid == 14 ? wd5 :
				mbid == 15 ? wd4 :
				mbid == 0 ? wd3    :
				mbid == 1 ? wd2    :
				mbid == 2 ? wd1    :
				mbid == 3 ? wd0    :
				0;
    assign	inD4 =	
				mbid == 13 ? wd7 :
				mbid == 14 ? wd6 :
				mbid == 15 ? wd5 :
				mbid == 0 ? wd4    :
				mbid == 1 ? wd3    :
				mbid == 2 ? wd2    :
				mbid == 3 ? wd1    :
				mbid == 4 ? wd0    :
				0;    
    assign	inD5 =	
				mbid == 14 ? wd7 :
				mbid == 15 ? wd6 :
				mbid == 0 ? wd5    :
				mbid == 1 ? wd4    :
				mbid == 2 ? wd3    :
				mbid == 3 ? wd2    :
				mbid == 4 ? wd1    :
				mbid == 5 ? wd0    :
				0;    
    assign	inD6 =	
				mbid == 15 ? wd7 :
				mbid == 0 ? wd6    :
				mbid == 1 ? wd5    :
				mbid == 2 ? wd4    :
				mbid == 3 ? wd3    :
				mbid == 4 ? wd2    :
				mbid == 5 ? wd1    :
				mbid == 6 ? wd0    :
				0;    
    assign	inD7 =	
				mbid == 0 ? wd7    :
				mbid == 1 ? wd6    :
				mbid == 2 ? wd5    :
				mbid == 3 ? wd4    :
				mbid == 4 ? wd3    :
				mbid == 5 ? wd2    :
				mbid == 6 ? wd1    :
				mbid == 7 ? wd0    :
				0;    
    assign	inD8 =	
				mbid == 1 ? wd7    :
				mbid == 2 ? wd6    :
				mbid == 3 ? wd5    :  
				mbid == 4 ? wd4	:
				mbid == 5 ? wd3    :
				mbid == 6 ? wd2    :
				mbid == 7 ? wd1    :
				mbid == 8 ? wd0    :
				0;    
    assign	inD9 =	
				mbid == 2 ? wd7    :
				mbid == 3 ? wd6    :
				mbid == 4 ? wd5    :
				mbid == 5 ? wd4    :
				mbid == 6 ? wd3    :
				mbid == 7 ? wd2    :
				mbid == 8 ? wd1    :
				mbid == 9 ? wd0    :
				0;    
    assign	inD10 =	
				mbid == 3 ? wd7    :
				mbid == 4 ? wd6    :
				mbid == 5 ? wd5    :
				mbid == 6 ? wd4    :
				mbid == 7 ? wd3    :
				mbid == 8 ? wd2    :
				mbid == 9 ? wd1    :
				mbid == 10 ? wd0 :
				0;    
    assign	inD11 =	
				mbid == 4 ? wd7    :
				mbid == 5 ? wd6    :
				mbid == 6 ? wd5    :
				mbid == 7 ? wd4    :
				mbid == 8 ? wd3    :
				mbid == 9 ? wd2    :
				mbid == 10 ? wd1 :
				mbid == 11 ? wd0 :
				0;    
    assign	inD12 =	
				mbid == 5 ? wd7    :
				mbid == 6 ? wd6    :
				mbid == 7 ? wd5    :
				mbid == 8 ? wd4    :
				mbid == 9 ? wd3    :
				mbid == 10 ? wd2 :
				mbid == 11 ? wd1 :
				mbid == 12 ? wd0 :
				0;   
    assign	inD13 =	
				mbid == 6 ? wd7    :
				mbid == 7 ? wd6    :
				mbid == 8 ? wd5    :
				mbid == 9 ? wd4    :
				mbid == 10 ? wd3    :
				mbid == 11 ? wd2    :
				mbid == 12 ? wd1    :
				mbid == 13 ? wd0 :
				0;    
    assign	inD14 =	
				mbid == 7 ? wd7    :
				mbid == 8 ? wd6    :
				mbid == 9 ? wd5    :
				mbid == 10 ? wd4    :
				mbid == 11 ? wd3    :
				mbid == 12 ? wd2    :
				mbid == 13 ? wd1    :
				mbid == 14 ? wd0 :
				0;    
    assign	inD15 =	
				mbid == 8 ? wd7    :
				mbid == 9 ? wd6    :
				mbid == 10 ? wd5    :
				mbid == 11 ? wd4    :
				mbid == 12 ? wd3    :
				mbid == 13 ? wd2    :
				mbid == 14 ? wd1    :
				mbid == 15 ? wd0 :
				0;    
        //计算16个bank的写入使能
        assign	dwEn0 = wenable & (mbid <= 0 | mbid >= 9);
        assign    dwEn1 = wenable & (mbid <= 1 | mbid >= 10);
        assign    dwEn2 = wenable & (mbid <= 2 | mbid >= 11);
        assign    dwEn3 = wenable & (mbid <= 3 | mbid >= 12);
        assign    dwEn4 = wenable & (mbid <= 4 | mbid >= 13);
        assign    dwEn5 = wenable & (mbid <= 5 | mbid >= 14);
        assign    dwEn6 = wenable & (mbid <= 6 | mbid >= 15);
        assign    dwEn7 = wenable & (mbid <= 7);
        assign    dwEn8 = wenable & (mbid >= 1 & mbid <= 8);
        assign    dwEn9 = wenable & (mbid >= 2 & mbid <= 9);
        assign    dwEn10 = wenable & (mbid >= 3 & mbid <= 10);
        assign    dwEn11 = wenable & (mbid >= 4 & mbid <= 11);
        assign    dwEn12 = wenable & (mbid >= 5 & mbid <= 12);
        assign    dwEn13 = wenable & (mbid >= 6 & mbid <= 13);
        assign    dwEn14 = wenable & (mbid >= 7 & mbid <= 14);
        assign	  dwEn15 = wenable & (mbid >= 8); 
endmodule
