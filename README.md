# Y86-64 Virtual Machine

源于《深入理解计算机系统》by Randal E. Bryant， David R.O' Hallaron
第四章处理器体系结构篇x86-64的简易版y86-64

feature 1	汇编码->机器码

示例文件testCode.txt
irmovq $15,%rbx
rrmovq %rbx,%rcx
rmmovq %rcx,-3(%rbx)
addq %rbx,%rcx

命令 python y86_64.py testCode.txt output.txt

输出结果
30f30f0000000000000020314013fdffffffffffffff6031
