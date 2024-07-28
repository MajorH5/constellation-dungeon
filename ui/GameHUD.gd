extends Control

@onready var weapon: Control = $QuickSwaps/GridContainer/Weapon
@onready var helmet: Control = $QuickSwaps/GridContainer/Helmet
@onready var chestplate: Control = $QuickSwaps/GridContainer/Chestplate
@onready var leggings: Control = $QuickSwaps/GridContainer/Leggings
@onready var boots: Control = $QuickSwaps/GridContainer/Boots
@onready var accessory: Control = $QuickSwaps/GridContainer/Accessory

func get_slot_from_constant (slot: int) -> Control:
	match slot:
		Item.SLOT_WEAPON: return weapon
		Item.SLOT_CHESTPLATE: return chestplate
		Item.SLOT_HELMET: return helmet
		Item.SLOT_LEGGINGS: return leggings
		Item.SLOT_BOOTS: return boots
		Item.SLOT_ACCESSORY: return accessory
	return null

func set_slot_item (slot_id: int, item: Item):
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
		var default_texture_pos = slot.get_meta("default_texture_pos")
		
		background_sprite.region_rect = default_texture_pos
		item_sprite.visible = false
	
	
