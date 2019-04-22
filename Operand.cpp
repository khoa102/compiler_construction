#include "Operand.hpp"
#include <iostream>

Operand::Operand(){
	this->operandType = NONE;
	this->dataType = NULL_T;

}
Operand::Operand (OperandType type, int v){
	this->operandType = type;
	this->iVal = v;
	this->dataType = INT_T;
}
Operand::Operand (OperandType type, int v, DataType dataType){
	this->operandType = type;
	this->iVal = v;
	this->dataType = dataType;
}
Operand::Operand (OperandType type, float v){
	this->operandType = type;
	this->fVal = v;
	this->dataType = FLOAT_T;
}
Operand::Operand (OperandType type, double v){
	this->operandType = type;
	this->fVal = v;
	this->dataType = FLOAT_T;
}
Operand::Operand (OperandType type, bool v){
	this->operandType = type;
	this->bVal = v;
	this->dataType = BOOL_T;
}
Operand::Operand (OperandType type, char v){
	this->operandType = type;
	this->cVal = v;
	this->dataType = CHAR_T;
}
Operand::Operand (OperandType type, string v){
	this->operandType = type;
	this->sVal = v;
	this->dataType = STRING_T;
}


string Operand::dumpOperand(){
	ostringstream os;

	if (operandType == REGISTER){
		os << "R" << iVal;
	}
	else if (operandType == MEM_ADDRESS){
		os<< "&" << iVal;
	} else if (operandType == CONST){
		if (this->dataType == INT_T)
			os << "$" << iVal;
		else if (this->dataType == FLOAT_T)
			os << "$" << fVal;
		else if (this->dataType == BOOL_T)
			os << "$" << bVal;
		else if (this->dataType == CHAR_T)
			os << "$" << cVal;
		else if (this->dataType == STRING_T)
			os << "$" << sVal;
		else 
			os << "$" << iVal;

	} else if (operandType == LABEL){
		os << "L" << iVal;
	}
	return os.str();
}

int Operand::getOperandValue(){
	return iVal;
}


Operand::OperandType Operand::getOperandType(){
	return operandType;
}

DataType Operand::getDataType(){
	return this->dataType;
}
/*
int main(){
	Operand test;
	cout << test.dumpOperand() <<endl;
	Operand test2(Operand::REGISTER, 1);
	cout << test2.dumpOperand()<<endl;
	return 0;
}*/