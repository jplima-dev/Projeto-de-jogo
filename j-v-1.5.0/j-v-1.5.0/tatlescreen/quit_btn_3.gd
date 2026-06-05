extends Button

var texto_original := "CREDITOS"

func _ready():
	text = texto_original

func _on_mouse_entered():
	text = "> CREDITOS <"

func _on_mouse_exited():
	text = texto_original
