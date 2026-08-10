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

# ==========================
# DASH
# ==========================

@export var velocidade_dash := 1200.0
@export var tempo_mira := 0.01
@export var tempo_tonto := 0.5

# Quantidade de dashes antes de voltar ao meio
@export var quantidade_dashes := 3
var dash_atual := 0

# ==========================
# PEDRAS
# ==========================

@export var quantidade_pedras := 10
@export var velocidade_pedras_min := 350.0
@export var velocidade_pedras_max := 500.0
@export var tempo_vida_pedras := 2.0

# ==========================
# ROTAÇÃO
# ==========================

@export var offset_rotacao := 90.0

# Rotação do terceiro impacto
@export var velocidade_rotacao_retorno := 25.0
@export var margem_retorno := 40.0

# ==========================
# ATAQUE 2
# ==========================

@export var ataque_2_dano := 20
@export var ataque_2_tempo_preparacao := 0.5
@export var ataque_2_tempo_ativo := 1.0

# ==========================
# ATAQUE 3
# ==========================

@export var ataque_3_dano := 20
@export var ataque_3_velocidade := 600.0
@export var ataque_3_duracao := 3.0

# ==========================
# PLAYER
# ==========================

var player
var direcao := Vector2.ZERO

# Impede múltiplas colisões no mesmo dash
var bateu := false

# Guarda a posição inicial do boss
var posicao_inicial := Vector2.ZERO


func _ready():

	player = get_tree().get_first_node_in_group("player")

	posicao_inicial = global_position

	$Timer.timeout.connect(_on_timer_timeout)

	$Timer.start(2)


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

	# ==========================
	# COLISÃO DURANTE O DASH
	# ==========================

	if estado == Estado.DASH and !bateu:

		for i in get_slide_collision_count():

			var colisao = get_slide_collision(i)
			var corpo = colisao.get_collider()

			if corpo == null:
				continue

			# ==========================
			# ACERTOU O PLAYER
			# ==========================

			if corpo.is_in_group("player"):

				if corpo.has_method("take_damage"):
					corpo.take_damage(20, direcao)

				bateu = true
				velocity = Vector2.ZERO

				await acertou_player()

				return

			# ==========================
			# BATEU NA PAREDE
			# ==========================

			bateu = true

			await bateu_parede()

			return


# ==========================================================
# INICIA UM DASH
# ==========================================================

func _on_timer_timeout():

	if estado != Estado.IDLE:
		return

	if !is_instance_valid(player):
		return

	bateu = false

	dash_atual += 1

	estado = Estado.MIRANDO

	# Mira UMA vez no player.
	# Depois disso o boss não acompanha mais o player.
	direcao = (
		player.global_position - global_position
	).normalized()

	# ==========================
	# RECUO / ESTICADA
	# ==========================

	var pos_original = global_position

	var tween = create_tween()

	# Encolhe
	tween.tween_property(
		self,
		"scale",
		Vector2(1.0, 1.0),
		tempo_mira * 0.35
	)

	await tween.finished

	# ==========================
	# IMPULSO
	# ==========================

	var tween2 = create_tween()

	tween2.set_parallel(true)

	# Volta para a posição original
	tween2.tween_property(
		self,
		"global_position",
		pos_original,
		tempo_mira * 0.20
	)

	# Dá uma leve esticada
	tween2.tween_property(
		self,
		"scale",
		Vector2(1.0, 0.90),
		tempo_mira * 0.20
	)

	await tween2.finished

	# ==========================
	# VOLTA AO NORMAL
	# ==========================

	var tween3 = create_tween()

	tween3.tween_property(
		self,
		"scale",
		Vector2.ONE,
		tempo_mira * 0.15
	)

	await tween3.finished

	# ==========================
	# DASH
	# ==========================

	estado = Estado.DASH


# ==========================================================
# BATEU NA PAREDE
# ==========================================================

