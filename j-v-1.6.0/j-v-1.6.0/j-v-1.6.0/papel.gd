extends Area2D

const DIALOGO = preload("res://Dialogo.tscn")

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

	await dialogo.iniciar(
		"Fire.leo...",
		body
	)

	# ===================================
	# Aqui futuramente abriremos o documento
	# ===================================

	body.pode_controlar = true

	dialogo_aberto = false
