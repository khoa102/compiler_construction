#ifndef Operand
#define Operand
class Operand {
	private:
		int operand_type;
		int register_id;
	public:
		Operand (int type, int id); 
		// static int REGISTER; 
};
#endif