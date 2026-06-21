extends CharacterBody2D

var Textocodigo = preload("res://Textocodigo.tscn")
const AFTER_IMAGE = preload("res://AfterImagem.tscn")

# ==============================
# ghost
# ==============================
@export var ghost_count := 15
@export var ghost_delay := 0.02
@export var ghost_fade_speed := 100
@export var ghost_scale := 0.1
@export var ghost_color := Color(1,1,1,0.2)
@export var ghost_disappear_delay := 0.02

# ==============================
# CONSTANTES DE MOVIMENTO
# ==============================
const SPEED = 500.0
const RUN_MULTIPLIER = 2.0
const DASH_COOLDOWN = 1.0
const DASH_DISTANCE = 220.0

# ==============================
# CONTROLE
# ==============================
var pode_mexer = true
var em_cutscene = false

# ==============================
# VARIÁVEIS DE DASH
# ==============================
var dash_cooldown_timer = 0.0

# ==============================
# VIDA
# ==============================
var max_health = 100
var health = 100
@onready var health_bar = $"../hud/TextureProgressBar"


# ==============================
# ATAQUE
# ==============================

@onready var habilidades = $TerminalAtaque

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
# SONS
# ==============================
@onready var som_passo: AudioStreamPlayer2D = $passo
@onready var som_correr: AudioStreamPlayer2D = $correr
@onready var som_dash: AudioStreamPlayer2D = $dash


# ==============================
# READY
# ==============================
func _ready():
	
	if Saves.carregando_save:

		global_position = Vector2(
			Saves.dados["posicao_x"],
			Saves.dados["posicao_y"]
		)

		Saves.carregando_save = false

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

	#if dir.x != 0 and dir.y != 0:
#
		#if abs(dir.x) > abs(dir.y):
			#dir.y = 0
		#else:
			#dir.x = 0

	dir = dir.normalized()

	if dir != Vector2.ZERO:
		facing_direction = dir

	var moving = dir.length() > 0

	# ==========================
	# MOVIMENTO + DASH
	# ==========================
	if Input.is_action_just_pressed("dash") \
	and dash_cooldown_timer <= 0 \
	and facing_direction != Vector2.ZERO:

		dash_cooldown_timer = DASH_COOLDOWN

		# toca o som
		if som_dash:
			som_dash.play()

		# calcula início e destino
		var inicio = global_position
		var destino = inicio + facing_direction * DASH_DISTANCE

		# cria o rastro
		spawn_after_images(inicio, destino)

		# teleporta
		global_position = destino
		
		var texto = Textocodigo.instantiate()
		get_tree().current_scene.add_child(texto)
		texto.iniciar("L.E.O '@me TP 200px'", self)
		
		$Camera2D.add_shake(1)
		
		dash_slowmo()


	var target_speed = dir * (
		SPEED * RUN_MULTIPLIER
		if Input.is_action_pressed("correr")
		else SPEED
	)

	velocity = velocity.lerp(target_speed, 0.5)

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

		if moving:

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


# ==============================
# SOM DOS PASSOS
# ==============================
func _on_frame_changed():

	if $AnimatedSprite2D.animation.begins_with("andar"):

		if $AnimatedSprite2D.frame == 1 or $AnimatedSprite2D.frame == 3:

			if som_passo:
				som_passo.play()

	if $AnimatedSprite2D.animation.begins_with("correr"):

		if $AnimatedSprite2D.frame == 1 or $AnimatedSprite2D.frame == 3:

			if som_correr:
				som_correr.play()


func _input(event):
	
	if event.is_action_pressed("ataque"):

		if not habilidades.aberto:

			habilidades.abrir($Falapos)
			

	if !pode_mexer:
		return

	if event.is_action_pressed("dano"):
		take_damage(50)

	if event.is_action_pressed("cura"):
		heal(10)


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

func salvar_jogo():

	Saves.dados["vida"] = health

	Saves.dados["max_vida"] = max_health

	Saves.dados["posicao_x"] = global_position.x

	Saves.dados["posicao_y"] = global_position.y

	Saves.salvar()
	
func spawn_after_images(inicio: Vector2, fim: Vector2):

	for i in range(ghost_count):

		var ghost = AFTER_IMAGE.instantiate()

		get_tree().current_scene.add_child(ghost)

		var t = float(i) / max(ghost_count - 1, 1)

		ghost.global_position = inicio.lerp(fim, t)
		ghost.rotation = rotation
		ghost.scale = scale

		ghost.fade_speed = ghost_fade_speed
		ghost.blur_scale = ghost_scale
		ghost.ghost_color = ghost_color
		ghost.fade_delay = i * ghost_disappear_delay

		var sprite = ghost.get_node("AnimatedSprite2D")

		sprite.sprite_frames = $AnimatedSprite2D.sprite_frames
		sprite.animation = $AnimatedSprite2D.animation
		sprite.play(sprite.animation)
		sprite.frame = $AnimatedSprite2D.frame
		sprite.flip_h = $AnimatedSprite2D.flip_h
		sprite.stop()

		ghost.setup()
		

func dash_slowmo():
	Engine.time_scale = 0.005  	
	await get_tree().create_timer(0.05, true, false, true).timeout
	Engine.time_scale = 1.0
