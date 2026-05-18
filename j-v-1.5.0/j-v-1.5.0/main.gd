extends Node

@onready var container: Control = $SceneContainer

const MENU := "res://tatlescreen/tela.tscn"
const PLAYER := "res://leandro.tscn"
const ENEMY := "res://jubis.tscn"
const SCENARIO := "res://cenario.tscn"

func _ready():
	call_deferred("load_menu")

# ================= MENU =================
func load_menu() -> void:
	_clear_container()
	_load_and_add(MENU)

# ================= JOGO =================
func load_game() -> void:
	_clear_container()
	_load_and_add(SCENARIO)
	_load_and_add(PLAYER)
	_load_and_add(ENEMY)

# ================= UTIL =================
func _load_and_add(path: String) -> void:
	var packed: PackedScene = load(path)
	if packed == null:
		push_error("Não achou: " + path)
		return

	var scene: Node = packed.instantiate()
	container.add_child(scene)

func _clear_container() -> void:
	for child in container.get_children():
		child.queue_free()
