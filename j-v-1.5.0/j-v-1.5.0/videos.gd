extends Control

@onready var anim = $Anim

@onready var btn_tela_cheia = $botões_principai/HBoxContainer/VBoxContainer/HBoxContainer/tela_cheia

@onready var btn_resolucao = $botões_principai/HBoxContainer/VBoxContainer/HBoxContainer2/resolução

var fullscreen = false

var resolucoes = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]

var resolucao_atual = 0


func _ready() -> void:

	anim.play("fade_botões")

	atualizar_textos()
	
	print(btn_tela_cheia)
	print(btn_resolucao)


func atualizar_textos():

	btn_tela_cheia.text = ("ON" if fullscreen else "OFF")

	var r = resolucoes[resolucao_atual]
	btn_resolucao.text = "%dx%d" % [r.x, r.y]


func _on_tela_cheia_pressed():

	fullscreen = !fullscreen

	if fullscreen:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)
	else:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)

	atualizar_textos()


func _on_resolução_pressed():

	resolucao_atual += 1

	if resolucao_atual >= resolucoes.size():
		resolucao_atual = 0

	DisplayServer.window_set_size(
		resolucoes[resolucao_atual]
	)

	atualizar_textos()


func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://config.tscn")


func destacar_botao(botao: Button):
	if not botao.text.begins_with("> "):
		botao.text = "> " + botao.text


func remover_destaque(botao: Button):
	botao.text = botao.text.replace("> ", "")
	

func _on_tela_cheia_mouse_entered():
	destacar_botao(btn_tela_cheia)

func _on_tela_cheia_mouse_exited():
	remover_destaque(btn_tela_cheia)


func _on_resolução_mouse_entered():
	destacar_botao(btn_resolucao)

func _on_resolução_mouse_exited():
	remover_destaque(btn_resolucao)
