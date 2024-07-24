# Author: Habib A 7-23-2024
# This node handles the generation and management
# of a dungeon. It's responsible for creating rooms
# and hallways, and populating them with content and entities.

class_name Dungeon
extends TileMap

var rng = RandomNumberGenerator.new()

func generate(seed: int):
	rng.set_seed(seed)
	var layout = LayoutGenerator.new()

func get_procedural_map_for():
	pass

func shift_and_settle():
	pass
