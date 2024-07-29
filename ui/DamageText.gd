extends Label

const MAX_LIFETIME = 0.25
const DAMAGE_TEXT_OFFSET = Vector2(0, -10)

func _ready():
	var tween = create_tween()
	
	tween.tween_property(self, "position", position + DAMAGE_TEXT_OFFSET, MAX_LIFETIME)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), MAX_LIFETIME)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(queue_free)
	
	tween.play()
