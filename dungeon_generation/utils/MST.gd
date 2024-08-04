class_name MST
extends Node

# Function to create the minimum spanning tree
static func tree(points, edges):
	var vertices = [points[0]]
	var tree = []
	while vertices.size() != points.size():
		var ln = 10000
		var temp1 = null
		var temp2 = null
		for i in range(vertices.size()):
			for p in range(points.size()):
				if not vertices.has(points[p]):
					if dist(points[p][0], points[p][1], vertices[i][0], vertices[i][1]) < ln and same(points[p][0], points[p][1], vertices[i][0], vertices[i][1], edges):
						ln = dist(points[p][0], points[p][1], vertices[i][0], vertices[i][1])
						temp1 = points[p]
						temp2 = vertices[i]
		vertices.append(temp1)
		tree.append(Delaunay.Edge.new(temp1, temp2))
	return tree

# Function to calculate distance between two points
static func dist(x1, y1, x2, y2):
	return sqrt(pow(abs(x2 - x1), 2) + pow(abs(y2 - y1), 2))

# Function to check if an edge exists between two points
static func same(x1, y1, x2, y2, edges):
	for i in range(edges.size()):
		if (x1 == edges[i].a[0] and y1 == edges[i].a[1] and x2 == edges[i].b[0] and y2 == edges[i].b[1]) or (x2 == edges[i].a[0] and y2 == edges[i].a[1] and x1 == edges[i].b[0] and y1 == edges[i].b[1]):
			return true
	return false
