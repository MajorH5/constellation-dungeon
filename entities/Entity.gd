class_name Entity
extends CharacterBody2D

const BASE_SPEED_MULTIPLIER = 13

@export_group("Combat Stats")
@export var health: int = 100
@export var attack: int = 1
@export var speed: int = 5
@export var vitality: int = 1

@export_group("Attributes")
@export var hostile: bool = false

var is_attacking: bool = false
var attack_direction: Vector2 = Vector2.ZERO

