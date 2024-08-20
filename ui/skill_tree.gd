extends Control

const TREE_DEFAULT_POS = Vector2.ZERO
const TREE_CONTAINER_POS = Vector2(-262, 0)

@onready var tree = $tree

@onready var unlocks = {$btn_attack_1: true,
		$btn_attack_1/btn_speed_1: false, "Speed2": false, "Speed3": false,
		"Health1": false, "Health2": false, "Health3": false,
		"Attack1": false, "Attack2": false, "Attack3": false,
		"Radiant": false, "Restoration": false, "Reaper": false, "Icarus": false,
		"Ascendent": false}

var tree_dict

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func show_unlocked():
	$btn_attack_1

func open_tree():
	tree.position = TREE_DEFAULT_POS
	tree.visible = true
	visible = false

func close():
	tree.visible = false
	visible = false
