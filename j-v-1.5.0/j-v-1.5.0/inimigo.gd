extends CharacterBody2D

@export var chase_speed: float = 200.0
@export var chase_distance: float = 200.0
@export var stop_distance: float = 50.0
@export var max_health: int = 50

var Textocodigo = preload("res://Textocodigo.tscn")

var player: CharacterBody2D
var health: int

var cont = 0

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

	if dist <= chase_distance and dist > stop_distance:

		dir = dir.normalized()
		velocity = velocity.lerp(dir * chase_speed, 0.2)

		if cont == 0:
			var texto = Textocodigo.instantiate()
			get_tree().current_scene.add_child(texto)
			texto.iniciar("Vou te matar", self, Color.DARK_RED, 16, 1, 0.5)

		cont = 1
		
	else:
		cont = 0
		velocity = velocity.lerp(Vector2.ZERO, 0.2)

	move_and_slide()
