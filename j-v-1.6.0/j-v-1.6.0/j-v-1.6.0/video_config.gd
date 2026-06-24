extends Button

var texto_original := "Video"

func _ready():
	text = texto_original

func _on_mouse_entered():
	text = "> Video <"

func _on_mouse_exited():
	text = texto_original
