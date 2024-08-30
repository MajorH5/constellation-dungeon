# Author: Habib A. 7-28-2024
# Handles ai behavior for asteroid construct entity

extends WanderAI

var trigger_radius = 50

func perform(delta: float):
	if not multiplayer.is_server() or agent.is_dead():
		return
	
	super.perform(delta)

	var nearby = get_nearby_players(trigger_radius)
		
	if len(nearby) == 0:
		wander(delta)
		agent.attack_to(Vector2.ZERO)
		return
	
	nearby.sort_custom(func (a, z):
		return a.position.distance_to(agent.position) < z.position.distance_to(agent.position)
	)
	
	var closest = nearby[0]
	var to_player = get_direction(closest.position)
	
	agent.attack_to(to_player)
	agent.walk_to(get_vector_away_from(nearby))
	
func get_vector_away_from (players: Array[Player]) -> Vector2:
	var away = Vector2.ZERO
	
	for player in players:
		away += agent.position - player.position
	
	return away.normalized()
	
