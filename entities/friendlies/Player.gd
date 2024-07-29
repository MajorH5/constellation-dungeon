# Author: Habib A. 7-28-2024
# character controller class
class_name Player
extends Entity

@export var controls_locked: bool = false

@onready var camera: Camera2D = $Camera2D
@onready var nametag: Label = $Nametag

var server_position: Vector2 = Vector2.ZERO
var server_velocity: Vector2 = Vector2.ZERO

var hud: Control = null
var player_name: String
var inventory = []
var DEV_item_index = 0
var swap_time: float = 0

#				  weapo. helm. ches. leg.  boot. acce.
var quick_swaps: Array[Item] = [null, null, null, null, null, null]

@rpc("any_peer")
func intial_state():
	# its okay to let other clients call this
	# since it only lets them view gear not modify it
	# NOTE: returns an array of item ids, must be converted
	# back to object on client for details
	
	for slot_index in range(len(quick_swaps)):
		var item_id = ItemLookup.get_id(quick_swaps[slot_index])
		client_set_slot_item.rpc(owner_id, Item.SlotType.QUICK_SWAP, slot_index, item_id, 1)
	
	# always set initial position, velocity when spawning
	set_own_position.rpc_id(multiplayer.get_remote_sender_id(), position, velocity)

func get_projectile_damage() -> int:
	# need to consider weapon damage instead of only
	# base damage if possible
	
	var weapon = get_weapon()
	
	if weapon == null:
		return base_damage
	
	return base_damage + weapon.get_rand_damage()

func on_weapon_equip (weapon: Item):
	# called whenever an item is put into the
	# weapon slot, any item.. not just weapons so we need
	# to be safe
	
	if weapon is Weapon:
		fire_rate = weapon.rate_of_fire
		projectile_data = weapon.projectile_data
	else:
		fire_rate = INF
		projectile_data = null

@rpc("authority")
func client_set_slot_item (id: int, slot_type: Item.SlotType, slot_index: int, item_id: int, quantity: int):
	# equivalent to set_slot_item but instead is to be called by
	# server to let client know to change equipment info using item_id
	# since objects dont serialize over rpc
	
	if owner_id != id:
		return
	
	var item: Item = ItemLookup.get_item(item_id)
	
	if item == null and item_id != -1:
		push_warning("[Player.client_set_slot_item]: Item slot set failed for item id %d because the item was not found!" % item_id)
		return
	
	set_slot_item(slot_type, slot_index, item, quantity)

@rpc("authority")
func set_slot_item(slot_type: Item.SlotType, slot_index: int, item: Item, quantity: int):
	if item != null:
		item.quantity = quantity
	
	if slot_type == Item.SlotType.QUICK_SWAP:
		quick_swaps[slot_index] = item
		
		match slot_index:
			Item.SLOT_WEAPON: on_weapon_equip(item)
	
	if multiplayer.is_server():
		var item_id = ItemLookup.get_id(item)
		
		if item != null and item_id == -1:
			push_warning("[Player.set_slot_item]: An item with unregisteried id was placed on the player! Item name: %s" % item.item_name)
			return
		
		client_set_slot_item.rpc(owner_id, slot_type, slot_index, item_id, quantity)
	else:
		print("Server Slot Set! slot_type: ", slot_type, " slot_index: ", slot_index, " item: ", item.item_name if item != null else "null", " quantity: ", quantity)
		
		# update ui to reflect item state
		if slot_type == Item.SlotType.QUICK_SWAP:
			hud.set_quick_swap_item(slot_index, item)

func _ready():
	despawn_on_death = false
	
	var game = find_parent("Game")
	
	if game != null:
		hud = game.find_children("GameHud")[0]
	
	if multiplayer.get_unique_id() == owner_id:
		camera.make_current()
		hud.set_health(health, max_health)
	else:
		nametag.modulate = Color(1, 1, 1, 0.5)
	
	if not multiplayer.is_server():
		intial_state.rpc_id(1)
	
	nametag.text = player_name

func player_input():
	if multiplayer.get_unique_id() != owner_id:
		return
		
	# gathers player input and updates variables
	# which are relating to movement and current
	# attack direction
	if controls_locked or is_dead():
		if Input.get_action_raw_strength("respawn") == 1:
			find_parent("Level1").respawn_player.rpc_id(1)
		walk_to(Vector2.ZERO)
		attack_to(Vector2.ZERO)
		return
	
	# movement
	var dir_x: float = Input.get_axis("ui_left", "ui_right")
	var dir_y: float = Input.get_axis("ui_up", "ui_down")
	var walk_direction = Vector2(dir_x, dir_y).normalized()
	
	# attacking
	var attack_dir = Vector2.ZERO
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_position = camera.get_global_mouse_position()
		attack_dir = (mouse_position - position).normalized()
	
	if not multiplayer.is_server():
		# these functions internally rate limmit so we
		#wont just blast up the server
		walk_to(walk_direction)
		attack_to(attack_dir)
		
		if Input.get_action_raw_strength("ui_select") == 1 and swap_time >= 0.5:
			var level = find_parent("Level1")
			
			match(DEV_item_index):
				0: level.equip_weapon.rpc_id(1, ItemLookup.GOD_SWORD)
				1: level.equip_weapon.rpc_id(1, ItemLookup.DAGGER)
				2: level.equip_weapon.rpc_id(1, ItemLookup.BOW)
			
			swap_time = 0
			DEV_item_index = (DEV_item_index + 1) % 3
		

func _on_death():
	super._on_death()
	controls_locked = true

func get_weapon() -> Weapon:
	return quick_swaps[Item.SLOT_WEAPON]

func lock_controls (is_locked: bool):
	controls_locked = is_locked

func _physics_process(delta):
	swap_time += delta
	
	player_input()
	hud.set_health(health, max_health)
	
	if multiplayer.is_server():
		server_position = position
		server_velocity = velocity
		pass
	else:
		# we are allowing clients to be fully authoritative
		# over their own position
		# sacrificing some game integrity for reduced latency input lag
		
		if multiplayer.get_unique_id() != owner_id:
			position = server_position
			velocity = server_velocity
		else:
			pass
			set_own_position.rpc_id(1, position, velocity)

func _on_input_event(viewport, event, shape_idx):
	print(multiplayer.is_server())
