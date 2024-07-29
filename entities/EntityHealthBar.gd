# Author: Habib A. 7-28-2024
# script just for updating a healthbar that
# appears above an entity
extends ColorRect

@onready var progress: ColorRect = $Progress

func _ready():
	visible = false

func set_health_percent(percentage: float):
	visible = percentage != 0 and percentage != 1
	progress.size = Vector2(percentage * size.x, size.y)
