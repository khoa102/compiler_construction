#include "ControlFlowGraph.hpp"

using namespace std;

Graph::Graph(BasicBlock baseBlock){
	graph.resize(graph.size() + 1);
	map.push_back(baseBlock);
	lastAddedBlockID = baseBlock.blockID;
}

// insert srcBlock -> newBlock edge
void Graph::addEdge(int srcBlockID, BasicBlock destBlock){
	if (destBlock.blockID >= graph.size()){ 	// destBlock is not currently in graph
		createNewNode(destBlock);
	}

	vector<int>* src_list = &(graph.at(srcBlockID));

	// make a copy of destBlock and add it to the end of src_list
	src_list->push_back(destBlock.blockID);
}

BasicBlock Graph::getBasicBlock(int blockID){
	return map.at(blockID);
}

//void Graph::updateBasicBlock(BasicBlock block){
//	if (block.blockID >= map.size()){
//		cout << "Block " << block.blockID << " does not exist in the current list" << endl;
//		exit(-1);
//	} else {
//		map.at(block.blockID) = block;
//	}
//}

// Print Instruction Representation (IR)
void Graph::dumpGraph(){
	cout << "Dumping IR ... " << endl;

	for (int i = 1; i < map.size(); i++){	// ignore block 0
		BasicBlock block = map.at(i);
		cout << block.dumpBasicBlock() << endl;
	}
}

void Graph::createNewNode(BasicBlock block){
	graph.resize(graph.size()+1);
	map.push_back(block);
	lastAddedBlockID = block.blockID;
}

