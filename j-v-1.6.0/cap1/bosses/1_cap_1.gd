extends CharacterBody2D

const PEDRA = preload("res://projetilteste.tscn")


enum Estado {
	IDLE,
	MIRANDO,
	DASH,
	TONTO,
	RETORNANDO
}


var estado = Estado.IDLE


# ==========================================================
# DASH
# ==========================================================

@export var velocidade_dash := 1200.0
@export var tempo_mira := 0.01
@export var tempo_tonto := 0.3
@export var recuo_impacto := 50.0
@export var tempo_recuo_impacto := 0.5

# Quantidade de dashes antes de voltar ao meio
@export var quantidade_dashes := 3

var dash_atual := 0



# ==========================================================
# PEDRAS
# ==========================================================

@export var quantidade_pedras := 10
@export var velocidade_pedras_min := 350.0
@export var velocidade_pedras_max := 500.0

# Tempo que cada pedra permanece viva
@export var tempo_vida_pedras := 0.3

# Abertura do leque das pedras
@export var spread_pedras := 120.0


# ==========================================================
# ROTAÇÃO
# ==========================================================

@export var offset_rotacao := 90.0

# Rotação do terceiro impacto
@export var velocidade_rotacao_retorno := 25.0

# Margem de erro ao voltar para o centro
@export var margem_retorno := 40.0

var usb = null

@export var distancia_orbita_usb := 80.0
@export var velocidade_orbita_usb := 6.0


# ==========================================================
# ATAQUE 2
# ==========================================================

@export var ataque_2_dano := 20
@export var ataque_2_tempo_preparacao := 0.5
@export var ataque_2_tempo_ativo := 1.0


# ==========================================================
# ATAQUE 3 - CHICOTE USB
# ==========================================================

@export var ataque_3_dano := 20
@export var ataque_3_velocidade := 1400.0
@export var ataque_3_distancia_maxima := 500.0
@export var ataque_3_tempo_preparacao := 0.4
@export var ataque_3_tempo_recuperacao := 0.5
@export var ataque_3_tempo_fim := 0.5

# ==========================================================
# ANIMAÇÃO DO ATAQUE 3
# ==========================================================

@export var ataque_3_tempo_carga := 0.20
@export var ataque_3_inclinacao_tras := 15.0
@export var ataque_3_inclinacao_frente := 20.0
@export var ataque_3_tempo_golpe := 10


# ==========================================================
# PLAYER
# ==========================================================

var player
var direcao := Vector2.ZERO

# Impede múltiplas colisões no mesmo dash
var bateu := false
var sentido_rotacao := 1.0


# ==========================================================
# READY
# ==========================================================

func _ready():

	player = get_tree().get_first_node_in_group("player")

	$Timer.timeout.connect(_on_timer_timeout)

	$Timer.start(2)


# ==========================================================
# PHYSICS
# ==========================================================

func _physics_process(delta):

	match estado:

		Estado.IDLE:
			velocity = Vector2.ZERO

		Estado.MIRANDO:
			velocity = Vector2.ZERO

		Estado.DASH:
			velocity = direcao * velocidade_dash

		Estado.TONTO:
			velocity = Vector2.ZERO

		Estado.RETORNANDO:
			velocity = Vector2.ZERO


	move_and_slide()


	# ======================================================
	# COLISÃO DURANTE O DASH
	# ======================================================

	if estado == Estado.DASH and !bateu:

		for i in get_slide_collision_count():

			var colisao = get_slide_collision(i)
			var corpo = colisao.get_collider()

			if corpo == null:
				continue


			# ==================================================
			# ACERTOU O PLAYER
			# ==================================================

			if corpo.is_in_group("player"):

				if corpo.has_method("take_damage"):
					corpo.take_damage(20, direcao)

				bateu = true

				velocity = Vector2.ZERO

				await acertou_player()

				return


			# ==================================================
			# BATEU NA PAREDE
			# ==================================================

			bateu = true
			
			var normal_parede: Vector2 = colisao.get_normal()

			if abs(normal_parede.x) > abs(normal_parede.y):
				# Parede lateral
				if normal_parede.x > 0:
					# Bateu na parede da esquerda
					sentido_rotacao = 1.0
				else:
					# Bateu na parede da direita
					sentido_rotacao = -1.0

			await bateu_parede()

			return


