extends CharacterBody2D


const PEDRA = preload("res://projetilteste.tscn")
const PARTICLE = preload("res://ParticleManager/Particle.tscn")
const DASH_PARTICLE = preload("res://ParticleManager/new_resource.tres")


enum Estado {
	IDLE,
	MIRANDO,
	DASH,
	TONTO,
	RETORNANDO,
	GIRANDO_USB,
	INERCIA_ATAQUE_2
}


var estado = Estado.IDLE
var segunda_fase_ativa := false


# ==========================================================
# PARTICULAS DO DASH
# ==========================================================

var tempo_proxima_particula_dash := 0.0


# ==========================================================
# DASH
# ==========================================================

@export var velocidade_dash := 1200.0
@export var tempo_mira := 0.01
@export var tempo_tonto := 0.3
@export var recuo_impacto := 50.0
@export var tempo_recuo_impacto := 0.5
@export var tempo_tonto_impacto_final := 0
@export var velocidade_atual_dash := 0.0

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
@export var tremor_parede = 28.0


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
# Tempo parado antes de começar a girar
@export var ataque_2_tempo_preparacao := 0.5
# Tempo total girando
@export var ataque_2_tempo_ativo := 3.0
# Distância entre o centro da arena e o boss
@export var ataque_2_raio := 300.0
# Velocidade do giro
@export var ataque_2_velocidade := 5.0
# Quantidade de voltas
@export var ataque_2_voltas := 3.0
# Centro da órbita
var ataque_2_centro := Vector2.ZERO
# Ângulo atual do boss na circunferência
var ataque_2_angulo := 0.0
# Indica se o ataque 2 está acontecendo
var ataque_2_ativo := false

var direcao_inercia_ataque_2: Vector2 = Vector2.ZERO


# ==========================================================
# ATAQUE 2 - DESLOCAMENTO PARA O CENTRO
# ==========================================================

var em_ataque_2_deslocando := false
var em_ataque_2_fixo := false

@export var ataque_2_tremor := 0
@export var ataque_2_velocidade_inercia := 1500.0

