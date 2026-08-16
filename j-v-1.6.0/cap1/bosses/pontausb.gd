extends CharacterBody2D


# ==========================================================
# FÍSICA DO CABO
# ==========================================================

@export var distancia_do_mouse := 150.0
@export var forca_cabo := 6000.0
@export var amortecimento := 1000.0
@export var velocidade_maxima := 1200.0


# ==========================================================
# CHICOTE
# ==========================================================
var direcao_chicote: Vector2 = Vector2.RIGHT

var em_chicote := false
var retornando_chicote := false

var alvo_chicote: Node2D = null

@export var velocidade_chicote := 1400.0
@export var distancia_maxima_chicote := 500.0
@export var distancia_acerto_chicote := 30.0
@export var dano_chicote := 20

# Posição onde o player estava no momento em que o ataque começou
var posicao_alvo_chicote: Vector2 = Vector2.ZERO

# Posição onde a ponta estava quando o chicote começou
var posicao_retorno_chicote: Vector2 = Vector2.ZERO

signal chicote_finalizado


# ==========================================================
# ROTAÇÃO DA USB
# ==========================================================

@export var velocidade_rotacao := 10.0

@export var offset_rotacao_usb := 90.0

@export var velocidade_minima_rotacao := 20.0

var ultima_direcao_mouse := Vector2.LEFT


# ==========================================================
# ÓRBITA
# ==========================================================

@export var velocidade_orbita_usb := 6.0

var em_orbita := false
var boss_orbita = null
var distancia_orbita := 80.0
var angulo_orbita := 0.0


# ==========================================================
# MOUSE
# ==========================================================

var mouse = null



# ==========================================================
# READY
# ==========================================================

func _ready():

	# Procura o mouse/boss
	mouse = get_tree().get_first_node_in_group("mouse")

	if mouse == null:

		push_warning(
			"PontaUSB: Mouse não encontrado no grupo 'mouse'."
		)


	# ======================================================
	# ROTAÇÃO INICIAL
	# ======================================================

	rotation = deg_to_rad(90.0)


# ==========================================================
# PHYSICS
# ==========================================================

func _physics_process(delta):


	# ==========================================================
	# MODO CHICOTE - VOLTANDO PARA O MOUSE
	# ==========================================================

	if retornando_chicote:

		if !is_instance_valid(mouse):

			finalizar_chicote()

			return


		var vetor_retorno: Vector2 = (
			mouse.global_position
			- global_position
		)

		var distancia_retorno: float = (
			vetor_retorno.length()
		)


		# ======================================================
		# CHEGOU NO MOUSE
		# ======================================================

		if distancia_retorno <= 15.0:

			global_position = mouse.global_position

			velocity = Vector2.ZERO

			finalizar_chicote()

			return


		# ======================================================
		# VOLTA PARA O MOUSE
		# ======================================================

		velocity = (
			vetor_retorno.normalized()
			* velocidade_chicote
			* 0.75
		)

		move_and_slide()

		return


	# ==========================================================
	# MODO CHICOTE - INDO PARA A POSIÇÃO SALVA
	# ==========================================================

	if em_chicote:

		var vetor_alvo: Vector2 = (
			posicao_alvo_chicote
			- global_position
		)

		var distancia_alvo: float = (
			vetor_alvo.length()
		)


		# ======================================================
		# CHEGOU NA POSIÇÃO ONDE O PLAYER ESTAVA
		# ======================================================

		if distancia_alvo <= distancia_acerto_chicote:

			# Verifica se o player ainda está perto
			# da posição salva.

			if is_instance_valid(alvo_chicote):

				var distancia_player: float = (
					alvo_chicote.global_position
					.distance_to(
						posicao_alvo_chicote
					)
				)


				if distancia_player <= distancia_acerto_chicote:

					if alvo_chicote.is_in_group("player"):

						if alvo_chicote.has_method("take_damage"):

							alvo_chicote.take_damage(
								dano_chicote
							)


			# Mesmo acertando ou errando,
			# a ponta volta para o mouse.

			iniciar_retorno_chicote()

			return


		# ======================================================
		# CHEGOU NO LIMITE MÁXIMO
		# ======================================================

		if global_position.distance_to(
			posicao_retorno_chicote
		) >= distancia_maxima_chicote:

			iniciar_retorno_chicote()

			return


		# ======================================================
		# MOVIMENTO ATÉ A POSIÇÃO FIXA
		# ======================================================

		var direcao_chicote: Vector2 = (
			vetor_alvo.normalized()
		)

		velocity = (
			direcao_chicote
			* velocidade_chicote
		)

		move_and_slide()

		return


	# ==========================================================
	# MODO ÓRBITA
	# ==========================================================

	if em_orbita and is_instance_valid(boss_orbita):

		angulo_orbita += (
			velocidade_orbita_usb
			* delta
		)


		global_position = (
			boss_orbita.global_position
			+ Vector2.RIGHT.rotated(
				angulo_orbita
			)
			* distancia_orbita
		)


		# Enquanto estiver orbitando,
		# não usa a física normal.

		return


	# ==========================================================
	# VERIFICA O MOUSE
	# ==========================================================

	if !is_instance_valid(mouse):

		return


	# ==========================================================
	# ROTAÇÃO DA PONTA
	# ==========================================================

	var velocidade_mouse: Vector2 = (
		mouse.velocity
	)


	if velocidade_mouse.length() > velocidade_minima_rotacao:

		var direcao_movimento: Vector2 = (
			velocidade_mouse.normalized()
		)


		# A ponta metálica aponta para trás,
		# no sentido contrário ao movimento.

		ultima_direcao_mouse = (
			-direcao_movimento
		)


	# ==========================================================
	# ROTAÇÃO ALVO
	# ==========================================================

	var rotacao_alvo: float = (
		ultima_direcao_mouse.angle()
		+ deg_to_rad(offset_rotacao_usb)
	)


	# ==========================================================
	# ROTAÇÃO SUAVE
	# ==========================================================

	rotation = lerp_angle(
		rotation,
		rotacao_alvo,
		velocidade_rotacao * delta
	)


	# ==========================================================
	# POSIÇÃO DO MOUSE
	# ==========================================================

	var pos_mouse: Vector2 = (
		mouse.global_position
	)


	# ==========================================================
	# VETOR DO MOUSE ATÉ A PONTA
	# ==========================================================

	var vetor: Vector2 = (
		global_position
		- pos_mouse
	)

	var distancia: float = (
		vetor.length()
	)


	# ==========================================================
	# FÍSICA NORMAL DO CABO
	# ==========================================================

	if distancia > distancia_do_mouse:

		var direcao_para_mouse: Vector2 = (
			pos_mouse
			- global_position
		).normalized()


		var excesso: float = (
			distancia
			- distancia_do_mouse
		)


		var forca: Vector2 = (
			direcao_para_mouse
			* excesso
			* forca_cabo
		)


		velocity += (
			forca
			* delta
		)


	# ==========================================================
	# AMORTECIMENTO
	# ==========================================================

	velocity *= 1.0 / (
		1.0
		+ amortecimento * delta
	)


	# ==========================================================
	# VELOCIDADE MÁXIMA
	# ==========================================================

	if velocity.length() > velocidade_maxima:

		velocity = (
			velocity.normalized()
			* velocidade_maxima
		)


	# ==========================================================
	# MOVIMENTO NORMAL
	# ==========================================================

	move_and_slide()


