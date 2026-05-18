extends CharacterBody2D

@export var wander_speed: float = 250.0
@export var chase_speed: float = 1000.0
@export var chase_distance: float = 5000.0
@export var stop_distance: float = 50.0
@export var max_health: int = 50
@export var attack_pause: float = 0.5   # tempo de pausa após atacar

var player: CharacterBody2D
var health: int
var wander_timer = 0.0
var wander_direction = Vector2.ZERO
var is_paused = false
var pause_timer = 0.0
var was_chasing = false
var invincible = false
var invincible_time = 0.3

@onready var sprite: Sprite2D = $Sprite2D   # ou AnimatedSprite2D se for o caso

func _ready():
	add_to_group("enemies")   # corrigido para bater com o Player
	player = get_tree().get_first_node_in_group("player")
	health = max_health
	if player == null:
		print("⚠️ Player não encontrado! Verifique se está no grupo 'player'.")

func _physics_process(delta):
	if player == null:
		return

	var d = global_position.distance_to(player.global_position)

	if not is_paused:
		if d <= chase_distance:
			_chase_player(d)
			was_chasing = true
		else:
			if was_chasing:
				_start_pause(randf_range(1.0, 2.0)) # pausa curta ao perder o player
				was_chasing = false
			if !is_paused:
				_wander(delta)
	else:
		_pause(delta)

	move_and_slide()

func _wander(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		wander_timer = randf_range(1.0, 3.0)
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	velocity = wander_direction * wander_speed

func _pause(delta):
	pause_timer -= delta
	if pause_timer <= 0:
		is_paused = false
	velocity = Vector2.ZERO

func _chase_player(d: float):
	if d > stop_distance:
		velocity = (player.global_position - global_position).normalized() * chase_speed
	else:
		velocity = Vector2.ZERO

func _start_pause(time: float):
	is_paused = true
	pause_timer = time
	velocity = Vector2.ZERO

# Quando o Player entra na área de ataque do inimigo
func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(10)
		# pausa maior após atacar
		_start_pause(attack_pause)

# ---- Dano com piscar vermelho ----
func take_damage(amount: int):
	if invincible:
		return

	health -= amount

	if sprite:
		sprite.modulate = Color(1, 0, 0)   # vermelho
		invincible = true
		await get_tree().create_timer(invincible_time).timeout
		sprite.modulate = Color(1, 1, 1)   # volta ao normal
		invincible = false

	if health <= 0:
		die()

func die():
	queue_free()
