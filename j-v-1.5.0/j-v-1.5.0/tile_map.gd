extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	# Configurar limites da câmera com base no TileMap
	var tilemap = get_node("/root/Main/TileMap")  # Ajuste esse caminho conforme sua cena
	var camera = $Camera2D



	
