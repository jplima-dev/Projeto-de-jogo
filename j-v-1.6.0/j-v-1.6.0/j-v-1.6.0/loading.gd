extends Node

var next_scene := ""

var player: AudioStreamPlayer

var musicas = {
	"menu": preload("res://whvle-aboard-a-aurora-game-menu-pulse-203549.mp3"),
	"boss": preload("res://teste.ogg"),
	"musica_cutscene": preload("res://musica.mp3"),
	
	# adicionar outras músicas aqui
	# "cidade": preload("res://musicas/cidade.ogg"),
	# "fase1": preload("res://musicas/fase1.ogg"),
}

func _ready():

	player = AudioStreamPlayer.new()
	add_child(player)

	player.bus = "Music"
	player.volume_db = -5


func tocar(nome: String, fade := true):

	if !musicas.has(nome):
		push_error("Música '%s' não encontrada." % nome)
		return

	# evita reiniciar a mesma música
	if player.playing and player.stream == musicas[nome]:
		return

	if fade and player.playing:

		var tween = create_tween()

		tween.tween_property(
			player,
			"volume_db",
			-60,
			1.0
		)

		await tween.finished

	player.stop()

	player.stream = musicas[nome]

	if fade:

		player.volume_db = -60
		player.play()

		var tween = create_tween()

		tween.tween_property(
			player,
			"volume_db",
			-5,
			1.5
		)

	else:

		player.volume_db = -5
		player.play()


func parar(fade := true):

	if !player.playing:
		return

	if fade:

		var tween = create_tween()

		tween.tween_property(
			player,
			"volume_db",
			-60,
			1.0
		)

		await tween.finished

	player.stop()
	player.volume_db = -5
