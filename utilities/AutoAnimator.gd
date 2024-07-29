# Author: Habib A. 7-27-2024
# utility tool for automatically creating entity
# animations for a sprite
@tool
extends Node

@export var choose_sprite_to_animate: AnimatedSprite2D:
	set(node):
		create_animations(node)
@export var choose_texture_to_use: Texture

@export var sprite_size = Vector2(16, 16)
@export var attack_frames: int = 2
@export var walk_frames: int = 2
@export var idle_frames: int = 1
@export var death_frames: int = 5
@export var use_death_anim_timing: bool = true

const ACTIONS = ["idle", "walk", "attack"]
const DIRECTIONS = ["east", "west", "south", "north"]
const DEATH_ANIM_TIMING = [5, 3, 3, 1.3, 5]

func get_animation_length(action: String) -> int:
	match action:
		"idle":
			return idle_frames
		"attack":
			return attack_frames
		"walk":
			return walk_frames
		"death":
			return death_frames
	
	return 0

func create_animations(sprite: AnimatedSprite2D):
	if choose_texture_to_use == null:
		push_warning("[AutoAnimator]: Please select a texture before choosing a AnimatedSprite2D node to animate.")
		return
	
	var texture: Texture = choose_texture_to_use
	var frames = SpriteFrames.new()
	frames.remove_animation("default")
	
	# first create all directional animations
	# for each specific action
	for i in range(DIRECTIONS.size()):
		var total_frames = 0
		var direction = DIRECTIONS[i]
		
		for action in ACTIONS:
			var animation_name = "%s_%s" % [action, direction]
			frames.add_animation(animation_name)
			frames.set_animation_loop(animation_name, true)
			
			if action == "walk":
				frames.set_animation_speed(animation_name, 7)
			elif action == "attack":
				frames.set_animation_speed(animation_name, 1)
			
			var animation_length = get_animation_length(action)
			
			for j in range(animation_length):
				var anim_coords = Vector2(total_frames + j, i)
				var frame = AtlasTexture.new()
				
				frame.atlas = texture
				frame.region = Rect2(anim_coords * sprite_size, sprite_size)
				frames.add_frame(animation_name, frame)
			
			total_frames += animation_length
	
	sprite.sprite_frames = frames
	
	# now create death animation separately
	# since it only has one direction
	
	frames.add_animation("death")
	frames.set_animation_loop("death", false)
	
	for i in range(death_frames):
		# skip over all default anims; death is always 5th
		var death_anim_coords = Vector2(i, len(DIRECTIONS))
		var frame = AtlasTexture.new()
		var frame_duration = 1
		
		if use_death_anim_timing and i < len(DEATH_ANIM_TIMING):
			frame_duration = DEATH_ANIM_TIMING[i]
		
		frame.atlas = texture
		frame.region = Rect2(death_anim_coords * sprite_size, sprite_size)
		frames.add_frame("death", frame, frame_duration)
	
	print("[AutoAnimator]: Successfully created default animations for sprite!")
