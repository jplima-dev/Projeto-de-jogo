extends Control

@export var player: NodePath

@onready var player_node: Node2D = get_node_or_null(player)

@onready var habilidades = $VBoxContainer/Habilidades
@onready var regras = $VBoxContainer/Regras

const ESCALA_NORMAL := Vector2.ONE
const ESCALA_HOVER := Vector2(1.25, 1.25)
const VELOCIDADE := 10.0

var botao_hover: Control = null


func _ready():

	visible = false

	habilidades.visible = true
	regras.visible = true


func _process(delta):

	if !player_node:
		return

	if Input.is_action_pressed("inv"):

		visible = true

	else:

		visible = false

	animar_botoes(habilidades, delta)
	animar_botoes(regras, delta)


func animar_botoes(container: Control, delta):

	for botao in container.get_node("GridContainer").get_children():

		var alvo = ESCALA_NORMAL

		if botao == botao_hover:
			alvo = ESCALA_HOVER

		botao.scale = botao.scale.lerp(alvo, VELOCIDADE * delta)


# ---------- HABILIDADES ----------

func _on_button_mouse_entered():
	botao_hover = $VBoxContainer/Habilidades/GridContainer/Button

func _on_button_mouse_exited():
	if botao_hover == $VBoxContainer/Habilidades/GridContainer/Button:
		botao_hover = null


func _on_button_2_mouse_entered():
	botao_hover = $VBoxContainer/Habilidades/GridContainer/Button2

func _on_button_2_mouse_exited():
	if botao_hover == $VBoxContainer/Habilidades/GridContainer/Button2:
		botao_hover = null


func _on_button_3_mouse_entered():
	botao_hover = $VBoxContainer/Habilidades/GridContainer/Button3

func _on_button_3_mouse_exited():
	if botao_hover == $VBoxContainer/Habilidades/GridContainer/Button3:
		botao_hover = null


func _on_button_4_mouse_entered():
	botao_hover = $VBoxContainer/Habilidades/GridContainer/Button4

func _on_button_4_mouse_exited():
	if botao_hover == $VBoxContainer/Habilidades/GridContainer/Button4:
		botao_hover = null


# ---------- REGRAS ----------

func _on_button_5_mouse_entered():
	botao_hover = $VBoxContainer/Regras/GridContainer/Button5

func _on_button_5_mouse_exited():
	if botao_hover == $VBoxContainer/Regras/GridContainer/Button5:
		botao_hover = null


func _on_button_6_mouse_entered():
	botao_hover = $VBoxContainer/Regras/GridContainer/Button6

func _on_button_6_mouse_exited():
	if botao_hover == $VBoxContainer/Regras/GridContainer/Button6:
		botao_hover = null


func _on_button_7_mouse_entered():
	botao_hover = $VBoxContainer/Regras/GridContainer/Button7

func _on_button_7_mouse_exited():
	if botao_hover == $VBoxContainer/Regras/GridContainer/Button7:
		botao_hover = null


func _on_button_8_mouse_entered():
	botao_hover = $VBoxContainer/Regras/GridContainer/Button8

func _on_button_8_mouse_exited():
	if botao_hover == $VBoxContainer/Regras/GridContainer/Button8:
		botao_hover = null
