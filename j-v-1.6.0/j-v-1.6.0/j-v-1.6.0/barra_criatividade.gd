extends AnimatedSprite2D

@export var tempo_total := 25.0

var tempo_atual := 25.0
var criatividade := 100.0
var ativo := false

var terminal


func iniciar(novo_terminal):

	terminal = novo_terminal

	tempo_atual = tempo_total
	criatividade = 100.0

	visible = true
	ativo = true



func parar():

	ativo = false


func _process(delta):

	if !ativo:
		return

	tempo_atual -= delta

	# atualiza a barra pelo tempo
	var porcentagem_tempo = tempo_atual / tempo_total

	if porcentagem_tempo > 0.8:
		frame = 0

	elif porcentagem_tempo > 0.6:
		frame = 1

	elif porcentagem_tempo > 0.4:
		frame = 2

	elif porcentagem_tempo > 0.2:
		frame = 3

	else:
		frame = 4

	# tempo acabou
	if tempo_atual <= 0:

		ativo = false

		if terminal:

			await terminal.piscar_terminal()

			terminal.fechar()


func habilidade_criada():

	criatividade -= 40

	if criatividade < 0:
		criatividade = 0

	print("CRIATIVIDADE:", criatividade)


func regra_criada():

	criatividade -= 40

	if criatividade < 0:
		criatividade = 0

	print("CRIATIVIDADE:", criatividade)


func erro_sintaxe():

	criatividade -= 15

	if criatividade < 0:
		criatividade = 0

	print("CRIATIVIDADE:", criatividade)


func tem_criatividade(valor: float) -> bool:

	return criatividade >= valor
