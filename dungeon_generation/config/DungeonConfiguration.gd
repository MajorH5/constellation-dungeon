class_name DungeonConfiguration
extends Resource

const DEFAULT_BORDER_PADDING = 1
const DEFAULT_MAX_REPEAT_SEARCH_DEPTH = 2

const DEFAULT_WORLD_SIZE = Vector2(20, 20)
const DEFAULT_TOTAL_ROOMS = 20
const DEFAULT_MAX_TRAVEL_DISTANCE = max(DEFAULT_WORLD_SIZE.x, DEFAULT_WORLD_SIZE.y)
const DEFAULT_MAIN_ROOMS = 3
const DEFAULT_BASE_ROOM_SIZE = Vector2(29, 29)
const DEFAULT_MINIMUM_ROOM_SIZE = DEFAULT_BASE_ROOM_SIZE
const DEFAULT_ROOM_SIZE_VARIATION = Vector2(10, 10)
const DEFAULT_ROOM_SPACING = Vector2(5, 5)
const DEFAULT_BOSS_ROOM_SCALAR = 2.5

const DEFAULT_MAP: Array[PackedScene] = [preload("res://dungeon_generation/maps/BasicRoom.tscn")]

const DEFAULT_HALLWAY_THICKNESS = 3
const DEFAULT_HALLWAY_WALL_TILES: Array[Vector2i] = [Tile.BRICK]
const DEFAULT_HALLWAY_FLOOR_TILES: Array[Vector2i] = [Tile.FLOOR]

@export_group("Default")
## Specifies the amount of empty tiles to place around the generated map.
@export_range(1, INF) var border_padding: int = DEFAULT_BORDER_PADDING
## How far the algorithm searches to prevent repeated rooms.
@export_range(1, INF) var max_repeat_search_depth: int = DEFAULT_MAX_REPEAT_SEARCH_DEPTH
## Estimate on how large the world should be. NOTE: This value is only and approximation, final world size can vary.
@export var world_size: Vector2 = DEFAULT_WORLD_SIZE

@export_group("Layout")
@export var total_rooms: int = DEFAULT_TOTAL_ROOMS
@export var max_travel_distance: float = DEFAULT_MAX_TRAVEL_DISTANCE
@export var main_rooms: int = DEFAULT_MAIN_ROOMS
@export var base_room_size: Vector2 = DEFAULT_BASE_ROOM_SIZE
@export var room_size_variation: Vector2 = DEFAULT_ROOM_SIZE_VARIATION
@export var room_spacing: Vector2 = DEFAULT_ROOM_SPACING
@export var boss_room_scalar: float = DEFAULT_BOSS_ROOM_SCALAR
@export var minimum_room_size: Vector2 = DEFAULT_MINIMUM_ROOM_SIZE

@export_group("Specification")
@export var spawn_maps: Array[PackedScene] = DEFAULT_MAP
@export var boss_maps: Array[PackedScene] = DEFAULT_MAP
@export var general_maps: Array[PackedScene] = DEFAULT_MAP

@export_group("Hallways")
@export var hallway_thickness: int = DEFAULT_HALLWAY_THICKNESS
@export var hallway_wall_tiles: Array[Vector2i] = DEFAULT_HALLWAY_WALL_TILES
@export var hallway_floor_tiles: Array[Vector2i] = DEFAULT_HALLWAY_FLOOR_TILES

func get_random_map_with_ignore (room_type: String, ignore: Array[String]) -> ProceduralMap:
	# returns a value from the list of maps
	# and ignore whatever types are optionally secified
	# if all keys are in ignore, a random one is given and
	#ignore is disregarded
	
	var maps = get_maps_of_type(room_type)
	
	if len(maps) == 0:
		return null
	
	var choices = maps.duplicate()
	var map = null
	
	while len(choices) > 0:
		# keep picking needle out of haystack
		#until we get something calid
		var index = randi_range(0, len(choices) - 1)
		map = choices[index]
		
		choices.pop_at(index)
		
		if ignore.find(map) == -1:
			break
	
	if map != null:
		return map.instantiate()
	else:
		# we failed to find a random one
		# all keys are in ignore list?
		# lets just pick a random map
		return maps[randi_range(0, len(maps) - 1)].instantiate()


func get_maps_of_type (room_type: String) -> Array:
	if room_type == Room.GENERAL_ROOM:
		return general_maps
	elif room_type == Room.BOSS_ROOM:
		return boss_maps
	elif room_type == Room.SPAWN_ROOM:
		return spawn_maps
	
	return []
