#include "SymbolTable.hpp"


#include <iostream>
#include <sstream>
using namespace std;

Node::Node(){
	this->identifier = "";
	this->idType = VAR;
	this->scope = GLOBAL;
	this->registerNo = -1;
	this->dataType = NULL_T;
	this->lineNo = -1;
}
Node::Node(string key, int registerNo, IdType idType, ScopeType scope, DataType dataType, int lineNo){
	this->identifier = key;
	this->idType = idType;
	this->scope = scope;
	this->registerNo = registerNo;
	this->dataType = dataType;
	this->lineNo = lineNo;
}

int Node::getRegister(){
	return this->registerNo;
}

Node::IdType Node::getIdType(){
	return this->idType;
}
DataType Node::getDataType(){
	return this->dataType;
}
Node::ScopeType Node::getScope(){
	return this->scope;
}


string Node::dumpNode(){
	ostringstream os;
	os << "Id: " << identifier << "\tidType: " << idType << "\tScope: " << scope <<"\tRegister Num: " << registerNo << "\tDataType: "<< dataType<< "\tLine Num: " << lineNo <<endl;
	return os.str();
}


SymbolTable::SymbolTable(){

}

int SymbolTable::hash(string id){
	return int(std::toupper(id[0])) - 65;
}

bool SymbolTable::insert(string id, int registerNo, Node::IdType idType, Node::ScopeType scope, DataType dataType, int lineNo){
	int index = hash(id);
	Node data (id, registerNo, idType, scope, dataType, lineNo);
	table[index].push_back(data);
}

bool SymbolTable::find (string id){
	int index = hash(id);
	for (std::vector<Node>::iterator it = table[index].begin(); it != table[index].end(); ++it){
		if (it->identifier == id){
			return true;
		}
	}
	return false;
}

bool SymbolTable::deleteRecord(string id){
	int index = hash(id);
	for (std::vector<Node>::iterator it = table[index].begin(); it != table[index].end(); ++it){
		if (it->identifier == id){
			it = table[index].erase(it);
			return true;
		}
	}
	return false;
}

bool SymbolTable::modify(string id, int registerNo, Node::IdType idType, Node::ScopeType scope, DataType dataType, int lineNo){
	int index = hash(id);
	for (std::vector<Node>::iterator it = table[index].begin(); it != table[index].end(); ++it){
		if (it->identifier == id){
			Node temp(id, registerNo, idType, scope, dataType, lineNo);
			*it = temp;
			// it->type = type;
			// it->scope = scope;
			// it->registerNo = registerNo;
			// it->lineNo = lineNo;
			return true;
		}
	}
	return false;
}

int SymbolTable::getRegister(string id){
	int index = hash(id);
	for (std::vector<Node>::iterator it = table[index].begin(); it != table[index].end(); ++it){
		if (it->identifier == id){
			return it->registerNo;
		}
	}
	return -1;
}
Node SymbolTable::getNode(string id){
	int index = hash(id);
	for (std::vector<Node>::iterator it = table[index].begin(); it != table[index].end(); ++it){
		if (it->identifier == id){
			return *it;
		}
	}
	Node node;
	return node;
}

std::string SymbolTable::dumpTable(){
	string result = "SymbolTable\n";
	for (int i = 0; i < 26; i++){
		for (std::vector<Node>::iterator it = table[i].begin(); it != table[i].end(); ++it){
			result += it->dumpNode();
		}
	}
	return result;
}
/*
int main(){
	SymbolTable testTable;
	testTable.insert("a", 1, Node::INT, Node::GLOBAL, 1);
	testTable.insert("b", 2, Node::INT, Node::GLOBAL, 2);
	cout << testTable.dumpTable();
	cout << "Find a: " << testTable.find("a") << endl;
	cout << "Find c: " << testTable.find("c") << endl;
	cout << "Erase c: " << testTable.deleteRecord("c") << endl;
	cout << "Erase b: " << testTable.deleteRecord("b") << endl;
	cout << testTable.dumpTable();
	cout << "Modify c: " << testTable.modify("a", 1, Node::INT, Node::GLOBAL, 1) << endl;
	cout << "Modify a: " << testTable.modify("a", 3, Node::INT, Node::CONST, 3) << endl;
	cout << testTable.dumpTable();
	cout << Node::GLOBAL <<endl;
	return 0;
}
*/
