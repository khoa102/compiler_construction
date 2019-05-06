#include "BasicBlock.hpp"

BasicBlock::BasicBlock(int id){
	blockID = id;
}

void BasicBlock::pushBackInstruction(Instruction instruction){
	basicBlock.push_back(instruction);
}

string BasicBlock::dumpBasicBlock(){
	ostringstream os;
	os << "L" << blockID << endl;
	std::list<Instruction>::iterator it;
	for (it = basicBlock.begin(); it != basicBlock.end(); ++it){
		os << it->dumpInstruction();
	}
	return os.str();
}

int BasicBlock::getInstructionNum(){
	return basicBlock.size();
}

/*
int main(){
	BasicBlock block(0);
	Operand dest (Operand::REGISTER, 0);
	Operand src1 (Operand::REGISTER, 1);
	Operand src2 (Operand::REGISTER, 2);
	Instruction test_inst(Instruction::ADD, dest, src1, src2);
	block.pushBackInstruction(test_inst);
	block.pushBackInstruction(test_inst);
	cout << "getInstructionNum(): "<< block.getInstructionNum()<<endl;
	cout << "dumpBasicBlock():\n"<< block.dumpBasicBlock()<<endl;
	return 0;
}
*/