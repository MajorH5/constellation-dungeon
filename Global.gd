extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	var experience = 0
	var skill_points = 0
	var health = 100
	var attack = 10
	var dexterity = 10
	var speed = 10
	
	var skill_unlocks = {"Base": true,
		"Speed1": false, "Speed2": false, "Speed3": false,
		"Health1": false, "Health2": false, "Health3": false,
		"Attack1": false, "Attack2": false, "Attack3": false,
		"Radiant": false, "Restoration": false, "Reaper": false, "Icarus": false,
		"Ascendent": false}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
