extends Node2D

@export var fade_speed := 8.0
@export var blur_scale := 1.0
@export var ghost_color := Color.WHITE

var fade_delay := 0.0
var can_fade := false

func setup():
	modulate = ghost_color
	scale *= blur_scale

	if fade_delay > 0:
		await get_tree().create_timer(fade_delay).timeout

	can_fade = true


func _process(delta):

	if !can_fade:
		return

	modulate.a -= fade_speed * delta

	if modulate.a <= 0:
		queue_free()
