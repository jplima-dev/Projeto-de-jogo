extends Button

var texto_original := "Keyboard"

func _ready():
	text = texto_original

func _on_mouse_entered():
	text = "> Keyboard <"

func _on_mouse_exited():
	text = texto_original
