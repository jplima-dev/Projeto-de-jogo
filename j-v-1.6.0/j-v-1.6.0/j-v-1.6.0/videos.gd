extends Control

@onready var anim = $Anim

@onready var btn_tela_cheia = $botões_principai/HBoxContainer/VBoxContainer/HBoxContainer/tela_cheia
@onready var btn_resolucao = $botões_principai/HBoxContainer/VBoxContainer/HBoxContainer2/resolução

var resolucoes = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]

var resolucao_atual := 0


func _ready() -> void:

	anim.play("fade_botões")

	# Descobre qual resolução está salva
	for i in range(resolucoes.size()):
		if resolucoes[i] == Config.resolution:
			resolucao_atual = i
			break

	atualizar_textos()


func atualizar_textos():

	btn_tela_cheia.text = (
		"ON" if Config.fullscreen else "OFF"
	)

	var r = resolucoes[resolucao_atual]

	btn_resolucao.text = "%dx%d" % [
		r.x,
		r.y
	]


func _on_tela_cheia_pressed():

	Config.fullscreen = !Config.fullscreen

	Config.aplicar()
	Config.salvar()

	atualizar_textos()


func _on_resolução_pressed():

	resolucao_atual += 1

	if resolucao_atual >= resolucoes.size():
		resolucao_atual = 0

	Config.resolution = resolucoes[resolucao_atual]

	Config.aplicar()
	Config.salvar()

	atualizar_textos()


func _on_back_btn_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://config.tscn"
	)


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
