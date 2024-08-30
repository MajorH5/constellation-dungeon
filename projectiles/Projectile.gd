# Author: Habib A. 7-27-2024
# Base class for any projectile in the game
# can set the speed, damage, and sprite
class_name Projectile
extends RigidBody2D

const ENEMY_COLLISION_LAYER = 4
const PLAYER_COLLISION_LAYER = 2
const BASE_PROJECTILE_SPEED = 13

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Area2D

# these properties will be modified  by whatever
# instantiates this scene
var from_player: bool = false
@export var lifetime: float = 1.0
var damage: int = 0

var sender: int = -1

func _on_body_entered(body):
	# fires whenever the projectile has collided with
	# some entity in the world
	
	if multiplayer.is_server():
		return
	
	if not (body is Entity):
		# hit a wall?
		queue_free()
		return
	
	var friendly_hitting_hostile = from_player and body.hostile
	var hostile_hitting_friendly = not from_player and not body.hostile

	var from_entity = Entity.entity_registry.get(sender)

	if not body.is_dead():
		if friendly_hitting_hostile and from_entity.owner_id == multiplayer.get_unique_id():
			body.register_projectile_hit.rpc_id(1, from_entity.entity_id)
			queue_free()
			
			if body.get_node("OnHit") != null:
				body.get_node("OnHit").play()
		elif hostile_hitting_friendly and body.owner_id == multiplayer.get_unique_id():
			body.register_self_hit.rpc_id(1, from_entity.entity_id)
			queue_free()
			
			if body.get_node("OnHit") != null:
				body.get_node("OnHit").play()
		

func _ready ():
	if not multiplayer.is_server():
		var creator: Entity = Entity.entity_registry.get(sender)
		
		if creator != null:
			var projectile_data = creator.projectile_data
			
			sprite.sprite_frames = projectile_data.texture
			var total_frames = sprite.sprite_frames.get_frame_count("default")
			sprite.sprite_frames.set_animation_speed("default", 1.0 / (lifetime / total_frames))
			
			sprite.play("default")
		else:
			print("[Projectile._ready]: Client failed to determine the creator for a projectile!")
	
	var layer: int = ENEMY_COLLISION_LAYER if from_player else PLAYER_COLLISION_LAYER
	hitbox.set_collision_layer_value(layer, true)

func _process (delta: float):
	# updaes the projectile's lifetime
	# counting down till when it despawns
	lifetime -= delta

	if lifetime <= 0:
		queue_free()
