extends Area2D

var player = null


# Called when the node enters the scene tree for the first time.
func _ready():
	if player == null:
		player = get_tree().get_first_node_in_group("player")

	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_body_entered(body):
	print("Colidiu com:", body.name)
	
	if body.is_in_group("player"):
		body.take_damage(15)
