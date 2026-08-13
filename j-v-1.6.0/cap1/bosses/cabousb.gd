extends Node2D


# ==========================================================
# CONFIGURAÇÃO DA CORDA
# ==========================================================

@export var quantidade_pontos := 24
@export var folga := 1
@export var gravidade := 200.0
@export var iteracoes_fisica := 10
@export var amortecimento := 0.995
@export var deslocamento_maximo := 10.0


# ==========================================================
# VISUAL
# ==========================================================

@export var largura_cabo := 8.0


# ==========================================================
# MARCADORES
# ==========================================================

var ponto_a: Node2D
var ponto_b: Node2D


# ==========================================================
# VERLET
# ==========================================================

var posicoes: Array[Vector2] = []
var posicoes_anteriores: Array[Vector2] = []

var comprimento_segmento := 0.0


# ==========================================================
# VELOCIDADE DAS ÂNCORAS
# ==========================================================

var posicao_anterior_a := Vector2.ZERO
var posicao_anterior_b := Vector2.ZERO

var velocidade_a := Vector2.ZERO
var velocidade_b := Vector2.ZERO


# ==========================================================
# READY
# ==========================================================

func _ready():

	await get_tree().process_frame

	var marcadores = get_tree().get_nodes_in_group(
		"cabo_ponto"
	)

	print(
		"CaboUSB - marcadores encontrados: ",
		marcadores.size()
	)

	if marcadores.size() < 2:

		push_error(
			"CaboUSB: são necessários 2 Marker2D no grupo 'cabo_ponto'."
		)

		return


	# ======================================================
	# PEGA OS DOIS MARCADORES
	# ======================================================

	ponto_a = marcadores[0]
	ponto_b = marcadores[1]


	# ======================================================
	# DISTÂNCIA INICIAL
	# ======================================================

	var inicio: Vector2 = ponto_a.global_position
	var fim: Vector2 = ponto_b.global_position

	var distancia_inicial := inicio.distance_to(fim)


	# ======================================================
	# COMPRIMENTO DOS SEGMENTOS
	# ======================================================

	comprimento_segmento = (
		distancia_inicial
		* folga
		/ float(quantidade_pontos - 1)
	)


	# ======================================================
	# CONFIGURA LINE2D
	# ======================================================

	$Cabo.width = largura_cabo
	$Cabo.z_index = 20

	$Cabo.begin_cap_mode = Line2D.LINE_CAP_ROUND
	$Cabo.end_cap_mode = Line2D.LINE_CAP_ROUND
	$Cabo.joint_mode = Line2D.LINE_JOINT_ROUND


	# ======================================================
	# CRIA OS PONTOS
	# ======================================================

	posicoes.clear()
	posicoes_anteriores.clear()


	for i in range(quantidade_pontos):

		var t: float = (
			float(i)
			/ float(quantidade_pontos - 1)
		)

		var posicao := inicio.lerp(fim, t)

		posicoes.append(posicao)
		posicoes_anteriores.append(posicao)


	posicao_anterior_a = inicio
	posicao_anterior_b = fim


	atualizar_visual()


# ==========================================================
# PHYSICS
# ==========================================================

func _physics_process(delta):

	if !is_instance_valid(ponto_a):
		return

	if !is_instance_valid(ponto_b):
		return

	if posicoes.size() < 2:
		return


	# ======================================================
	# ATUALIZA VELOCIDADE DAS ÂNCORAS
	# ======================================================

	var nova_posicao_a := ponto_a.global_position
	var nova_posicao_b := ponto_b.global_position


	velocidade_a = (
		nova_posicao_a
		- posicao_anterior_a
	) / max(delta, 0.0001)


	velocidade_b = (
		nova_posicao_b
		- posicao_anterior_b
	) / max(delta, 0.0001)


	posicao_anterior_a = nova_posicao_a
	posicao_anterior_b = nova_posicao_b


	# ======================================================
	# FIXA AS ÂNCORAS
	# ======================================================

	posicoes[0] = nova_posicao_a
	posicoes[-1] = nova_posicao_b

	posicoes_anteriores[0] = nova_posicao_a
	posicoes_anteriores[-1] = nova_posicao_b


	# ======================================================
	# VERLET
	# ======================================================

	for i in range(1, quantidade_pontos - 1):

		var atual := posicoes[i]
		var anterior := posicoes_anteriores[i]

		posicoes_anteriores[i] = atual


		var velocidade := (
			atual - anterior
		) * amortecimento


		var aceleracao := Vector2(
			0.0,
			gravidade
		)


		var nova_posicao : Vector2 = (
			atual
			+ velocidade
			+ aceleracao * delta * delta
		)


		var deslocamento := (
			nova_posicao - atual
		)


		if deslocamento.length() > deslocamento_maximo:

			nova_posicao = (
				atual
				+ deslocamento.normalized()
				* deslocamento_maximo
			)


		posicoes[i] = nova_posicao


	# ======================================================
	# ARRASTO DAS ÂNCORAS
	# ======================================================

	if quantidade_pontos > 2:

		posicoes[1] += (
			velocidade_a
			* delta
			* 0.12
		)

		posicoes[-2] += (
			velocidade_b
			* delta
			* 0.12
		)


	# ======================================================
	# RESOLVE AS RESTRIÇÕES
	# ======================================================

	for _iteration in range(iteracoes_fisica):

		posicoes[0] = nova_posicao_a
		posicoes[-1] = nova_posicao_b


		for i in range(quantidade_pontos - 1):

			var atual := posicoes[i]
			var proximo := posicoes[i + 1]

			var vetor := (
				proximo - atual
			)

			var distancia := vetor.length()


			if distancia <= 0.0001:
				continue


			var direcao := (
				vetor / distancia
			)


			var erro := (
				distancia
				- comprimento_segmento
			)


			var correcao := (
				direcao
				* erro
				* 0.5
			)


			if i != 0:
				posicoes[i] += correcao


			if i + 1 != quantidade_pontos - 1:
				posicoes[i + 1] -= correcao


		posicoes[0] = nova_posicao_a
		posicoes[-1] = nova_posicao_b


	# ======================================================
	# DESENHA O CABO
	# ======================================================

	atualizar_visual()


# ==========================================================
# VISUAL
# ==========================================================

func atualizar_visual():

	if !is_instance_valid($Cabo):
		return


	var pontos := PackedVector2Array()


	for posicao in posicoes:

		pontos.append(
			to_local(posicao)
		)


	$Cabo.points = pontos
