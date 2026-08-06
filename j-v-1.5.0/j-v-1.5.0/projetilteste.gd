extends ColorRect

@export var speed := 500.0
@export var life_time := 5.0
@export var turn_speed := 6.0

# =========================
# VARIÁVEIS DO INIMIGO (compatibilidade)
# =========================
var teleguiado := false
var player: CharacterBody2D = null
var homing_time := 0.5

# =========================
# CONTROLE INTERNO
# =========================
var direction := Vector2.ZERO
var homing_timer := 0.0

# HITBOX SIMPLES
@export var hit_radius := 10.0


func _ready():

	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT

	if player == null:
		player = get_tree().get_first_node_in_group("player")

	homing_timer = homing_time

	await get_tree().create_timer(life_time).timeout
	queue_free()


func _process(delta):

	# --------------------------
	# TELEGUIADO COM TEMPO LIMITADO
	# --------------------------
	if teleguiado and is_instance_valid(player):

		if homing_timer > 0.0:
			homing_timer -= delta

			var to_player = player.global_position - global_position

			if to_player.length() > 0.01:
				to_player = to_player.normalized()

				direction = direction.lerp(to_player, turn_speed * delta)

				if direction.length() > 0.01:
					direction = direction.normalized()

	# --------------------------
	# MOVIMENTO
	# --------------------------
	global_position += direction * speed * delta

	# --------------------------
	# COLISÃO MANUAL COM PLAYER
	# --------------------------
	if is_instance_valid(player):
		if global_position.distance_to(player.global_position) <= hit_radius:
			queue_free()
