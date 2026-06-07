extends Node

var next_scene := ""

var menu_music: AudioStreamPlayer


func _ready():

	menu_music = AudioStreamPlayer.new()
	add_child(menu_music)

	menu_music.stream = preload("res://whvle-aboard-a-aurora-game-menu-pulse-203549.mp3")
	menu_music.bus = "Music"
	menu_music.volume_db = -5
	menu_music.autoplay = false


func tocar_menu():

	if menu_music.playing:
		return

	menu_music.volume_db = -80

	menu_music.play()

	var tween = create_tween()

	tween.tween_property(
		menu_music,
		"volume_db",
		-5,
		2.0
	)


func parar_menu():

	if not menu_music.playing:
		return

	var tween = create_tween()

	tween.tween_property(
		menu_music,
		"volume_db",
		-20,
		1.5
	)

	await tween.finished

	menu_music.stop()

	menu_music.volume_db = -5
