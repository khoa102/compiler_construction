#include "Operand.hpp"
#include <iostream>

Operand::Operand(){
	operandType = NONE;

}
Operand::Operand (OperandType type, int v){
	operandType = type;
	value = v;
}


string Operand::dumpOperand(){
	ostringstream os;

	if (operandType == REGISTER){
		os << "R" << value;
	}
	else if (operandType == MEM_ADDRESS){
		os<< "&" << value;
	} else if (operandType == CONST){
		os << "$" << value;
	} else if (operandType == LABEL){
		os << "L" << value;
	}
	return os.str();
}

int Operand::getOperandValue(){
	return value;
}

Operand::OperandType Operand::getOperandType(){
	return operandType;
}

/*
int main(){
	Operand test;
	cout << test.dumpOperand() <<endl;
	Operand test2(Operand::REGISTER, 1);
	cout << test2.dumpOperand()<<endl;
	return 0;
}*/