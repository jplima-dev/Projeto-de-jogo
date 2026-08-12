extends CharacterBody2D

@export var distancia_do_mouse := 80.0
@export var forca_cabo := 18.0
@export var amortecimento := 5.0
@export var velocidade_maxima := 1800.0

# ==========================
# ÓRBITA
# ==========================

@export var velocidade_orbita_usb := 6.0

var em_orbita := false
var boss_orbita = null
var distancia_orbita := 80.0
var angulo_orbita := 0.0

# ==========================
# MOUSE
# ==========================

var mouse = null


func _ready():

	# Procura o mouse/boss
	mouse = get_tree().get_first_node_in_group("mouse")

	if mouse == null:
		push_warning(
			"PontaUSB: Mouse não encontrado no grupo 'mouse'."
		)

	# ==========================
	# COLISÃO
	# ==========================

	# A ponta NÃO colide com o mouse.
	# Ela só colide com o player.

	collision_layer = 2
	collision_mask = 1


func _physics_process(delta):

	# ==================================================
	# MODO ÓRBITA
	# ==================================================

	if em_orbita and is_instance_valid(boss_orbita):

		angulo_orbita += velocidade_orbita_usb * delta

		global_position = (
			boss_orbita.global_position
			+ Vector2.RIGHT.rotated(angulo_orbita)
			* distancia_orbita
		)

		return


	# ==================================================
	# FÍSICA NORMAL DO CABO
	# ==================================================

	if !is_instance_valid(mouse):
		return


	# ==================================================
	# POSIÇÃO DO MOUSE
	# ==================================================

	var pos_mouse: Vector2 = mouse.global_position

	var vetor: Vector2 = global_position - pos_mouse

	var distancia: float = vetor.length()


	# ==================================================
	# FÍSICA DO CABO
	# ==================================================

	if distancia > distancia_do_mouse:

		var direcao_para_mouse: Vector2 = (
			pos_mouse - global_position
		).normalized()

		var excesso: float = distancia - distancia_do_mouse

		var forca: Vector2 = (
			direcao_para_mouse
			* excesso
			* forca_cabo
		)

		velocity += forca * delta


	# ==================================================
	# AMORTECIMENTO
	# ==================================================

	velocity *= 1.0 / (
		1.0 + amortecimento * delta
	)


	# ==================================================
	# VELOCIDADE MÁXIMA
	# ==================================================

	if velocity.length() > velocidade_maxima:

		velocity = (
			velocity.normalized()
			* velocidade_maxima
		)


	# ==================================================
	# MOVIMENTO
	# ==================================================

	move_and_slide()


# ==========================================================
# INICIAR ÓRBITA
# ==========================================================

func iniciar_orbita(boss, distancia):

	em_orbita = true

	boss_orbita = boss

	distancia_orbita = distancia

	# Começa a órbita exatamente da posição
	# atual da ponta USB.

	angulo_orbita = (
		global_position - boss.global_position
	).angle()

	# Zera a velocidade física para ela não
	# continuar acumulando durante a orbital.

	velocity = Vector2.ZERO


# ==========================================================
# PARAR ÓRBITA
# ==========================================================

func parar_orbita():

	em_orbita = false

	boss_orbita = null

	# Depois da orbital, a ponta volta a ser
	# controlada pela física normal.
