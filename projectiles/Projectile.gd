# Author: Habib A. 7-27-2024
# Base class for any projectile in the game
# can set the speed, damage, and sprite
class_name Projectile
extends RigidBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $CollisionShape2D

# these properties will be modified  by whatever
# instantiates this scene
var from_player: bool = false
@export var lifetime: float = 1.0
var damage: int = 0

func _on_body_entered(body):
	# fires whenever the projectile has collided with
	# some entity in the world
	
	queue_free()
	
	if from_player and body.is_hostile:
		pass
	elif not from_player and not body.is_hostile:
		pass
	

func _process (delta: float):
	# updaes the projectile's lifetime
	# counting down till when it despawns
	if not multiplayer.is_server():
		return
	
	lifetime -= delta
	
	if lifetime <= 0:
		queue_free()
