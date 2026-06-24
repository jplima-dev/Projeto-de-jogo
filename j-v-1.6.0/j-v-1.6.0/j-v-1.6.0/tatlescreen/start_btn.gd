extends Button

var texto_original := "Start"

func _ready():
	text = texto_original

func _on_mouse_entered():
	text = "> Start <"

func _on_mouse_exited():
	text = texto_original
