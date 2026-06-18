extends Node2D

# =========================
# CENAS
# =========================
var player_scene = preload("res://leandro2.tscn")
var sala_scene = preload("res://cenario.tscn")
var dialogo_scene = preload("res://dialogo.tscn")

# =========================
# NÓS
# =========================
var player: CharacterBody2D
var sala

# =========================
# MARKERS
# =========================
@onready var pc_leandro = $pcleandro
@onready var lousa = $lousa


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
	# CARREGA O PLAYER
	# =====================
	player = player_scene.instantiate()
	add_child(player)

	print("PLAYER:", player)
	print("SCRIPT PLAYER:", player.get_script())

	# =====================
	# ESCONDE HUD
	# =====================
	player.get_node("HUD").visible = false

	# =====================
	# TRAVA MOVIMENTO
	# =====================
	player.pode_mexer = false

	player.get_node("Sprite2D").visible = true
	player.get_node("AnimatedSprite2D").visible = false

	# =====================
	# VERIFICA SE É UM SAVE
	# =====================

	if Saves.dados["cutscene_feita"]:

		player.global_position = Vector2(
			Saves.dados["posicao_x"],
			Saves.dados["posicao_y"]
		)

		player.get_node("HUD").visible = true
		player.pode_mexer = true

		# Faz o fade ao carregar um save
		var tween = create_tween()

		tween.tween_property(
			$CanvasLayer/Fade,
			"modulate:a",
			0.0,
			1.0
		)

		await tween.finished

		print("SAVE CARREGADO")

		return

	# =====================
	# PRIMEIRA VEZ
	# =====================

	player.global_position = pc_leandro.global_position

	await get_tree().process_frame

	await start_cutscene()


# =========================
# SISTEMA DE FALA
# =========================
func falar(texto: String):

	var dialogo = dialogo_scene.instantiate()

	add_child(dialogo)

	await dialogo.iniciar(
		texto,
		player.get_node("Falapos")
	)

	await dialogo.desaparecer()

	dialogo.queue_free()
	
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
	# LEANDRO NO PC
	# =====================
	await get_tree().create_timer(2.0).timeout

	# =====================
	# LEANDRO VAI PRA LOUSA
	# =====================

	# ativa modo cutscene
	player.em_cutscene = true

	# libera movimentação interna
	player.pode_mexer = true

	# pega animação
	var anim = player.get_node("AnimatedSprite2D")

	# mostra animação
	player.get_node("Sprite2D").visible = false
	anim.visible = true

	# toca animação
	anim.play("andar")

	while player.global_position.distance_to(lousa.global_position) > 5:

		var direcao = (
			lousa.global_position - player.global_position
		).normalized()

		# salva direção
		player.facing_direction = direcao

		# movimenta player
		player.velocity = direcao * 250

		# move usando physics
		player.move_and_slide()

		# flip automático
		anim.flip_h = direcao.x > 0

		await get_tree().process_frame

	# para movimento
	player.velocity = Vector2.ZERO

	# desativa modo cutscene
	player.em_cutscene = false

	# trava novamente
	player.pode_mexer = false

	# =====================
	# PARA NA LOUSA
	# =====================

	anim.stop()

	anim.visible = false
	player.get_node("Sprite2D").visible = true

	player.facing_direction = Vector2.DOWN

	# =====================
	# PROFESSOR FALANDO
	# =====================

	await falar("Good morning, kids...")

	await falar("Today we're going to have a OOP class...")

	await falar("The OOP, is a programming paradigm...")

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

	await get_tree().create_timer(2.5).timeout

	# =====================
	# SOM ESTRANHO
	# =====================

	await falar("Sometings fell in the classroom...")

	await falar("(I need to find out what that was...)")

	# =====================
	# VOLTA VISÃO
	# =====================

	var tween2 = create_tween()

	tween2.tween_property(
		$CanvasLayer/Fade,
		"modulate:a",
		0.6,
		0.6
	)

	await tween2.finished

	# =====================
	# MOSTRA HUD
	# =====================
	player.get_node("HUD").visible = true

	# =====================
	# LIBERA PLAYER
	# =====================

	player.pode_mexer = true

	print("GAMEPLAY COMEÇOU")
	
	Saves.dados["cutscene_feita"] = true
	Saves.salvar()
