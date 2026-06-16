extends Control

@onready var anim = $Anim

func _ready():

	anim.play("fade_botões")

	atualizar_slot(
		$MarginContainer/VBoxContainer/HBoxContainer/Slot1,
		1
	)

	atualizar_slot(
		$MarginContainer/VBoxContainer/HBoxContainer/Slot2,
		2
	)

	atualizar_slot(
		$MarginContainer/VBoxContainer/HBoxContainer/Slot3,
		3
	)

	$MarginContainer/VBoxContainer/HBoxContainer/Slot1.pressed.connect(_slot1)

	$MarginContainer/VBoxContainer/HBoxContainer/Slot2.pressed.connect(_slot2)

	$MarginContainer/VBoxContainer/HBoxContainer/Slot3.pressed.connect(_slot3)


func _slot1():
	criar_save(1)

func _slot2():
	criar_save(2)

func _slot3():
	criar_save(3)


func criar_save(slot):

	var caminho = "user://slot%d.json" % slot

	var dados = {
		"capitulo": 1,
		"parte": 1,
		"horas": 0,
		"minutos": 0,

		"cena": "res://cutscene_inicial.tscn",

		"posicao_x": 0,
		"posicao_y": 0
	}

	var arquivo = FileAccess.open(
		caminho,
		FileAccess.WRITE
	)

	arquivo.store_string(
		JSON.stringify(dados)
	)

	print("SAVE CRIADO NO SLOT ", slot)
	
	Loading.parar_menu()

	get_tree().change_scene_to_file(
		"res://carregamento.tscn"
	)


func carregar_slot(numero_slot):

	var caminho = "user://slot%d.json" % numero_slot

	if !FileAccess.file_exists(caminho):
		return null

	var arquivo = FileAccess.open(
		caminho,
		FileAccess.READ
	)

	return JSON.parse_string(
		arquivo.get_as_text()
	)


func atualizar_slot(slot_node, numero_slot):

	var dados = carregar_slot(numero_slot)

	var titulo = slot_node.get_node("VBoxContainer/LabelTitulo")
	var capitulo = slot_node.get_node("VBoxContainer/LabelCapitulo")
	var parte = slot_node.get_node("VBoxContainer/LabelParte")
	var tempo = slot_node.get_node("VBoxContainer/LabelTempo")

	if dados == null:

		titulo.text = "SLOT %d" % numero_slot
		capitulo.text = "Vazio"
		parte.text = ""
		tempo.text = ""

		return

	titulo.text = "SLOT %d" % numero_slot

	capitulo.text = "Cap %d" % dados["capitulo"]

	parte.text = "Part %d" % dados["parte"]

	tempo.text = "%02dh %02dmin" % [
		dados["horas"],
		dados["minutos"]
	]	


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://tatlescreen/tatlescreen.tscn")
