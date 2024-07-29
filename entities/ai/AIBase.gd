# Author: Habib A. 7-28-2024
# This class represents the base ai from which all subsequent
# ai behaviors shall inherit. it provides lots of utility functions
# for derived classes

class_name AIBase
extends Node

var agent: Entity = null

func _ready():
	var parent = get_parent()
	
	if not (parent is Entity):
		push_warning("[AIBase.ready]: AI node must be parented to a valid entity node.")
		return
	
	agent = parent

func _process (delta: float):
	if not is_logic_allowed():
		return
	
	perform(delta)

func perform (delta: float):
	# called each frame to update the agents'
	# current ai state
	pass

func is_logic_allowed():
	return multiplayer.is_server() and agent != null and not agent.is_dead()

func attack_closest_player():
	pass

func move_to_position(position: Vector2):
	pass

func get_closest_player() -> Player:
	return null
