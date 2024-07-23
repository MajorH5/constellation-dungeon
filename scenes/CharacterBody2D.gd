extends CharacterBody2D

const SPEED = 65.0

const NORTH = 'north'
const EAST = 'east'
const SOUTH = 'south'
const WEST = 'west'

var current_facing = SOUTH
@onready var sprite = $AnimatedSprite2D

var controls_locked = false

func _ready ():
	sprite.speed_scale = 0.75

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
	
func update_movement():
	if controls_locked:
		velocity = Vector2.ZERO
		return
	
	var dir_x = Input.get_axis("ui_left", "ui_right")
	var dir_y = Input.get_axis("ui_up", "ui_down")
	
	var direction = Vector2(dir_x, dir_y)
	
	if dir_x != 0 or dir_y != 0:
		velocity = (direction / direction.length()) * SPEED
	else:
		velocity = Vector2.ZERO
	
func determine_animation_state():
	var animation_postfix = facing_from_velocity(velocity) if velocity.length() > 0 else current_facing
	var animation_prefix = "walk" if velocity.length() > 0 else "idle"
	
	var animation_name = animation_prefix + "_" + animation_postfix
	
	current_facing = animation_postfix
	
	if sprite.animation != animation_name:
		sprite.play(animation_name)

func lock_controls (is_locked: bool):
	controls_locked = is_locked

func _physics_process(delta):
	update_movement()
	determine_animation_state()
	move_and_slide()
