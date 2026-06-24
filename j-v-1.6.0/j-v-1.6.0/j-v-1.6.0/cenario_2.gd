extends Node2D

# =========================
# PLAYER
# =========================
var player_scene = preload("res://leandro2.tscn")

var player: CharacterBody2D

@onready var player_spawn = $PlayerSpawn


# =========================
# READY
# =========================
func _ready():

	# instancia player
	player = player_scene.instantiate()

	# adiciona na cena
	add_child(player)

	# posiciona no spawn
	player.global_position = player_spawn.global_position
