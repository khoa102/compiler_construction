#ifndef INSTRUCTION_H
#define INSTRUCTION_H

#include "Operand.hpp"

// TODO check if given operands and opcode are valid
// (should match the number of required operands for each opcode)

/*
 * Instruction class models a particular instruction in 3-address code
 * [OPCODE]	[DEST_OPERAND]  [SRC_OPERAND_1]	[SRC_OPERAND_2 (if any)]
 */

class Instruction{
	public:
		enum Opcode {	// arithmetic instructions: [dest_op] [src_op_1] [src_op_2]
						ADD,
						SUB,
						MUL,
						DIV,
						// memory instructions: [dest_op] [src_op]
						MOVE,
						LOAD,
						STORE,
						// conditional instructions: [dest_op] [src_op_1] [src_op_2]
						EQUAL,
						INEQUAL,
						GREATER_EQUAL,
						LESS_THAN,
						GREATER_THAN,
						LESS_EQUAL,
						// control flow instructions:
						JUMP,				// unconditional jump [dest_label]
						JUMP_TRUE,			// conditional jump [dest_label] [src_op] if src_op is true
						JUMP_FALSE,			// conditional jump [dest_label] [src_op] if src_op is false
						// no-op
						NONE};

		Instruction();
		Instruction(Opcode);
		Instruction(Opcode, Operand);
		Instruction(Opcode, Operand, Operand);
		Instruction(Opcode, Operand, Operand, Operand);

		const string dumpInstruction();

	private:
		Opcode opcode;
		Operand srcOperand1, srcOperand2, destOperand;

		const string opcodeNameList[17] = {	"ADD",
											"SUB",
											"MUL",
											"DIV",
											"MV",
											"LD",
											"STR",
											"EQ",
											"NE",
											"GE",
											"LT",
											"GT",
											"LE",
											"JMP",
											"JMPT",
											"JMPF",
											"NO-OP"};

		const string opcodeComments[17] = {	"[dest_op] = [src_op_1] + [src_op_2]",
											"[dest_op] = [src_op_1] - [src_op_2]",
											"[dest_op] = [src_op_1] * [src_op_2]",
											"[dest_op] = [src_op_1] / [src_op_2]",
											"[dest_op] <- [src_op_1: register]",
											"[dest_op] <- [src_op_1: memory address/ constant]",
											"[dest_op: memory address] <- [src_op_1]",
											"[dest_op] = [src_op_1] == [src_op_2]",
											"[dest_op] = [src_op_1] != [src_op_2]",
											"[dest_op] = [src_op_1] >= [src_op_2]",
											"[dest_op] = [src_op_1] <  [src_op_2]",
											"[dest_op] = [src_op_1] >  [src_op_2]",
											"[dest_op] = [src_op_1] <= [src_op_2]",
											"[dest_op: label]",
											"[dest_op: label] if [src_op_1: 0 or 1] is 1",
											"[dest_op: label] if [src_op_1: 0 or 1] is 0",
											"NO-OP"};
};

#endif
