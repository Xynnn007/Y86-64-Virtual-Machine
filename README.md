# Y86-64 Virtual Machine

Դ�ڡ������������ϵͳ��by Randal E. Bryant�� David R.O' Hallaron
�����´�������ϵ�ṹƪx86-64�ļ��װ�y86-64

feature 1	�����->������

ʾ���ļ�testCode.txt
irmovq $15,%rbx
rrmovq %rbx,%rcx
rmmovq %rcx,-3(%rbx)
addq %rbx,%rcx

���� python y86_64.py testCode.txt output.txt

������
30f30f0000000000000020314013fdffffffffffffff6031
