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


func abrir(novo_alvo: Node2D):

	if aberto:
		return

	aberto = true
	alvo = novo_alvo
	
	alvo.pode_controlar = false

	$CanvasLayer.visible = true
	panel.visible = true

	texto.text = "> "

	panel.scale = Vector2(0.1, 0.1)
	panel.modulate.a = 0.0

	var tween = create_tween()
	tween.set_parallel()
	tween.set_ignore_time_scale(true)

	tween.tween_property(panel, "scale", Vector2.ONE, 0.25)
	tween.tween_property(panel, "modulate:a", 1.0, 0.25)

	mudar_time_scale(0.6)

	await tween.finished

	barra.iniciar(self)

	texto.grab_focus()

	texto.set_caret_line(texto.get_line_count() - 1)
	texto.set_caret_column(2)


func fechar():
	
	alvo.pode_controlar = true

	if !aberto:
		return
		
	if alvo:
		alvo.pode_controlar = true

	aberto = false

	mudar_time_scale(1.0)

	texto.release_focus()

	var tween = create_tween()
	tween.set_parallel()
	tween.set_ignore_time_scale(true)

	tween.tween_property(panel, "scale", Vector2(0.1, 0.1), 0.20)
	tween.tween_property(panel, "modulate:a", 0.0, 0.20)

	await tween.finished

	barra.parar()

	panel.visible = false
	$CanvasLayer.visible = false


func mudar_time_scale(valor: float):

	var tween = create_tween()
	tween.set_ignore_time_scale(true)

	tween.tween_method(
		func(v):
			Engine.time_scale = v,
		Engine.time_scale,
		valor,
		0.15
	)


func _process(_delta):

	if alvo and aberto:
		global_position = alvo.global_position

	if aberto and !texto.has_focus():
		texto.grab_focus()

	_forcar_ultima_linha()


func _forcar_ultima_linha():

	var ultima = texto.get_line_count() - 1

	if texto.get_caret_line() < ultima:
		texto.set_caret_line(ultima)

	if texto.get_caret_column() < 2:
		texto.set_caret_column(2)


func executar_comando():

	var linhas = texto.text.split("\n")
	var comando = linhas[linhas.size() - 1]

	comando = comando.replace("> ", "")
	comando = comando.strip_edges().to_lower()

	# =====================================================
	# COMANDO DE EQUIPAR
	# fire as 1
	# heal as 2
	# =====================================================

	if comando.contains(" as "):

		var partes = comando.split(" as ")

		if partes.size() != 2:

			escrever_erro("Sintaxe inválida.")
			return

		var habilidade = partes[0].strip_edges().to_lower()
		var slot = int(partes[1])

		if !AttackManager.ataque_existe(habilidade):

			escrever_erro("Skill \"" + habilidade + "\" não existe.")
			return

		if SkilBar.equipar(habilidade, slot):

			var teclas = [
				"Y",
				"U",
				"I",
				"O",
				"H",
				"J",
				"K",
				"L"
			]

			escrever_sucesso("Registrando Skill...")

			await get_tree().create_timer(0.45).timeout

			escrever_sucesso(
				"Registrado no Slot %d (%s)." % [
					slot,
					teclas[slot - 1]
				]
			)
			
			texto.insert_text_at_caret("\n> ")


			await get_tree().create_timer(0.8).timeout

			await fechar()

			return

		else:

			escrever_erro("Slot inválido.")
			return


	# =====================================================
	# EXECUTA ATAQUE
	# =====================================================

	var resultado = AttackManager.executar(comando, alvo)

	if resultado:

		await fechar()

	else:

		escrever_erro("Comando inexistente.")

func nova_linha_terminal():

	texto.insert_text_at_caret("\n> ")

	var ultima = texto.get_line_count() - 1

	texto.set_caret_line(ultima)
	texto.set_caret_column(2)


func _input(event):

	if !aberto:
		return

	if event is InputEventKey and event.pressed:

		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:

			executar_comando()

			get_viewport().set_input_as_handled()

		elif event.keycode == KEY_ESCAPE:

			fechar()

			get_viewport().set_input_as_handled()
			
func escrever_linha(msg:String):

	texto.insert_text_at_caret("\n" + msg)


func escrever_erro(msg:String):

	escrever_linha("ERRO: " + msg)


func escrever_sucesso(msg:String):

	escrever_linha(msg)
