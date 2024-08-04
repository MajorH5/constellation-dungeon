class_name Armor
extends Item

@export var defense: int = 10
@export var speed: int = 5

func get_descriptor() -> String:
	var item_desc = super.get_descriptor()
	
	var defense_txt = "[color=#3050d1]DEF: %d[/color]" % [defense]
	var speed_txt = "[color=#2c9944]SPD BST: %d[/color]" % [defense]
	
	return "%s[b]\n%s\t\t%s[/b]" % [item_desc, defense_txt, speed_txt]
