extends Area2D

@export var enemy_scene: PackedScene
var enemy_instance: Node2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"): # jogador precisa estar no grupo "player"
		if enemy_instance == null:
			enemy_instance = enemy_scene.instantiate()
			add_child(enemy_instance)
