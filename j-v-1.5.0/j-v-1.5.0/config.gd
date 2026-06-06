extends Control

@onready var anim = $Anim

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("fade_botões")


func _on_controls_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://teclado.tscn")


func _on_audio_btn_pressed() -> void:
	pass # Replace with function body.


func _on_video_btn_2_pressed() -> void:
	get_tree().change_scene_to_file("res://videos.tscn")


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://tatlescreen/tatlescreen.tscn")
