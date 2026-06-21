extends Node2D

@onready var label: Label = $Label

func iniciar(texto: String, alvo: Node2D):

	label.text = texto

	randomize()

	# posição aleatória ao redor do alvo
	global_position = alvo.global_position + Vector2(
		randf_range(-60, 60),
		randf_range(-35, 35)
	)

	scale = Vector2(0.8, 0.8)
	modulate.a = 0.0

	var tween = create_tween()

	tween.parallel().tween_property(
		self,
		"modulate:a",
		1.0,
		0.08
	)

	tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ONE,
		0.12
	)

	tween.tween_property(
		self,
		"position:y",
		position.y - 45,
		1.5
	)

	tween.parallel().tween_property(
		self,
		"modulate:a",
		0.0,
		1.5
	)

	await tween.finished

	queue_free()
