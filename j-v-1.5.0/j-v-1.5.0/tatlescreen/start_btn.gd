extends Button

var texto_original := "START"

func _ready():
	text = texto_original

func _on_mouse_entered():
	text = "> START <"

func _on_mouse_exited():
	text = texto_original
