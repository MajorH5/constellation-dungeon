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
const chest_scn = preload("res://objects/Chest.tscn")

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
@export var drop_data: Array[ItemDropData] = []
@export var skill_point_drop_min: int = 1
@export var skill_point_drop_max: int = 1
@export var invulnerable: bool = false

@export_group("Sound Effects")
@export var on_hit: AudioStreamPlayer = null
@export var on_death: AudioStreamPlayer = null

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
		
	# dont need this in degrees but helps with visualization...
	
	var total_projectiles = projectile_data.amount
	
	for i in range(total_projectiles):
		var projectile = projectile_scn.instantiate()
		
		var emission_angle = (i - (total_projectiles / 2)) * deg_to_rad(projectile_data.spread) + atan2(attack_direction.y, attack_direction.x)
		var emission_direction = Vector2(cos(emission_angle), sin(emission_angle))
		
		var radians = atan2(-emission_direction.y, emission_direction.x)
		var degrees = floori(rad_to_deg(radians) + 360) % 360
		
		projectile.linear_velocity = emission_direction * projectile_data.speed * Projectile.BASE_PROJECTILE_SPEED
		projectile.damage = get_projectile_damage()
		projectile.rotation_degrees = 45 - degrees
		projectile.from_player = not hostile
		projectile.lifetime = projectile_data.lifetime
		projectile.sender = entity_id
		projectile.position = position + emission_direction * projectile_data.spawn_distance
		
		#TODO: uhm how to do this bruh? jank boxes for now
		#projectile.hitbox.shape = ????
		
		get_parent().get_parent().add_child(projectile)

func get_projectile_damage() -> int:
	return base_damage

func damage(amount: int, source: Variant) -> bool:
	# damages the entity by the given amount
	# and returns ture if successfull
	if is_dead() or amount != amount or invulnerable:
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
func register_projectile_hit(sender_id: int):
	if sender_id != sender_id:
		return
		
	var sender = Entity.entity_registry.get(sender_id)
	
	if sender == null:
		return
	
	if multiplayer.get_remote_sender_id() != sender.owner_id:
		return
	
	damage(sender.get_projectile_damage(), sender)

@rpc("any_peer")
func register_self_hit(attacker_id: int):
	if multiplayer.get_remote_sender_id() != owner_id:
		print("rsh fail 1")
		return
	
	if attacker_id != attacker_id:
		print("rsh fail 2")
		return
	
	var attacker = Entity.entity_registry.get(attacker_id)
	
	if attacker == null:
		print("rsh fail 3")
		return
	
	damage(attacker.get_projectile_damage(), attacker)

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
	if not multiplayer.is_server():
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
	
		if len(drop_data) > 0:
			var dropped_items = []
			
			for item_drop in drop_data:
				var min_drop = item_drop.min_possible_drop_amount
				var max_drop = item_drop.max_possible_drop_amount
				
				var item = item_drop.item.instantiate()
				item.quantity = 0
				
				for i in range(min_drop, max_drop + 1):
					if randf() * 100 <= item_drop.drop_chance:
						item.quantity += 1
				
				if item.quantity > 0:
					dropped_items.push_back(item)

			var total_chests = ceili(len(dropped_items) / 15.0) # divide into chest size
			
			for i in range(total_chests):
				var offset = Vector2(randf() * 8, randf() * 8 + 5) if i > 0 else Vector2(0, 5)
				
				var chest = chest_scn.instantiate()
				chest.type = floori(randf() * 4)
				chest.position = position + offset
				
				var start = 15 * i
				var stop = min(start + 15, len(dropped_items))
				
				for j in range(start, stop):
					chest.set_slot(j % 15, dropped_items[j])
				
				get_parent().add_child(chest)
	
	if despawn_on_death:
		get_tree().create_timer(ENTITY_DESPAWN_DELAY).timeout.connect(queue_free)
		
	if hostile:
		var skp_drop = randi_range(skill_point_drop_min, skill_point_drop_max)
		var nearby = Players.get_nearby(position)
		
		for player in nearby:
			player.earn_skp(skp_drop)

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
