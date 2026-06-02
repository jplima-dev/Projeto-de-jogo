extends Button

var texto_original := "QUIT GAME"

func _ready():
	text = texto_original

func _on_mouse_entered():
	text = "> QUIT GAME <"

func _on_mouse_exited():
	text = texto_original
