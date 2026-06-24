extends Area2D

@onready var destino: Marker2D = $corredor

var can_tp = true

func _on_body_entered(body: Node2D) -> void:

	if !body.is_in_group("player"):
		return

	if !can_tp:
		return

	if destino == null:
		return

	can_tp = false

	var fade = get_tree().current_scene.get_node_or_null(
		"CanvasLayer/Fade"
	)

	if fade:
		fade.hide()

	body.global_position = destino.global_position

	# espera o player terminar de ser teleportado
	await get_tree().create_timer(2.0).timeout

	Saves.dados["posicao_x"] = body.global_position.x
	Saves.dados["posicao_y"] = body.global_position.y

	Saves.dados["cena"] = (
		get_tree().current_scene.scene_file_path
	)
	
	print("SALVANDO POSIÇÃO:")
	print(body.global_position)

	Saves.dados["posicao_x"] = body.global_position.x
	Saves.dados["posicao_y"] = body.global_position.y

	Saves.salvar()

	print("CHECKPOINT SALVO")

	can_tp = true
