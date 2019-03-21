#include "Operand.hpp"

Operand::Operand (int type, int id){
	operand_type = type;
	register_id = id;
}

int Operand::REGISTER = 0;