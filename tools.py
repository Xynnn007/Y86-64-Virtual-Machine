#用来存一些其他方法
#
import re
class tools():
	def __init__(self):
		self.registerMap =  {'%rax':'0',
		'%rcx':'1',
		'%rdx':'2',
		'%rbx':'3',
		'%rsp':'4',
		'%rbp':'5',
		'%rsi':'6',
		'%rdi':'7',
		'%r8':'8',
		'%r9':'9',
		'%r10':'a',
		'%r11':'b',
		'%r12':'c',
		'%r13':'d',
		'%r14':'e'}

		self.operationMap = {'addq':'0',
		'subq':'1',
		'andq':'2',
		'xorq':'3'}

		self.jmpMap = {'jmp' : '0',
		'jle' :'1',
		'jl' : '2',
		'je' :'3',
		'jne':'4',
		'jge':'5',
		'jg':'6'}

		self.cmovMap = {'rrmovq':'0',
		'cmovle':'1',
		'cmovl':'2',
		'cmove':'3',
		'cmovne':'4',
		'cmovge':'5',
		'cmovg':'6'}

	def typeof(variate):
		type=None
		if isinstance(variate,int):
			type = "int"
		elif isinstance(variate,str):
			type = "str"
		elif isinstance(variate,float):
			type = "float"
		elif isinstance(variate,list):
			type = "list"
		elif isinstance(variate,tuple):
			type = "tuple"
		elif isinstance(variate,dict):
			type = "dict"
		elif isinstance(variate,set):
			type = "set"
		return type

	#分割编译命令
	def split(self, sentence, separationChar = '[,\s()\n]'):
		res = re.split(separationChar, sentence)
		res1 = []
		for i in res:
			if (i != ''):
				res1.append(i)
		return res1

    #寄存器名称转化为不带0x十六进制数字编号
	def hexByRegister(self, register):
		return self.registerMap[register]

    #偏移量或立即数转化为小端8字节表示
	def opInt2LittleEndine(self, inputInt):
		inputInt = eval(inputInt.replace('$',''))
		#删除数字中可能存在的$符号
		#
		if(inputInt < 0):
			inputInt = inputInt + 0x10000000000000000
		hexResult = '%.16x' % inputInt
		#转化为十六进制表示
		outResult = hexResult[14:] \
		+ hexResult[12:14] \
		+ hexResult[10:12] \
		+ hexResult[8:10] \
		+ hexResult[6:8] \
		+ hexResult[4:6] \
		+ hexResult[2:4] \
		+ hexResult[:2]
		return outResult

    #整数操作指令转换为不带0x十六进制数字编号
	def hexByOP(self, operation):
		return self.operationMap[operation]

    #分支指令转换为不带0x的十六进制数字编号
	def hexByJmp(self, jmp):
		return self.jmpMap[jmp]


	#条件传送指令转换为不带0x的十六进制数字编号
	def hexByCmov(self, cmov):
		return self.cmovMap[cmov]