func bateu_parede():

	estado = Estado.TONTO

	velocity = Vector2.ZERO

	print("BATEU PAREDE - DASH ", dash_atual)

	# ======================================================
	# 1º E 2º DASH
	# ======================================================
	# Nesses dois impactos as pedras continuam aparecendo.

	if dash_atual < quantidade_dashes:

		spawn_pedras()

	# ======================================================
	# 3º DASH
	# ======================================================
	# No terceiro impacto NÃO cria pedras.
	# O boss gira e volta para perto do centro da sala.

	else:

		await impacto_final()


	# ==========================
	# ATORDOAMENTO
	# ==========================

	await get_tree().create_timer(tempo_tonto).timeout

	# ==========================
	# FINAL DOS 3 DASHES
	# ==========================

	if dash_atual >= quantidade_dashes:

		dash_atual = 0

		estado = Estado.IDLE

		bateu = false

		$Timer.start(2)

	else:

		estado = Estado.IDLE

		bateu = false

		# Próximo dash rapidamente
		$Timer.start(0.2)


# ==========================================================
# IMPACTO FINAL DO TERCEIRO DASH
# ==========================================================


func impacto_final():

	var camera = get_viewport().get_camera_2d()

	if camera != null and camera.has_method("tremer"):
		camera.tremer(22)

	estado = Estado.RETORNANDO
	velocity = Vector2.ZERO

	# ======================================================
	# PEGA O BOSS SPAWN DA CENA DE TESTE
	# ======================================================

	var boss_spawn = get_tree().current_scene.get_node_or_null("BossSpawn")

	if boss_spawn == null:
		print("BossSpawn não encontrado!")
		return

	# ======================================================
	# PEQUENA MARGEM DE ERRO
	# ======================================================

	var deslocamento: Vector2 = Vector2(
		randf_range(-margem_retorno, margem_retorno),
		randf_range(-margem_retorno, margem_retorno)
	)

	var destino: Vector2 = boss_spawn.global_position + deslocamento

	# ======================================================
	# ROTAÇÃO + MOVIMENTO ATÉ O CENTRO
	# ======================================================

	var distancia: float = global_position.distance_to(destino)

	# Quanto mais longe, mais tempo leva para voltar
	var tempo_retorno: float = clamp(
		distancia / 400.0,
		0.5,
		1.2
	)

	var rotacao_inicial: float = rotation

	var tween = create_tween()

	tween.set_parallel(true)

	# Vai lentamente para o centro
	tween.tween_property(
		self,
		"global_position",
		destino,
		tempo_retorno
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Enquanto volta, fica rodando
	tween.tween_property(
		self,
		"rotation",
		rotacao_inicial + deg_to_rad(1080.0),
		tempo_retorno
	).set_trans(Tween.TRANS_LINEAR)

	await tween.finished

	# ======================================================
	# PEQUENA "FREIADA" DE DESENHO ANIMADO
	# ======================================================

	var tween_final = create_tween()

	tween_final.tween_property(
		self,
		"rotation",
		rotacao_inicial,
		0.15
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await tween_final.finished




# ==========================================================
# PEDRAS
# ==========================================================

func spawn_pedras():

	var angulo_base: float = direcao.angle() + PI
	var abertura: float = deg_to_rad(120.0)

	for i in range(quantidade_pedras):

		var pedra = PEDRA.instantiate()

		get_tree().current_scene.add_child(pedra)

		# Nasce um pouco atrás do mouse,
		# na direção oposta ao dash.
		pedra.global_position = global_position + direcao * 20.0

		var t: float = float(i) / float(quantidade_pedras - 1)

		var angulo: float = lerp(
			-abertura / 2.0,
			abertura / 2.0,
			t
		)

		pedra.direction = Vector2.RIGHT.rotated(
			angulo_base + angulo
		)

		pedra.speed = randf_range(
			velocidade_pedras_min,
			velocidade_pedras_max
		)

		pedra.life_time = tempo_vida_pedras

		pedra.teleguiado = false


# ==========================================================
# ACERTOU O PLAYER
# ==========================================================

func acertou_player():

	estado = Estado.TONTO

	velocity = Vector2.ZERO

	# Tremida da câmera
	var camera = get_viewport().get_camera_2d()

	if camera != null and camera.has_method("tremer"):
		camera.tremer(18)

	# Pequena balançada do mouse
	var rot_original: float = rotation

	var tween = create_tween()

	tween.tween_property(
		self,
		"rotation",
		rot_original + deg_to_rad(randf_range(-10.0, 10.0)),
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

	await get_tree().create_timer(tempo_tonto).timeout

	estado = Estado.IDLE

	bateu = false

	# O dash que acertou o player também conta.
	if dash_atual >= quantidade_dashes:

		dash_atual = 0

	$Timer.start(0.2)


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

	# Vazio por enquanto.
	# A implementação será feita depois.

	pass
