module alu(aluA,aluB,ifun,valE,newCC);
    //设定四种计算的编码
    parameter ALUADD = 4'h0;
    parameter ALUSUB = 4'h1;
    parameter ALUAND = 4'h2;
    parameter ALUXOR = 4'h3;
    input[63:0] aluA;
    input[63:0] aluB;
    input[3:0] ifun;
    output[63:0] valE;
    output[2:0] newCC;
    //计算valE
    assign valE = ifun==ALUADD ? aluA+aluB:
                  ifun==ALUSUB ? aluB-aluA:
                  ifun==ALUAND ? aluB&aluA:
                  aluB^aluA;
    //设置newCC
    assign newCC[2] = (valE==0);
    assign newCC[1] = valE[63];
    assign newCC[0] = (aluA[63]==aluB[63])&(valE[63]!=aluB[63])&(ifun==ALUADD) ? 1:
                      (aluA[63]!=aluB[63])&(aluB[63]!=valE[63])&(ifun==ALUSUB) ? 1:
                      0;
endmodule