#内存字长为8字节
#内存里某个地址的数据统一表示为字符串形式为00，表示一个字节
import tools,sys




class y86_64_vitualMachine():
	def __init__(self, sizeOfMemory):
		#初始化内存
		self.__setMemory(sizeOfMemory)
		#初始化寄存器
		self.__setRegister()
		#初始化标志位
		self.__setCC()
		#初始化程序计数器

		#初始化停机状态
		self.haltState = 0

		self.tools = tools.tools()

		#设置内存
	def __setMemory(self, sizeOfMemory):
		self.__memory = ['00' for i in range(sizeOfMemory)]

		#设置寄存器
	def __setRegister(self):
		self.__register = {'%rax':'0000000000000000',
		'%rcx':'0000000000000000',
		'%rdx':'0000000000000000',
		'%rbx':'0000000000000000',
		'%rsp':'0000000000000000',
		'%rbp':'0000000000000000',
		'%rsi':'0000000000000000',
		'%rdi':'0000000000000000',
		'%r8':'0000000000000000',
		'%r9':'0000000000000000',
		'%r10':'0000000000000000',
		'%r11':'0000000000000000',
		'%r12':'0000000000000000',
		'%r13':'0000000000000000',
		'%r14':'0000000000000000',
		'pc':'0000000000000000'}

	def __setCC(self):
		self.__CC = {'ZF':0,
		'SF':0,
		'OF':0}

		#写状态寄存器
	def __writeCC(self,CC,value):
		if CC in self.__CC:
			self.__CC[CC] = value

		#读状态寄存器
	def __readCC(self,CC):
		if CC in self.__CC:
			return self.__CC[CC]

		#设置程序计数器PC
	def __setPC(self, value):
		hexValue = self.tools.opInt2LittleEndine(value)

		self.__writeRegister('pc',hexValue)

		#获得程序计数器PC
	def __getPC(self):
		intValue = self.tools.opLittleEndine2Int(self.__readRegister('pc'))
		return intValue

		#读内存一个字节
	def __readMemoryByte(self,addr):
		return self.__memory[addr]

		#读内存8个字节
	def __readMemory8Byte(self,addr):
		readMemory = "" + self.__readMemoryByte(addr+7)\
		+ self.__readMemoryByte(addr+6) \
		+ self.__readMemoryByte(addr+5) \
		+ self.__readMemoryByte(addr+4) \
		+ self.__readMemoryByte(addr+3) \
		+ self.__readMemoryByte(addr+2) \
		+ self.__readMemoryByte(addr+1) \
		+ self.__readMemoryByte(addr) \

		return readMemory

		#写内存一个字节
	def __writeMemoryByte(self,addr,data):
		self.__memory[addr] = data
		return True

		#写内存8个字节，小端模式
	def __writeMemory8Byte(self,addr,data):
		self.__writeMemoryByte(addr, data[14:16])
		self.__writeMemoryByte(addr + 1, data[12:14])
		self.__writeMemoryByte(addr + 2, data[10:12])
		self.__writeMemoryByte(addr + 3, data[8:10])
		self.__writeMemoryByte(addr + 4, data[6:8])
		self.__writeMemoryByte(addr + 5, data[4:6])
		self.__writeMemoryByte(addr + 6, data[2:4])
		self.__writeMemoryByte(addr + 7, data[0:2])


		#写寄存器
	def __writeRegister(self, register , value):
		if register in self.__register:
			self.__register[register] = value

		#读寄存器
	def __readRegister(self, register):
		if register in self.__register:
			return self.__register[register]

		#入栈8字节
	def __push(self, data):
		presentPoint = self.tools.opLittleEndine2Int(self.__readRegister('rsp'))
		presentPoint -= 8
		self.__writeMemory8Byte(presentPoint, data)
		self.__writeRegister('rsp', self.tools.opInt2LittleEndine(presentPoint))

		#出栈8字节到寄存器
	def __pop(self, register):
		presentPoint = self.tools.opLittleEndine2Int(self.__readRegister('rsp'))
		data = self.__readMemory8Byte(presentPoint)
		presentPoint += 8
		self.__writeRegister('rsp', self.tools.opInt2LittleEndine(presentPoint))
		self.__writeRegister(register, data)

		#连续跑命令
	def runCommands(self, commandSeries):
		commandsLength = len(commandSeries)
		while(not self.haltState):
			i = self.__getPC() * 2
			code = commandSeries[i]
			if(code == '0'):
				self.__runCommand(commandSeries[i:i+2], 0)

			elif(code == '1'):
				self.__runCommand(commandSeries[i:i+2], 1)

			elif(code == '2'):
				self.__runCommand(commandSeries[i:i+4], 2)

			elif(code == '3'):
				self.__runCommand(commandSeries[i:i+20], 3)

			elif(code == '4'):
				self.__runCommand(commandSeries[i:i+20], 4)

			elif(code == '5'):
				self.__runCommand(commandSeries[i:i+20], 5)
	
			elif(code == '6'):
				self.__runCommand(commandSeries[i:i+4], 6)
			
			elif(code == '7'):
				self.__runCommand(commandSeries[i:i+18], 7)
			
			elif(code == '8'):
				self.__runCommand(commandSeries[i:i+18], 8)
		
			elif(code == '9'):
				self.__runCommand(commandSeries[i:i+2], 9)
			
			elif(code == 'a'):
				self.__runCommand(commandSeries[i:i+4], 0xa)
			
			elif(code == 'b'):
				self.__runCommand(commandSeries[i:i+4], 0xb)
				
			i = self.__getPC() * 2

		#跑一条命令
		print("运行结束!\n")
		print("寄存器状态：\n")
		print("%%rax	%s\n" %self.__readRegister('%rax'))
		print("%%rbx	%s\n" %self.__readRegister('%rbx'))
		print("%%rcx	%s\n" %self.__readRegister('%rcx'))
		print("%%rdx	%s\n" %self.__readRegister('%rdx'))
		print("%%rsi	%s\n" %self.__readRegister('%rsi'))
		print("%%rdi	%s\n" %self.__readRegister('%rdi'))
		print("%%rsp	%s\n" %self.__readRegister('%rsp'))
		print("%%rbp	%s\n" %self.__readRegister('%rbp'))
		print("%%r8 	%s\n" %self.__readRegister('%r8'))
		print("%%r9 	%s\n" %self.__readRegister('%r9'))
		print("%%r10 	%s\n" %self.__readRegister('%r10'))
		print("%%r11 	%s\n" %self.__readRegister('%r11'))
		print("%%r12	%s\n" %self.__readRegister('%r12'))
		print("%%r13	%s\n" %self.__readRegister('%r13'))
		print("%%r14	%s\n" %self.__readRegister('%r14'))
		print("%%pc 	%s\n" %self.__readRegister('pc'))
		#跑一条命令
	def __runCommand(self, command, type):
			#停机
			i = 0
			if (type == 0):
				i += 1
				if command[i] == '0':
					self.haltState = 1
					#HALT
				self.__setPC(self.__getPC() + 1)

			#nop
			elif (type == 1):
				i += 1
				if command[i] == '0':
					pass
					#nop
				self.__setPC(self.__getPC() + 1)	

			#rrmovq/cmovXX
			elif (type == 2):
				i += 1
				op = command[i]
				i += 1
				rA = self.tools.registerByHex(command[i])
				i += 1
				rB = self.tools.registerByHex(command[i])
				if op == '0':
					self.__writeRegister(rB , self.__readRegister(rA))

					#cmovle
				elif(op == '1' and (not(self.__readCC('SF') ^ self.__readCC('OF'))or self.__readCC('ZF')) ):
					self.__writeRegister(rB , self.__readRegister(rA))
					
					#cmovl
				elif(op == '2' and (self.__readCC('SF') ^ self.__readCC('OF')) ):
					self.__writeRegister(rB , self.__readRegister(rA))
					
					#cmove
				elif(op == '3' and self.__readCC('ZF') ):
					self.__writeRegister(rB , self.__readRegister(rA))
					
					#cmovne
				elif(op == '4' and (not self.__readCC('ZF')) ):
					self.__writeRegister(rB , self.__readRegister(rA))

					#cmovge
				elif(op == '5' and (not (self.__readCC('SF') ^ self.__readCC('OF'))) ):
					self.__writeRegister(rB , self.__readRegister(rA))

					#cmovg
				elif(op == '6' and (not (self.__readCC('SF') ^ self.__readCC('OF'))and not self.__readCC('ZF')) ):
					self.__writeRegister(rB , self.__readRegister(rA))
				self.__setPC(self.__getPC() + 2)

			#irmovq
			elif (type == 3):
				i += 2

				if command[i-1:i+1] == '0f':
					i += 1
					rB = self.tools.registerByHex(command[i])
					i += 16
					V = command[i-15:i+1]
					self.__writeRegister(rB , V)
					self.__setPC(self.__getPC() + 10)
					#irmovq

			#rmmovq
			elif (type == 4):
				i += 1
				if command[i] == '0':
					i += 1
					rA = self.tools.registerByHex(command[i])
					i += 1
					rB = self.tools.registerByHex(command[i])
					i += 16
					D = self.tools.opLittleEndine2Int(command[i-15:i+1])
					self.__writeMemory8Byte(self.__readRegister(rB) + D, self.__readRegister(rA))
					self.__setPC(self.__getPC() + 10)
					#rmmovq

			#mrmovq
			elif (type == 5):
				i += 1
				if command[i] == '0':
					i += 1
					rA = self.tools.registerByHex(command[i])
					i += 1
					rB = self.tools.registerByHex(command[i])
					i += 16
					D = self.tools.opLittleEndine2Int(command[i-15:i+1])
					self.__writeRegister(rA, self.__readMemory8Byte(self.tools.opLittleEndine2Int(self.__readRegister(rB)) + D, 16))
					self.__setPC(self.__getPC() + 10)
					#mrmovq

				# OP 操作符
			
			#OP
			elif (type == 6):
				i += 1
				op = self.tools.mathSymbolByHex(command[i])
				i += 1
				rA = self.tools.registerByHex(command[i])
				i += 1
				rB = self.tools.registerByHex(command[i])

				#加减算法
				if (op in ['+','-']):
					equation =  str(self.tools.opLittleEndine2Int(self.__readRegister(rB))) + op + str(self.tools.opLittleEndine2Int(self.__readRegister(rA)))
					result = eval(equation)
					#设置标志位
					if (result < -0x100000000000000 or result > 0x7fffffffffffffff):
						self.__writeCC('OF',1)
					else:
						self.__writeCC('OF',0)
					if (result == 0):
						self.__writeCC('ZF',1)
					else:
						self.__writeCC('ZF',0)
					result = self.tools.set2StandardInt(result)
					if (result & 0x8000000000000000 != 0 ):
						self.__writeCC('SF',1)
					else :
						self.__writeCC('SF',0)
					result = self.tools.opInt2LittleEndine(result)
				#位级算法
				elif (op in ['&','^']):
					equcation = "0x" + self.__readRegister(rB) + op + "0x" + self.__readRegister(rA)
					result = eval(equcation)

					#设置标志位
					self.__writeCC('OF',0)
					if (result == 0):
						self.__writeCC('ZF',1)
					else:
						self.__writeCC('ZF',0)

					result = "%.16x" % result
					if (result[0] == '0'):
						self.__writeCC('SF',0)
					else:
						self.__writeCC('SF',1)
				
				#写入寄存器rB
				self.__writeRegister(rB, result)
				self.__setPC(self.__getPC() + 2)
				#OPq rA,rB
				
				#跳转操作符
			
			#jXX
			elif (type == 7):
				i += 1
				JXXCode = command[i]
				i += 16
				Dest = self.tools.opLittleEndine2Int(command[i-15:i+1])
				if (JxxCode =='0'):
					self.__setPC(Dest)
					
					#jle
				elif(JxxCode == '1' and (not (self.__readCC('SF') ^ self.__readCC('OF'))or self.__readCC('ZF')) ):
					self.__setPC(Dest)
					
					#jl
				elif(JxxCode == '2' and (self.__readCC('SF') ^ self.__readCC('OF')) ):
					self.__setPC(Dest)
					
					#je
				elif(JxxCode == '3' and self.__readCC('ZF') ):
					self.__setPC(Dest)
					
					#jne
				elif(JxxCode == '4' and (not self.__readCC('ZF')) ):
					self.__setPC(Dest)

					#jge
				elif(JxxCode == '5' and (not (self.__readCC('SF') ^ self.__readCC('OF'))) ):
					self.__setPC(Dest)

					#jg
				elif(JxxCode == '6' and (not (self.__readCC('SF') ^ self.__readCC('OF'))and not self.__readCC('ZF')) ):
					self.__setPC(Dest)
				self.__setPC(self.__getPC() + 9)
				
			#call Dest
			elif (type == 8):
				i += 1
				if command[i] == '0':
					i += 16
					Dest = self.tools.opLittleEndine2Int(command[i-15:i+1])
					self.__setPC(Dest)
					self.__push(self.tools.opInt2LittleEndine(self.__getPC + 9))

			#ret
			elif (type == 9):
				i += 1
				if command[i] == '0':
					self.__pop('pc')

			#pushq
			elif (type == 0xa):
				i += 1
				if command[i] == '0':
					i += 1
					rA = self.tools.registerByHex(command[i])
					i += 1
					if command[i] == 'f':
						self.__push(self.__readRegister[rA])
						self.__setPC(self.__getPC + 2)

			#popq
			elif (type == 0xb):
				i += 1
				if command[i] == '0':
					i += 1
					rA = self.tools.registerByHex(command[i])
					i += 1
					if command[i] == 'f':
						self.__pop(rA)
						self.__setPC(self.__getPC + 2)
	#def __runCommand(command):

	#def __compile()