var velocidade_inercia_ataque_2 : Vector2 = Vector2.ZERO


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

	timer_segunda_fase()


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

			velocidade_atual_dash = move_toward(
				velocidade_atual_dash,
				velocidade_dash,
				4000.0 * delta
			)

			velocity = direcao * velocidade_atual_dash


			# ======================================================
			# PARTICULAS DO DASH
			# ======================================================

			tempo_proxima_particula_dash -= delta

			# Quanto mais rápido o boss estiver,
			# menor o intervalo entre as partículas.

			var progresso_velocidade: float = (
			velocidade_atual_dash
			/ velocidade_dash
			)

			progresso_velocidade = clamp(
			progresso_velocidade,
			0.0,
			1.0
			)

			var intervalo_particulas: float = lerp(
			0.07,
			0.025,
			progresso_velocidade
			)

			if tempo_proxima_particula_dash <= 0.0:

				var particle = PARTICLE.instantiate()

				if particle != null:

					get_tree().current_scene.add_child(
					particle
					)


					# ==============================================
					# POSIÇÃO ATRÁS DO BOSS
					# ==============================================

					var distancia_atras: float = randf_range(
					15.0,
					30.0
					)

					var deslocamento_lateral: float = randf_range(
					-12.0,
					12.0
					)

					var direcao_lateral: Vector2 = Vector2(
					-direcao.y,
					direcao.x
					).normalized()

					particle.global_position = (
					global_position
					- direcao * distancia_atras
					+ direcao_lateral * deslocamento_lateral
					)


					# ==============================================
					# DIREÇÃO DA PARTICULA
					# ==============================================

					var direcao_particula: Vector2 = (
					-direcao
					)


					# Variação maior conforme a velocidade aumenta.

					var abertura: float = lerp(
					8.0,
					22.0,
					progresso_velocidade
					)

					direcao_particula = direcao_particula.rotated(
						deg_to_rad(
							randf_range(
								-abertura,
								abertura
							)
						)
					)


					# ==============================================
					# CRIA A PARTICULA
					# ==============================================

					particle.iniciar(
						DASH_PARTICLE,
						direcao_particula
					)


					tempo_proxima_particula_dash = (
						intervalo_particulas
					)


		Estado.TONTO:
			velocity = Vector2.ZERO

		Estado.RETORNANDO:
			velocity = Vector2.ZERO

		Estado.GIRANDO_USB:

			velocity = Vector2.ZERO

			# ==============================================
			# GIRO DO BOSS AO REDOR DA PONTA USB
			# ==============================================

			ataque_2_angulo -= (
				ataque_2_velocidade
				* delta
			)

			var nova_posicao: Vector2 = (
				ataque_2_centro
				+ Vector2.RIGHT.rotated(
					ataque_2_angulo
				)
				* ataque_2_raio
			)

			global_position = nova_posicao

			rotation = (
				ataque_2_angulo
				- PI / 2.0
			)

			return


		Estado.INERCIA_ATAQUE_2:

			# Apenas mantém a velocidade da saída do giro.
			# NÃO pode ter return aqui.
			velocity = velocidade_inercia_ataque_2


	# ======================================================
	# MOVIMENTO
	# ======================================================

	move_and_slide()


	# ======================================================
	# COLISÃO DURANTE DASH OU INÉRCIA
	# ======================================================

	if (
		estado == Estado.DASH
		or estado == Estado.INERCIA_ATAQUE_2
	) and !bateu:

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

					corpo.take_damage(
						20,
						direcao
					)

				bateu = true

				velocity = Vector2.ZERO

				await acertou_player()

				return


			# ==================================================
			# BATEU NA PAREDE
			# ==================================================

			bateu = true

			var normal_parede: Vector2 = (
				colisao.get_normal()
			)

			if abs(normal_parede.x) > abs(normal_parede.y):

				if normal_parede.x > 0:

					# Parede da esquerda
					sentido_rotacao = 1.0

				else:

					# Parede da direita
					sentido_rotacao = -1.0


			# USA A MESMA FUNÇÃO DO DASH
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

	# ======================================================
	# DESCOBRE SE O IMPACTO VEIO DA INÉRCIA DO ATAQUE 2
	# ======================================================

	var era_inercia_ataque_2: bool = (
		estado == Estado.INERCIA_ATAQUE_2
	)


	# ======================================================
	# ESTADO INICIAL DO IMPACTO
	# ======================================================

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

			camera.tremer(
				tremor_parede
			)


	# ======================================================
	# IMPACTO DA INÉRCIA DO ATAQUE 2
	# ======================================================

	if era_inercia_ataque_2:

		# Pequena pausa no impacto
		await get_tree().create_timer(
			0.10
		).timeout


		# ==================================================
		# ESPREMIDA MAIS FORTE
		# ==================================================

		var escala_original_inercia: Vector2 = scale

		var tween_inercia = create_tween()

		tween_inercia.tween_property(
			self,
			"scale",
			Vector2(1.25, 0.65),
			0.05
		).set_trans(
			Tween.TRANS_QUAD
		).set_ease(
			Tween.EASE_OUT
		)

		tween_inercia.tween_property(
			self,
			"scale",
			Vector2(0.90, 1.10),
			0.07
		).set_trans(
			Tween.TRANS_BACK
		).set_ease(
			Tween.EASE_OUT
		)

		tween_inercia.tween_property(
			self,
			"scale",
			escala_original_inercia,
			0.10
		).set_trans(
			Tween.TRANS_BACK
		).set_ease(
			Tween.EASE_OUT
		)


		# ==================================================
		# ESPERA A ANIMAÇÃO
		# ==================================================

		await tween_inercia.finished


		# ==================================================
		# GARANTE ROTAÇÃO NORMAL
		# ==================================================

		var tween_rotacao_inercia = create_tween()

		tween_rotacao_inercia.tween_property(
			self,
			"rotation",
			0.0,
			0.15
		).set_trans(
			Tween.TRANS_BACK
		).set_ease(
			Tween.EASE_OUT
		)

		await tween_rotacao_inercia.finished


		# ==================================================
		# PEQUENA CHACOALHADA
		# ==================================================

		var rotacao_inercia_original: float = rotation

		var tween_chacoalhada_inercia = create_tween()

		tween_chacoalhada_inercia.tween_property(
			self,
			"rotation",
			rotacao_inercia_original
			+ deg_to_rad(12.0),
			0.04
		)

		tween_chacoalhada_inercia.tween_property(
			self,
			"rotation",
			rotacao_inercia_original
			- deg_to_rad(10.0),
			0.04
		)

		tween_chacoalhada_inercia.tween_property(
			self,
			"rotation",
			rotacao_inercia_original,
			0.06
		)

		await tween_chacoalhada_inercia.finished


		# ==================================================
		# STUN
		# ==================================================

		await get_tree().create_timer(
			tempo_tonto
		).timeout


		# ==================================================
		# LIBERA O BOSS
		# ==================================================

		bateu = false
		estado = Estado.IDLE

		return


	# ======================================================
	# IMPACTO NORMAL
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

		await impacto_final()

		await get_tree().create_timer(
			tempo_tonto
		).timeout

		await escolher_ataque_aleatorio()


		# ==================================================
		# REINICIA O CICLO
		# ==================================================

		dash_atual = 0
		bateu = false
		estado = Estado.IDLE

		await get_tree().create_timer(
			2.0
		).timeout

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
		global_position
		- direcao * distancia_recuo
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

	tween.tween_property(
		self,
		"rotation",
		rotacao_inicial
		+ deg_to_rad(15.0)
		* sentido_rotacao,
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
		rot_original
		+ deg_to_rad(34.0),
		0.05
	)

	tween_chacoalhada.tween_property(
		self,
		"rotation",
		rot_original
		- deg_to_rad(32.0),
		0.05
	)

	tween_chacoalhada.tween_property(
		self,
		"rotation",
		rot_original
		+ deg_to_rad(16.0),
		0.04
	)

	tween_chacoalhada.tween_property(
		self,
		"rotation",
		rot_original
		- deg_to_rad(8.0),
		0.04
	)

	tween_chacoalhada.tween_property(
		self,
		"rotation",
		rot_original,
		0.08
	)

	await tween_chacoalhada.finished

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

	var abertura: float = deg_to_rad(
		spread_pedras
	)


	for i in range(quantidade_pedras):

		var pedra = PEDRA.instantiate()

		get_tree().current_scene.add_child(pedra)

		pedra.global_position = (
			global_position
			+ direcao * 20.0
		)


		# ==================================================
		# POSIÇÃO DA PEDRA NO LEQUE
		# ==================================================

		var t: float

		if quantidade_pedras > 1:

			t = float(i) / float(
				quantidade_pedras - 1
			)

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
		rot_original
		+ deg_to_rad(
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


# ==========================================================
# INICIA DASH
# ==========================================================

func iniciar_dash():

	if !is_instance_valid(player):
		return


	bateu = false


	if dash_atual >= quantidade_dashes:
		dash_atual = 0


	dash_atual += 1

	velocidade_atual_dash = 0.0

	tempo_proxima_particula_dash = 0.0


	estado = Estado.MIRANDO


	direcao = (
		player.global_position
		- global_position
	).normalized()


	# ======================================================
	# RECUO / ESTICADA
	# ======================================================

	var pos_original: Vector2 = (
		global_position
	)


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
	
	if segunda_fase_ativa:
		return

	# ======================================================
	# PROCURA A PONTA USB EXISTENTE
	# ======================================================

	var usb = get_tree().get_first_node_in_group("usb")

	if !is_instance_valid(usb):

		push_warning(
			"Ataque 2: não encontrei a pontausb no grupo 'usb'."
		)

		return


	# ======================================================
	# LIBERA A DETECÇÃO DE COLISÃO
	# ======================================================

	bateu = false


	# ======================================================
	# GUARDA APENAS A ROTAÇÃO ORIGINAL
	# ======================================================

	var rotacao_original: float = rotation


	# ======================================================
	# PEGA O CENTRO DA ARENA
	# ======================================================

	var camera: Camera2D = (
		get_viewport().get_camera_2d()
	)

	if camera == null:

		push_warning(
			"Camera2D não encontrada."
		)

		return


	var centro_arena: Vector2 = (
		camera.global_position
	)

	ataque_2_centro = centro_arena


	# ======================================================
	# PREPARAÇÃO
	# ======================================================

	estado = Estado.TONTO
	velocity = Vector2.ZERO


	# ======================================================
	# DESCOBRE DE QUE LADO O CENTRO ESTÁ
	# ======================================================

	var diferenca_x: float = (
		centro_arena.x
		- global_position.x
	)

	var inclinacao: float = 0.0


	if diferenca_x > 0.0:

		# Centro está à direita.
		# Boss inclina para trás, à esquerda.

		inclinacao = -15.0

	elif diferenca_x < 0.0:

		# Centro está à esquerda.
		# Boss inclina para trás, à direita.

		inclinacao = 15.0


	# ======================================================
	# INCLINA PARA TRÁS
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
	# LANÇA A USB PARA O CENTRO
	# ======================================================

	if is_instance_valid(usb):

		if usb.has_method("lancar_para_centro"):

			await usb.lancar_para_centro(
				centro_arena
			)

		else:

			push_warning(
				"Ataque 2: lancar_para_centro() não existe na pontausb."
			)

			return


	# ======================================================
	# GARANTE O ÂNGULO INICIAL DO GIRO
	# ======================================================

	var vetor_inicial: Vector2 = (
		global_position
		- ataque_2_centro
	)

	if vetor_inicial.length() > 0.01:

		ataque_2_angulo = (
			vetor_inicial.angle()
		)

	else:

		ataque_2_angulo = 0.0


	# ======================================================
	# AJUSTA O RAIO
	# ======================================================

	ataque_2_raio = max(
		ataque_2_raio,
		vetor_inicial.length()
	)


	# ======================================================
	# VOLTA O BOSS PARA A ROTAÇÃO NORMAL
	# ======================================================

	var tween_pre_giro = create_tween()

	tween_pre_giro.tween_property(
		self,
		"rotation",
		rotacao_original,
		0.12
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	await tween_pre_giro.finished


	# ======================================================
	# COMEÇA O GIRO
	# ======================================================

	ataque_2_ativo = true
	estado = Estado.GIRANDO_USB

	print(
		"ATAQUE 2 - GIRO USB"
	)


	# ======================================================
	# TEMPO DO GIRO
	# ======================================================

	await get_tree().create_timer(
		ataque_2_tempo_ativo
	).timeout


	# ======================================================
	# PARA O GIRO
	# ======================================================

	ataque_2_ativo = false


	if is_instance_valid(usb):

		if usb.has_method("liberar_do_centro"):

			usb.liberar_do_centro()


	# ======================================================
	# CALCULA A DIREÇÃO TANGENCIAL DA INÉRCIA
	# ======================================================

	var direcao_inercia_ataque_2: Vector2 = Vector2(
		-sin(ataque_2_angulo),
		cos(ataque_2_angulo)
	).normalized()


	# ======================================================
	# CALCULA A VELOCIDADE DE SAÍDA
	# ======================================================

	velocidade_inercia_ataque_2 = (
		direcao_inercia_ataque_2
		* ataque_2_velocidade_inercia
	)


	# ======================================================
	# SAI DO GIRO COM INÉRCIA
	# ======================================================

	estado = Estado.INERCIA_ATAQUE_2

	print(
		"ATAQUE 2 - INÉRCIA"
	)


	# ======================================================
	# ESPERA A COLISÃO COM A PAREDE
	# ======================================================

	while estado == Estado.INERCIA_ATAQUE_2:

		await get_tree().process_frame


	# ======================================================
	# ATAQUE TERMINOU
	# ======================================================

	print(
		"ATAQUE 2 FINALIZADO"
	)


# ==========================================================
# ATAQUE 3
# ==========================================================

func ataque_3():
	
	if segunda_fase_ativa:
		return

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

		inclinacao = -35.0


	# Player à esquerda -> inclina para a direita
	elif diferenca_x < 0.0:

		inclinacao = 35.0


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

	await get_tree().create_timer(
		ataque_3_tempo_fim
	).timeout


	# ======================================================
	# FINAL DO ATAQUE
	# ======================================================

	estado = Estado.IDLE


# ==========================================================
# ESCOLHE ATAQUE
# ==========================================================

func escolher_ataque_aleatorio():

	if !is_instance_valid(player):
		return

	if segunda_fase_ativa:
		return

	var ataque := randi_range(2, 3)

	print(
		"Ataque escolhido: ",
		ataque
	)

	match ataque:

		2:
			await ataque_2()

		3:
			await ataque_3()


# ==========================================================
# SEGUNDA FASE
# ==========================================================

func segunda_fase():

	segunda_fase_ativa = true


	# ======================================================
	# ATRIBUTOS DA SEGUNDA FASE
	# ======================================================

	velocidade_pedras_max = 800
	tempo_vida_pedras = 0.25
	tremor_parede = 28.0

	velocidade_dash = 1500.0
	tempo_tonto = 0.1
	tempo_tonto_impacto_final = 0.6


	# ======================================================
	# PONTA USB
	# ======================================================

	var ponta_usb = get_tree().get_first_node_in_group(
		"usb"
	)

	if is_instance_valid(ponta_usb):

		var camera = get_viewport().get_camera_2d()

		if camera != null:

			var centro = camera.global_position

			if ponta_usb.has_method(
				"fixar_no_centro"
			):

				ponta_usb.fixar_no_centro(
					centro
				)


	# ======================================================
	# CABO USB
	# ======================================================

	var cabo_usb = get_tree().get_first_node_in_group(
		"cabo_usb"
	)

	if is_instance_valid(cabo_usb):

		cabo_usb.visible = false


	# ======================================================
	# TROCA SPRITE
	# ======================================================

	var novo_sprite: Texture2D = load(
		"res://cap1/bosses/boss_2.png"
	)

	if novo_sprite != null:

		$Sprite2D.texture = novo_sprite

	else:

		push_warning(
			"Não foi possível carregar boss_2.png"
		)


	print(
		"SEGUNDA FASE ATIVADA"
	)


# ==========================================================
# TIMER DA SEGUNDA FASE
# ==========================================================

func timer_segunda_fase():

	await get_tree().create_timer(
		12.0
	).timeout

	segunda_fase()
