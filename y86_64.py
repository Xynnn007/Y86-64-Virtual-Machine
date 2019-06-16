#内存字长为8字节
#内存里某个地址的数据统一表示为字符串形式为00，表示一个字节
import tools,sys




class y86_64_vitualMachine():
	def __init__(self, sizeOfMemory):
		#初始化内存
		self.__setMemory()
		#初始化寄存器
		self.__setRegister()
		#初始化标志位
		self.__setCC()
		#初始化程序计数器
		self.PC = 0


		#设置内存
	def __setMemory(self):
		self.memory = ['00' for i in range(sizeOfMemory)]

		#设置寄存器
	def __setRegister():
		self.register = {'rax':'00',
		'rcx':'00',
		'rdx':'00',
		'rbx':'00',
		'rsp':'00',
		'rbp':'00',
		'rsi':'00',
		'rdi':'00',
		'r8':'00',
		'r9':'00',
		'r10':'00',
		'r11':'00',
		'r12':'00',
		'r13':'00',
		'r14':'00'}

	def __setCC(self):
		self.CC = {'ZF':0,
		'SF':0,
		'OF':0}

		#读内存
	def __readMemory(self,addr,size):
		return self.memory[addr:addr+size]

		#写内存
	def __writeMemory(self,addr,data):
		if (len(data) != 4 & data[:2]!='0x'):
			return False
		self.memory[addr] = data
		return True

		#写寄存器
	def __writeRegister(register , value):
		if register in self.register:
			self.register[register] = value

		#读寄存器
	def __readRegister(register):
		if register in self.register:
			return self.register[register]


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
			binCode += self.tools.opInt2LittleEndine(icode[1])
			return binCode

		#rmmovq rA,D(rB)  -> 4|0|rA|rB|D
		elif (icode[0] == 'rmmovq'):
			binCode = '40'

			#寄存器rA
			binCode += self.tools.hexByRegister(icode[1])

			#寄存器rB
			binCode += self.tools.hexByRegister(icode[3])

			#内存偏移D
			binCode += self.tools.opInt2LittleEndine(icode[2])
			return binCode

		#mrmovq rA,D(rB)  -> 5|0|rA|rB|D
		elif (icode[0] == 'mrmovq'):
			binCode = '50'

			#寄存器rA
			binCode += self.tools.hexByRegister(icode[3])

			#寄存器rB
			binCode += self.tools.hexByRegister(icode[2])

			#内存偏移D
			binCode += self.tools.opInt2LittleEndine(icode[1])
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
			binCode += self.tools.opInt2LittleEndine(icode[1])

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
			binCode += self.tools.opInt2LittleEndine(icode[1])

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
							V = self.tools.opLittleEndine2Int(inputFile.read(16))
							outputFile.write('irmovq %s, %s\n' % (V,rB))

					elif (char == '4'):
						char = inputFile.read(1)
						if char == '0':
							rA = self.tools.registerByHex(inputFile.read(1))
							rB = self.tools.registerByHex(inputFile.read(1))
							D = self.tools.opLittleEndine2Int(inputFile.read(16))
							outputFile.write('rmmovq %s, %s(%s)\n' % (rA,D,rB))

					elif (char == '5'):
						char = inputFile.read(1)
						if char == '0':
							rA = self.tools.registerByHex(inputFile.read(1))
							rB = self.tools.registerByHex(inputFile.read(1))
							D = self.tools.opLittleEndine2Int(inputFile.read(16))
							outputFile.write('mrmovq %s(%s), %s\n' % (D,rB,rA))

					elif (char == '6'):
						op = self.tools.opByHex(inputFile.read(1))
						rA = self.tools.registerByHex(inputFile.read(1))
						rB = self.tools.registerByHex(inputFile.read(1))
						outputFile.write('%s %s, %s\n' % (op,rA,rB))

					elif (char == '7'):
						jXX = self.tools.jmpByHex(inputFile.read(1))
						Dest = self.tools.opLittleEndine2Int(inputFile.read(16))
						outputFile.write('%s %s\n' % (jXX,Dest))

					elif (char == '8'):
						char = inputFile.read(1)
						if char == '0':
							Dest = self.tools.opLittleEndine2Int(inputFile.read(16))
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
