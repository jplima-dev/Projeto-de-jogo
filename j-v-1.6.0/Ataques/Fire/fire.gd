extends Node2D

var TextoCodigo = preload("res://Textocodigo.tscn")
const FIRE_PROJECTILE = preload("res://Ataques/Fire/FireProjectile.tscn")

func usar(player):

	print("FIRE EXECUTADO")

	# ==========================
	# TEXTO DO ATAQUE
	# ==========================
	var texto = TextoCodigo.instantiate()
	get_tree().current_scene.add_child(texto)

	texto.iniciar(
		"FIRE!",
		player,
		Color.ORANGE,
		28,
		1.2,
		1.0
	)

	# ==========================
	# CRIA O PROJÉTIL
	# ==========================
	var fire = FIRE_PROJECTILE.instantiate()

	get_tree().current_scene.add_child(fire)

	# nasce um pouco na frente do player
	fire.global_position = player.global_position + player.facing_direction.normalized() * 24

	# direção do projétil
	fire.direction = player.facing_direction.normalized()

	# gira o sprite para olhar na direção do movimento
	fire.rotation = fire.direction.angle()

	# ==========================
	# FINALIZA
	# ==========================
	queue_free()
