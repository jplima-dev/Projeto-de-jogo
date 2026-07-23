extends Node

var ataques := {}


func _ready():

	print("ATTACK MANAGER INICIADO")

	carregar_ataques()

	print(ataques)


func carregar_ataques():

	var dir = DirAccess.open("res://Ataques")

	if dir == null:
		push_error("Pasta Ataques não encontrada.")
		return

	dir.list_dir_begin()

	while true:

		var nome = dir.get_next()

		if nome == "":
			break

		if dir.current_is_dir():

			var caminho = "res://Ataques/%s/%s.tscn" % [nome, nome]

			if ResourceLoader.exists(caminho):

				ataques[nome.to_lower()] = load(caminho)

	dir.list_dir_end()


func executar(comando:String, player):
	
	print(player)
	print(player.get_class())

	print("Executando:", comando)

	match comando:
		"heal":
			print("HEAL ENCONTRADO")

	comando = comando.to_lower()

	if !ataques.has(comando):
		print("Ataque inexistente:", comando)
		return false

	var ataque = ataques[comando].instantiate()

	get_tree().current_scene.add_child(ataque)

	if ataque.has_method("usar"):
		ataque.usar(player)

	return true
