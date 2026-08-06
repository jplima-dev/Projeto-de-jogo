extends Area2D

const DIALOGO = preload("res://dialogo.tscn")
const DOCUMENTO = preload("res://documentos.tscn")

var dialogo_aberto := false


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):

	if !body.is_in_group("player"):
		return

	if dialogo_aberto:
		return

	dialogo_aberto = true

	body.pode_controlar = false

	# ==========================
	# Primeira fala
	# ==========================

	var dialogo = DIALOGO.instantiate()
	get_tree().current_scene.add_child(dialogo)

	await dialogo.iniciar(
		"Hmm... What's this?",
		body
	)

	# ==========================
	# Segunda fala
	# ==========================

	dialogo = DIALOGO.instantiate()
	get_tree().current_scene.add_child(dialogo)
	
	print(body)
	print(body.get_class())
	print(body.name)

	await dialogo.iniciar(
		"Fire.leo...",
		body
	)

	# ==========================
	# Abre o documento
	# ==========================

	var documento = DOCUMENTO.instantiate()

	get_tree().current_scene.add_child(documento)

	documento.abrir("res://Papeis/.txt/fire.txt")

	# Espera o jogador fechar o documento
	await documento.tree_exited
	
	Skilldata.aprender("fire")

	body.pode_controlar = true

	dialogo_aberto = false
