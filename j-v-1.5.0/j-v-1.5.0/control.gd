extends Control

func _ready():
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Button.pressed.connect(_on_restart_pressed)

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://cenario.tscn")
