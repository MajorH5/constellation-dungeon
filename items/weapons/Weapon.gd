# Author: Habib A. 7-2-2024
# class handles all logic for any weapon item
# within the game
class_name Weapon
extends Item

@export var min_damage: int = 1
@export var max_damage: int = 1
@export var rate_of_fire: float = 1
@export var projectile_data: ProjectileData

func get_rand_damage() -> int:
	return floori(min_damage + (max_damage - min_damage) * randf())

func get_descriptor() -> String:
	var item_desc = super.get_descriptor()	
	return "%s\n[color=red]Damage: %s-%s[/color]\n[color=yellow]Attack Speed: %.2f[/color]" % [item_desc, min_damage, max_damage, rate_of_fire]
