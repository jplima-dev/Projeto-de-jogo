extends Node2D

@onready var fade: ColorRect = $CanvasLayer/ColorRect

var progress: Array[float] = []
var loading_finished := false


func _ready():

	# =====================
	# PRIMEIRA CENA DO JOGO
	# =====================
	if Loading.next_scene.is_empty():
		Loading.next_scene = "res://cutscene_inicial.tscn"

	# =====================
	# VERIFICA SE EXISTE
	# =====================
	if !ResourceLoader.exists(Loading.next_scene):

		push_error(
			"Cena inválida ou inexistente: "
			+ Loading.next_scene
		)

		return

	# =====================
	# FADE
	# =====================
	fade.modulate.a = 1.0

	# =====================
	# COMEÇA CARREGAMENTO
	# =====================
	ResourceLoader.load_threaded_request(
		Loading.next_scene
	)


func _process(_delta):

	if loading_finished:
		return

	var status := ResourceLoader.load_threaded_get_status(
		Loading.next_scene,
		progress
	)

	match status:

		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass


		ResourceLoader.THREAD_LOAD_LOADED:

			loading_finished = true

			await get_tree().process_frame

			var scene := ResourceLoader.load_threaded_get(
				Loading.next_scene
			) as PackedScene

			get_tree().change_scene_to_packed(scene)


		ResourceLoader.THREAD_LOAD_FAILED:

			push_error(
				"Erro ao carregar a cena: "
				+ Loading.next_scene
			)

			loading_finished = true
