extends Button

var texto_original := "SAIR"

func _ready():
	text = texto_original

func _on_mouse_entered():
	text = "> SAIR <"

func _on_mouse_exited():
	text = texto_original


func _on_pressed() -> void:
	pass # Replace with function body.
