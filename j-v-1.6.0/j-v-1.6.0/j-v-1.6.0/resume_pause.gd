extends Button

var texto_original := "Resume"

func _ready():
	text = texto_original

func _on_mouse_entered():
	text = "> Resume <"

func _on_mouse_exited():
	text = texto_original
