extends Control

@onready var state_info = $Status/StateInfo

@onready var health_bar = $Status/HealthBar
@onready var health_progress = $Status/HealthBar/Progress
@onready var health_label = $Status/HealthBar/Health

@onready var experience_bar = $Status/ExperienceBar
@onready var experience_progress = $Status/ExperienceBar/Progress
@onready var experience_label = $Status/ExperienceBar/Experience

@onready var weapon = $QuickSwaps/GridContainer/Weapon
@onready var helmet = $QuickSwaps/GridContainer/Helmet
@onready var chestplate = $QuickSwaps/GridContainer/Chestplate
@onready var leggings = $QuickSwaps/GridContainer/Leggings
@onready var boots = $QuickSwaps/GridContainer/Boots
@onready var accessory = $QuickSwaps/GridContainer/Accessory

@onready var backpack = $BackpackWindow

var health_tween = null
var experience_tween = null

var quick_swaps: Array[Item] = [null, null, null, null, null, null]

func _ready():
	var swaps_ui = [weapon, helmet, chestplate, leggings, boots, accessory]
	
	for slot_index in range(len(swaps_ui)):
		var slot = swaps_ui[slot_index]
		
		slot.mouse_entered.connect(func ():
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				#shooting, maybe?
				return
			
			slot.get_node("NinePatchRect").visible = quick_swaps[slot_index] != null
		)
		slot.mouse_exited.connect(func ():
			slot.get_node("NinePatchRect").visible = false
		)

func update_status (class_type: String, level: int):
	state_info.text = "%s • [color=gold]Lvl %d[/color]" % [class_type, level]

func get_slot_from_constant (slot: int) -> Control:
	match slot:
		Item.SLOT_WEAPON: return weapon
		Item.SLOT_CHESTPLATE: return chestplate
		Item.SLOT_HELMET: return helmet
		Item.SLOT_LEGGINGS: return leggings
		Item.SLOT_BOOTS: return boots
		Item.SLOT_ACCESSORY: return accessory
	return null

func update_quick_swap_description(slot_id: int):
	var slot = get_slot_from_constant(slot_id)
	
	if slot == null:
		return
	
	var item = quick_swaps[slot_id]
	var label: RichTextLabel = slot.get_node("NinePatchRect/RichTextLabel")
	
	if item != null:
		label.text = item.get_descriptor()
		print(label.text)
	else:
		label.text = ""
		label.visible = false

func set_health (health: int, max_health: int):
	if health_tween != null:
		health_tween.stop()
	
	health_label.text = "HP: %s / %s" % [health, max_health]
	
	var percentage = 1.0 * health / max_health
	var goal_size = Vector2(percentage * health_bar.size.x, health_bar.size.y)
	
	health_tween = create_tween()
	health_tween.set_trans(Tween.TRANS_EXPO)
	health_tween.set_ease(Tween.EASE_OUT)
	health_tween.tween_property(health_progress, "size", goal_size, 0.65)


func set_experience (experience: int, max_experience: int):
	if experience_tween != null:
		experience_tween.stop()
	
	experience_label.text = "XP: %s / %s" % [experience, max_experience]
	
	var percentage = 1.0 * experience / max_experience
	var goal_size = Vector2(percentage * experience_bar.size.x, experience_bar.size.y)
	
	experience_tween = create_tween()
	experience_tween.set_trans(Tween.TRANS_EXPO)
	experience_tween.set_ease(Tween.EASE_OUT)
	experience_tween.tween_property(experience_progress, "size", goal_size, 0.65)


func set_quick_swap_item (slot_id: int, item: Item):
	var slot = get_slot_from_constant(slot_id)
	
	if slot == null:
		return
	
	var background_sprite: Sprite2D = slot.get_node("Slot")
	var item_sprite: Sprite2D = slot.get_node("Item")
	
	if item != null:
		var texture = item.texture.atlas
		var region = item.texture.region
		
		background_sprite.region_rect = Rect2(540, 180, 90, 90)
		item_sprite.visible = true
		item_sprite.texture = texture
		item_sprite.region_rect = region
	else:
		var default_texture_pos = background_sprite.get_meta("default_texture_pos")
		
		background_sprite.region_rect = default_texture_pos
		item_sprite.visible = false
	
	quick_swaps[slot_id] = item
	update_quick_swap_description(slot_id)


func _on_satchel_button_down():
	if backpack.is_open():
		backpack.close()
	else:
		backpack.open_satchel()
	
