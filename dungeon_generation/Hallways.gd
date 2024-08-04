extends Object

class_name Hallways

const WALL = "hallway_wall"
const FLOOR = "hallway_floor"

var _hallway_segments : Array
var _hallway_points : Dictionary
var _maps : Array
var _rng : RandomNumberGenerator

func _init(hallway_segments: Array, maps: Array, rng: RandomNumberGenerator):
	_hallway_segments = hallway_segments
	_hallway_points = {
		WALL: [],
		FLOOR: []
	}
	_maps = maps
	_rng = rng

func get_walls() -> Array:
	# Returns all the wall positions for this hallways object
	return _hallway_points[WALL]

func get_floors() -> Array:
	# Returns all the floor positions for this hallways object
	return _hallway_points[FLOOR]

func splat(tilemap: TileMap):
	# paste the halways onto the given tilemap
	for wall in get_walls():
		tilemap.set_cell(0, wall.position, Tile.DEFAULT_TILESET_SOURCE_ID, wall.tile)
	
	for floor in get_floors():
		tilemap.set_cell(0, floor.position, Tile.DEFAULT_TILESET_SOURCE_ID, floor.tile)
	

func safe_set(position: Vector2, hallway_type: String, tile: Vector2i):
	# Prevents placing a tile where a room is located
	for map: ProceduralMap in _maps:
		var room: Room = map.room
		
		if not room.point_intersects(position):
			continue
		
		var localized_position = position - room.get_position()
		
		if map.get_cell_atlas_coords(0, localized_position) != -Vector2i.ONE:
			return
		
	_hallway_points[hallway_type].append({
		"position": position,
		"tile": tile
	})

func formalize(config: DungeonConfiguration):
	# Given a list of line segments, returns a list of points
	# that fill in the segment with the given thickness
	var free_areas = {}
	var walled_areas = {}

	for hallway_segment in _hallway_segments:
		for segment in hallway_segment:
			var point1 = segment[0]
			var point2 = segment[1]
			
			var start_y = min(point1.y, point2.y)
			var end_y = max(point1.y, point2.y)
			var start_x = min(point1.x, point2.x)
			var end_x = max(point1.x, point2.x)
			
			var hallway_thickness = config.hallway_thickness
			
			for y in range(start_y, end_y + 1):
				for x in range(start_x, end_x + 1):
					for y_offset in range(start_y - hallway_thickness, end_y + hallway_thickness + 1):
						for x_offset in range(start_x - hallway_thickness, end_x + hallway_thickness + 1):
							var is_boundary = y_offset == start_y - hallway_thickness or y_offset == end_y + hallway_thickness or x_offset == start_x - hallway_thickness or x_offset == end_x + hallway_thickness
							
							if is_boundary:
								var position = Vector2(x_offset, y_offset)
								var key = "%d, %d" % [position.x, position.y]
								walled_areas[key] = position
					
					hallway_thickness -= 1
					
					for y_offset in range(start_y, end_y + 1):
						for x_offset in range(start_x, end_x + 1):
							for x_inner_offset in range(-hallway_thickness, hallway_thickness + 1):
								for y_inner_offset in range(-hallway_thickness, hallway_thickness + 1):
									var position = Vector2(x_offset + x_inner_offset, y_offset + y_inner_offset)
									var key = "%d, %d" % [position.x, position.y]
									
									var is_corner = abs(x_inner_offset) == hallway_thickness and abs(y_inner_offset) == hallway_thickness
									
									if is_corner and not free_areas.has(key):
										pass
										# walled_areas[key] = position
									else:
										if walled_areas.has(key):
											walled_areas.erase(key)
										free_areas[key] = position

	var is_free = func (position: Vector2) -> bool:
		var key = "%d, %d" % [position.x, position.y]
		return free_areas.has(key)

	var is_wall = func (position: Vector2) -> bool:
		var key = "%d, %d" % [position.x, position.y]
		return walled_areas.has(key)

	var clean_wall_intersections = func ():
		var pending_deletion = []
		
		for key in walled_areas.keys():
			var wall_position = walled_areas[key]
			var neighboring_free_cells = 0
			var neighboring_walled_cells = 0
			
			if is_free.call(wall_position + Vector2(0, -1)): neighboring_free_cells += 1
			if is_free.call(wall_position + Vector2(0, 1)): neighboring_free_cells += 1
			if is_free.call(wall_position + Vector2(-1, 0)): neighboring_free_cells += 1
			if is_free.call(wall_position + Vector2(1, 0)): neighboring_free_cells += 1
			
			if is_wall.call(wall_position + Vector2(0, -1)): neighboring_walled_cells += 1
			if is_wall.call(wall_position + Vector2(0, 1)): neighboring_walled_cells += 1
			if is_wall.call(wall_position + Vector2(-1, 0)): neighboring_walled_cells += 1
			if is_wall.call(wall_position + Vector2(1, 0)): neighboring_walled_cells += 1

			var is_corner_wall = (
				(is_wall.call(wall_position + Vector2(-1, 0)) and is_wall.call(wall_position + Vector2(0, 1))) or
				(is_wall.call(wall_position + Vector2(1, 0)) and is_wall.call(wall_position + Vector2(0, -1))) or
				(is_wall.call(wall_position + Vector2(1, 0)) and is_wall.call(wall_position + Vector2(0, 1))) or
				(is_wall.call(wall_position + Vector2(-1, 0)) and is_wall.call(wall_position + Vector2(0, -1)))
			)
			
			if (neighboring_free_cells > 1 and not is_corner_wall) or (neighboring_walled_cells == 1 and neighboring_free_cells == 1):
				pending_deletion.append(key)
		
		for key in pending_deletion:
			free_areas[key] = walled_areas[key]
			walled_areas.erase(key)
	
	clean_wall_intersections.call()
	clean_wall_intersections.call()
	
	var floor_tiles = config.hallway_floor_tiles
	var wall_tiles = config.hallway_wall_tiles
	
	for key in free_areas.keys():
		var floor_position = free_areas[key]
		safe_set(floor_position, FLOOR, floor_tiles[_rng.randi_range(0, floor_tiles.size() - 1)])
	
	for key in walled_areas.keys():
		var wall_position = walled_areas[key]
		safe_set(wall_position, WALL, wall_tiles[_rng.randi_range(0, wall_tiles.size() - 1)])
	
	return self
