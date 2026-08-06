extends CharacterBody2D

const PEDRA = preload("res://projetilteste.tscn")

enum Estado{
	IDLE,
	MIRANDO,
	DASH,
	TONTO
}

var estado = Estado.IDLE

@export var velocidade_dash := 1200.0
@export var tempo_mira := 0.7
@export var tempo_tonto := 1.0
@export var quantidade_pedras := 10

# Ajuste este valor dependendo da orientação do sprite
@export var offset_rotacao := 90.0

var player
var direcao := Vector2.ZERO
var bateu := false


func _ready():

	player = get_tree().get_first_node_in_group("player")
	
	$Usbtip.alvo = self

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

	# Sempre olha para o player (exceto durante o dash)
	if estado != Estado.DASH and is_instance_valid(player):

		rotation = (
			player.global_position - global_position
		).angle() + deg_to_rad(offset_rotacao)

	move_and_slide()

	if estado == Estado.DASH and !bateu:

		if get_slide_collision_count() > 0:

			bateu = true

			await bateu_parede()


func _on_timer_timeout():

	if estado != Estado.IDLE:
		return

	bateu = false

	estado = Estado.MIRANDO

	direcao = (
		player.global_position - global_position
	).normalized()

	scale = Vector2(1.08, 0.92)

	await get_tree().create_timer(tempo_mira).timeout

	scale = Vector2.ONE

	estado = Estado.DASH


func bateu_parede():

	estado = Estado.TONTO

	velocity = Vector2.ZERO

	print("BATEU")

	# Tremida da câmera
	var camera = get_viewport().get_camera_2d()

	if camera != null and camera.has_method("tremer"):
		camera.tremer(18)

	# Pequena balançada
	var rot_original := rotation

	var tween = create_tween()

	tween.tween_property(
		self,
		"rotation",
		rot_original + deg_to_rad(randf_range(-12.0, 12.0)),
		0.06
	)

	await tween.finished

	var tween2 = create_tween()

	tween2.tween_property(
		self,
		"rotation",
		rot_original,
		0.10
	)

	spawn_pedras()

	await get_tree().create_timer(tempo_tonto).timeout

	estado = Estado.IDLE

	bateu = false

	$Timer.start(2)


func spawn_pedras():

	var angulo_base: float = direcao.angle() + PI
	var abertura: float = deg_to_rad(120.0)

	for i in range(quantidade_pedras):

		var pedra = PEDRA.instantiate()

		get_tree().current_scene.add_child(pedra)

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

		pedra.speed = randf_range(350.0, 500.0)
		pedra.life_time = 2.0
		pedra.teleguiado = false
