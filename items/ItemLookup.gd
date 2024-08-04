class_name ItemLookup
extends Node

enum {
	DAGGER,
	BOW,
	GOD_SWORD,
	SILVER_BOW,
	GOLD_BOW,
	WOODEN_HELMET, WOODEN_CHESTPLATE,
	WOODEN_LEGGINGS, WOODEN_BOOTS,
	
	AMETHYST, 
	CHEESE, 
	GOLD_RING, 
	SILVER_BLOOD_BOURNE, 
	WOOD_OPAL, 
	DEMON_HELMET, 
	FLESH_PLATE, 
	GOLD_HELMET, 
	IRON_CHESTPLATE, 
	IRON_HELMET, 
	SKULLMET, 
	STONE_CHESTPLATE, 
	WOOD, 
	IRON, 
	DIAMOND_LEGGINGS, 
	GOLD_LEGGINGS, 
	JEANS, 
	SILVER_LEGGINGS,
	GOLD_CHESTPLATE
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
	WOODEN_BOOTS: preload("res://items/armors/WoodenBoots.tscn"),
	
	AMETHYST: preload("res://items/accessories/Amethyst.tscn"),
	CHEESE: preload("res://items/accessories/Cheese.tscn"),
	GOLD_RING: preload("res://items/accessories/GoldRing.tscn"),
	SILVER_BLOOD_BOURNE: preload("res://items/accessories/SilverBloodBourne.tscn"),
	WOOD_OPAL: preload("res://items/accessories/WoodOpal.tscn"),
	DEMON_HELMET: preload("res://items/armors/DemonHelmet.tscn"),
	FLESH_PLATE: preload("res://items/armors/FleshPlate.tscn"),
	GOLD_HELMET: preload("res://items/armors/GoldHelmet.tscn"),
	IRON_CHESTPLATE: preload("res://items/armors/IronChestplate.tscn"),
	GOLD_CHESTPLATE: preload("res://items/armors/GoldChestplate.tscn"),
	IRON_HELMET: preload("res://items/armors/IronHelmet.tscn"),
	SKULLMET: preload("res://items/armors/Skullmet.tscn"),
	STONE_CHESTPLATE: preload("res://items/armors/StoneChestplate.tscn"),
	WOOD: preload("res://items/resources/Wood.tscn"),
	IRON: preload("res://items/resources/Iron.tscn"),
	DIAMOND_LEGGINGS: preload("res://items/leggings/DiamondLeggings.tscn"),
	GOLD_LEGGINGS: preload("res://items/leggings/GoldLeggings.tscn"),
	JEANS: preload("res://items/leggings/Jeans.tscn"),
	SILVER_LEGGINGS: preload("res://items/leggings/SilverLeggings.tscn")
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