class y86_64_compiler():
	def __init__(self):
		self.tools = tools.tools()
	def helper(self):
		print(
			'''
		y86-64编译器，请使用命令格式如下：
			参数1：源汇编文件
			参数2：输出文件
			'''
			)

	#编译函数
	def compile(self, infile, outfile):
		with open(infile , 'r') as inputFile:
			with open(outfile ,'w') as outputFile:
				sentence = inputFile.readline()
				while(sentence):
					outputFile.write(self.__compileSentence(sentence))
					sentence = inputFile.readline()

	#逐句编译
	def __compileSentence(self, sentence):
		#拆分语句为每个变量
		sentence = sentence.lower()
		icode = self.tools.split(sentence)

		#计算语句元长度
		lenOfSentence = len(icode)
		
		#halt
		if (icode[0] == 'halt'):
			return '00'

		#nop
		elif (icode[0] == 'nop'):
			return '10'

		#rrmovq rA,rB -> 2|0|rA|rB
		elif (icode[0] == 'rrmovq'):
			binCode = '20'

			#寄存器rA
			binCode += self.tools.hexByRegister(icode[1])

			#寄存器rB
			binCode += self.tools.hexByRegister(icode[2])
			return binCode

		#irmovq V,rB  -> 3|0|F|rB
		elif (icode[0] == 'irmovq'):
			binCode = '30f'

			#寄存器rB
			binCode += self.tools.hexByRegister(icode[2])

			#立即数V
			binCode += self.tools.opIntString2LittleEndine(icode[1])
			return binCode

		#rmmovq rA,D(rB)  -> 4|0|rA|rB|D
		elif (icode[0] == 'rmmovq'):
			binCode = '40'

			#寄存器rA
			binCode += self.tools.hexByRegister(icode[1])

			#寄存器rB
			binCode += self.tools.hexByRegister(icode[3])

			#内存偏移D
			binCode += self.tools.opIntString2LittleEndine(icode[2])
			return binCode

		#mrmovq rA,D(rB)  -> 5|0|rA|rB|D
		elif (icode[0] == 'mrmovq'):
			binCode = '50'

			#寄存器rA
			binCode += self.tools.hexByRegister(icode[3])

			#寄存器rB
			binCode += self.tools.hexByRegister(icode[2])

			#内存偏移D
			binCode += self.tools.opIntString2LittleEndine(icode[1])
			return binCode

		#OPq rA,rB  -> 6|fn|rA|rB
		elif (icode[0] in ['addq','subq','andq','xorq']):
			binCode = '6'

			#操作数fn
			binCode += self.tools.hexByOP(icode[0])

			#寄存器rA
			binCode += self.tools.hexByRegister(icode[1])

			#寄存器rB
			binCode += self.tools.hexByRegister(icode[2])
			return binCode

		#jXX Dest  -> 7|fn|Dest
		elif (icode[0][0] == 'j'):
			binCode = '7'

			#操作数fn
			binCode += self.tools.hexByJmp(icode[0])

			#目的地址Dest
			binCode += self.tools.opIntString2LittleEndine(icode[1])

			return binCode

		#cmovXX rA,rB  -> 2|fn|rA|rB
		elif (icode[0][:4] == 'cmov'):
			binCode = '2'

			#操作数fn
			binCode += self.tools.hexByCmov(icode[0])

			#寄存器rA
			binCode += self.tools.hexByRegister(icode[1])

			#寄存器rB
			binCode += self.tools.hexByRegister(icode[2])

			return binCode

		#call Dest  -> 8|0|Dest	
		elif (icode[0] == 'call'):
			binCode = '80'

			#目的地址Dest
			binCode += self.tools.opIntString2LittleEndine(icode[1])

			return binCode
		
		#ret
		elif (icode[0] == 'ret'):
			binCode = '90'

			return binCode

		#pushq rA  -> a|0|rA|f
		elif (icode[0] == 'call'):
			binCode = 'a0'

			#寄存器rA
			binCode += self.tools.hexByRegister(icode[1])

			binCode += 'f'

			return binCode

		#popq rA  -> b|0|rA|f
		elif (icode[0] == 'call'):
			binCode = 'b0'

			#寄存器rA
			binCode += self.tools.hexByRegister(icode[1])

			binCode += 'f'

			return binCode

