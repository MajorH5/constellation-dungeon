extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	var graph = {
 	'A': {'B': 4, 'C': 2},
 	'B': {'A': 4, 'C': 1, 'D': 5},
 	'C': {'A': 2, 'B': 1, 'D': 8, 'E': 10},
 	'D': {'B': 5, 'C': 8, 'E': 2},
 	'E': {'C': 10, 'D': 2}
	};
	
	var mst = prims_algorithm(graph, "A")
	print(mst)

func prims_algorithm(graph : Dictionary, start): 
	var mst : Array = [start]
	var edges = graph.get(start) # String : Int dict
	
	while(mst.size() < graph.size()):
		var min_edge = find_min_edge(edges) 
		mst.append(min_edge)
		for neighboring_edge_of_min in graph.get(min_edge):
			if neighboring_edge_of_min not in mst:
				edges[neighboring_edge_of_min] = graph[min_edge][neighboring_edge_of_min]
					
		edges.erase(min_edge)
		
	return mst
	
func find_min_edge(neighbors: Dictionary):
	var min_edge = null
	var min_weight = INF
	
	for key in neighbors.keys():
		if neighbors.get(key) < min_weight:
			min_edge = key
			min_weight = neighbors.get(key)
			
	return min_edge