# ==========================================================
# INICIA UM DASH
# ==========================================================

func _on_timer_timeout():

	if estado != Estado.IDLE:
		return

	await iniciar_dash()

# ==========================================================
# BATEU NA PAREDE
# ==========================================================

func bateu_parede():

	estado = Estado.TONTO
	velocity = Vector2.ZERO

	print("BATEU PAREDE - DASH ", dash_atual)


	# ======================================================
	# TREMIDA DA CÂMERA
	# ======================================================

	var viewport = get_viewport()

	if viewport != null:

		var camera = viewport.get_camera_2d()

		if camera != null and camera.has_method("tremer"):
			camera.tremer(18)


	# ======================================================
	# ESPREMIDA
	# ======================================================

	var escala_original: Vector2 = scale

	var tween_impacto = create_tween()

	tween_impacto.tween_property(
		self,
		"scale",
		Vector2(1.20, 0.70),
		0.06
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	tween_impacto.tween_property(
		self,
		"scale",
		Vector2(0.90, 1.08),
		0.08
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

	tween_impacto.tween_property(
		self,
		"scale",
		escala_original,
		0.10
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)


	# ======================================================
	# PEDRAS SAEM IMEDIATAMENTE
	# ======================================================

	spawn_pedras()


	# ======================================================
	# RECUO SUAVE DOS IMPACTOS
	# ======================================================

	# O terceiro impacto não usa esse recuo,
	# pois possui o impacto_final().

	if dash_atual < quantidade_dashes:

		var destino_recuo: Vector2 = (
			global_position
			- direcao * recuo_impacto
		)

		var tween_recuo = create_tween()

		tween_recuo.tween_property(
			self,
			"global_position",
			destino_recuo,
			tempo_recuo_impacto
		).set_trans(
			Tween.TRANS_QUAD
		).set_ease(
			Tween.EASE_OUT
		)


	# ======================================================
	# 3º DASH
	# ======================================================

	if dash_atual >= quantidade_dashes:

		# Impacto final começa imediatamente.
		await impacto_final()

		# Tempo de stun depois do impacto final.
		await get_tree().create_timer(
			tempo_tonto
		).timeout

		# Escolhe ataque 2 ou 3.
		await escolher_ataque_aleatorio()

		# ==================================================
		# REINICIA O CICLO
		# ==================================================

		dash_atual = 0
		bateu = false
		estado = Estado.IDLE

		# Pequena espera antes do próximo conjunto.
		await get_tree().create_timer(2.0).timeout

		if estado == Estado.IDLE:

			await iniciar_dash()

		return


	# ======================================================
	# 1º E 2º DASH
	# ======================================================

	await tween_impacto.finished

	await get_tree().create_timer(
		tempo_tonto
	).timeout

	bateu = false
	estado = Estado.IDLE

	$Timer.start(0.2)
	
# ==========================================================
# IMPACTO FINAL DO TERCEIRO DASH
# ==========================================================

func impacto_final():

	estado = Estado.RETORNANDO

	velocity = Vector2.ZERO


	# ======================================================
	# DISTÂNCIA DO RECUO
	# ======================================================

	var distancia_recuo: float = 140.0

	var destino: Vector2 = (
		global_position - direcao * distancia_recuo
	)


	# ======================================================
	# ROTAÇÃO
	# ======================================================

	var rotacao_inicial: float = rotation


	# ======================================================
	# RECUO + ROTAÇÃO
	# ======================================================

	var tempo_recuo: float = 0.5

	var tween = create_tween()

	tween.set_parallel(true)


	# Vai um pouco para trás
	tween.tween_property(
		self,
		"global_position",
		destino,
		tempo_recuo
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)


	# Gira 3 voltas
	tween.tween_property(
		self,
		"rotation",
		rotacao_inicial + deg_to_rad(15.0) * sentido_rotacao,
		tempo_recuo
	).set_trans(
		Tween.TRANS_LINEAR
	)


	await tween.finished
	
	# ======================================================
	# VOLTA PARA A POSIÇÃO PADRÃO
	# ======================================================

	var rotacao_padrao: float = deg_to_rad(0.0)

	var tween_padrao = create_tween()

	tween_padrao.tween_property(
		self,
		"rotation",
		rotacao_padrao,
		0.10
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

	await tween_padrao.finished
	
	await get_tree().create_timer(0.08).timeout
	
			# ======================================================
	# CHACOALHADA CARTOON ANTES DO RETORNO
	# ======================================================

	var rot_original: float = rotation

	var tween_chacoalhada = create_tween()

	tween_chacoalhada.tween_property(
		self,
		"rotation",
		rot_original + deg_to_rad(34.0),
		0.05
	)

	tween_chacoalhada.tween_property(
		self,
		"rotation",
		rot_original - deg_to_rad(32.0),
		0.05
	)

	tween_chacoalhada.tween_property(
		self,
		"rotation",
		rot_original + deg_to_rad(16.0),
		0.04
	)

	tween_chacoalhada.tween_property(
		self,
		"rotation",
		rot_original - deg_to_rad(8.0),
		0.04
	)

	tween_chacoalhada.tween_property(
		self,
		"rotation",
		rot_original,
		0.08
	)

	await tween_chacoalhada.finished

	# Pequena pausa antes de sair voando
	await get_tree().create_timer(0.08).timeout


	# ======================================================
	# FREIADA CARTOON
	# ======================================================

	var tween_final = create_tween()

	tween_final.tween_property(
		self,
		"rotation",
		rotacao_inicial,
		0.15
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

	await tween_final.finished
	
# ==========================================================
# PEDRAS
# ==========================================================

func spawn_pedras():

	var angulo_base: float = direcao.angle() + PI

	# Spread controlado pelo Inspector

	var abertura: float = deg_to_rad(spread_pedras)


	for i in range(quantidade_pedras):

		var pedra = PEDRA.instantiate()

		get_tree().current_scene.add_child(pedra)


		# Nasce um pouco atrás do mouse,
		# na direção oposta ao dash.

		pedra.global_position = (
			global_position + direcao * 20.0
		)


		# ==================================================
		# POSIÇÃO DA PEDRA NO LEQUE
		# ==================================================

		var t: float

		if quantidade_pedras > 1:

			t = float(i) / float(quantidade_pedras - 1)

		else:

			t = 0.5


		var angulo: float = lerp(
			-abertura / 2.0,
			abertura / 2.0,
			t
		)


		pedra.direction = Vector2.RIGHT.rotated(
			angulo_base + angulo
		)


		# ==================================================
		# VELOCIDADE
		# ==================================================

		pedra.speed = randf_range(
			velocidade_pedras_min,
			velocidade_pedras_max
		)

		pedra.life_time = tempo_vida_pedras
		pedra.teleguiado = false

		pedra.iniciar_vida()


		# ==================================================
		# TEMPO DE VIDA
		# ==================================================

		pedra.life_time = tempo_vida_pedras


		pedra.teleguiado = false


# ==========================================================
# ACERTOU O PLAYER
# ==========================================================

func acertou_player():

	estado = Estado.TONTO

	velocity = Vector2.ZERO


	# ======================================================
	# TREMIDA DA CÂMERA
	# ======================================================

	var viewport = get_viewport()
	
	if viewport != null:
		var camera = viewport.get_camera_2d()

		if camera != null and camera.has_method("tremer"):
			camera.tremer(18)


	# ======================================================
	# PEQUENA BALANÇADA DO MOUSE
	# ======================================================

	var rot_original: float = rotation


	var tween = create_tween()

	tween.tween_property(
		self,
		"rotation",
		rot_original + deg_to_rad(
			randf_range(-10.0, 10.0)
		),
		0.05
	)

	await tween.finished


	var tween2 = create_tween()

	tween2.tween_property(
		self,
		"rotation",
		rot_original,
		0.08
	)

	await tween2.finished


	# Não cria pedras quando acerta o player.

	await get_tree().create_timer(
		tempo_tonto
	).timeout


	estado = Estado.IDLE

	bateu = false


	# O dash que acertou o player também conta.

	if dash_atual >= quantidade_dashes:

		dash_atual = 0


	$Timer.start(0.2)
	
func iniciar_dash():

	if !is_instance_valid(player):
		return

	bateu = false

	if dash_atual >= quantidade_dashes:
		dash_atual = 0

	dash_atual += 1

	estado = Estado.MIRANDO

	direcao = (
		player.global_position - global_position
	).normalized()

	# ======================================================
	# RECUO / ESTICADA
	# ======================================================

	var pos_original: Vector2 = global_position

	var tween = create_tween()

	tween.tween_property(
		self,
		"scale",
		Vector2(1.0, 1.0),
		tempo_mira * 0.35
	)

	await tween.finished

	# ======================================================
	# IMPULSO
	# ======================================================

	var tween2 = create_tween()

	tween2.set_parallel(true)

	tween2.tween_property(
		self,
		"global_position",
		pos_original,
		tempo_mira * 0.20
	)

	tween2.tween_property(
		self,
		"scale",
		Vector2(1.0, 0.90),
		tempo_mira * 0.20
	)

	await tween2.finished

	# ======================================================
	# VOLTA AO NORMAL
	# ======================================================

	var tween3 = create_tween()

	tween3.tween_property(
		self,
		"scale",
		Vector2.ONE,
		tempo_mira * 0.15
	)

	await tween3.finished

	estado = Estado.DASH


# ==========================================================
# ATAQUE 2
# ==========================================================

func ataque_2():

	# Vazio por enquanto.
	# A implementação será feita depois.

	pass


# ==========================================================
# ATAQUE 3
# ==========================================================

func ataque_3():

	if !is_instance_valid(player):
		return

	var rotacao_original: float = rotation


	# ======================================================
	# DESCOBRE DE QUE LADO O PLAYER ESTÁ
	# ======================================================

	var diferenca_x: float = (
		player.global_position.x
		- global_position.x
	)

	var inclinacao: float = 0.0


	# Player à direita -> inclina para a esquerda
	if diferenca_x > 0.0:

		inclinacao = -15.0


	# Player à esquerda -> inclina para a direita
	elif diferenca_x < 0.0:

		inclinacao = 15.0


	# ======================================================
	# CARREGA O GOLPE
	# ======================================================

	var tween_carga = create_tween()

	tween_carga.tween_property(
		self,
		"rotation",
		rotacao_original
		+ deg_to_rad(inclinacao),
		0.15
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	await tween_carga.finished


	# ======================================================
	# DIREÇÃO DO CHICOTE
	# ======================================================
	#
	# O boss calcula a direção do player neste momento.
	# A ponta recebe essa direção.
	#

	var direcao_chicote: Vector2 = (
		player.global_position
		- global_position
	).normalized()


	# ======================================================
	# INICIA O CHICOTE
	# ======================================================

	var usb = get_tree().get_first_node_in_group("usb")

	if is_instance_valid(usb):

		if usb.has_method("iniciar_chicote"):

			usb.iniciar_chicote(
				player,
				direcao_chicote
			)


	# ======================================================
	# GOLPE PARA FRENTE
	# ======================================================

	var tween_golpe = create_tween()

	tween_golpe.tween_property(
		self,
		"rotation",
		rotacao_original
		- deg_to_rad(inclinacao),
		0.08
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

	await tween_golpe.finished


	# ======================================================
	# VOLTA AO NORMAL
	# ======================================================

	var tween_retorno = create_tween()

	tween_retorno.tween_property(
		self,
		"rotation",
		rotacao_original,
		0.15
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	await tween_retorno.finished


	# ======================================================
	# TEMPO EXTRA NO ATAQUE
	# ======================================================
	#
	# Dá tempo para a ponta do cabo voltar para perto
	# do mouse antes de liberar o próximo ciclo.
	#

	await get_tree().create_timer(
		ataque_3_tempo_fim
	).timeout


	# ======================================================
	# FINAL DO ATAQUE
	# ======================================================

	estado = Estado.IDLE
	
func escolher_ataque_aleatorio():

	if !is_instance_valid(player):
		return

	var ataque := 3

	print("Ataque escolhido: ", ataque)

	match ataque:

		2:
			await ataque_2()

		3:
			await ataque_3()
