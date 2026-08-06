extends Node2D

@export var alvo: Node2D

@export var distancia_minima := 8.0
@export var velocidade := 900.0
@export var amortecimento := 8.0

var velocidade_atual := Vector2.ZERO


func _physics_process(delta):

	if alvo == null:
		return

	var destino = alvo.global_position

	var distancia = global_position.distance_to(destino)

	if distancia > distancia_minima:

		var direcao = (destino - global_position).normalized()

		velocidade_atual = velocidade_atual.lerp(
			direcao * velocidade,
			amortecimento * delta
		)

	else:

		velocidade_atual = velocidade_atual.lerp(
			Vector2.ZERO,
			12.0 * delta
		)

	global_position += velocidade_atual * delta
