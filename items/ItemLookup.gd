class_name ItemLookup
extends Node

enum {
	DAGGER,
	BOW,
	GOD_SWORD,
	SILVER_BOW,
	GOLD_BOW,
	WOODEN_HELMET, WOODEN_CHESTPLATE,
	WOODEN_LEGGINGS, WOODEN_BOOTS
}

static var registry = {
	DAGGER: preload("res://items/weapons/Dagger.tscn"),
	BOW: preload("res://items/weapons/Bow.tscn"),
	GOD_SWORD: preload("res://items/weapons/GodSword.tscn"),
	SILVER_BOW: preload("res://items/weapons/SilverBow.tscn"),
	GOLD_BOW: preload("res://items/weapons/GoldBow.tscn"),
	WOODEN_HELMET: preload("res://items/armors/WoodenHelmet.tscn"),
	WOODEN_CHESTPLATE: preload("res://items/armors/WoodenChestplate.tscn"),
	WOODEN_LEGGINGS: preload("res://items/armors/WoodenLeggings.tscn"),
	WOODEN_BOOTS: preload("res://items/armors/WoodenBoots.tscn")
}

static func get_id (item: Item) -> int:
	if item == null:
		return -1
	
	for item_id in registry:
		# TODO: this is really bad, please find a better way okay?
		if registry[item_id].instantiate().item_name == item.item_name:
			return item_id
	
	return -1

static func get_item (item_id: int) -> Item:
	var item = registry.get(item_id)
	
	if item != null:
		return item.instantiate()
	
	if item_id != -1:
		print("[ItemLookup.get_item]: Failed to find the item with id: %d" % item_id)
	
	return null
