extends CanvasLayer

func _ready():
	layer = 11
	process_mode = Node.PROCESS_MODE_ALWAYS

	$morte/Button.pressed.connect(_on_restart_pressed)


func _on_restart_pressed():

	queue_free()

	get_tree().paused = false

	get_tree().reload_current_scene()
