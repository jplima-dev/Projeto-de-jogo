extends Area2D

var caster = null

@export var speed := 700.0
@export var damage := 25
@export var lifetime := 2.0

var direction := Vector2.RIGHT

func _ready():

	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _process(delta):

	global_position += direction * speed * delta


func _on_body_entered(body):

	print("BODY:", body.name)

	if body == caster:
		return

	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()


func _on_area_entered(area):

	var enemy = area.get_parent()

	if enemy.is_in_group("enemies"):

		print("INIMIGO ACERTADO:", enemy.name)

		enemy.take_damage(damage)

		queue_free()
