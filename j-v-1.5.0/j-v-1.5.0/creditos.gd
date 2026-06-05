extends Control

@onready var scroll_container = $ScrollContainer
@onready var anim = $AnimationPlayer

var velocidade = 100.0
var terminou = false
var ultimo_scroll = -1

func _ready():
	scroll_container.scroll_vertical = 0

	var v_bar = scroll_container.get_v_scroll_bar()
	v_bar.modulate.a = 0

	var h_bar = scroll_container.get_h_scroll_bar()
	h_bar.modulate.a = 0


func _physics_process(delta):
	if terminou:
		return

	scroll_container.scroll_vertical += velocidade * delta

	# Se o scroll não mudou desde o frame anterior,
	# significa que chegou ao fim.
	if scroll_container.scroll_vertical == ultimo_scroll:
		terminou = true
		print("CHEGOU NO FINAL")
		anim.play("fade_logo_creditos")
	

	ultimo_scroll = scroll_container.scroll_vertical	
