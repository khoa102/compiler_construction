#include "Operand.hpp"

class Instruction {
	private:
		int instruction_type;
		Operand* dest, source1, source2;
	public:
		Instruction();
		Instruction(int, Operand*, Operand*, Operand*);
		static int ADD;
		static int MINUS; 
}

int Instruction::ADD = 0;
int Instruction::MINUS = 1;