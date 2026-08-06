extends Node2D

@onready var label: Label = $Label

func iniciar(
	texto: String,
	alvo: Node2D,
	cor: Color = Color.WHITE,
	tamanho_fonte: int = 16,
	tempo: float = 1.0,
	opacidade: float = 1.0,
	offset: Vector2 = Vector2(60, 35)
):

	label.text = texto
	label.add_theme_font_size_override("font_size", tamanho_fonte)
	label.modulate = cor

	randomize()

	# posição aleatória ao redor do alvo
	global_position = alvo.global_position + Vector2(
		randf_range(-offset.x, offset.x),
		randf_range(-offset.y, offset.y)
	)

	scale = Vector2(0.8, 0.8)
	modulate.a = 0.0

	var tween = create_tween()

	# Aparece
	tween.parallel().tween_property(
		self,
		"modulate:a",
		opacidade,
		0.08
	)

	tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ONE,
		0.12
	)

	# Sobe
	tween.tween_property(
		self,
		"position:y",
		position.y - 45,
		tempo
	)

	# Desaparece
	tween.parallel().tween_property(
		self,
		"modulate:a",
		0.0,
		tempo
	)

	await tween.finished
	queue_free()
