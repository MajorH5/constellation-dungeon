# Author: Habib A. 7-28-2024
# Handles ai behavior for bad omen entity

extends AIBase

var time_walking_in_direction: float = 0
var current_walk_time_limit: float = 0
var time_since_last_collision: float = 0

var max_time_walking_range: Vector2 = Vector2(0.5, 2.3)

func perform(delta: float):
	if not multiplayer.is_server():
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
