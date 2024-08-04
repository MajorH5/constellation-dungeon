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
var DEV_item_index = 0
var swap_time: float = 0

#				  weapo. helm. ches. leg.  boot. acce.
var quick_swaps: Array[Item] = [null, null, null, null, null, null]
var satchel = {}

var skill_unlocks = {"Base": true,
		"Speed1": false, "Speed2": false, "Speed3": false,
		"Health1": false, "Health2": false, "Health3": false,
		"Attack1": false, "Attack2": false, "Attack3": false,
		"Radiant": false, "Restoration": false, "Reaper": false, "Icarus": false,
		"Ascendent": false}

@rpc("any_peer")
func intial_state():
	# its okay to let other clients call this
	# since it only lets them view gear not modify it
	# NOTE: returns an array of item ids, must be converted
	# back to object on client for details
	
	for slot_index in range(len(quick_swaps)):
		var item_id = ItemLookup.get_id(quick_swaps[slot_index])
		client_set_slot_item.rpc(owner_id, Item.SlotType.QUICK_SWAP, slot_index, item_id, 1)
	
	for slot_index in satchel:
		var item = satchel.get(slot_index)
		var item_id = ItemLookup.get_id(item)
		client_set_slot_item.rpc(owner_id, Item.SlotType.INVENTORY, slot_index, item_id, item.quantity)
	
	# always set initial position, velocity when spawning
	set_own_position.rpc_id(multiplayer.get_remote_sender_id(), position, velocity)

@rpc("any_peer")
func swap_slots(orig_type: Item.SlotType, orig_index: int, dest_type: Item.SlotType, dest_index: int, container_id: int):
	if orig_type == Item.SlotType.INVENTORY and dest_type == Item.SlotType.INVENTORY:
		# inv <--> inv item swapping
		
		if orig_index < 0 or orig_index >= 24: return
		if dest_index < 0 or dest_index >= 24: return
		
		var orig_item = satchel.get(orig_index)
		var dest_item = satchel.get(dest_index)
		
		if orig_item != null and dest_item != null and orig_item.item_name == dest_item.item_name:
			set_slot_item(Item.SlotType.INVENTORY, dest_index, orig_item, orig_item.quantity + dest_item.quantity)
			set_slot_item(Item.SlotType.INVENTORY, orig_index, null, -1)
		else:
			set_slot_item(Item.SlotType.INVENTORY, orig_index, dest_item, -1)
			set_slot_item(Item.SlotType.INVENTORY, dest_index, orig_item, -1)
	elif orig_type == Item.SlotType.CONTAINER and dest_type == Item.SlotType.CONTAINER:
		# container <-> container item swapping
		
		if orig_index < 0 or orig_index >= 15: return
		if dest_index < 0 or dest_index >= 15: return
		
		var container: Chest = Chest.global.get(container_id)
		
		if container == null: return
		
		var orig_item = container.contents.get(orig_index)
		var dest_item = container.contents.get(dest_index)
		
		if orig_item != null and dest_item != null and orig_item.item_name == dest_item.item_name:
			set_slot_item(Item.SlotType.CONTAINER, dest_index, orig_item, orig_item.quantity + dest_item.quantity, container_id)
			set_slot_item(Item.SlotType.CONTAINER, orig_index, null, -1, container_id)
		else:
			set_slot_item(Item.SlotType.CONTAINER, orig_index, dest_item, -1, container_id)
			set_slot_item(Item.SlotType.CONTAINER, dest_index, orig_item, -1, container_id)
	elif orig_type == Item.SlotType.CONTAINER and dest_type == Item.SlotType.INVENTORY:
		# container <-> inventory item swapping
		if orig_index < 0 or orig_index >= 15: return
		if dest_index < 0 or dest_index >= 24: return
		
		var container: Chest = Chest.global.get(container_id)
		if container == null: return
		
		var orig_item = container.contents.get(orig_index)
		var dest_item = satchel.get(dest_index)
		
		if orig_item != null and dest_item != null and orig_item.item_name == dest_item.item_name:
			set_slot_item(Item.SlotType.INVENTORY, dest_index, orig_item, orig_item.quantity + dest_item.quantity)
			set_slot_item(Item.SlotType.CONTAINER, orig_index, null, -1, container_id)
		else:
			set_slot_item(Item.SlotType.CONTAINER, orig_index, dest_item, -1, container_id)
			set_slot_item(Item.SlotType.INVENTORY, dest_index, orig_item, -1)
	elif orig_type == Item.SlotType.INVENTORY and dest_type == Item.SlotType.CONTAINER:
		# inventory <-> container item swapping
		if orig_index < 0 or orig_index >= 24: return
		if dest_index < 0 or dest_index >= 15: return
		
		var container: Chest = Chest.global.get(container_id)
		if container == null: return
		
		var orig_item = satchel.get(orig_index)
		var dest_item = container.contents.get(dest_index)
		
		if orig_item != null and dest_item != null and orig_item.item_name == dest_item.item_name:
			set_slot_item(Item.SlotType.CONTAINER, dest_index, orig_item, orig_item.quantity + dest_item.quantity, container_id)
			set_slot_item(Item.SlotType.INVENTORY, orig_index, null, -1)
		else:
			set_slot_item(Item.SlotType.INVENTORY, orig_index, dest_item, -1)
			set_slot_item(Item.SlotType.CONTAINER, dest_index, orig_item, -1, container_id)


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
func client_set_slot_item (id: int, slot_type: Item.SlotType, slot_index: int, item_id: int, quantity: int, container_id: int = -1):
	# equivalent to set_slot_item but instead is to be called by
	# server to let client know to change equipment info using item_id
	# since objects dont serialize over rpc
	
	if owner_id != id:
		return
	
	var item: Item = ItemLookup.get_item(item_id)
	
	if item == null and item_id != -1:
		push_warning("[Player.client_set_slot_item]: Item slot set failed for item id %d because the item was not found!" % item_id)
		return
	
	set_slot_item(slot_type, slot_index, item, quantity, container_id)

