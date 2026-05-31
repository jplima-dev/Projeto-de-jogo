extends Control

@onready var background = $bg


func _ready() -> void:
	await get_tree().process_frame

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.size = get_viewport_rect().size


func _process(delta: float) -> void:
	pass


func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://carregamento.tscn")


func _on_credits_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://creditos.tscn")


func _on_quit_btn_3_pressed() -> void:
	get_tree().quit()
