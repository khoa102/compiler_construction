#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <iostream>
#include <vector>
#include "Utilities.hpp"
class Node {
	public:
		// Does it matter what type the id is (except for function, variable, constant)
		enum IdType {FUNC,
					 VAR,
					 CONST};

		// What kind of scope do we need? Do we need the scope?
		// Is the lineNo also contribute to the scope
		enum ScopeType {GLOBAL,
						FUNC_PARAM,
						LOCAL};
		Node();
		Node(std::string key, int registerNo, IdType idType, ScopeType scope, DataType dataType, int lineNo);
		int getRegister();
		IdType getIdType();
		DataType getDataType();
		ScopeType getScope();
		std::string dumpNode();
		friend class SymbolTable;
	private:
		std::string identifier;
		IdType idType;
		ScopeType scope;
		DataType dataType;
		int lineNo, registerNo;
};
class SymbolTable{
	std::vector<Node> table[26];

	public:
		SymbolTable();
		int hash(std::string id);
		bool insert(std::string id, int registerNo, Node::IdType type, Node::ScopeType scope, DataType dataType, int lineNo);
		bool find (std::string id);
		bool deleteRecord(std::string id);
		bool modify(std::string id, int registerNo, Node::IdType type, Node::ScopeType scope, DataType dataType, int lineNo);
		int getRegister(std::string id);
		Node getNode(std::string id);
		std::string dumpTable();
};
#endif