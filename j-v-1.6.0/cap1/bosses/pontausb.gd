extends CharacterBody2D


# ==========================================================
# FÍSICA DO CABO
# ==========================================================

@export var distancia_do_mouse := 150.0
@export var forca_cabo := 60.0
@export var amortecimento := 12.0
@export var velocidade_maxima := 1200.0


# ==========================================================
# ROTAÇÃO DA USB
# ==========================================================

# Velocidade com que a ponta gira para acompanhar
# a direção do movimento do mouse.
@export var velocidade_rotacao := 10.0

# Diferença de 90 graus para corrigir a orientação
# da imagem da ponta USB.
@export var offset_rotacao_usb := 90.0

# Velocidade mínima do mouse necessária para
# atualizar a direção da ponta.
@export var velocidade_minima_rotacao := 20.0

# Última direção utilizada pela ponta.
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

	# Começa deitada
	rotation = deg_to_rad(-90.0)


# ==========================================================
# PHYSICS
# ==========================================================

func _physics_process(delta):


	# ======================================================
	# MODO ÓRBITA
	# ======================================================

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


	# ======================================================
	# VERIFICA O MOUSE
	# ======================================================

	if !is_instance_valid(mouse):
		return


	# ======================================================
	# ROTAÇÃO DA PONTA
	# ======================================================

	var velocidade_mouse: Vector2 = mouse.velocity


	if velocidade_mouse.length() > velocidade_minima_rotacao:

		# Direção em que o mouse está se movendo
		var direcao_movimento: Vector2 = (
			velocidade_mouse.normalized()
		)


		# A ponta metálica aponta para trás,
		# no sentido contrário ao movimento.

		ultima_direcao_mouse = -direcao_movimento


	# ======================================================
	# ROTAÇÃO ALVO
	# ======================================================

	var rotacao_alvo: float = (
		ultima_direcao_mouse.angle()
		+ deg_to_rad(offset_rotacao_usb)
	)


	# ======================================================
	# ROTAÇÃO SUAVE
	# ======================================================

	rotation = lerp_angle(
		rotation,
		rotacao_alvo,
		velocidade_rotacao * delta
	)


	# ======================================================
	# POSIÇÃO DO MOUSE
	# ======================================================

	var pos_mouse: Vector2 = (
		mouse.global_position
	)


	# ======================================================
	# VETOR DO MOUSE ATÉ A PONTA
	# ======================================================

	var vetor: Vector2 = (
		global_position
		- pos_mouse
	)


	var distancia: float = (
		vetor.length()
	)


	# ======================================================
	# FÍSICA DO CABO
	# ======================================================

	if distancia > distancia_do_mouse:

		var direcao_para_mouse: Vector2 = (
			pos_mouse
			- global_position
		).normalized()


		# Quanto mais longe do mouse,
		# maior a força do cabo.

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


	# ======================================================
	# AMORTECIMENTO
	# ======================================================

	velocity *= 1.0 / (
		1.0
		+ amortecimento * delta
	)


	# ======================================================
	# VELOCIDADE MÁXIMA
	# ======================================================

	if velocity.length() > velocidade_maxima:

		velocity = (
			velocity.normalized()
			* velocidade_maxima
		)


	# ======================================================
	# MOVIMENTO
	# ======================================================

	move_and_slide()


# ==========================================================
# INICIAR ÓRBITA
# ==========================================================

func iniciar_orbita(
	boss,
	distancia
):

	em_orbita = true

	boss_orbita = boss

	distancia_orbita = distancia


	# Começa a órbita exatamente da posição
	# atual da ponta USB.

	angulo_orbita = (
		global_position
		- boss.global_position
	).angle()


	# Zera a velocidade física para ela
	# não continuar acumulando durante a orbital.

	velocity = Vector2.ZERO


# ==========================================================
# PARAR ÓRBITA
# ==========================================================

func parar_orbita():

	em_orbita = false

	boss_orbita = null


	# Depois da orbital, a ponta volta
	# a ser controlada pela física normal.
