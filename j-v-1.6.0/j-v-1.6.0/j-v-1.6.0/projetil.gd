extends Area2D

@export var speed := 500.0
@export var life_time := 5.0
@export var turn_speed := 6.0

# TELEGUIADO
var teleguiado := false
var player = null
var homing_time := 0.5

# MOVIMENTO
var direction := Vector2.RIGHT
var homing_timer := 0.0

func _ready():

	if player == null:
		player = get_tree().get_first_node_in_group("player")

	homing_timer = homing_time

	body_entered.connect(_on_body_entered)

	await get_tree().create_timer(life_time).timeout
	queue_free()


func _process(delta):

	if teleguiado and is_instance_valid(player):

		if homing_timer > 0.0:
			homing_timer -= delta

			var to_player = player.global_position - global_position

			if to_player.length() > 0.01:
				to_player = to_player.normalized()

				direction = direction.lerp(
					to_player,
					turn_speed * delta
				).normalized()

	global_position += direction * speed * delta


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(15)
		queue_free()
