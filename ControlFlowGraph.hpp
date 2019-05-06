//#ifndef GRAPH_ADT_HPP
//#define GRAPH_ADT_HPP
//
//#include <vector>
//#include "BasicBlock.hpp"
//
//using namespace std;
//
//// Graph class
//class Graph{
//	public:
//		Graph(BasicBlock baseBlock);
//
//		// insert newBlock directly to srcBlock in the graph
//		// an edge can have condition value either true or false
//		void addEdge(int srcBlockID, BasicBlock destBlock, bool conditionValue);
//
//		void dumpGraph();
//
//	private:
//		vector< vector<BasicBlock> > graph;
//};
//
//#endif

/*
 * The graph is represented as a series of node ids
 * each node id is hashed with a real basic block
 */

#ifndef GRAPH_ADT_HPP
#define GRAPH_ADT_HPP

#include <vector>
#include "BasicBlock.hpp"
#include <unordered_map>

using namespace std;

// Graph class
class Graph{
	public:
		Graph(BasicBlock baseBlock);

		// insert newBlock directly to srcBlock in the graph
		// an edge can have condition value either true or false
		void addEdge(int srcBlockID, BasicBlock destBlock);

		BasicBlock getBasicBlock(int blockId);
//		void updateBasicBlock(BasicBlock block);

		void dumpGraph();
		int lastAddedBlockID;	// ID of the last block added to the graph
	private:
		vector< vector<int> > graph;			// graph of basic block ids
		vector<BasicBlock> map;		// a map btw basic block and its ids
		void createNewNode(BasicBlock block);
};

#endif
