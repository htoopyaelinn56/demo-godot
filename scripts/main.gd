extends Node2D

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")

const SPAWN_POINTS: Array[Vector2] = [
	Vector2(300, 400),
	Vector2(1700, 300),
	Vector2(500, 1800),
	Vector2(1800, 1750),
]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	for pos in SPAWN_POINTS:
		var enemy := ENEMY_SCENE.instantiate()
		enemy.position = pos
		add_child(enemy)
