extends CanvasLayer

@onready var barra = $Control/TextureProgressBar
@onready var nome = $Control/Label

var boss = null

func configurar(alvo, nome_boss: String):

	boss = alvo

	nome.text = nome_boss

	barra.max_value = boss.max_health
	barra.value = boss.health

	visible = true


func _process(_delta):

	if boss == null:
		queue_free()
		return

	barra.value = boss.health

	if boss.health <= 0:
		queue_free()
