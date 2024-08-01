extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	#Set Opacity for skill nodes
	get_node("Speed_1").modulate = Color("818181")
	get_node("Speed_2").modulate = Color("818181")
	get_node("Speed_3").modulate = Color("818181")
	get_node("Health_1").modulate = Color("818181")
	get_node("Health_2").modulate = Color("818181")
	get_node("Health_3").modulate = Color("818181")
	get_node("Attack_1").modulate = Color("818181")
	get_node("Attack_2").modulate = Color("818181")
	get_node("Attack_3").modulate = Color("818181")
	get_node("Reaper").modulate = Color("818181")
	get_node("Radiant").modulate = Color("818181")
	get_node("Restoration").modulate = Color("818181")
	get_node("Icarus").modulate = Color("818181")
	get_node("Ascendency").modulate = Color("818181")
	
	#Set Opacity for skill links
	get_node("Speed1_to_Health1").modulate = Color("818181")
	get_node("Health1_to_Attack1").modulate = Color("818181")
	get_node("Attack1_to_Reaper").modulate = Color("818181")
	get_node("Health1_to_Health2").modulate = Color("818181")
	get_node("Health2_to_Health3").modulate = Color("818181")
	get_node("Health3_to_Restoration").modulate = Color("818181")
	get_node("Attack1_to_Attack2").modulate = Color("818181")
	get_node("Attack2_to_Attack3").modulate = Color("818181")
	get_node("Attack3_to_Radiant").modulate = Color("818181")
	get_node("Attack1_to_Speed2").modulate = Color("818181")
	get_node("Speed2_to_Speed3").modulate = Color("818181")
	get_node("Speed3_to_Icarus").modulate = Color("818181")
	
	#Set Opacity for skill links
	get_node("txt_Speed1").modulate = Color("818181")
	get_node("txt_Speed2").modulate = Color("818181")
	get_node("txt_Speed3").modulate = Color("818181")
	get_node("txt_Attack1").modulate = Color("818181")
	get_node("txt_Attack2").modulate = Color("818181")
	get_node("txt_Attack3").modulate = Color("818181")
	get_node("txt_Health1").modulate = Color("818181")
	get_node("txt_Health2").modulate = Color("818181")
	get_node("txt_Health3").modulate = Color("818181")
	get_node("txt_Reaper").modulate = Color("818181")
	get_node("txt_Restoration").modulate = Color("818181")
	get_node("txt_Radiant").modulate = Color("818181")
	get_node("txt_Ascendency").modulate = Color("818181")
	get_node("txt_Icarus").modulate = Color("818181")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		
	
