extends Control

@export var player: NodePath
@export var offset := Vector2(0, -50)

@onready var player_node: Node2D = get_node(player)

func _ready():
	visible = false
	set_process_input(true)

func _process(_delta):
	if visible and player_node:
		# Converte posição do mundo → tela
		var cam := get_viewport().get_camera_2d()
		if cam:
			global_position = cam.unproject_position(
				player_node.global_position + offset
			)

func _unhandled_input(event):
	if event.is_action_pressed("inv"):
		visible = not visible
