extends Camera2D

var intensidade := 0.0

func tremer(forca: float):

	intensidade = max(intensidade, forca)


func _process(delta):

	if intensidade > 0.0:

		offset = Vector2(
			randf_range(-intensidade, intensidade),
			randf_range(-intensidade, intensidade)
		)

		intensidade = lerp(intensidade, 0.0, 20.0 * delta)

	else:

		offset = Vector2.ZERO
