extends Node2D

# =========================
# CENAS
# =========================
var player_scene = preload("res://leandro2.tscn")
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

	print("CUTSCENE READY")

	# =====================
	# CONFIGURA FADE
	# =====================
	$CanvasLayer/Fade.z_index = 999
	$CanvasLayer/Fade.modulate.a = 1.0

	# =====================
	# CARREGA O CENÁRIO
	# =====================
	sala = sala_scene.instantiate()
	add_child(sala)

	print("CENÁRIO CARREGADO")

	# =====================
	# PEGA O PLAYER SPAWN
	# =====================
	var spawn = sala.get_node("PlayerSpawn")

	# =====================
	# CARREGA O PLAYER
	# =====================
	player = player_scene.instantiate()

	add_child(player)

	print("PLAYER:", player)
	print("SCRIPT PLAYER:", player.get_script())

	# =====================
	# POSIÇÃO INICIAL
	# =====================
	player.global_position = spawn.global_position

	# =====================
	# TRAVA MOVIMENTO
	# =====================
	player.pode_mexer = false

	# espera 1 frame
	await get_tree().process_frame

	# começa cutscene
	await start_cutscene()


# =========================
# CUTSCENE
# =========================
func start_cutscene():

	print("CUTSCENE INICIADA")

	# =====================
	# FADE IN
	# =====================
	var tween = create_tween()

	tween.tween_property(
		$CanvasLayer/Fade,
		"modulate:a",
		0.0,
		3.0
	)

	await tween.finished

	print("FADE FINALIZADO")

	# =====================
	# PROFESSOR FALANDO
	# =====================
	print("Professor: turma, prestem atenção...")

	await get_tree().create_timer(0.0).timeout

	print("Professor: hoje vamos aprender programação...")

	await get_tree().create_timer(0.0).timeout

	print("Professor: programação pode mudar vidas...")

	await get_tree().create_timer(0.0).timeout

	# =====================
	# LUZ PISCANDO
	# =====================
	for i in range(3):

		print("PISCANDO:", i)

		$CanvasLayer/Fade.modulate.a = 0.6
		await get_tree().create_timer(0.08).timeout

		$CanvasLayer/Fade.modulate.a = 0.0
		await get_tree().create_timer(0.08).timeout

	# =====================
	# APAGÃO TOTAL
	# =====================
	print("APAGÃO")

	$CanvasLayer/Fade.modulate.a = 0.6

	await get_tree().create_timer(3.0).timeout

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
		$CanvasLayer/Fade,
		"modulate:a",
		0.0,
		0.0
	)

	await tween2.finished

	print("VISÃO VOLTOU")

	# =====================
	# LIBERA PLAYER
	# =====================
	player.pode_mexer = true

	print("GAMEPLAY COMEÇOU")
