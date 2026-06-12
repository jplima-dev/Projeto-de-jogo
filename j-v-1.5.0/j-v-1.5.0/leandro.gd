extends CharacterBody2D

# ==============================
# CONSTANTES DE MOVIMENTO
# ==============================
const SPEED = 500.0
const RUN_MULTIPLIER = 2.0
const DASH_SPEED = 2500.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 1.0

# ==============================
# CONTROLE
# ==============================
var pode_mexer = true
var em_cutscene = false

# ==============================
# VARIÁVEIS DE DASH
# ==============================
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = Vector2.ZERO

# ==============================
# VIDA
# ==============================
var max_health = 100
var health = 100
@onready var health_bar = $"../hud/TextureProgressBar"

# ==============================
# DIREÇÃO E INVENCIBILIDADE
# ==============================
var facing_direction = Vector2.ZERO
var invincible = false
var invincible_time = 0.5

# ==============================
# PISCAR
# ==============================
var blink_timer: Timer
var blinking_color: Color = Color(1, 1, 1)
var saved_mask = 0

# ==============================
# ATAQUE
# ==============================
@onready var terminal: Node2D = $TerminalAtaque

@onready var attack_panel: Panel = $TerminalAtaque/CanvasLayer/Panel

@onready var attack_input: LineEdit = $TerminalAtaque/CanvasLayer/Panel/LineEdit

var digitando_comando := false

# ==============================
# SONS
# ==============================
@onready var som_passo: AudioStreamPlayer2D = $passo
@onready var som_correr: AudioStreamPlayer2D = $correr
@onready var som_dash: AudioStreamPlayer2D = $dash


# ==============================
# READY
# ==============================
func _ready():

	add_to_group("player")

	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

	blink_timer = Timer.new()
	blink_timer.wait_time = 0.1
	blink_timer.one_shot = false
	blink_timer.timeout.connect(_toggle_visibility)
	add_child(blink_timer)


	$AnimatedSprite2D.frame_changed.connect(_on_frame_changed)

	attack_panel.visible = false

# ==============================
# MOVIMENTO
# ==============================
func _physics_process(delta):

	# ==========================
	# CUTSCENE
	# ==========================
	if !pode_mexer and !em_cutscene:

		velocity = Vector2.ZERO
		move_and_slide()

		# mostra apenas sprite parado
		$Sprite2D.visible = true
		$AnimatedSprite2D.visible = false

		return

	var dir = Vector2(
		Input.get_action_strength("move-right") - Input.get_action_strength("move-left"),
		Input.get_action_strength("move-down") - Input.get_action_strength("move-up")
	)

	if dir.x != 0 and dir.y != 0:

		if abs(dir.x) > abs(dir.y):
			dir.y = 0
		else:
			dir.x = 0

	dir = dir.normalized()

	if dir != Vector2.ZERO:
		facing_direction = dir

	var moving = dir.length() > 0 or is_dashing

	# ==========================
	# MOVIMENTO + DASH
	# ==========================
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and dir != Vector2.ZERO:

		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN
		dash_direction = dir

		if som_dash:
			som_dash.play()

		if dir.y < 0:
			$AnimatedSprite2D.play("dash_cima")

		elif dir.y > 0:
			$AnimatedSprite2D.play("dash_baixo")

		else:
			$AnimatedSprite2D.play("dash")
			update_flip()

	velocity = dash_direction * DASH_SPEED if is_dashing else dir * (
		SPEED * RUN_MULTIPLIER if Input.is_action_pressed("correr") else SPEED
	)

	if is_dashing:

		dash_timer -= delta

		if dash_timer <= 0:
			is_dashing = false

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	move_and_slide()

	# ==========================
	# NÃO CONTROLA ANIMAÇÕES
	# DURANTE CUTSCENE
	# ==========================
	if em_cutscene:
		move_and_slide()
		
		return 

	# ==========================
	# ANIMAÇÕES
	# ==========================
	if has_node("Sprite2D"):
		$Sprite2D.visible = !moving

	if has_node("AnimatedSprite2D"):

		$AnimatedSprite2D.visible = true

		if moving and !is_dashing:

			if dir.y < 0:

				if Input.is_action_pressed("correr"):
					$AnimatedSprite2D.play("correr_cima")
				else:
					$AnimatedSprite2D.play("andar_cima")

			elif dir.y > 0:

				if Input.is_action_pressed("correr"):
					$AnimatedSprite2D.play("correr_baixo")
				else:
					$AnimatedSprite2D.play("andar_baixo")

			else:

				if Input.is_action_pressed("correr"):
					$AnimatedSprite2D.play("correr")
				else:
					$AnimatedSprite2D.play("andar")

				update_flip()

		elif !moving:

			if facing_direction.x != 0:

				$AnimatedSprite2D.visible = true
				$Sprite2D.visible = false

				$AnimatedSprite2D.play("parado_direcional")

				update_flip()

			else:

				$AnimatedSprite2D.visible = false
				$Sprite2D.visible = true


