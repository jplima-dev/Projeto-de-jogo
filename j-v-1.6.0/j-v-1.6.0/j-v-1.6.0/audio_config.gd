extends Button

var texto_original := "Audio"

func _ready():
	text = texto_original

func _on_mouse_entered():
	text = "> Audio <"

func _on_mouse_exited():
	text = texto_original