class y86_64_disassembler():
	def __init__(self):
		self.tools = tools.tools()
	def helper(self):
		print(
			'''
		y86-64反汇编器，请使用命令格式如下：
			参数1：源机器代码文件
			参数2：输出汇编文件
			'''
			)
	def disassemble(self, infile, outfile):
		with open(infile , 'r') as inputFile:
			with open(outfile ,'w') as outputFile:
				char = inputFile.read(1)
				while(char):
					if (char == '0'):
						char = inputFile.read(1)
						if char == '0':
							outputFile.write('halt\n')

					elif (char == '1'):
						char = inputFile.read(1)
						if char == '0':
							outputFile.write('nop\n')

					elif (char == '2'):
						char = inputFile.read(1)
						if char == '0':
							rA = self.tools.registerByHex(inputFile.read(1))
							rB = self.tools.registerByHex(inputFile.read(1))
							outputFile.write('rrmovq %s, %s\n' % (rA,rB))

					elif (char == '3'):
						char = inputFile.read(2)
						if char == '0f':
							rB = self.tools.registerByHex(inputFile.read(1))
							V = self.tools.opLittleEndine2IntString(inputFile.read(16))
							outputFile.write('irmovq %s, %s\n' % (V,rB))

					elif (char == '4'):
						char = inputFile.read(1)
						if char == '0':
							rA = self.tools.registerByHex(inputFile.read(1))
							rB = self.tools.registerByHex(inputFile.read(1))
							D = self.tools.opLittleEndine2IntString(inputFile.read(16))
							outputFile.write('rmmovq %s, %s(%s)\n' % (rA,D,rB))

					elif (char == '5'):
						char = inputFile.read(1)
						if char == '0':
							rA = self.tools.registerByHex(inputFile.read(1))
							rB = self.tools.registerByHex(inputFile.read(1))
							D = self.tools.opLittleEndine2IntString(inputFile.read(16))
							outputFile.write('mrmovq %s(%s), %s\n' % (D,rB,rA))

					elif (char == '6'):
						op = self.tools.opByHex(inputFile.read(1))
						rA = self.tools.registerByHex(inputFile.read(1))
						rB = self.tools.registerByHex(inputFile.read(1))
						outputFile.write('%s %s, %s\n' % (op,rA,rB))

					elif (char == '7'):
						jXX = self.tools.jmpByHex(inputFile.read(1))
						Dest = self.tools.opLittleEndine2IntString(inputFile.read(16))
						outputFile.write('%s %s\n' % (jXX,Dest))

					elif (char == '8'):
						char = inputFile.read(1)
						if char == '0':
							Dest = self.tools.opLittleEndine2IntString(inputFile.read(16))
							outputFile.write('call %s\n' % (Dest))

					elif (char == '9'):
						char = inputFile.read(1)
						if char == '0':
							outputFile.write('ret\n')

					elif (char == 'a'):
						char = inputFile.read(1)
						if char == '0':
							rA = self.tools.registerByHex(inputFile.read(1))
							char = inputFile.read(1)
							if char == 'f':
								outputFile.write('pushq %s\n' % (rA))

					elif (char == 'b'):
						char = inputFile.read(1)
						if char == '0':
							rA = self.tools.registerByHex(inputFile.read(1))
							char = inputFile.read(1)
							if char == 'f':
								outputFile.write('popq %s\n' % (rA))

					char = inputFile.read(1)

def main():
	compiler = y86_64_compiler()
	if len(sys.argv) != 3:
		usage()
		sys.exit()

	inputFile = sys.argv[1]
	outputFile = sys.argv[2]

	compiler.compile(inputFile, outputFile)
	print("编译完成，输出文件为%s\n" % outputFile)

if __name__ == '__main__':
    main()
