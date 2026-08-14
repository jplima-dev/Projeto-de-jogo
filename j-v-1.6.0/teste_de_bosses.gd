extends Node2D


const PLAYER = preload("res://leandro2.tscn")
const BOSS = preload("res://cap1/bosses/1_cap1.tscn")
const PONTA_USB = preload("res://cap1/bosses/pontausb.tscn")
const CABO_USB = preload("res://cap1/bosses/cabousb.tscn")


var player
var boss
var ponta_usb
var cabo_usb


func _ready():

	# ==========================
	# PLAYER
	# ==========================

	player = PLAYER.instantiate()

	add_child(player)

	player.global_position = $PlayerSpawn.global_position

	# Desativa a câmera enquanto configuramos a cena
	player.get_node("Camera2D").enabled = false


	# ==========================
	# BOSS / MOUSE
	# ==========================

	boss = BOSS.instantiate()

	print("Boss: ", boss)

	add_child(boss)

	boss.global_position = $BossSpawn.global_position


	# ==========================
	# PONTA DO CABO USB
	# ==========================

	ponta_usb = PONTA_USB.instantiate()

	add_child(ponta_usb)

	# Começa próxima do mouse
	ponta_usb.global_position = (
		boss.global_position
		+ Vector2(-80, 0)
	)


	# ==========================
	# CABO USB
	# ==========================

	cabo_usb = CABO_USB.instantiate()

	add_child(cabo_usb)


	# ==========================
	# CÂMERA DO PLAYER
	# ==========================

	var camera = player.get_node("Camera2D")

	camera.enabled = true
