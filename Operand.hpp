#ifndef OPERAND_H
#define OPERAND_H

#include <string>
#include <sstream>
#include "Utilities.hpp"

using namespace std;

/*
 *	Operand class models a particular operand (register, memory or constant)
 *	in the following format
 *	[Operand type] [Value]
 */

class Operand {
	public:
		enum OperandType {	REGISTER,			// e.g., R1
							MEM_ADDRESS,		// e.g., &1234
							CONST,				// e.g., $5
							LABEL,				// e.g., L1
							NONE};				// empty

		Operand();
		Operand(OperandType type, int v);
		Operand(OperandType type, bool v);
		Operand(OperandType type, float v);
		Operand(OperandType type, double v);
		Operand(OperandType type, char v);
		Operand(OperandType type, string v);
		Operand (OperandType type, int v, DataType dataType);  // This is for storing register, mem_address or label
		string dumpOperand();
		int getOperandValue();
		OperandType getOperandType();
		DataType getDataType();

	private:
		OperandType operandType;
		int iVal;
		bool bVal;
		double fVal;
		char cVal;
		string sVal;
		DataType dataType;
};

#endif
