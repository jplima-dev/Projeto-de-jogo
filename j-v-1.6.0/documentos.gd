extends CanvasLayer

@onready var texto = $TextureRect/RichTextLabel


func _ready():

	hide()


func abrir(caminho:String):

	if !FileAccess.file_exists(caminho):

		push_error("Documento não encontrado: " + caminho)
		return

	var file = FileAccess.open(caminho, FileAccess.READ)

	texto.text = file.get_as_text()

	show()


func _input(event):

	if !visible:
		return

	if event.is_action_pressed("ui_cancel"):

		get_viewport().set_input_as_handled()

		queue_free()

	elif event.is_action_pressed("ui_accept"):

		get_viewport().set_input_as_handled()

		queue_free()
