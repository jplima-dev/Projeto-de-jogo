extends Control

signal resume_requested

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("resume_requested")

func _on_resume_pressed():
	emit_signal("resume_requested")
	hide()


func _on_quit_pressed() -> void:

	var player = get_tree().get_first_node_in_group("player")

	if player:
		Saves.salvar_jogo(player)

	get_tree().paused = false
	get_tree().change_scene_to_file("res://tatlescreen/tatlescreen.tscn")


func _on_config_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://config.tscn")
