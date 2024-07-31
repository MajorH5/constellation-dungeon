extends Control

const SATCHEL_SLOTS = 24
const CONTAINER_SLOTS = 15

const SATCHEL_DEFAULT_POS = Vector2.ZERO
const SATCHEL_CONTAINER_POS = Vector2(-262, 0)

@onready var satchel = $Satchel
@onready var container = $Container

@onready var satchel_slots = $Satchel/GridContainer
@onready var container_slots = $Container/GridContainer

var satchel_dict
var container_dict

var currently_selected = null

func bind_to_slot(slot: Control):
	#if multiplayer.is_server():
		#return
	
	slot.gui_input.connect(func (input: InputEvent):
		if input is InputEventMouseButton and input.button_index == MOUSE_BUTTON_LEFT and input.pressed:
			# user just clicked on this slot, are we swapping
			# or are we making a first selection
			
			if currently_selected == null:
				# making our first selection, lets get into
				# select mode with this node as target
				
				var container = satchel_dict if slot.get_parent() == satchel_slots else container_dict
				
				if container != null and container.get(slot.get_meta("slot_index")) != null:
					enable_select_mode(slot)
			elif slot == currently_selected:
				# if we choose the same slot to swap
				# back out before doing anything
				disable_select_mode()
			else:
				# we already made our first selection,
				# lets do this swap
				
				var from = currently_selected
				var to = slot
				
				var from_sprite = from.get_node("Item")
				var to_sprite = to.get_node("Item")
				
				# get respective containers
				var from_container = satchel_dict if from.get_parent() == satchel_slots else container_dict
				var to_container = satchel_dict if to.get_parent() == satchel_slots else container_dict
				
				var origin_item = from_container.get(from.get_meta("slot_index"))
				var destination_item = to_container.get(to.get_meta("slot_index"))
				
				#if origin_item != null:
					#to_sprite.visible = true
					#to_sprite.texture = origin_item.texture
				#else:
					#to_sprite.visible = false
				#
				#if destination_item != null:
					#from_sprite.visible = true
					#from_sprite.texture = destination_item.texture
				#else:
					#from_sprite.visible = false
				
				var player = find_parent("Game").find_child("Players").get_node(str(multiplayer.get_unique_id()))

				if player != null:
					var origin_type = Item.SlotType.CONTAINER if from.get_parent() == container_slots else Item.SlotType.INVENTORY
					var dest_type = Item.SlotType.CONTAINER if to.get_parent() == container_slots else Item.SlotType.INVENTORY
					
					var container_id = -1
					var container = Chest.get_current()
					
					if container != null:
						container_id = container.container_id
					
					player.swap_slots.rpc_id(1, origin_type, from.get_meta("slot_index"), dest_type, to.get_meta("slot_index"), container_id)
				
				get_tree().create_timer(3).timeout.connect(func():
					set_satchel(satchel_dict)
					set_container(container_dict)
				)
				
				# finally exit select mode
				disable_select_mode()
	)
	slot.mouse_entered.connect(func ():
		if currently_selected != null:
			slot.modulate = Color(1, 1, 1, 1)
	)
	slot.mouse_exited.connect(func ():
		if currently_selected != null and slot != currently_selected:
			slot.modulate = Color(0, 1, 1, 1)
	)

func _ready():
	for slot in satchel_slots.get_children():
		bind_to_slot(slot)
	
	for slot in container_slots.get_children():
		bind_to_slot(slot)

func enable_select_mode(target: Control):
	# all nodes except target in from should darken
	# and be barely visible to avoid attention
	for node in satchel_slots.get_children():
		if node == target:
			continue
		node.modulate = Color(0, 1, 1, 1)
	
	# now all nodes in to should get a slight
	# blue tint so we know they are available for swapping
	for node in container_slots.get_children():
		if node == target:
			continue
		node.modulate = Color(0, 1, 1, 1)
	
	currently_selected = target

func disable_select_mode():
	# reset all color modifications
	for node in satchel_slots.get_children():
		node.modulate = Color(1, 1, 1, 1)
	for node in container_slots.get_children():
		node.modulate = Color(1, 1, 1, 1)
	currently_selected = null

func get_slot_by_index(container: Control, index: int):
	for node in container.get_children():
		if node.get_meta("slot_index") == index:
			return node
	
	return null

func update_slots (dict, slots, total_size):
	for i in range(total_size):
		if dict == null or dict.get(i) == null:
			var slot = get_slot_by_index(slots, i)
			slot.get_node("Item").visible = false
	
	if dict == null:
		return
	
	for slot_index in dict:
		var slot = get_slot_by_index(slots, int(slot_index))
		var item = dict.get(slot_index)
		var item_sprite: Sprite2D = slot.get_node("Item")
		
		item_sprite.visible = true
		item_sprite.texture = item.texture

func set_satchel(s):
	satchel_dict = s
	update_slots(satchel_dict, satchel_slots, SATCHEL_SLOTS)

func set_container(c):
	container_dict = c
	update_slots(container_dict, container_slots, CONTAINER_SLOTS)

func open_satchel():
	set_satchel(satchel_dict)
	satchel.position = SATCHEL_DEFAULT_POS
	container.visible = false
	visible = true

func open_container():
	set_satchel(satchel_dict)
	satchel.position = SATCHEL_CONTAINER_POS
	container.visible = true
	visible = true

func close():
	container.visible = false
	visible = false
	set_container(null)
	disable_select_mode()

func is_looking_at (container: Chest):
	if container == null:
		return false
	
	return container_dict == container.contents

func is_viewing_container():
	return container.visible

func is_open():
	return visible
