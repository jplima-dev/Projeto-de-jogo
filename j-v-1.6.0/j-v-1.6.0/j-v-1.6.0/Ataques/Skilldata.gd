extends Node

const CAMINHO := "user://skills.json"

var habilidades: Array[String] = []


func _ready():

	carregar()


func aprender(nome: String) -> bool:

	nome = nome.to_lower()

	if nome in habilidades:
		return false

	habilidades.append(nome)

	salvar()

	print("Nova habilidade aprendida:", nome)

	return true


func esquecer(nome: String):

	nome = nome.to_lower()

	if nome in habilidades:

		habilidades.erase(nome)

		salvar()


func tem(nome: String) -> bool:

	return nome.to_lower() in habilidades


func listar() -> Array[String]:

	return habilidades.duplicate()


func resetar():

	habilidades.clear()

	salvar()


func salvar():

	var dados = {
		"skills": habilidades
	}

	var arquivo = FileAccess.open(CAMINHO, FileAccess.WRITE)

	arquivo.store_string(JSON.stringify(dados, "\t"))

	arquivo.close()


func carregar():

	habilidades.clear()

	if !FileAccess.file_exists(CAMINHO):

		salvar()

		return

	var arquivo = FileAccess.open(CAMINHO, FileAccess.READ)

	var texto = arquivo.get_as_text()

	arquivo.close()

	var json = JSON.new()

	if json.parse(texto) != OK:

		push_error("Erro ao carregar skills.")

		return

	var dados = json.data

	if dados.has("skills"):

		for skill in dados["skills"]:

			habilidades.append(skill.to_lower())

	print("Skills carregadas:", habilidades)
