# Author: Habib A. 7-23-2024
# class for representing a procedurally generated room.
# holds data about its spacing in the world,
# relavant connections, and room types

class_name Room
extends Node2D

# Class for representing a procedurally generated room.
# Holds data about its spacing in the world,
# relevant connections, and room types.

# Constants for referring to the amount of paths to this room
const ONE_WAY = 1
const TWO_WAY = 2
const THREE_WAY = 3
const FOUR_WAY = 4
const NO_WAY = 0

# Constants for types of rooms
const SPAWN_ROOM = 's'
const BOSS_ROOM = 'b'
const GENERAL_ROOM = 'g'

# Directional vectors for pathways into/out of each room
const NORTH = 'n'
const SOUTH = 's'
const EAST = 'e'
const WEST = 'w'
const UNKNOWN = ''

var paths = {
	NORTH: [],
	SOUTH: [],
	EAST: [],
	WEST: []
}

var velocity: Vector2 = Vector2.ZERO
var neighbor_count: int = 0
var size: Vector2 = Vector2.ZERO
var room_type: String = GENERAL_ROOM
var map_type: String = ""

func _init(position: Vector2, size: Vector2, room_type: String = GENERAL_ROOM):
	self.position = position
	self.size = size
	self.room_type = room_type

func connect_to(room: Room) -> Array:
	# Performs a connection between the two rooms
	# and returns a list of points to connect between
	# the center of their closest sides
	
	var position1 = Vector2(self.position)
	var position2 = Vector2(room.position)

	var size1 = self.size
	var size2 = room.size

	var rooms_are_colliding = room_intersects(room)

	if rooms_are_colliding:
		print('[Room.Connect]: A collision occurred during room connection!')
		return []

	var center1 = get_center().round()
	var center2 = room.get_center().round()

	var closest_sides = get_closest_sides(room)
	
	var closest_side1 = closest_sides[0]
	var closest_side2 = closest_sides[1]
	
	occupy((closest_side1 - center1).normalized(), room)
	room.occupy((closest_side2 - center2).normalized(), self)

	var boxes_are_aligned = center1.x == center2.x or center1.y == center2.y

	if boxes_are_aligned:
		return [[closest_side1, closest_side2]]

	var look_vector1 = get_look_vector(closest_side1)
	var look_vector2 = room.get_look_vector(closest_side2)
	
	var facing_direction = look_vector1 * look_vector2
	var is_facing_same_side = facing_direction.length() == 1
	var mid_point = ((closest_side1 + closest_side2) / 2).round()

	if is_facing_same_side:
		if facing_direction.y < 0:
			return [
				[closest_side1, Vector2(closest_side1.x, mid_point.y)],
				[Vector2(closest_side1.x, mid_point.y), Vector2(closest_side2.x, mid_point.y)],
				[closest_side2, Vector2(closest_side2.x, mid_point.y)]
			]
		else:
			return [
				[closest_side1, Vector2(mid_point.x, closest_side1.y)],
				[Vector2(mid_point.x, closest_side1.y), Vector2(mid_point.x, closest_side2.y)],
				[closest_side2, Vector2(mid_point.x, closest_side2.y)]
			]
	else:
		if look_vector1.x != 0:
			return [
				[closest_side1, Vector2(closest_side2.x, closest_side1.y)],
				[Vector2(closest_side2.x, closest_side1.y), closest_side2]
			]
		else:
			return [
				[closest_side1, Vector2(closest_side1.x, closest_side2.y)],
				[Vector2(closest_side1.x, closest_side2.y), closest_side2]
			]

func distance_from(room: Room) -> float:
	# Returns the exact distance from this room's center
	# to the given room's center
	
	var center1 = self.position + self.size / 2
	var center2 = room.position + room.size / 2

	return sqrt((center2.x - center1.x) ** 2 + (center2.y - center1.y) ** 2)

func point_intersects(position: Vector2) -> bool:
	# Checks whether or not the given position
	# lies within the bounds of this room and returns
	# true if it does
	
	return position.x >= self.position.x and \
		   position.x < self.position.x + self.size.x and \
		   position.y >= self.position.y and \
		   position.y < self.position.y + self.size.y

