extends Node2D

# =========================
# CENAS
# =========================
var player_scene = preload("res://leandro.tscn")
var sala_scene = preload("res://cenario.tscn")

# =========================
# NÓS
# =========================
var player: CharacterBody2D
var sala


# =========================
# READY
# =========================
func _ready():

	# =====================
	# CONFIGURA FADE
	# =====================
	$Fade.z_index = 999
	$Fade.modulate.a = 1.0

	# =====================
	# CARREGA O CENÁRIO
	# =====================
	sala = sala_scene.instantiate()
	add_child(sala)

	# =====================
	# CARREGA O PLAYER
	# =====================
	var player_container = player_scene.instantiate()
	add_child(player_container)

	player = player_container.get_node("leandro")

	# posição inicial
	player.global_position = Vector2(500, 300)

	# impede movimentação
	player.pode_mexer = false

	# espera 1 frame
	await get_tree().process_frame

	# começa cutscene
	await start_cutscene()


# =========================
# CUTSCENE
# =========================
func start_cutscene():

	# =====================
	# FADE IN
	# =====================

	var tween = create_tween()

	tween.tween_property(
		$Fade,
		"modulate:a",
		0.0,
		3.0
	)

	await tween.finished


	# =====================
	# PROFESSOR FALANDO
	# =====================

	print("Professor: turma, prestem atenção...")

	await get_tree().create_timer(2.0).timeout

	print("Professor: hoje vamos aprender programação...")

	await get_tree().create_timer(2.0).timeout

	print("Professor: programação pode mudar vidas...")

	await get_tree().create_timer(2.0).timeout


	# =====================
	# LUZ PISCANDO
	# =====================

	for i in range(3):

		$Fade.modulate.a = 0.7
		await get_tree().create_timer(0.08).timeout

		$Fade.modulate.a = 0.0
		await get_tree().create_timer(0.08).timeout


	# =====================
	# APAGÃO TOTAL
	# =====================

	$Fade.modulate.a = 1.0

	print("...")

	await get_tree().create_timer(2.0).timeout


	# =====================
	# SOM ESTRANHO
	# =====================

	print("Algo caiu na sala...")

	await get_tree().create_timer(1.5).timeout


	# =====================
	# VOLTA DA VISÃO
	# =====================

	var tween2 = create_tween()

	tween2.tween_property(
		$Fade,
		"modulate:a",
		0.0,
		2.0
	)

	await tween2.finished


	# =====================
	# LIBERA PLAYER
	# =====================

	player.pode_mexer = true

	print("Gameplay começou")
