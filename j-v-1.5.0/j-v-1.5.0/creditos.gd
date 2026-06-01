extends Control

@onready var scroll_container = $ScrollContainer

var velocidade = 60.0


func _ready():
	scroll_container.scroll_vertical = 0

	var v_bar = scroll_container.get_v_scroll_bar()
	v_bar.modulate.a = 0

	var h_bar = scroll_container.get_h_scroll_bar()
	h_bar.modulate.a = 0


func _physics_process(delta):
	scroll_container.set_v_scroll(
		scroll_container.get_v_scroll() + velocidade * delta
	)