func room_intersects(room: Room) -> bool:
	# Checks if the given room intersects this room
	# and returns true if it does
	
	return self.position.x < room.position.x + room.size.x and \
		   room.position.x < self.position.x + self.size.x and \
		   self.position.y < room.position.y + room.size.y and \
		   room.position.y < self.position.y + self.size.y

func convert_vector_to_direction(vector: Vector2) -> String:
	# Converts the given vector to a string
	# direction that can be used for storing data
	# in a hash map for example
	# Only supports NESW directions
	
	vector = vector.round().floor()
	
	if vector == -Vector2.UP:
		return NORTH
	elif vector == Vector2.UP:
		return SOUTH
	elif vector == Vector2.RIGHT:
		return EAST
	elif vector == -Vector2.RIGHT:
		return WEST
	
	print("[Room.ConvertVectorToDirection]: Received unexpected vector: (%.3f, %.3f)." % [vector.x, vector.y])
	
	return UNKNOWN

func convert_direction_to_vector(direction: String) -> Vector2:
	# Converts the given directional string (NESW)
	# to its associated vector
	
	if direction == NORTH:
		return -Vector2.UP
	elif direction == SOUTH:
		return Vector2.UP
	elif direction == EAST:
		return Vector2.RIGHT
	elif direction == WEST:
		return -Vector2.RIGHT
	
	print("[Room.ConvertDirectionToVector]: Received unexpected direction: ({})".format(direction))

	return Vector2.ZERO

func occupy(vector: Vector2, room: Room):
	# Places the given room into the occupancy
	# list for the given direction
	
	var direction = convert_vector_to_direction(vector)

	if direction == UNKNOWN:
		return

	paths[direction].append(room)

func is_direction_occupied(direction: String) -> bool:
	# Returns true if the given cardinal direction
	# has at least one room attached to it for this room
	
	if direction == UNKNOWN:
		return false
	
	return paths[direction].size() > 0

func is_vector_occupied(vector: Vector2) -> bool:
	# Returns true if the given vector
	# has at least one room attached to it for this room
	
	var direction = convert_vector_to_direction(vector)
	return is_direction_occupied(direction)

func settle():
	# Zeros the moving velocity for this room
	# and floors the position and size
	
	velocity = Vector2.ZERO
	position = position.floor()
	size = size.floor()

func move():
	# Causes the room's position to shift by the
	# current movement velocity
	
	position += velocity


func apply_impulse(velocity: Vector2):
	# Adds the given velocity to the current
	# movement velocity
	
	self.velocity += velocity


func get_area() -> float:
	# Returns the absolute area of this room
	
	return self.size.x * self.size.y

func get_sides() -> Array[Vector2]:
	# Returns the center of all the sides
	# of this room
	var center = get_center()
	
	return [
		center + Vector2(0, -size.y / 2), # top
		center + Vector2(size.x / 2, 0),  # right
		center + Vector2(0, size.y / 2),  # bottom
		center + Vector2(-size.x / 2, 0)  # left
	]

func get_closest_sides(room: Room) -> Array[Vector2]:
	# Returns two sides which are the closest
	# between this room and the other given room
	
	var sides1 = get_sides()
	var sides2 = room.get_sides()
	
	var minimum_distance = INF
	var closest1 = null
	var closest2 = null

	for side1 in sides1:
		for side2 in sides2:
			var distance = (side2 - side1).length()

			if distance < minimum_distance:
				minimum_distance = distance
				closest1 = side1
				closest2 = side2

	return [closest1, closest2]

func get_look_vector(side: Vector2) -> Vector2:
	# Returns the direction which the given
	# side is facing relative to the center
	
	var center = get_center()
	var direction = Vector2.ZERO

	if side.x < center.x:
		direction += Vector2.LEFT	
	elif side.x > center.x:
		direction += Vector2.RIGHT	
	
	if side.y < center.y:
		direction += Vector2.UP
	elif side.y > center.y:		
		direction += Vector2.DOWN

	return direction

func get_total_paths() -> int:
	# Returns the total number of paths
	# that can be accessed from this room
	
	var total = 0
	
	for direction in [NORTH, EAST, SOUTH, WEST]:
		if is_direction_occupied(direction):
			total += 1
	
	return total

func get_center() -> Vector2:
	# Returns the center position
	# of this room in the world
	
	return position + size / 2
