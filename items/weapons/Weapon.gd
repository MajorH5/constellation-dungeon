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
	
	var damage_txt = "[color=#f56642]DMG: %d-%d[/color]" % [min_damage, max_damage]
	var attackspd_txt = "[color=yellow]RATE: %.1f[/color]" % rate_of_fire 
	
	var bullets_txt = "[color=#9c9391]BLTS: %d[/color]" % projectile_data.amount
	var speed_txt = "[color=#2c9944]SPD: %.1f[/color]" % projectile_data.speed
	
	var range_txt = "[color=#d9861a]RANG: %d [/color]" % floori(projectile_data.speed * projectile_data.lifetime * 13)
	
	return "%s\n[b]%s\t\t%s\n%s\t\t%s\n%s[/b]" % [item_desc, damage_txt, attackspd_txt, bullets_txt, speed_txt, range_txt]
