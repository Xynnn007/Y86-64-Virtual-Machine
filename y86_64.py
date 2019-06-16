#内存字长为8字节
#内存里某个地址的数据统一表示为字符串形式为0x00，表示一个字节
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
		self.memory = ['0x00' for i in range(sizeOfMemory)]

		#设置寄存器
	def __setRegister():
		self.register = {'rax':'0x00',
		'rcx':'0x00',
		'rdx':'0x00',
		'rbx':'0x00',
		'rsp':'0x00',
		'rbp':'0x00',
		'rsi':'0x00',
		'rdi':'0x00',
		'r8':'0x00',
		'r9':'0x00',
		'r10':'0x00',
		'r11':'0x00',
		'r12':'0x00',
		'r13':'0x00',
		'r14':'0x00'}

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
			with open(outfile ,'a') as outputFile:
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
