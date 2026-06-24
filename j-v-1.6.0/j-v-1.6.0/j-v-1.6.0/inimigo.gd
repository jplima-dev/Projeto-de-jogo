extends CharacterBody2D

@export var chase_speed: float = 300.0
@export var chase_distance: float = 800.0
@export var attack_distance: float = 250.0
@export var stop_distance: float = 1000.0

@export var shoot_delay: float = 1

# OPÇÕES DE ATAQUE
@export var projectile_count: int = 3
@export var spread_angle: float = 35.0
@export var teleguiado: bool = false
@export var em_volta: bool = false
@export var homing_time: float = 0.5

@export var max_health: int = 50

const PROJETIL = preload("res://projetilteste.tscn")
var Textocodigo = preload("res://Textocodigo.tscn")

var player: CharacterBody2D
var health: int

var shoot_timer := 0.0
var falou := false
var is_attacking := false
var ultimo_ataque := ""


func escolher_ataque():

	var ataques = ["wave", "shot", "about", "cross_shot", "homing_spray"]

	var novo_ataque = ataques[randi() % ataques.size()]

	while novo_ataque == ultimo_ataque:
		novo_ataque = ataques[randi() % ataques.size()]

	ultimo_ataque = novo_ataque

	return novo_ataque

func _ready():
	add_to_group("enemies")
	health = max_health


func _physics_process(delta):

	if player == null or !is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	var dir = player.global_position - global_position
	var dist = dir.length()

	# --------------------------
	# FORA DO RANGE
	# --------------------------
	if dist > chase_distance:
		velocity = Vector2.ZERO
		falou = false
		shoot_timer = 0.0
		move_and_slide()
		return

	# --------------------------
	# PERSEGUIR
	# --------------------------
	if dist > attack_distance:
		velocity = dir.normalized() * chase_speed

	# --------------------------
	# ATACAR
	# --------------------------
	else:
		velocity = Vector2.ZERO

		if !falou:
			var texto = Textocodigo.instantiate()
			get_tree().current_scene.add_child(texto)

			texto.iniciar(
				"Vou te matar",
				self,
				Color.DARK_RED,
				16,
				1.0,
				0.5
			)

			falou = true

	move_and_slide()
	
	if dist <= attack_distance and !is_attacking:
		iniciar_ataque()


func atirar(direcao: Vector2):

	# --------------------------
	# TIRO EM VOLTA (CORRIGIDO)
	# --------------------------
	if em_volta:

		var passo = TAU / max(projectile_count, 1)

		for i in range(projectile_count):

			var angulo = passo * i
			var bala = PROJETIL.instantiate()

			get_tree().current_scene.add_child(bala)

			bala.global_position = global_position

			# direção correta radial
			bala.direction = Vector2.RIGHT.rotated(angulo)

			if "teleguiado" in bala:
				bala.teleguiado = teleguiado

			if "player" in bala:
				bala.player = player

			if "homing_time" in bala:
				bala.homing_time = homing_time

		return


	# --------------------------
	# TIRO SIMPLES
	# --------------------------
	if projectile_count <= 1:

		var bala = PROJETIL.instantiate()
		get_tree().current_scene.add_child(bala)

		bala.global_position = global_position
		bala.direction = direcao

		if "teleguiado" in bala:
			bala.teleguiado = teleguiado

		if "player" in bala:
			bala.player = player

		if "homing_time" in bala:
			bala.homing_time = homing_time

		return


	# --------------------------
	# TIRO EM LEQUE
	# --------------------------
	var total = deg_to_rad(spread_angle)
	var inicio = -total / 2.0

	for i in range(projectile_count):

		var t = float(i) / float(projectile_count - 1)
		var angulo = lerp(inicio, total / 2.0, t)

		var bala = PROJETIL.instantiate()

		get_tree().current_scene.add_child(bala)

		bala.global_position = global_position
		bala.direction = direcao.rotated(angulo)

		if "teleguiado" in bala:
			bala.teleguiado = teleguiado

		if "player" in bala:
			bala.player = player

		if "homing_time" in bala:
			bala.homing_time = homing_time
			
func ataque_wave() -> void:

	for wave in range(5):

		var passo = TAU / 100

		for i in range(100):

			var bala = PROJETIL.instantiate()
			get_tree().current_scene.add_child(bala)

			bala.global_position = global_position
			bala.direction = Vector2.RIGHT.rotated(passo * i)
			bala.teleguiado = false

		await get_tree().create_timer(3.0).timeout
			
func ataque_shot(direcao: Vector2):

	var dir = direcao.normalized()

	for i in range(projectile_count):

		var t := 0.0

		if projectile_count > 1:
			t = float(i) / float(projectile_count - 1)

		var angulo = lerp(-deg_to_rad(spread_angle)/2.0, deg_to_rad(spread_angle)/2.0, t)

		var bala = PROJETIL.instantiate()
		get_tree().current_scene.add_child(bala)

		bala.global_position = global_position
		bala.direction = dir.rotated(angulo)

		bala.teleguiado = false
		
func ataque_about():

	for burst in range(3):

		var passo = TAU / 5

		for i in range(5):

			var angulo = passo * i
			var bala = PROJETIL.instantiate()

			get_tree().current_scene.add_child(bala)

			bala.global_position = global_position
			bala.direction = Vector2.RIGHT.rotated(angulo)

			bala.teleguiado = true
			bala.homing_time = homing_time
			bala.player = get_tree().get_first_node_in_group("player")

		await get_tree().create_timer(0.3).timeout
		
func executar_ataque() -> void:
	var ataque = escolher_ataque()

	match ataque:
		"wave":
			await ataque_wave()
		"shot":
			await ataque_shot(player.global_position - global_position)
		"about":
			await ataque_about()
		"cross_shot":
			await ataque_cross_shot()
		"homing_spray":
			await ataque_homing_spray()

	await get_tree().create_timer(1.0).timeout

	is_attacking = false
	
func iniciar_ataque():
	if is_attacking:
		return

	is_attacking = true
	await executar_ataque()
	is_attacking = false

func ataque_cross_shot():

	var direcoes = [
		Vector2.RIGHT,
		Vector2.LEFT,
		Vector2.UP,
		Vector2.DOWN,
		Vector2(1, 1).normalized(),
		Vector2(-1, 1).normalized(),
		Vector2(1, -1).normalized(),
		Vector2(-1, -1).normalized()
	]

	for d in direcoes:

		var bala = PROJETIL.instantiate()
		get_tree().current_scene.add_child(bala)

		bala.global_position = global_position
		bala.direction = d

		bala.teleguiado = false

	await get_tree().create_timer(0.3).timeout
	
func ataque_homing_spray():

	for i in range(20):

		var dir = Vector2.RIGHT.rotated(randf_range(0, TAU))

		var bala = PROJETIL.instantiate()
		get_tree().current_scene.add_child(bala)

		bala.global_position = global_position
		bala.direction = dir

		bala.teleguiado = true
		bala.homing_time = 2.5
		bala.player = player

	await get_tree().create_timer(1.0).timeout
