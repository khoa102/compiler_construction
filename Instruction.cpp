#include "Instruction.hpp"
#include <iostream>
using namespace std;

Instruction::Instruction(){

}

Instruction::Instruction(Opcode code){
	opcode = code;
}

Instruction::Instruction(Opcode code, Operand dest){
	opcode = code;
	destOperand = dest;
}

Instruction::Instruction(Opcode code, Operand dest, Operand src){
	opcode = code;
	destOperand = dest;
	srcOperand1 = src;
}

Instruction::Instruction(Opcode code, Operand dest, Operand src1, Operand src2){
	opcode = code;
	srcOperand1 = src1;
	srcOperand2 = src2;
}

const string Instruction::dumpInstruction(){
	string result = opcodeNameList[opcode];
	if (destOperand.getOperandType() != Operand::NONE) result += " " + destOperand.dumpOperand();
	if (srcOperand1.getOperandType() != Operand::NONE) result += " " + srcOperand1.dumpOperand();
	if (srcOperand2.getOperandType() != Operand::NONE) result += " " + srcOperand2.dumpOperand();

	return result;
}

int main(){
	Operand test(Operand::MEM_ADDRESS, 123);
	cout << test.dumpOperand() <<endl;
	Operand test2(Operand::REGISTER, 1);
	cout << test2.dumpOperand()<<endl;

	Instruction inst (Instruction::ADD, test, test2);
	cout<<inst.dumpInstruction()<<endl;
	return 0;
}