# ==============================
# FLIP
# ==============================
func update_flip():

	var anim = $AnimatedSprite2D.animation

	# andar/parado
	if anim == "andar" or anim == "parado_direcional":
		$AnimatedSprite2D.flip_h = facing_direction.x > 0

	# correr
	if anim == "correr":
		$AnimatedSprite2D.flip_h = facing_direction.x < 0

	# dash
	if anim == "dash":
		$AnimatedSprite2D.flip_h = facing_direction.x < 0


# ==============================
# SOM DOS PASSOS
# ==============================
func _on_frame_changed():

	if is_dashing:
		return

	if $AnimatedSprite2D.animation.begins_with("andar"):

		if $AnimatedSprite2D.frame == 1 or $AnimatedSprite2D.frame == 3:

			if som_passo:
				som_passo.play()

	if $AnimatedSprite2D.animation.begins_with("correr"):

		if $AnimatedSprite2D.frame == 1 or $AnimatedSprite2D.frame == 3:

			if som_correr:
				som_correr.play()


# ==============================
# INPUT
# ==============================
func _input(event):

	if !pode_mexer:
		return

	if event.is_action_pressed("ataque"):
		if !digitando_comando:
			abrir_comando()

		return
		
	if digitando_comando:

		if event.is_action_pressed("atacar"):
			fechar_comando()

		return

	if event.is_action_pressed("dano"):
		take_damage(50)

	if event.is_action_pressed("cura"):
		heal(10)


# ==============================
# ATAQUE
# ==============================
func _on_AttackArea_body_entered(body):

	if body.is_in_group("enemies"):
		body.take_damage(20)


# ==============================
# VIDA
# ==============================
func take_damage(amount: int):

	if invincible:
		return

	health = max(health - amount, 0)

	if health_bar:
		health_bar.value = health

	if health <= 0:
		die()
		return

	invincible = true

	blinking_color = Color(1, 0.3, 0.3)

	set_color(blinking_color)

	_start_blink()

	await get_tree().create_timer(invincible_time).timeout

	_stop_blink()

	set_color(Color(1, 1, 1))

	invincible = false


func heal(amount: int):

	health = min(health + amount, max_health)

	if health_bar:
		health_bar.value = health

	blinking_color = Color(0.3, 1, 0.3)

	set_color(blinking_color)

	_start_blink()

	await get_tree().create_timer(0.3).timeout

	_stop_blink()

	set_color(Color(1, 1, 1))


# ==============================
# MORTE
# ==============================
func die():

	get_tree().paused = false
	get_tree().change_scene_to_file("res://morte.tscn")
	queue_free()
# ==============================
# BLINK
# ==============================
func _start_blink():

	blink_timer.start()

	saved_mask = collision_mask

	collision_mask &= ~(1 << 1)


func _stop_blink():

	blink_timer.stop()

	_set_visible(true)

	collision_mask = saved_mask


func _toggle_visibility():

	var visible = !$AnimatedSprite2D.visible

	_set_visible(visible)

	if visible:
		set_color(blinking_color)


func _set_visible(v: bool):

	if has_node("Sprite2D"):
		$Sprite2D.visible = v

	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.visible = v


func set_color(c: Color):

	if has_node("Sprite2D"):
		$Sprite2D.modulate = c

	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.modulate = c
		
		
func abrir_comando():

	digitando_comando = true

	attack_input.text = ""

	attack_panel.visible = true

	attack_input.grab_focus()

	terminal.scale = Vector2(0.1, 0.1)
	terminal.modulate.a = 0.0

	var tween = create_tween()

	tween.set_parallel()

	tween.tween_property(
		terminal,
		"scale",
		Vector2.ONE,
		0.25
	)

	tween.tween_property(
		terminal,
		"modulate:a",
		1.0,
		0.25
	)

	await tween.finished
	
func fechar_comando():

	digitando_comando = false

	print("COMANDO:", attack_input.text)

	var tween = create_tween()

	tween.set_parallel()

	tween.tween_property(
		terminal,
		"scale",
		Vector2(0.1, 0.1),
		0.2
	)

	tween.tween_property(
		terminal,
		"modulate:a",
		0.0,
		0.2
	)

	await tween.finished

	attack_input.release_focus()

	attack_panel.visible = false