# ==========================================================
# INICIAR ÓRBITA
# ==========================================================

func iniciar_orbita(
	boss,
	distancia
):

	if em_chicote or retornando_chicote:

		return


	em_orbita = true

	boss_orbita = boss

	distancia_orbita = distancia


	# Começa a órbita exatamente da posição
	# atual da ponta USB.

	angulo_orbita = (
		global_position
		- boss.global_position
	).angle()


	velocity = Vector2.ZERO


# ==========================================================
# PARAR ÓRBITA
# ==========================================================

func parar_orbita():

	em_orbita = false

	boss_orbita = null


# ==========================================================
# INICIAR CHICOTE
# ==========================================================

func iniciar_chicote(
	alvo: Node2D,
	direcao: Vector2
):

	if alvo == null:
		return

	if em_chicote or retornando_chicote:
		return


	# ======================================================
	# DESATIVA ÓRBITA
	# ======================================================

	em_orbita = false
	boss_orbita = null


	# ======================================================
	# GUARDA O PLAYER
	# ======================================================

	alvo_chicote = alvo


	# ======================================================
	# GUARDA A POSIÇÃO DO PLAYER
	# ======================================================

	posicao_alvo_chicote = (
		alvo.global_position
	)


	# ======================================================
	# GUARDA A POSIÇÃO DA PONTA
	# ======================================================

	posicao_retorno_chicote = (
		global_position
	)


	# ======================================================
	# RECEBE A DIREÇÃO DO BOSS
	# ======================================================

	if direcao.length() <= 0.01:
		return

	direcao_chicote = (
		direcao.normalized()
	)


	# ======================================================
	# ATIVA O CHICOTE
	# ======================================================

	em_chicote = true
	retornando_chicote = false

	velocity = Vector2.ZERO


	# ======================================================
	# APONTA PARA A DIREÇÃO DO GOLPE
	# ======================================================

	rotation = (
		direcao_chicote.angle()
		+ deg_to_rad(offset_rotacao_usb)
	)


	# ======================================================
	# DESATIVA COLISÃO DURANTE O CHICOTE
	# ======================================================

	collision_mask = 0


# ==========================================================
# INICIAR RETORNO DO CHICOTE
# ==========================================================

func iniciar_retorno_chicote():

	em_chicote = false

	retornando_chicote = true

	alvo_chicote = null

	velocity = Vector2.ZERO


	# Mantém sem colisão durante o retorno

	collision_mask = 0


# ==========================================================
# FINALIZAR CHICOTE
# ==========================================================

func finalizar_chicote():

	em_chicote = false

	retornando_chicote = false

	alvo_chicote = null

	velocity = Vector2.ZERO


	# Volta a procurar somente o player

	collision_mask = 1


	emit_signal(
		"chicote_finalizado"
	)
