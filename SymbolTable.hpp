#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <iostream>
#include <vector>
class Node {
	std::string identifier, scope, type;
	int lineNo, registerNo;

	public:
		// Does it matter what type the id is (except for function, variable, constant)
		enum IdType {FUNC,
					 INT,
					 NONE};

		// What kind of scope do we need? Do we need the scope?
		// Is the lineNo also contribute to the scope
		enum ScopeType {GLOBAL,
						FUNC_PARAM,
						CONST};

		Node();
		Node(std::string key, int registerNo, IdType type, ScopeType scope, int lineNo);
		std::string dumpNode();
		friend class SymbolTable;
};
class SymbolTable{
	std::vector<Node> table[26];

	public:
		SymbolTable();
		int hash(std::string id);
		bool insert(std::string id, int registerNo, Node::IdType type, Node::ScopeType scope, int lineNo);
		bool find (std::string id);
		bool deleteRecord(std::string id);
		bool modify(std::string id, int registerNo, Node::IdType type, Node::ScopeType scope, int lineNo);
		std::string dumpTable();
};
#endif