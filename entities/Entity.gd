# Author: Habib A. 7-28-2024
# Base class for all entities in the game and handles
# basic multiplayer replication functions
class_name Entity
extends CharacterBody2D

const BASE_SPEED_MULTIPLIER = 13

@export_group("Combat Stats")
@export var health: int = 100
@export var attack: int = 1
@export var speed: int = 5
@export var vitality: int = 1

@export_group("Attributes")
@export var hostile: bool = false
@export var fire_rate: float = 1.0 / 3.0
@export var base_projectile_damage: int = 0

var owner_id: int # unique multiplayer client id or blank if server owned

var last_walking_direction: Vector2 = Vector2.ZERO
var last_attacking_direction: Vector2 = Vector2.ZERO
var last_fire_time = 0

signal on_death(cause: Variant)

var is_attacking: bool = false
var attack_direction: Vector2 = Vector2.ZERO

func is_dead() -> bool:
	# returns true if this entity is dead
	return health <= 0

func spawn_projectile():
	if not multiplayer.is_server():
		var dagger = load("res://items/weapons/Dagger.tscn").instantiate()
		var projectile: RigidBody2D = dagger.create_projectile(true, 1, attack_direction)
		
		projectile.position = position
		projectile.linear_velocity = attack_direction * 65 * 2
		
		get_parent().get_parent().add_child(projectile)

func damage(amount: int, source: Variant) -> bool:
	# damages the entity by the given amount
	# and returns ture if successfull
	if is_dead() or amount != amount:
		return false
	
	health = max(0, health - amount)
	
	if health == 0:
		on_death.emit(source)
	
	return true

@rpc("any_peer")
func rpc_attack(direction: Vector2):
	if multiplayer.get_remote_sender_id() != owner_id:
		return
		
	if direction.x != direction.x or direction.y != direction.y:
		# handle NaN input
		return
	
	attack_to(direction)

func attack_to(direction: Vector2):
	# casues the entity to begin emitting projectiles
	# in the given direction relative to its center
	# NOTE: zero vector will stop shooting
	
	if not multiplayer.is_server():
		if last_attacking_direction != direction:
				rpc_attack.rpc_id(1, direction)
				last_attacking_direction = direction
	else:
		if direction.x == 0 and direction.y == 0:
			is_attacking = false
			attack_direction = Vector2.ZERO
			return
		
		is_attacking = true
		attack_direction = direction

@rpc("any_peer")
func rpc_walk(direction: Vector2):
	if multiplayer.get_remote_sender_id() != owner_id:
		return
		
	if direction.x != direction.x or direction.y != direction.y:
		# handle NaN input
		return
	
	walk_to(direction)

func walk_to(direction: Vector2):
	# causes the entity to begin moving towards
	# the specified directio relative to its center
	# while maintining its speed constraints
	# NOTE: zero vector will stop movement
	
	if not direction.is_normalized():
		# expects a unit vec
		direction = direction.normalized()
	
	if not multiplayer.is_server():
		if last_walking_direction != direction:
			rpc_walk.rpc_id(1, direction)
			last_walking_direction = direction
	else:
		if direction.x != 0 or direction.y != 0:
			velocity = (direction / direction.length()) * BASE_SPEED_MULTIPLIER * speed
		else:
			velocity = Vector2.ZERO

func _process (delta):
	if not multiplayer.is_server():
		last_fire_time += delta
		
		if is_attacking and last_fire_time >= fire_rate:
			spawn_projectile()
			last_fire_time = 0
