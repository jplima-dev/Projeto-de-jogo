extends Button

var texto_original := "Credits"

func _ready():
	text = texto_original

func _on_mouse_entered():
	text = "> Credits <"

func _on_mouse_exited():
	text = texto_original
