extends Control

@onready var anim = $Anim

@onready var slider_geral = $botoes_audio/HBoxContainer/VBoxContainer/HBoxContainer/HSlider
@onready var slider_musica = $botoes_audio/HBoxContainer/VBoxContainer/HBoxContainer2/HSlider2
@onready var slider_efeitos = $botoes_audio/HBoxContainer/VBoxContainer/HBoxContainer3/HSlider3

var bus_master : int
var bus_music : int
var bus_sfx : int


func _ready() -> void:

	anim.play("fade_botões")

	bus_master = AudioServer.get_bus_index("Master")
	bus_music = AudioServer.get_bus_index("Music")
	bus_sfx = AudioServer.get_bus_index("SFX")

	# Define valores iniciais dos sliders
	slider_geral.value = db_to_linear(
		AudioServer.get_bus_volume_db(bus_master)
	) * 100

	slider_musica.value = db_to_linear(
		AudioServer.get_bus_volume_db(bus_music)
	) * 100

	slider_efeitos.value = db_to_linear(
		AudioServer.get_bus_volume_db(bus_sfx)
	) * 100


func _on_h_slider_value_changed(value):

	if value <= 0:
		AudioServer.set_bus_volume_db(bus_master, -80)
	else:
		AudioServer.set_bus_volume_db(
			bus_master,
			linear_to_db(value / 100.0)
		)


func _on_h_slider_2_value_changed(value):

	if value <= 0:
		AudioServer.set_bus_volume_db(bus_music, -80)
	else:
		AudioServer.set_bus_volume_db(
			bus_music,
			linear_to_db(value / 100.0)
		)


func _on_h_slider_3_value_changed(value):

	if value <= 0:
		AudioServer.set_bus_volume_db(bus_sfx, -80)
	else:
		AudioServer.set_bus_volume_db(
			bus_sfx,
			linear_to_db(value / 100.0)
		)


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://config.tscn")
