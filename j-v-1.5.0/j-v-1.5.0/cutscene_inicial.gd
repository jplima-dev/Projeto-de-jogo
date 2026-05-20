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

@onready var dialogue_box = $CanvasLayer/DialogueBox
@onready var dialogue_label = $CanvasLayer/DialogueBox/Panel/MarginContainer/Label


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

	dialogue_box.visible = false

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
# SISTEMA DE FALA
# =========================
func falar(texto: String, tempo := 2.0):

	dialogue_box.visible = true
	dialogue_label.text = texto

	await get_tree().create_timer(tempo).timeout

	dialogue_box.visible = false


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
	await falar("Leandro: Bom dia crianças!...", 3.0)

	await falar("Leandro: Hoje vamos ter uma aula de POO...", 3.5)

	await falar("Leandro: O POO, programação orientada a objeto...", 1.5)

	# =====================
	# LUZ PISCANDO
	# =====================
	for i in range(3):

		print("PISCANDO:", i)

		$CanvasLayer/Fade.modulate.a = 0.6
		await get_tree().create_timer(0.08).timeout

		if i < 2:
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
	await falar("Algo caiu na sala...", 1.5)
	
	await falar ("(Leandro: Preciso Descobrir oque foi isso...)")

	# =====================
	# LIBERA PLAYER
	# =====================
	player.pode_mexer = true

	print("GAMEPLAY COMEÇOU")
