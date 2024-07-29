# Author: Habib A. 7-28-2024
# Base class for all entities in the game and handles
# basic multiplayer replication functions
class_name Entity
extends CharacterBody2D

const BASE_SPEED_MULTIPLIER = 13
const ENTITY_DESPAWN_DELAY = 3

static var entity_registry: Dictionary = {}
static var entity_id_track: int = 0

const projectile_scn = preload("res://projectiles/Projectile.tscn")
const damage_text_scn = preload("res://ui/DamageText.tscn")

@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar

@export_group("Combat Stats")
@export var max_health: int = 100
@export var health: int = 100
@export var attack: int = 1
@export var speed: int = 5
@export var vitality: int = 1

@export_group("Attributes")
@export var hostile: bool = false
@export var fire_rate: float = 1
@export var projectile_data: ProjectileData
@export var base_damage: int = 0
@export var despawn_on_death: bool = true

var entity_id: int = -1
var owner_id: int # unique multiplayer client id or blank if server owned

var last_walking_direction: Vector2 = Vector2.ZERO
var last_attacking_direction: Vector2 = Vector2.ZERO
var last_fire_time = 0

signal death(cause: Variant)

var is_attacking: bool = false
var attack_direction: Vector2 = Vector2.ZERO

func is_dead() -> bool:
	# returns true if this entity is dead
	return health <= 0

func spawn_projectile():
	# create the correspoding projectile which will
	# move and do damage that is emitted from this entity
	
	if is_dead():
		return
	
	var projectile = projectile_scn.instantiate()
	
	# dont need this in degrees but helps with visualization...
	var radians = atan2(-attack_direction.y, attack_direction.x)
	var degrees = floori(rad_to_deg(radians) + 360) % 360
	
	projectile.linear_velocity = attack_direction * projectile_data.speed * Projectile.BASE_PROJECTILE_SPEED
	projectile.damage = get_projectile_damage()
	projectile.rotation_degrees = 45 - degrees
	projectile.from_player = not hostile
	projectile.lifetime = projectile_data.lifetime
	projectile.sender = entity_id
	projectile.position = position + attack_direction * projectile_data.spawn_distance
	
	#TODO: uhm how to do this bruh? jank boxes for now
	#projectile.hitbox.shape = ????
	
	get_parent().get_parent().add_child(projectile)

func get_projectile_damage() -> int:
	return base_damage

func damage(amount: int, source: Variant) -> bool:
	# damages the entity by the given amount
	# and returns ture if successfull
	if is_dead() or amount != amount:
		return false
	
	health = max(0, health - amount)
	health_bar.set_health_percent(health * 1.0 / max_health)
	
	var damage_text = damage_text_scn.instantiate()
	damage_text.position = Vector2(damage_text.position.x, -20)
	damage_text.text = "-%d" % amount
	add_child(damage_text)
	
	if health == 0:
		_on_death()
		death.emit(source)
	
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
func set_own_position(goal_position: Vector2, goal_velocity: Vector2):
	# allows players to arbitrarily set their
	# player position if they own this entity
	
	if not multiplayer.is_server():
		# sever is enforce and authoritative position set
		position = goal_position
		velocity = goal_velocity
		return
	
	if multiplayer.get_remote_sender_id() != owner_id:
		return
	
	if goal_position.x != goal_position.x or goal_position.y != goal_position.y:
		return
	
	if goal_velocity.x != goal_velocity.x or goal_velocity.y != goal_velocity.y:
		return
	
	# TODO: enforce atleast some kind of security constraints
	# based on known info: player speed stats and timing
	position = goal_position
	velocity = goal_velocity

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
	
	#if not multiplayer.is_server():
		#if last_walking_direction != direction:
			#rpc_walk.rpc_id(1, direction)
			#last_walking_direction = direction
	#else:
	if direction == Vector2.ZERO:
		velocity = Vector2.ZERO
	else:
		velocity = direction * BASE_SPEED_MULTIPLIER * speed

func _process (delta):
	if multiplayer.is_server():
		last_fire_time += delta
		
		if is_attacking and last_fire_time >= 1 / fire_rate:
			spawn_projectile()
			last_fire_time = 0
	
	health_bar.set_health_percent((health * 1.0) / max_health)
	
	move_and_slide()

func _on_death():
	if multiplayer.is_server():
		attack_to(Vector2.ZERO)
		walk_to(Vector2.ZERO)
	
	if despawn_on_death:
		get_tree().create_timer(ENTITY_DESPAWN_DELAY).timeout.connect(queue_free)

func _enter_tree():
	if multiplayer.is_server():
		entity_id = Entity.entity_id_track
		Entity.entity_registry[entity_id] = self
		Entity.entity_id_track += 1
	else:
		# id was already set by server, just store it
		Entity.entity_registry[entity_id] = self

func _exit_tree():
	entity_id = -1
	Entity.entity_registry.erase(entity_id)
