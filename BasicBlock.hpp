#ifndef BASIC_BLOCK_HPP
#define BASIC_BLOCK_HPP

#include "Instruction.hpp"
#include <list>
#include <iostream>

/*
 *	BasicBlock = linear list of instructions
 */

using namespace std;

class BasicBlock{
	public:
		int blockID;				// block id in CFG (also a control flow label)

		BasicBlock(int id);

		void pushBackInstruction(Instruction instruction);
		string dumpBasicBlock();
		int getInstructionNum();

	private:
		list<Instruction> basicBlock;
};

#endif
