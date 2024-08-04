class_name BasicRoom
extends ProceduralMap

func generate():
	for y in range(room.size.y):
		for x in range(room.size.x):
			if y == 0 or x == 0 or y == room.size.y - 1 or x == room.size.x - 1:
				var north_path = y == 0 and room.is_vector_occupied(Vector2.UP) and abs(x - room.size.x / 2) <= 1
				var south_path = y == room.size.y - 1 and room.is_vector_occupied(Vector2.DOWN) and abs(x - room.size.x / 2) <= 1
				var east_path = x == room.size.x - 1 and room.is_vector_occupied(Vector2.RIGHT) and abs(y - room.size.y / 2) <= 1
				var west_path = x == 0 and room.is_vector_occupied(Vector2.LEFT) and abs(y - room.size.y / 2) <= 1
				
				if not north_path and not south_path and not east_path and not west_path:
					safe_set(Vector2i(x, y), Tile.BRICK)
			else:
				safe_set(Vector2i(x, y), Tile.FLOOR)
	
	# create list of entrances
	#var starting_list: Array[Vector2i] = []
	#var ending_list: Array[Vector2i] = []
	#var temp = []
	#
	#for direction in [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT]:
		#if room.is_vector_occupied(direction):
#
			#temp.push_back({
				#"center": room.size / 2,
				#"direction": direction
			#})
	#
	#if len(temp) == 1:
		#var center = temp[0]["center"]
		#var direction = temp[0]["direction"] * -1
		#ending_list.push_back(Vector2i(center + center * direction))
	#
	#for t in temp:
		#var center = temp[0]["center"]
		#var direction = temp[0]["direction"]
		#starting_list.push_back(Vector2i(center + center * direction))
	#
	#var generator = RoomGenerator.new()
#
	#print("room_size: ", room.size, " starting_list: ", starting_list, " ending_list: ", ending_list)
#
	#generator.boardWidth = int(room.size.x)
	#generator.boardHeight = int(room.size.y)
	#generator.board = generator.zeros(generator.boardWidth, generator.boardHeight)
	#
	#var result = generator.generateBoard(starting_list, ending_list)
	#
	#for y in range(len(result)):
		#for x in range(len(result[y])):
			#var is_wall = result[y][x] == 1
			#
			#safe_set(Vector2i(x, y), Tile.BRICK if is_wall else Tile.FLOOR)
