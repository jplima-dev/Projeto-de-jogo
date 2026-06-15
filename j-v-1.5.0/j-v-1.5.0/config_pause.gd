extends Button

var texto_original := "Configurations"

func _ready():
	text = texto_original

func _on_mouse_entered():
	text = "> Configurations <"

func _on_mouse_exited():
	text = texto_original
