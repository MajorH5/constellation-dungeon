class_name ProceduralMap
extends TileMap


var room: Room

func _ready():
	if room == null:
		print("[Room._ready]: Room must be set before being parented!")
	
	add_layer(0)

func safe_set(set_pos: Vector2i, atlas_coord: Vector2i):
	# sets a position and ensures its within
	# the bounds of its room
	
	#if not room.point_intersects(set_pos):
		#return
	
	set_cell(0, set_pos, 0, atlas_coord)

func splat(tilemap: TileMap):
	# copies all contents of this tilemap
	# onto the provided one based on room position
	var pos = room.position
	var cell_size = Tile.DEFAULT_TILESET.tile_size
	var source_id = Tile.DEFAULT_TILESET_SOURCE_ID
	var world_size = Tile.DEFAULT_TILESET_SIZE

	for x in range(get_used_rect().size.x):
		for y in range(get_used_rect().size.y):
			var atlas_coords = get_cell_atlas_coords(0, Vector2i(x, y))
			
			if atlas_coords != -Vector2i.ONE:  # Make sure there's a tile at this cell
				var tile_pos = pos + Vector2(x, y) 
				tilemap.set_cell(0, Vector2i(tile_pos), source_id, atlas_coords)

func generate():
	# overwritten by sub classes
	pass
