extends Control

@onready var godot_splash_screen = $GodotSplashScreen
@onready var main = $Main

func _ready():
	var jam_connect: JamConnect = find_parent("Game").find_child("JamConnect")
	#jam_connect.
	#print(client_ui.client)
	godot_splash_screen.visible = true
	main.visible = true
	main.modulate = Color(1, 1, 1, 0)
	
	var controller: AnimationPlayer = godot_splash_screen.get_node("Control/Sprite2D/AnimationPlayer")
	controller.play("zoom")
	
	await get_tree().create_timer(3).timeout
	
	var fade_out = create_tween()
	fade_out.tween_property(godot_splash_screen, "modulate", Color(1, 1, 1, 0), 0.5)
	
	fade_out.play()
	
	await fade_out.finished
	
	var fade_in = create_tween()
	fade_in.tween_property(main, "modulate", Color(1, 1, 1, 1), 0.5)
	fade_in.play()
	
