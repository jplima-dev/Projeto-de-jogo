extends Node2D

@onready var label = $Panel/MarginContainer/Label

var alvo: Node2D


func iniciar(texto: String, novo_alvo: Node2D):

	label.text = texto

	alvo = novo_alvo


func _process(_delta):

	if alvo:

		global_position = alvo.global_position
