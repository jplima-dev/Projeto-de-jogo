extends Control

@onready var background = $bg
@onready var anim = $Anim

func _ready() -> void:
	await get_tree().process_frame

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.size = get_viewport_rect().size

	anim.play("fade_botões")
	Loading.tocar_menu()

func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Saves.tscn")

	
	

func _on_config_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://config.tscn")
	
	
func _on_credits_btn_2_pressed() -> void:
	get_tree().change_scene_to_file("res://creditos.tscn")
	Loading.parar_menu()

func _on_quit_btn_4_pressed() -> void:
	get_tree().quit()
