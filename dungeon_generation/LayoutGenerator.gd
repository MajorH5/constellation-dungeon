# Author: Habib A 7-23-2024
# Script holds the class which creates the room
# layouts (room positioning and hallways) which are subsequently
# used for final positions of all keypoints
class_name LayoutGenerator
extends Node2D

const ROOM_SEPARATION_SPEED = 5

var rng: RandomNumberGenerator = null

func _init(random: RandomNumberGenerator):
	rng = random

func create_unique_layout(config: DungeonConfiguration):
	# creates a completely new room layout for a dungeon
	# which is a connected graph of rooms in the world
	# overwrites any previous layout stored in this generator
	# returns a list of rooms and a list of hallways
	
	# place all rooms randomly
	# within a radius; cluttered together
	var rooms: Array[Room] = create_room_list(config)
	
	# now pull all the rooms apart such that
	# they are no longer colliding
	separate_rooms(rooms, config)
	
	# table for fast lookup of:
	# 	position -> room
	var spatial_lookup = {}
	for room in rooms:
		var center = room.get_center()
		spatial_lookup["%.1f, %.1f" % [center.x, center.y]] = room
	
		
	# create list of points of room centers
	# to use for mesh generations
	# also store for later use with MST generation
	var vertices: Array[Vector2] = []
	for room in rooms:
		vertices.push_back(room.get_center())
	
	# generate a mesh of the current layout
	# to start building connections between rooms
	var edges = generate_mesh(vertices)
	
	# use our edges and vertices to create a
	# minimum spanning tree
	#var graph = MST.convert_to_graph(vertices, edges)
	#var tree = MST.prims_algorithm(graph, vertices[0])
	var tree = MST.tree(vertices, edges)
	
	var hallways = []
	
	for side in tree:
		var room_1 = spatial_lookup["%.1f, %.1f" % [side.a.x, side.a.y]]
		var room_2 = spatial_lookup["%.1f, %.1f" % [side.b.x, side.b.y]]
		
		var hallway = room_1.connect_to(room_2)
		
		if hallway != null:
			hallways.push_back(hallway)
	
	# now that layout is complete,
	# lets identify some key points
	
	# sort largest -> smallest
	rooms.sort_custom(func (a: Room, z: Room):
		return a.get_area() > z.get_area()
	)
	var boss_room = rooms[0]
	boss_room.room_type = Room.BOSS_ROOM # set largest as bossroom
	
	# furthest from boss room  will be spawn room
	rooms.sort_custom(func (a: Room, z: Room):
		return a.distance_from(boss_room) > z.distance_from(boss_room)
	)
	var initial_room = rooms[0]
	initial_room.room_type = Room.SPAWN_ROOM
	
	return {
		"rooms": rooms,
		"hallways": hallways,
		"edges": edges,
		"tree": tree
	}

func round_to_nearest_odd(number: float) -> int:
	# rounds given float to nearest odd integer
	# using this so room sizes remain odd, thus hallways
	# will be dead centered
	var rounded_number = floor(number / 2) * 2
	return rounded_number

func create_room_list(config: DungeonConfiguration) -> Array[Room]:
	# creates a list of randomly placed and randomly sized
	# rooms and returns the array
	
	var rooms: Array[Room] = []
	
	for i in range(config.total_rooms):
		# place rooms randomly in circle of max
		# travel distance
		var radius = config.max_travel_distance
		
		var theta = rng.randf() * 2 * PI
		var room_pos = Vector2(radius * cos(theta), radius * sin(theta))
		
		# final size is just base size +/- some offset within
		# some certain rainge
		var base_size = config.base_room_size
		var size_variation = config.room_size_variation
		var size_offset = Vector2(rng.randf() - 0.5, rng.randf() - 0.5)
		
		var size = Vector2(
			round_to_nearest_odd(base_size.x + size_variation.x * size_offset.x),
			round_to_nearest_odd(base_size.y + size_variation.y * size_offset.y)
		)
		
		# enforce size constraints...
		var min_size = config.minimum_room_size
		
		if size.x < min_size.x:
			size.x = min_size.x
		
		if size.y < min_size.y:
			size.y = min_size.y
		
		# center room on inital position
		position -= size / 2
		
		var room = Room.new(room_pos, size, Room.GENERAL_ROOM)
		rooms.push_back(room)
	
	return rooms

