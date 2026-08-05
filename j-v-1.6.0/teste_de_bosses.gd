extends Node2D

const PLAYER = preload("res://leandro2.tscn")
const BOSS = preload("res://1_cap1.tscn") # cena do mouse


var player
var boss


func _ready():

	# instancia player
	player = PLAYER.instantiate()
	add_child(player)

	player.global_position = $PlayerSpawn.global_position
	player.get_node("Camera2D").enabled = false

	# instancia boss
	boss = BOSS.instantiate()
	add_child(boss)

	boss.global_position = $BossSpawn.global_position

	# faz a câmera seguir o player
	var camera = player.get_node("Camera2D")

	camera.enabled = true
