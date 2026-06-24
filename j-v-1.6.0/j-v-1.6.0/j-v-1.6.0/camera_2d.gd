extends Camera2D

var shake_strength := 0.0

const ZOOM_NORMAL := Vector2(2.0, 2.0)
const ZOOM_BATALHA := Vector2(1.2, 1.2)

func _ready():
	add_to_group("camera")
	make_current()
	zoom = ZOOM_NORMAL

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


func camera_batalha():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "zoom", ZOOM_BATALHA, 0.6)
	print("BATALHA ATIVADA")


func camera_normal():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "zoom", ZOOM_NORMAL, 0.6)