@rpc("authority")
func set_slot_item(slot_type: Item.SlotType, slot_index: int, item: Item, quantity: int, container_id: int = -1):
	# NOTE: negative quantitie are ignored
	if item != null:
		if quantity > 0:
			item.quantity = quantity
		else:
			quantity = item.quantity
	
	if slot_type == Item.SlotType.QUICK_SWAP:
		quick_swaps[slot_index] = item
		
		match slot_index:
			Item.SLOT_WEAPON: on_weapon_equip(item)
	elif slot_type == Item.SlotType.INVENTORY:
		if item == null:
			satchel.erase(slot_index)
		else:
			satchel[slot_index] = item
	elif slot_type == Item.SlotType.CONTAINER:
		var container = Chest.global.get(container_id)
		
		print(slot_index, item, container)
		if container != null:
			container.set_slot(slot_index, item)
	
	if multiplayer.is_server():
		var item_id = ItemLookup.get_id(item)
		
		if item != null and item_id == -1:
			push_warning("[Player.set_slot_item]: An item with unregisteried id was placed on the player! Item name: %s" % item.item_name)
			return
		
		client_set_slot_item.rpc(owner_id, slot_type, slot_index, item_id, quantity, container_id)
	else:
		print("Server Slot Set! slot_type: ", slot_type, " slot_index: ", slot_index, " item: ", item.item_name if item != null else "null", " quantity: ", quantity)
		
		# update ui to reflect item state
		if multiplayer.get_unique_id() == owner_id:
			if slot_type == Item.SlotType.QUICK_SWAP:
				hud.set_quick_swap_item(slot_index, item)
			elif slot_type == Item.SlotType.INVENTORY:
				hud.backpack.set_satchel(satchel)
			elif slot_type == Item.SlotType.CONTAINER:
				var current = Chest.get_current()
				
				if hud.backpack.is_looking_at(current):
					hud.backpack.set_container(current.contents)
					

func _ready():
	despawn_on_death = false
	
	var game = find_parent("Game")
	
	if game != null:
		hud = game.find_children("GameHud")[0]
	
	if multiplayer.get_unique_id() == owner_id:
		camera.make_current()
		hud.set_health(health, max_health)
		hud.backpack.set_satchel(satchel)
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
		
		if Input.get_action_raw_strength("ui_select") == 1:
			if swap_time >= 0.5:
				var level = find_parent("Level1")
				
				match(DEV_item_index):
					0: level.equip_weapon.rpc_id(1, ItemLookup.GOD_SWORD)
					1: level.equip_weapon.rpc_id(1, ItemLookup.DAGGER)
					2: level.equip_weapon.rpc_id(1, ItemLookup.BOW)
					3: level.equip_weapon.rpc_id(1, ItemLookup.SILVER_BOW)
					4: level.equip_weapon.rpc_id(1, ItemLookup.GOLD_BOW)
					
				swap_time = 0
				DEV_item_index = (DEV_item_index + 1) % 5
			
			if hud.backpack.is_open():
				hud.backpack.close()
		

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
	
	if multiplayer.is_server():
		server_position = position
		server_velocity = velocity
		pass
	else:
		if owner_id == multiplayer.get_unique_id():
			hud.set_health(health, max_health)
		
		# we are allowing clients to be fully authoritative
		# over their own position
		# sacrificing some game integrity for reduced latency input lag
		
		if multiplayer.get_unique_id() != owner_id:
			position = server_position
			velocity = server_velocity
		else:
			set_own_position.rpc_id(1, position, velocity)

func _input(event):
	if multiplayer.get_unique_id() != owner_id:
		return
	
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_E and not is_dead():
			var current_chest = Chest.get_current()
			
			if current_chest == null:
				if hud.backpack.is_open():
					hud.backpack.close()
				return
			
			if hud.backpack.is_viewing_container():
				hud.backpack.close()
			else:
				hud.backpack.set_container(current_chest.contents)
				hud.backpack.open_container()
