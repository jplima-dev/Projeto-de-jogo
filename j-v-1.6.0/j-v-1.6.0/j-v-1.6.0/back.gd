extends Button

var texto_original := "Back"

func _ready():
	text = texto_original


func _on_mouse_entered():
	text = "> Back <"


func _on_mouse_exited() -> void:
	text = texto_original
