extends Control

@onready var anim = $AnimationPlayer

func _ready() -> void:
	anim.play("intro")

	await get_tree().create_timer(3.5).timeout
	get_tree().change_scene_to_file("res://tatlescreen/tatlescreen.tscn")
