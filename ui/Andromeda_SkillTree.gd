extends Control
class_name skillUnlocks

@export var skillPoints = 0

var unlocks = {"Base": true,
		"Speed1": false, "Speed2": false, "Speed3": false,
		"Health1": false, "Health2": false, "Health3": false,
		"Attack1": false, "Attack2": false, "Attack3": false,
		"Radiant": false, "Restoration": false, "Reaper": false, "Icarus": false,
		"Ascendent": false}
		
func getSkill(num):
	return unlocks[num]
	
func setSkill(num):
	return unlocks[num]

func skillStatus(num):
	return unlocks[num]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
	#Set Opacity for skill links	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
	
