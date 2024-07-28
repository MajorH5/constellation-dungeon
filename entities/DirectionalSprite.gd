# Author: Habib A. 7-28-2024
# this script is to be attached to any animated sprite
# which has directional animations and handles the animating
# of the sprite based on its parents' state
class_name DirectionalSprite
extends AnimatedSprite2D

const NORTH = 'north'
const EAST = 'east'
const SOUTH = 'south'
const WEST = 'west'

const ACTION_WALK = "walk"
const ACTION_ATTACK = "attack"
const ACTION_IDLE = "idle"

var current_facing: String = SOUTH

func facing_from_velocity(velocity: Vector2):
	# given a vector in a relative velocity to move towards
	# returns the corresponding direction of the vector
	if velocity.y < 0:
		return NORTH
	elif velocity.y > 0:
		return SOUTH
	elif velocity.x < 0:
		return WEST
	elif velocity.x > 0:
		return EAST
	
	# defaults to southern velocity for zero vectors
	return SOUTH

func facing_from_direction(direction: Vector2) -> String:
	# given a direction relative to sprite returns
	# the cardinal direction to face the proper angle
	
	if direction == Vector2.ZERO:
		# default to south for zero vecs
		return SOUTH
	
	direction = direction.normalized()
	
	var radians = atan2(-direction.y, direction.x)
	var angle = floori(rad_to_deg(radians) + 360) % 360
	
	if angle < 150 and angle > 30:
		return NORTH
	elif (angle <= 30 and angle >= 0) or (angle > 330 and angle <= 360):
		return EAST
	elif angle > 210 and angle <= 330:
		return SOUTH
	elif angle >= 150 and angle <= 210:
		return WEST
	
	# shouldn't be reachable but i don't
	# trust my code
	return SOUTH

func determine_animation(velocity: Vector2, is_attacking: bool, attack_direction: Vector2):
	# three possible main actions with priority: attacking > walking > idling
	var current_action = ACTION_IDLE
	
	if is_attacking:
		current_action = ACTION_ATTACK
	elif velocity.length() > 0:
		current_action = ACTION_WALK
	
	var current_direction = facing_from_velocity(velocity)
	
	if is_attacking:
		# facing where we are currently attacking
		# always takes priority over where we are moving
		current_direction = facing_from_direction(attack_direction)
	elif velocity.length() == 0:
		# if we're not moving face last known direction
		current_direction = current_facing
	
	var animation_name = "%s_%s" % [current_action, current_direction]
	
	current_facing = current_direction
	
	if animation != animation_name:
		play(animation_name)

func _physics_process(delta):
	# this node expects to be a child of an entity
	var entity = get_parent()
	
	if entity == null or not (entity is Entity):
		return
	
	determine_animation(entity.get_velocity(), entity.is_attacking, entity.attack_direction)
