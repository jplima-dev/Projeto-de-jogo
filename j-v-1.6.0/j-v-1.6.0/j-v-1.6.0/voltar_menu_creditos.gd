extends Button

var texto_original := "Back"

func _ready():
	text = texto_original


func _pressed() -> void:
	get_tree().change_scene_to_file("res://tatlescreen/tatlescreen.tscn")


func _on_mouse_entered():
	text = "> Back <"


func _on_mouse_exited() -> void:
	text = texto_original
