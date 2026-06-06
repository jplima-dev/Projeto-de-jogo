extends Control

@onready var anim = $Anim

@onready var btn_cima = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/cima
@onready var btn_baixo = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/baixo
@onready var btn_esquerda = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer3/esquerda
@onready var btn_direita = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer4/direita

var esperando_tecla = false
var acao_atual = ""
var botao_atual : Button


func _ready() -> void:

	carregar_controles()

	anim.play("fade_botões")

	atualizar_botao(btn_cima, "move-up")
	atualizar_botao(btn_baixo, "move-down")
	atualizar_botao(btn_esquerda, "move-left")
	atualizar_botao(btn_direita, "move-right")

func atualizar_botao(botao: Button, acao: String):

	var eventos = InputMap.action_get_events(acao)

	if eventos.size() > 0:

		var evento = eventos[0]

		if evento is InputEventKey:
			botao.text = char(evento.physical_keycode)

	else:
		botao.text = "Nenhuma"


func iniciar_remapeamento(acao: String, botao: Button):

	acao_atual = acao
	botao_atual = botao

	botao.text = "..."
	esperando_tecla = true


func _input(event):

	if not esperando_tecla:
		return

	if event is InputEventKey and event.pressed:

		InputMap.action_erase_events(acao_atual)
		InputMap.action_add_event(acao_atual, event)

		botao_atual.text = char(event.physical_keycode)

		salvar_controles()

		esperando_tecla = false
		acao_atual = ""
		botao_atual = null

func _on_cima_pressed():
	iniciar_remapeamento("move-up", btn_cima)


func _on_baixo_pressed():
	iniciar_remapeamento("move-down", btn_baixo)


func _on_esquerda_pressed():
	iniciar_remapeamento("move-left", btn_esquerda)


func _on_direita_pressed():
	iniciar_remapeamento("move-right", btn_direita)


func _on_quit_btn_4_pressed() -> void:
	get_tree().change_scene_to_file("res://config.tscn")
	
	
func destacar_botao(botao: Button):
	botao.text = "> " + botao.text


func remover_destaque(botao: Button):
	botao.text = botao.text.replace("> ", "")
	
func _on_cima_mouse_entered():
	destacar_botao(btn_cima)

func _on_cima_mouse_exited():
	remover_destaque(btn_cima)
	
func _on_baixo_mouse_entered():
	destacar_botao(btn_baixo)

func _on_baixo_mouse_exited():
	remover_destaque(btn_baixo)
	
func _on_esquerda_mouse_entered():
	destacar_botao(btn_esquerda)

func _on_esquerda_mouse_exited():
	remover_destaque(btn_esquerda)
	
func _on_direita_mouse_entered():
	destacar_botao(btn_direita)

func _on_direita_mouse_exited():
	remover_destaque(btn_direita)
	

func salvar_acao(config: ConfigFile, acao: String):

	var eventos = InputMap.action_get_events(acao)

	if eventos.size() > 0:

		var evento = eventos[0]

		if evento is InputEventKey:
			config.set_value(
				"controles",
				acao,
				evento.physical_keycode
			)
			
			
func salvar_controles():

	var config = ConfigFile.new()

	salvar_acao(config, "move-up")
	salvar_acao(config, "move-down")
	salvar_acao(config, "move-left")
	salvar_acao(config, "move-right")

	config.save("user://controles.cfg")
	
	
func carregar_controles():

	var config = ConfigFile.new()

	if config.load("user://controles.cfg") != OK:
		return

	carregar_acao(config, "move-up")
	carregar_acao(config, "move-down")
	carregar_acao(config, "move-left")
	carregar_acao(config, "move-right")


func carregar_acao(config: ConfigFile, acao: String):

	if not config.has_section_key("controles", acao):
		return

	var keycode = config.get_value(
		"controles",
		acao
	)

	var evento = InputEventKey.new()
	evento.physical_keycode = keycode

	InputMap.action_erase_events(acao)
	InputMap.action_add_event(acao, evento)
