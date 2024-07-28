class_name DirectionalSprite
extends AnimatedSprite2D

const NORTH = 'north'
const EAST = 'east'
const SOUTH = 'south'
const WEST = 'west'

var current_facing: String = SOUTH

func facing_from_velocity(speed: Vector2):
	if speed.y < 0:
		return NORTH
	elif speed.y > 0:
		return SOUTH
	elif speed.x < 0:
		return WEST
	elif speed.x > 0:
		return EAST
	
	# defaults to southern direction for zero vectors
	return SOUTH

func determine_animation(velocity: Vector2, is_attacking: bool):
	var animation_postfix = facing_from_velocity(velocity) if velocity.length() > 0 else current_facing
	var animation_prefix = "walk" if velocity.length() > 0 else "idle"
	
	var animation_name = animation_prefix + "_" + animation_postfix
	
	current_facing = animation_postfix
	
	if animation != animation_name:
		play(animation_name)

func _physics_process(delta):
	# this node expects to be a child of an entity
	var entity = get_parent()
	
	if entity == null or not (entity is Entity):
		return
	
	determine_animation(entity.get_velocity(), entity.is_attacking)
