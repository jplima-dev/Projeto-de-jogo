extends Node2D

@onready var panel = $CanvasLayer/Panel
@onready var texto = $CanvasLayer/Panel/LineEdit
@onready var anim = $CanvasLayer/Panel/BarraTopo/AnimatedSprite2D
@onready var barra = $CanvasLayer/Panel/BarraTopo/AnimatedSprite2D

var alvo: Node2D
var aberto := false


func _ready():

	texto.wrap_mode = TextEdit.LINE_WRAPPING_NONE

	$CanvasLayer.visible = false

	anim.play("default")

	texto.text = "> "


func abrir(novo_alvo:Node2D):

	if aberto:
		return

	aberto = true
	alvo = novo_alvo

	$CanvasLayer.visible = true
	panel.visible = true

	texto.text = "> "

	panel.scale = Vector2(0.1,0.1)
	panel.modulate.a = 0

	var tween = create_tween()
	tween.set_parallel()

	tween.tween_property(panel,"scale",Vector2.ONE,0.25)
	tween.tween_property(panel,"modulate:a",1.0,0.25)

	await tween.finished

	barra.iniciar(self)

	texto.grab_focus()

	texto.set_caret_line(texto.get_line_count()-1)
	texto.set_caret_column(2)


func fechar():

	if !aberto:
		return

	aberto = false

	texto.release_focus()

	var tween = create_tween()

	tween.set_parallel()

	tween.tween_property(panel,"scale",Vector2(0.1,0.1),0.20)
	tween.tween_property(panel,"modulate:a",0.0,0.20)

	await tween.finished

	barra.parar()

	panel.visible = false
	$CanvasLayer.visible = false


func _process(_delta):

	if alvo and aberto:
		global_position = alvo.global_position

	if aberto and !texto.has_focus():
		texto.grab_focus()

	_forcar_ultima_linha()


func _forcar_ultima_linha():

	var ultima = texto.get_line_count()-1

	if texto.get_caret_line() < ultima:
		texto.set_caret_line(ultima)

	if texto.get_caret_column() < 2:
		texto.set_caret_column(2)


#func _unhandled_input(event):
#
	#if !aberto:
		#return
#
	#if event.is_action_pressed("ui_cancel"):
#
		#fechar()
		#get_viewport().set_input_as_handled()
		#return
#
#
	#if event is InputEventKey and event.pressed:
#
		#if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
#
			#executar_comando()
#
			#get_viewport().set_input_as_handled()
			#return
#
		#if event.keycode == KEY_BACKSPACE:
#
			#if texto.get_caret_column() <= 2:
				#get_viewport().set_input_as_handled()


func executar_comando():

	print("1")

	var linhas = texto.text.split("\n")

	print("2")

	var comando = linhas[linhas.size() - 1]

	print("3")

	comando = comando.replace("> ", "")
	comando = comando.strip_edges().to_lower()

	print("Comando =", comando)

	print("4")

	var resultado = AttackManager.executar(comando, alvo)

	print("Resultado =", resultado)

	print("5")

	await fechar()

	print("6")


func nova_linha_terminal():

	texto.insert_text_at_caret("\n> ")

	var ultima = texto.get_line_count()-1

	texto.set_caret_line(ultima)
	texto.set_caret_column(2)
	
func _input(event):

	if !aberto:
		return

	if event is InputEventKey and event.pressed:

		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:

			print("ENTER DETECTADO")

			executar_comando()

			get_viewport().set_input_as_handled()

		elif event.keycode == KEY_ESCAPE:

			fechar()

			get_viewport().set_input_as_handled()
