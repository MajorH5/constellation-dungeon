# Author: Habib A. 8-29-2024
# generic ai wandering behavior
class_name WanderAI
extends AIBase


var time_walking_in_direction: float = 0
var current_walk_time_limit: float = 0
var time_since_last_collision: float = 0
var max_time_walking_range: Vector2 = Vector2(0.5, 2.3)

@export var should_randomly_attack: bool = false
@export var wander_default: bool = false # whether or not this agent should wander by default

func perform(delta: float):
	super.perform(delta)
	
	if wander_default:
		wander(delta)

func wander(delta: float):
	if not multiplayer.is_server() or agent.is_dead():
		return
	
	super.perform(delta)
	
	if time_walking_in_direction >= current_walk_time_limit:
		var min_time = max_time_walking_range.x
		var max_time = max_time_walking_range.y
		
		var walk_direction = Vector2(
			randf() * (-1 if randf() < 0.5 else 1),
			randf() * (-1 if randf() < 0.5 else 1)
		)

		agent.walk_to(walk_direction)
		
		if should_randomly_attack:
			if randf() < 0.5:
				agent.attack_to(walk_direction)
			else:
				agent.attack_to(Vector2.ZERO)
		
		time_walking_in_direction = 0
		current_walk_time_limit = min_time + (max_time - min_time) * randf()
	else:
		time_walking_in_direction += delta
	
	if agent.get_slide_collision_count() > 0 and time_since_last_collision > 1:
		agent.velocity *= -1
		time_since_last_collision = 0
	
	time_since_last_collision += delta
