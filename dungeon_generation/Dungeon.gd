# Author: Habib A 7-23-2024
# This node handles the generation and management
# of a dungeon. It's responsible for creating rooms
# and hallways, and populating them with content and entities.

class_name Dungeon
extends TileMap

@export var dungeon_config: DungeonConfiguration

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var room_generator: LayoutGenerator
var generated_rooms: Array[Room] = []
var iteration: int = 0
@export var seed: int = -1

func _init():
	room_generator = LayoutGenerator.new(rng)

func _ready():
	if dungeon_config == null:
		dungeon_config = DungeonConfiguration.new()
	
	add_layer(0)
	
	tile_set = Tile.DEFAULT_TILESET

@rpc("authority")
func fix_client (set_seed: int):
	seed = set_seed
	rng.set_seed(set_seed)
	generate()

func generate():
	var result: Dictionary = room_generator.create_unique_layout(dungeon_config)
	
	# first create inital layout by placing rooms
	# about a space and connecting them
	var rooms: Array[Room] = result.rooms
	var hallway_segments: Array = result.hallways
	
	# next normalize all the room
	# and hallway positionings because some are negative and floats
	var world_size: Vector2 = shift_and_settle(rooms, hallway_segments)
	
	# next step ->
	# 	begin generating insides of rooms
	var maps: Array[TileMap] = []
	for room in rooms:
		# determine which generator is best fit for
		# this map (non repetitive if possible)
		var procedural_map: ProceduralMap = get_procedural_map_for(room)
		
		if procedural_map == null:
			print("[DungeonGenerator.Generate]: Could not find a valid ProceduralMapGenerator to generate RoomType: '%s' so it was discarded!" % room.room_type)
			continue
		
		procedural_map.room = room
		procedural_map.generate()
		procedural_map.splat(self)
		
		maps.push_back(procedural_map)
	
	var hallways = Hallways.new(hallway_segments, maps, rng)
	hallways.formalize(dungeon_config)
	hallways.splat(self)
	
	iteration += 1
	generated_rooms = rooms
	
	visualize_layout(result)

func get_player_spawn_point() -> Vector2:
	var spawn_room = null
	
	for room in generated_rooms:
		if room.room_type == Room.SPAWN_ROOM:
			spawn_room = room
			break
	
	if spawn_room == null:
		return Vector2.ZERO
	
	var spawn_x = randi_range(1, spawn_room.size.x - 2)
	var spawn_y = randi_range(1, spawn_room.size.y - 2)
	
	var spawn_pos = Vector2(spawn_x, spawn_y)
	
	var tile_size = Vector2(Tile.DEFAULT_TILESET.tile_size)
	
	return spawn_room.position * tile_size + spawn_pos * tile_size

func get_recently_encountered(types: Array[String], room: Room, current_depth: int) -> Array[String]:
	if current_depth > dungeon_config.max_repeat_search_depth:
		return types
	
	var current_type = room.room_type
	
	if types.find(current_type) == -1:
		# lets remember we've recently seen this room
		types.push_back(current_type)
	
	# check all directions for occupancy
	for direction in [Room.NORTH, Room.EAST, Room.SOUTH, Room.WEST]:
		if room.is_direction_occupied(direction):
			# theres a path here lets check all rooms
			# down this path and store their encounteres
			for adjacent in room.paths[direction]:
				get_recently_encountered(types, adjacent, current_depth + 1)
	
	return types

func get_procedural_map_for(room: Room) -> ProceduralMap:
	# returns the procedural map
	# that would be a good choice for the given room
	
	var choices: Array = dungeon_config.get_maps_of_type(room.room_type)
	
	if choices == null or len(choices) == 0:
		return null
	
	var recent_procedural_maps = get_recently_encountered([], room, 0)
	
	# now we can tell dungeon config to ignore
	# the recently seen if possible
	var best_fit_map = dungeon_config.get_random_map_with_ignore(room.room_type, recent_procedural_maps)
	
	return best_fit_map
	

func shift_and_settle(rooms: Array[Room], hallways: Array) -> Vector2:
	# iterates over all the rooms and shifts them down and to the right
	# ultimately returns size of the final world
	
	# before anything we need to shift over all rooms
	# so that their positions are non negative and
	# axis align all values
	var min_world_x = INF
	var min_world_y = INF
	
	var max_world_x = -INF
	var max_world_y = -INF
	
	var padding = dungeon_config.border_padding
	
	# find room with lowest pos
	for room in rooms:
		var room_pos = room.position
		min_world_x = minf(room_pos.x, min_world_x)
		min_world_y = minf(room_pos.y, min_world_y)
	
	# now shift all rooms by this minimum
	for room in rooms:
		var normalized_pos = room.position + -Vector2(min_world_x, min_world_y) + Vector2.ONE * padding
		var size = room.size
		
		#room.position = normalized_pos
		room.position = normalized_pos.floor()
		
		# no need to consider hallways since they won't ever
		# extend beyond the bounds of the furthest room, in theory
		max_world_x = max(room.position.x + room.size.x, max_world_x)
		max_world_y = max(room.position.y + room.size.y, max_world_y)
	
	# now do the hallways
	for segments in hallways:
		for segment in segments:
			var offset = -Vector2(min_world_x, min_world_y) + Vector2.ONE * padding
			
			segment[0] = (segment[0] + offset).floor()
			segment[1] = (segment[1] + offset).floor()
	
	return Vector2(max_world_x, max_world_y) + Vector2.ONE * padding

func visualize_layout (result):
	var rooms = result.rooms
	var edges = result.edges
	var tree: Array = result.tree
	var hallways = result.hallways
	
	for room: Room in rooms:
		var sprite = ColorRect.new()
		
		sprite.position = room.position
		sprite.size = room.size
		
		for direction in [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]:
			if room.is_vector_occupied(direction):
				var rect = ColorRect.new()
				rect.color = Color(1, 0, 0)
				rect.size = Vector2(4 ,4)
				rect.position = sprite.size / 2 + (sprite.size / 2 + rect.size / 2)* direction
				sprite.add_child(rect)
		
		$CanvasLayer/Control.add_child(sprite)
	
	#for edge: Delaunay.Edge in edges:
		#var line = Line2D.new()
		#line.width = 2
		#line.default_color = Color(1, 0, 0, 0.10)
		##line.default_color = Color(randf(), randf(), randf(), 1)
		#
		#var points = [
			#edge.a, 
			#edge.b,
		#]
		#for i in range(len(points)):
			#points[i] = points[i]
		#
		#line.points = points
		#add_child(line)
		
	#for i in range(len(tree)):
		#tree[i].a = tree[i].a
		#tree[i].b= tree[i].b
		#var line = Line2D.new()
		#line.width = 2
		#line.default_color = Color(0, 0, 1, 1)
		#line.points = [tree[i].a, tree[i].b]
		#add_child(line)
	
			
	for i in range(len(hallways)):
		var points = []
		for segment in hallways[i]:
			var pos1 = segment[0]
			var pos2 = segment[1]
			#var pos1 = segment[0]
			#var pos2 = segment[1]
			points.push_back(pos1)
			points.push_back(pos2)
		#print(points)
		var line = Line2D.new()
		line.width = 2
		line.default_color = Color(0, 1, 1, 1)
		line.points = points
		$CanvasLayer/Control.add_child(line)
	#for i in range(len(tree)):
		#tree[i] = tree[i] + Vector2(200, 200)
	#var line = Line2D.new()
	#line.width = 2
	#line.default_color = Color(0, 0, 1, 1)
	#line.points = tree
	#add_child(line)
