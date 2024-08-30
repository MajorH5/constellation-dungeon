# Author: Habib A. 7-28-2024
# Handles ai behavior for bad omen entity

extends WanderAI

const CHANCE_TO_SWITCH = 0.095 # 9.5% chance to choose new target
const TELEPORT_CHANCE = 0.47
const MIN_ATTACK_TIME = 1.7
const MAX_ATTACK_TIME = 4.6

@export var attack_radius = 200
var is_teleporting = false
var teleport_timer = 0
var attack_time = 0
var target_teleport_pos = null
var time_spent_attacking = 0
var currently_chasing: Player = null
var post_teleport_time = 0
var wander_time = 0

@rpc("authority")
func client_handle_teleport():
	agent.sprite.manually_animated = true
	agent.sprite.play("death")
	
	var fade_out = create_tween()
	fade_out.tween_property(agent.sprite, "modulate", Color(1, 1, 1, 0), 1)
	
	get_tree().create_timer(3).timeout.connect(func ():
		agent.sprite.manually_animated = false
		agent.sprite.play("idle_south")
		
		var fade_in = create_tween()
		fade_in.tween_property(agent.sprite, "modulate", Color(1, 1, 1, 1), 1)
	)

func _ready ():
	super._ready()
	
	if randf() < 0.25:
		# wander on spawn
		wander_time = randi_range(1 * 100, 3 * 100) / 100
	elif randf() < 0.5:
		# attack on spawn
		pass
	else:
		# teleport on spawn
		get_new_target()
		is_teleporting = true

func perform(delta: float):
	if not multiplayer.is_server() or agent.is_dead():
		return
	
	super.perform(delta)
	
	if is_teleporting:
		handle_teleport(delta)
		return
	
	var nearby = get_nearby_players(attack_radius)
	if currently_chasing == null or not (currently_chasing in nearby):
		var target_found = get_new_target()
		
		if not target_found:
			currently_chasing = null # incase out of range
			return
		
	if currently_chasing == null:
		# no one to attack... just sit there and do nothing
		return
	
	if wander_time > 0:
		wander_time -= delta
		wander(delta)
	elif time_spent_attacking < attack_time:
		# let's attack em'!
		var to_target = get_direction(currently_chasing.position)

		time_spent_attacking += delta
		agent.attack_to(to_target)
		agent.walk_to(Vector2.ZERO)
	else:
		agent.attack_to(Vector2.ZERO)
		
		if randf() < TELEPORT_CHANCE:
			# teleport
			is_teleporting = true
		elif randf() < 0.33:
			# start attacking
			time_spent_attacking = 0
		else:
			# just wander
			wander_time = randi_range(1 * 100, 3 * 100) / 100
		
func handle_teleport(delta: float):
	if target_teleport_pos == null:
		if currently_chasing == null:
			# lost em during the intial teleport
			is_teleporting = false
			return
		
		var neg_or_pos = Vector2(
			-1 if randf() < 0.5 else 1,
			-1 if randf() < 0.5 else 1
		)
		var offset = Vector2(randf(), randf()) * neg_or_pos * 10
		target_teleport_pos = currently_chasing.position + offset
		client_handle_teleport.rpc()
		agent.walk_to(Vector2.ZERO)
		agent.invulnerable = true
	elif teleport_timer < 3:
		teleport_timer += delta
	else:
		agent.position = target_teleport_pos
		teleport_timer = 0
		target_teleport_pos = null
		is_teleporting = false
		time_spent_attacking = 0
		wander_time = randi_range(1 * 100, 3 * 100) / 100
		agent.invulnerable = false

func determine_attack_time ():
	attack_time = randi_range(MIN_ATTACK_TIME * 100, MAX_ATTACK_TIME * 100) / 100

func get_new_target() -> bool:
	var nearby = get_nearby_players(attack_radius)
	
	if len(nearby) == 0:
		return false
	
	var agent_pos = agent.position
	
	nearby.sort_custom(func (a, z):
		return a.position.distance_to(agent_pos) < z.position.distance_to(agent_pos)
	)
	
	currently_chasing = nearby[0]
	determine_attack_time()
	
	return true
