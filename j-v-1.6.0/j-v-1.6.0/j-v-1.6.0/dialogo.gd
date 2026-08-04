extends Node2D

@export var offset := Vector2(25, 65)

@onready var label = $Panel/MarginContainer/Label
@onready var audio_letra = $Voz

var alvo: Node2D

var pulando := false
var digitando := false
var avancar := false


func iniciar(texto: String, novo_alvo: Node2D):
	
	print("===================")
	print("ALVO:", novo_alvo)
	print("TIPO:", novo_alvo.get_class())
	print("NOME:", novo_alvo.name)
	print("===================")

	alvo = novo_alvo

	label.visible = true
	label.text = ""

	pulando = false
	digitando = true
	avancar = false

	# Começa na posição correta
	global_position = alvo.global_position + offset

	scale = Vector2(0.1, 0.1)
	modulate.a = 0.0

	var tween = create_tween()
	tween.set_parallel()

	tween.tween_property(self, "modulate:a", 1.0, 0.15)
	tween.tween_property(self, "scale", Vector2.ONE, 0.25)
	tween.tween_property(
		self,
		"global_position",
		alvo.global_position + offset,
		0.25
	)

	await tween.finished

	# Digitação
	for letra in texto:

		if pulando:
			label.text = texto
			break

		label.text += letra

		if letra != " ":
			tocar_som_letra()

		await get_tree().create_timer(0.03).timeout

	digitando = false

	var tempo := 0.0

	while tempo < 0.5:

		if avancar:
			break

		await get_tree().process_frame

		tempo += get_process_delta_time()

	await desaparecer()


func desaparecer():

	var tween = create_tween()
	tween.set_parallel()

	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.20)
	tween.tween_property(self, "global_position", alvo.global_position + offset, 0.20)
	tween.tween_property(self, "modulate:a", 0.0, 0.20)

	await tween.finished

	if is_instance_valid(alvo):
		alvo.pode_controlar = true

	queue_free()


func _process(_delta):

	if alvo and scale.x >= 0.9:
		global_position = alvo.global_position + offset


func _unhandled_input(event):

	if !event.is_action_pressed("ui_accept"):
		return

	if digitando:
		pulando = true
	else:
		avancar = true


func tocar_som_letra():

	audio_letra.pitch_scale = randf_range(0.85, 1.0)
	audio_letra.play()
