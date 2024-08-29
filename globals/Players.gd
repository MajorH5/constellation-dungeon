class_name Players
extends Node

static var registry: Dictionary = {}

static func register_player(pid: int, player: Player) -> void:
	Players.registry[pid] = player

static func unregister_player (pid: int) -> void:
	Players.registry.erase(pid)

static func get_all() -> Array[Player]:
	var players: Array[Player] = []
	
	for pid in Players.registry:
		players.push_back(Players.registry[pid])
	
	return players

static func get_player(pid: int) -> Player:
	return Players.registry.get(pid)

static func get_nearby(position: Vector2, min_distance: int = 200) -> Array[Player]:
	var players = Players.get_all()
	var eligible: Array[Player] = []
	
	for player in players:
		if player.position.distance_to(position) <= min_distance:
			eligible.push_back(player)
	
	return eligible
