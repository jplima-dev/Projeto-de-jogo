extends Area2D

@onready var destino: Marker2D = $corredor

var can_tp = true

func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group("player") and can_tp and destino:

		can_tp = false

		var fade = get_tree().current_scene.get_node_or_null("CanvasLayer/Fade")

		if fade:
			fade.hide()

		body.global_position = destino.global_position

		# espera 2 segundos
		await get_tree().create_timer(2.0).timeout

		# salva posição
		Saves.dados["posicao_x"] = body.global_position.x
		Saves.dados["posicao_y"] = body.global_position.y

		# salva cena atual
		Saves.dados["cena"] = get_tree().current_scene.scene_file_path

		Saves.salvar()

		print("CHECKPOINT SALVO")

		can_tp = true
