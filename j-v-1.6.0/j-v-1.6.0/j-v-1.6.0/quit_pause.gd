extends Button

var texto_original := "Quit"

func _ready():
	text = texto_original

func _on_mouse_entered():
	text = "> Quit <"

func _on_mouse_exited():
	text = texto_original
