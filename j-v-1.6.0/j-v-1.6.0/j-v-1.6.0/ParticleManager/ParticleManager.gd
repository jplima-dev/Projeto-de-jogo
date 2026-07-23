extends Node

const PARTICLE = preload("res://ParticleManager/Particle.tscn")

func spawn(data: ParticleData, pos: Vector2):

	for i in range(data.amount):

		var p = PARTICLE.instantiate()

		get_tree().current_scene.add_child(p)

		p.global_position = pos

		var angle = randf_range(-data.spread, data.spread)

		var dir = Vector2.RIGHT.rotated(deg_to_rad(angle))

		p.iniciar(data, dir)
