extends Camera2D

var shake_strength := 0.0

func _process(delta):
	if shake_strength > 0:
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_strength = lerp(shake_strength, 0.0, 10 * delta)
	else:
		offset = Vector2.ZERO

func add_shake(amount: float):
	shake_strength = amount
