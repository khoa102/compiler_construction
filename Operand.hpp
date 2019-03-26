#ifndef OPERAND_H
#define OPERAND_H

#include <string>
#include <sstream>

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
		Operand(OperandType, int);

		string dumpOperand();
		int getOperandValue();
		OperandType getOperandType();

	private:
		OperandType operandType;
		int value;
};

#endif
