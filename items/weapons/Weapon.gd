# Author: Habib A. 7-2-2024
# class handles all logic for any weapon item
# within the game
class_name Weapon
extends Item

const projectile_scn = preload("res://projectiles/Projectile.tscn")

@export var damage: int = 1
@export var rate_of_fire: float = 1

@export_group("Projectile Data")
@export var projectile_speed: int = 1
@export var projectile_texture: SpriteFrames
@export var projectile_lifetime: float = 1.0
@export var projectile_hitbox_size: Vector2 = Vector2(8, 8)
@export var projectile_hitbox_offset: Vector2 = Vector2.ZERO

func create_projectile(from_player: bool, projectile_damage: int, direction: Vector2) -> Projectile:
	# create the correspoding projectile which will
	# move and do damage that is emitted from this weapon
	var projectile = projectile_scn.instantiate()
	
	var radians = atan2(-direction.y, direction.x)
	var degrees = floori(rad_to_deg(radians) + 360) % 360
	
	projectile.ready.connect(func ():
		projectile.sprite.sprite_frames = projectile_texture
		projectile.sprite.play("default")
		projectile.rotation = degrees - 45
		projectile.damage = projectile_damage
		projectile.from_player = from_player
		projectile.lifetime = projectile_lifetime
	)
	
	
	#TODO: uhm how to do this bruh? jank boxes for now
	#projectile.hitbox.shape = ????
	
	return projectile
