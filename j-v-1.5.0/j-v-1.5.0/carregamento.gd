extends Node2D

@export var next_scene: String = "res://cenario.tscn"

@onready var fade: ColorRect = $CanvasLayer/ColorRect
@onready var bar: ProgressBar = $CanvasLayer/ProgressBar

var progress: Array[float] = []
var loading_finished := false

func _ready():
	if next_scene.is_empty() or !ResourceLoader.exists(next_scene):
		push_error("Cena inválida ou inexistente: " + next_scene)
		return

	fade.modulate.a = 1.0

	bar.min_value = 0
	bar.max_value = 100
	bar.value = 0
	bar.visible = true

	ResourceLoader.load_threaded_request(next_scene)

func _process(_delta):
	if loading_finished:
		return

	var status := ResourceLoader.load_threaded_get_status(next_scene, progress)

	if progress.size() > 0:
		bar.value = progress[0] * 100

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass

		ResourceLoader.THREAD_LOAD_LOADED:
			loading_finished = true
			await get_tree().process_frame
			var scene := ResourceLoader.load_threaded_get(next_scene) as PackedScene
			get_tree().change_scene_to_packed(scene)

		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Erro ao carregar a cena: " + next_scene)
			loading_finished = true
