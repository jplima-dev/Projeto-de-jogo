extends Node

var slot_atual := 1

var dados = {
	"vida": 100,
	"max_vida": 100,
	"posicao_x": 0,
	"posicao_y": 0,
	"cena": "",
	"habilidades": [],

	"capitulo": 1,
	"parte": 1,
	"horas": 0,
	"minutos": 0
}


func salvar():

	var caminho = "user://slot%d.json" % slot_atual

	var arquivo = FileAccess.open(
		caminho,
		FileAccess.WRITE
	)

	arquivo.store_string(
		JSON.stringify(dados)
	)

	print("JOGO SALVO NO SLOT ", slot_atual)


func carregar():

	var caminho = "user://slot%d.json" % slot_atual

	if !FileAccess.file_exists(caminho):
		print("SAVE NÃO EXISTE")
		return

	var arquivo = FileAccess.open(
		caminho,
		FileAccess.READ
	)

	var texto = arquivo.get_as_text()

	var resultado = JSON.parse_string(texto)

	if resultado != null:
		dados = resultado

	print("JOGO CARREGADO DO SLOT ", slot_atual)
