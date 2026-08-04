extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var data: ParticleData

var velocity := Vector2.ZERO
var age := 0.0


func iniciar(particle_data: ParticleData, direction: Vector2):

	data = particle_data
	
	print(data)

	if data == null:
		push_error("ParticleData não foi enviado!")
		queue_free()
		return

	sprite.texture = data.texture

	sprite.texture = data.texture
	sprite.modulate = data.start_color

	scale = Vector2.ONE * data.start_scale

	rotation = randf() * TAU

	var spread = deg_to_rad(data.spread)
	var angle = randf_range(-spread / 2.0, spread / 2.0)

	var dir = direction.rotated(
	deg_to_rad(
		randf_range(
			-data.direction_randomness,
			 data.direction_randomness
			)
		)
	)

	velocity = dir * data.speed


func _process(delta):

	if data == null:
		return

	age += delta

	if age >= data.lifetime:
		queue_free()
		return

	# Movimento

	velocity.y += data.gravity * delta

	position += velocity * delta

	rotation += data.rotation_speed * delta

	# Interpolação

	var t = age / data.lifetime

	scale = Vector2.ONE * lerp(
		data.start_scale,
		data.end_scale,
		t
	)

	sprite.modulate = data.start_color.lerp(
		data.end_color,
		t
	)