func separate_rooms(rooms: Array[Room], config: DungeonConfiguration):
	# given a list of rooms, runs a physics agent simulation
	# where rooms are pushed away from each other until they are all no
	# longer intersecting

	# now we think of the rooms as
	# workable agents with velocity and neighbor information
	var agents = rooms
	var average_size = 0
	
	for i in range(rooms.size()):
		var room = rooms[i]
		average_size += (room.size + config.room_spacing).length()
	
	average_size /= rooms.size()
	
	var seperation_not_complete = true
	
	while seperation_not_complete:
		# each step we assume everything is separated
		# unless we determine otherwise
		seperation_not_complete = false
		
		# now we need to compare the positioning
		# of each agent against every other to determine its velocity
		# away from the crowd
		for my_agent in agents:
			for other_agent in agents:
				if my_agent == other_agent:
					continue
				
				var distance = my_agent.distance_from(other_agent)
				
				if distance < average_size - 10:
					#too close still have work to do
					seperation_not_complete = true
				
				if distance < average_size:
					# add a push away from this room
					my_agent.apply_impulse(my_agent.position - other_agent.position)
					my_agent.neighbor_count += 1
			
			if my_agent.neighbor_count < 0:
				# slow movement based on neighbor count
				my_agent.velocity /= my_agent.neighbor_count
			
			if my_agent.velocity.length() > 0:
				# normalize the moving velocity
				my_agent.velocity /= my_agent.velocity.length()
			
			# add arbitrary speed value for separation
			my_agent.velocity *= ROOM_SEPARATION_SPEED
			
			# finally shift the position of the room
			# by its current velocity
			my_agent.move()

func get_unique_edges(p1: Vector2, p2: Vector2, p3: Vector2, clashes: Array) -> Array:
	#helper function which returns a list of unique
	# edges given triangles which havent been seen before
	var edges = []
	
	if not clashes[0]: edges.push_back(Delaunay.Edge.new(p1, p2))
	if not clashes[1]: edges.push_back(Delaunay.Edge.new(p2, p3))
	if not clashes[2]: edges.push_back(Delaunay.Edge.new(p3, p1))
	
	return edges

func generate_mesh(vertices: Array[Vector2]):
	# given a list of points, uses delaunay triangulation
	# to create a mesh between center points
	
	var delaunay = Delaunay.new()
	
	for point in vertices:
		delaunay.add_point(point)
	
	var triangles = delaunay.triangulate()
	
	# for some reason this implementation
	# keeps border triangles?
	delaunay.remove_border_triangles(triangles)
	
	
	# now the resulting triangles will have
	# several repeated edges due to them being
	# close neighbors, so now lets make it unique
	var sides = {}
	var edges = []
	for t in triangles:
		var side1_1 = "(%.1f, %.1f) -> (%.1f, %.1f)" % [t.a.x, t.a.y, t.b.x, t.b.y]
		var side1_2 = "(%.1f, %.1f) -> (%.1f, %.1f)" % [t.b.x, t.b.y, t.a.x, t.a.y]
		
		var side2_1 = "(%.1f, %.1f) -> (%.1f, %.1f)" % [t.b.x, t.b.y, t.c.x, t.c.y]
		var side2_2 = "(%.1f, %.1f) -> (%.1f, %.1f)" % [t.c.x, t.c.y, t.b.x, t.b.y]
		
		var side3_1 = "(%.1f, %.1f) -> (%.1f, %.1f)" % [t.c.x, t.c.y, t.a.x, t.a.y]
		var side3_2 = "(%.1f, %.1f) -> (%.1f, %.1f)" % [t.a.x, t.a.y, t.c.x, t.c.y]
		
		var clashes = [
			sides.get(side1_1) or sides.get(side1_2),
			sides.get(side2_1) or sides.get(side2_2),
			sides.get(side3_1) or sides.get(side3_2),
		]
		
		sides[side1_1] = true
		sides[side1_2] = true

		sides[side2_1] = true
		sides[side2_2] = true

		sides[side3_1] = true
		sides[side3_2] = true
		
		var unique_edges = get_unique_edges(t.a, t.b, t.c, clashes)
		
		for edge in unique_edges:
			edges.push_back(edge)
		
	return edges
