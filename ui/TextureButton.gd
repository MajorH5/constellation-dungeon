extends Button

var tween: Tween
var hotbar_action: Label
@onready var texture = $TextureRect

func _ready():
	hotbar_action = get_parent().get_node("HotbarAction")

func edit_bottom_anchor(anchor_pos: float):
	texture.set_anchor(SIDE_BOTTOM, anchor_pos, true, false)
	texture.set_anchor(SIDE_TOP, anchor_pos, true, false)

func _on_mouse_entered():
	if tween != null:
		tween.stop()
	
	tween = create_tween()
	tween.tween_method(edit_bottom_anchor, texture.anchor_bottom, 0.3, 0.1)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.finished.connect(func ():
		tween = null
	)
	
	if hotbar_action != null:
		hotbar_action.text = name
	tween.play()


func _on_mouse_exited():
	if tween != null:
		tween.stop()
	
	tween = create_tween()
	tween.tween_method(edit_bottom_anchor, texture.anchor_bottom, 0.5, 0.1)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.finished.connect(func ():
		tween = null
	)
	
	if hotbar_action != null:
		hotbar_action.text = ""
	tween.play()

func _is_pos_in(checkpos:Vector2):
	var gr=get_global_rect()
	return checkpos.x>=gr.position.x and checkpos.y>=gr.position.y and checkpos.x<gr.end.x and checkpos.y<gr.end.y

func _input(event):
	if event is InputEventMouseButton and not _is_pos_in(event.position):
		release_focus()
	elif event is InputEventKey:
		release_focus()
