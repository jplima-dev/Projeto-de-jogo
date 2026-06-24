extends Control

@onready var anim = $Anim

@onready var slider_geral = $botoes_audio/HBoxContainer/VBoxContainer/HBoxContainer/HSlider
@onready var slider_musica = $botoes_audio/HBoxContainer/VBoxContainer/HBoxContainer2/HSlider2
@onready var slider_efeitos = $botoes_audio/HBoxContainer/VBoxContainer/HBoxContainer3/HSlider3


func _ready() -> void:

	anim.play("fade_botões")

	# Carrega os valores salvos
	slider_geral.value = Config.master_volume * 100
	slider_musica.value = Config.music_volume * 100
	slider_efeitos.value = Config.sfx_volume * 100


func _on_h_slider_value_changed(value):

	Config.master_volume = value / 100.0

	Config.aplicar()
	Config.salvar()


func _on_h_slider_2_value_changed(value):

	Config.music_volume = value / 100.0

	Config.aplicar()
	Config.salvar()


func _on_h_slider_3_value_changed(value):

	Config.sfx_volume = value / 100.0

	Config.aplicar()
	Config.salvar()


func _on_back_btn_pressed() -> void:

	get_tree().change_scene_to_file("res://config.tscn")
