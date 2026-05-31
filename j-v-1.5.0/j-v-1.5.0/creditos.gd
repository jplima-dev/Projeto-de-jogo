extends Control

@onready var scroll_container = $ScrollContainer


func _ready():
	var barra = scroll_container.get_v_scroll_bar()
	barra.modulate.a = 0
	barra.hide()

func _process(delta):
	scroll_container.scroll_vertical += 60 * delta
