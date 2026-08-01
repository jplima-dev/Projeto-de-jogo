extends Control

@onready var habilidades = $VBoxContainer/Habilidades/GridContainer
@onready var regras = $VBoxContainer/Regras/GridContainer

const ESCALA_NORMAL = Vector2.ONE
const ESCALA_HOVER = Vector2(1.15,1.15)
const VELOCIDADE = 10.0

var aberto = false

var botoes = []
var indice = 0


func _ready():

	visible = false

	for b in habilidades.get_children():
		botoes.append(b)

	for b in regras.get_children():
		botoes.append(b)

	atualizar_selecao()


func _input(event):

	if event.is_action_pressed("inv"):

		aberto = !aberto
		visible = aberto

		if aberto:
			atualizar_nomes()

		return


	if !aberto:
		return


	if event.is_action_pressed("ui_right"):

		indice = (indice + 1) % botoes.size()
		atualizar_selecao()


	elif event.is_action_pressed("ui_left"):

		indice -= 1
		if indice < 0:
			indice = botoes.size()-1

		atualizar_selecao()


	elif event.is_action_pressed("ui_down"):

		indice += 4

		if indice >= botoes.size():
			indice = botoes.size()-1

		atualizar_selecao()


	elif event.is_action_pressed("ui_up"):

		indice -= 4

		if indice < 0:
			indice = 0

		atualizar_selecao()


	elif event.is_action_pressed("ui_accept"):

		executar_botao(indice)

		aberto = false
		visible = false



func _process(delta):

	if !aberto:
		return

	for i in range(botoes.size()):

		var alvo = ESCALA_NORMAL

		if i == indice:
			alvo = ESCALA_HOVER

		botoes[i].scale = botoes[i].scale.lerp(alvo, VELOCIDADE * delta)



func atualizar_selecao():
	pass



func executar_botao(slot:int):

	var ataque = SkilBar.pegar(slot + 1)

	if ataque == "":
		return

	var player = get_tree().get_first_node_in_group("player")

	AttackManager.executar(ataque, player)

func atualizar_nomes():

	for i in range(8):

		var atk = SkilBar.pegar(i + 1)

		if atk == "":
			botoes[i].text = "-"
		else:
			botoes[i].text = atk.capitalize()
