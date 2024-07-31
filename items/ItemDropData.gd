class_name ItemDropData
extends Resource

@export var item: PackedScene
@export var drop_chance: float = 100.0
@export_range(1, INF) var min_possible_drop_amount: int = 1
@export var max_possible_drop_amount: int = 1
