# Author: Habib A. 7-28-2024
# character controller class
class_name Player
extends Entity

@export var controls_locked: bool = false

@onready var camera: Camera2D = $Camera2D
@onready var nametag: Label = $Nametag

var player_name: String

var weapon: Weapon = null
var helmet: Item = null
var chestplate: Item = null
var leggings: Item = null
var boots: Item = null
var accessory: Item = null

@rpc("authority")
func equip_weapon(weapon: Weapon):
	if weapon != null:
		fire_rate = weapon.rate_of_fire
		base_projectile_damage = weapon.damage
	else:
		fire_rate = INF
		base_projectile_damage = 0
	
	if multiplayer.is_server():
		print("telling now ", owner_id)
		equip_weapon.rpc_id(owner_id, weapon)
	else:
		print("server told me to do it!")

func _ready():
	if multiplayer.get_unique_id() == owner_id:
		camera.make_current()
	
	nametag.text = player_name

func player_input():
	if multiplayer.get_unique_id() != owner_id:
		return
		
	# gathers player input and updates variables
	# which are relating to movement and current
	# attack direction
	if controls_locked:
		walk_to(Vector2.ZERO)
		attack_to(Vector2.ZERO)
		return
	
	# movement
	var dir_x = Input.get_axis("ui_left", "ui_right")
	var dir_y = Input.get_axis("ui_up", "ui_down")
	var walk_direction = Vector2(dir_x, dir_y).normalized()
	
	# attacking
	var attack_direction = Vector2.ZERO
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_position = camera.get_global_mouse_position()
		attack_direction = (mouse_position - position).normalized()
	
	if not multiplayer.is_server():
		# these functions internally rate limmit so we
		#wont just blast up the server
		walk_to(walk_direction)
		attack_to(attack_direction)

func lock_controls (is_locked: bool):
	controls_locked = is_locked

func _physics_process(delta):
	player_input()
	move_and_slide()
