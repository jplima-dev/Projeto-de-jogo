extends Control

@onready var background = $bg
@onready var anim = $Anim

func _ready() -> void:
	await get_tree().process_frame

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.size = get_viewport_rect().size

	background.modulate = Color(1, 1, 1, 89.0 / 255.0)

	# anim.play("tela")


func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://carregamento.tscn")


func _on_credits_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://creditos.tscn")


func _on_quit_btn_3_pressed() -> void:
	get_tree().quit()
