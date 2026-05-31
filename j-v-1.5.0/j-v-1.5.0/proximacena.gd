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

		await get_tree().create_timer(0.5).timeout

		can_tp = true
