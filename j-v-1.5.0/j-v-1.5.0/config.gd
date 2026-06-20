extends Node

const ARQUIVO := "user://config.cfg"

var master_volume := 0.8
var music_volume := 0.8
var sfx_volume := 0.8

var fullscreen := false
var resolution := Vector2i(1600, 900)


func _ready():
	carregar()


func salvar():

	var cfg = ConfigFile.new()

	cfg.set_value("audio", "master", master_volume)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)

	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.set_value("video", "width", resolution.x)
	cfg.set_value("video", "height", resolution.y)

	cfg.save(ARQUIVO)


func carregar():

	var cfg = ConfigFile.new()

	if cfg.load(ARQUIVO) != OK:

		# Primeira vez abrindo o jogo
		salvar()
		aplicar()
		return

	master_volume = cfg.get_value("audio", "master", 0.8)
	music_volume = cfg.get_value("audio", "music", 0.8)
	sfx_volume = cfg.get_value("audio", "sfx", 0.8)

	fullscreen = cfg.get_value("video", "fullscreen", false)

	resolution = Vector2i(
		cfg.get_value("video", "width", 1600),
		cfg.get_value("video", "height", 900)
	)

	aplicar()


func aplicar():

	# ---------- VÍDEO ----------

	if fullscreen:

		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)

	else:

		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)

		DisplayServer.window_set_size(resolution)

		# Espera a Godot aplicar o novo tamanho
		call_deferred("centralizar_janela")

	# ---------- ÁUDIO ----------

	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(master_volume)
	)

	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(music_volume)
	)

	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(sfx_volume)
	)


func centralizar_janela():

	if fullscreen:
		return

	var tela = DisplayServer.screen_get_usable_rect().size

	var tamanho = DisplayServer.window_get_size()

	var posicao = (tela - tamanho) / 2

	DisplayServer.window_set_position(Vector2i(posicao))
