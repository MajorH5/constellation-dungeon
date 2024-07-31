# Author: Habib A. 7-27-2024
# base class for every item in the game
class_name Item
extends Node

# enum for specifying where this
# item can be placed
enum {
	SLOT_WEAPON, SLOT_HELMET,
	SLOT_CHESTPLATE, SLOT_LEGGINGS,
	SLOT_BOOTS, SLOT_ACCESSORY,
	SLOT_INVENTORY,
}

enum SlotType {
	QUICK_SWAP,
	INVENTORY,
	CONTAINER
}

@export var texture: AtlasTexture
@export var item_name: String
@export_multiline var item_description: String
@export_range(1, INF) var quantity: int = 1

func get_descriptor() -> String:
	return "[b]%s[/b]\n%s" % [item_name, item_description]
