#用来存一些其他方法
#
import re
class tools():
	def __init__(self):
		self.register2CodeMap =  {'%rax':'0',
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

		self.code2RegisterMap =  dict([val,key] for key,val in self.register2CodeMap.items())

		self.operation2CodeMap = {'addq':'0',
		'subq':'1',
		'andq':'2',
		'xorq':'3'}

		self.code2OperationMap =  dict([val,key] for key,val in self.operation2CodeMap.items())

		self.jmp2CodeMap = {'jmp' : '0',
		'jle' :'1',
		'jl' : '2',
		'je' :'3',
		'jne':'4',
		'jge':'5',
		'jg':'6'}

		self.code2JmpMap =  dict([val,key] for key,val in self.jmp2CodeMap.items())

		self.cmov2CodeMap = {'rrmovq':'0',
		'cmovle':'1',
		'cmovl':'2',
		'cmove':'3',
		'cmovne':'4',
		'cmovge':'5',
		'cmovg':'6'}

		self.code2CmovMap =  dict([val,key] for key,val in self.cmov2CodeMap.items())

		self.hex2MathSymbol = {'0':'+',
		'1':'-',
		'2':'&',
		'3':'^'}

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

    #偏移量字符串或立即数转化为小端8字节表示
	def opIntString2LittleEndine(self, inputInt):
		inputInt = eval(inputInt.replace('$',''))
		#删除数字中可能存在的$符号
		#
		if(inputInt < 0):
			inputInt = inputInt + 0x10000000000000000
		hexResult = '%.16x' % inputInt
		#转化为十六进制表示
		'''
		outResult = hexResult[14:] \
		+ hexResult[12:14] \
		+ hexResult[10:12] \
		+ hexResult[8:10] \
		+ hexResult[6:8] \
		+ hexResult[4:6] \
		+ hexResult[2:4] \
		+ hexResult[:2]
		'''
		outResult = hexResult[::-1]
		return outResult

	    #整数转化为小端8字节表示
	def opInt2LittleEndine(self, inputInt):

		inputInt = self.set2StandardInt(inputInt)
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

	#小端8字节转化为十进制数string 带$
	def opLittleEndine2IntString(self, LittleEndineCode):
		#重新调序
		hexOrigin = '0x' + LittleEndineCode[14:] \
		+ LittleEndineCode[12:14] \
		+ LittleEndineCode[10:12] \
		+ LittleEndineCode[8:10] \
		+ LittleEndineCode[6:8] \
		+ LittleEndineCode[4:6] \
		+ LittleEndineCode[2:4] \
		+ LittleEndineCode[:2]
		OutputInt = eval(hexOrigin)
		#判断负数
		if (eval(hexOrigin[:3])&0b1000 != 0):
			OutputInt -= 0x10000000000000000
		OutputString = '$' + str(OutputInt)
		return OutputString

	#小端八字节表示为int
	def opLittleEndine2Int(self, LittleEndineCode):
		#重新调序
		hexOrigin = '0x' + LittleEndineCode[14:] \
		+ LittleEndineCode[12:14] \
		+ LittleEndineCode[10:12] \
		+ LittleEndineCode[8:10] \
		+ LittleEndineCode[6:8] \
		+ LittleEndineCode[4:6] \
		+ LittleEndineCode[2:4] \
		+ LittleEndineCode[:2]
		OutputInt = eval(hexOrigin)
		return self.set2StandardInt(OutputInt)

		#将输入数字转化为合适的处于64位表示范围内的整数
	def set2StandardInt(self, result):
		return result % 0x10000000000000000

    #寄存器名称转化为不带0x十六进制数字编号
	def hexByRegister(self, register):
		return self.register2CodeMap[register]

	#字节码转化为存储器名称
	def registerByHex(self, hex):
		return self.code2RegisterMap[hex]

    #整数操作指令转换为不带0x十六进制数字编号
	def hexByOP(self, operation):
		return self.operation2CodeMap[operation]

 	#字节码转化为整数操作指令
	def opByHex(self, hex):
		return self.code2OperationMap[hex]

	#字节码转化为数学运算符号
	def mathSymbolByHex(self, hex):
		return self.hex2MathSymbol[hex]

    #分支指令转换为不带0x的十六进制数字编号
	def hexByJmp(self, jmp):
		return self.jmp2CodeMap[jmp]

	#字节码转化为分支指令
	def jmpByHex(self, hex):
		return self.code2JmpMap[hex]

	#条件传送指令转换为不带0x的十六进制数字编号
	def hexByCmov(self, cmov):
		return self.cmov2CodeMap[cmov]

	#字节码转换为条件传送指令
	def cmovByHex(self, hex):
		return self.code2CmovMap[hex]