# Y86-64 Virtual Machine

源于《深入理解计算机系统》by Randal E. Bryant， David R.O' Hallaron<br>
第四章处理器体系结构篇x86-64的简易版y86-64<br>

feature 1	汇编码->机器码
=======================
使用示例 1
--------
testCode.txt：<br>
`irmovq $15,%rbx`<br>
`rrmovq %rbx,%rcx`<br>
`rmmovq %rcx,-3(%rbx)`<br>
`addq %rbx,%rcx`<br>
命令 python y86_64.py testCode.txt output.txt<br>
输出结果<br>
30f30f0000000000000020314013fdffffffffffffff6031<br>
![编译器命令提示](https://github.com/Xynnn007/Y86-64-Virtual-Machine/blob/master/introPictures/compiler.png)<br>
使用示例 2
--------
input.txt：<br>
irmovq $-4, %rbx<br>
irmovq $10, %rax<br>
subq %rbx, %rax<br>
halt<br>
输出结果<br>
30f3fcffffffffffffff30f00a00000000000000613000<br>
feature 2 机器码->虚拟机执行
=======================
使用示例 3
-------
利用脚本testVM.py，其中的机器码由示例2编译生成<br>
from y86_64 import y86_64_vitualMachine<br>
a = y86_64_vitualMachine(2000)<br>
b = '30f3fcffffffffffffff30f00a00000000000000613000'<br>
a.runCommands(b)<br>
测试得到输出结果：<br>
运行结束!<br>
<br>
寄存器状态：<br>
%rax	0e00000000000000<br>
%rbx	fcffffffffffffff<br>
%rcx	0000000000000000<br>
%rdx	0000000000000000<br>
%rsi	0000000000000000<br>
%rdi	0000000000000000<br>
%rsp	0000000000000000<br>
%rbp	0000000000000000<br>
%r8 	0000000000000000<br>
%r9 	0000000000000000<br>
%r10 	0000000000000000<br>
%r11 	0000000000000000<br>
%r12	0000000000000000<br>
%r13	0000000000000000<br>
%r14	0000000000000000<br>
%pc 	1700000000000000<br>
可以由示例2汇编语法得到，最终%rax=10-(-4)=14，转换为十六进制为0xe，小端表示则为0e0000000000000000，而%rbx为-4的小端表示，也就是fcffffffffffffff，整个指令执行到pc为23结束。
