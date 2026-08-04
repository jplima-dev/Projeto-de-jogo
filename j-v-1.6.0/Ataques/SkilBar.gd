extends Node

const TOTAL_SLOTS := 8

var slots := [
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	""
]


func equipar(nome: String, slot: int) -> bool:

	if slot < 1 or slot > TOTAL_SLOTS:
		return false

	slots[slot - 1] = nome.to_lower()

	print("Equipado '%s' no slot %d." % [nome, slot])

	return true


func pegar(slot: int) -> String:

	if slot < 1 or slot > TOTAL_SLOTS:
		return ""

	return slots[slot - 1]


func remover(slot: int) -> bool:

	if slot < 1 or slot > TOTAL_SLOTS:
		return false

	slots[slot - 1] = ""

	return true


func limpar():

	for i in range(TOTAL_SLOTS):
		slots[i] = ""


func usar(slot: int, player) -> bool:

	var habilidade := pegar(slot)

	if habilidade == "":
		print("Nenhuma habilidade equipada no slot", slot)
		return false

	return AttackManager.executar(habilidade, player)


func listar():

	print("===== SKILBAR =====")

	var teclas = [
		"Y",
		"U",
		"I",
		"O",
		"H",
		"J",
		"K",
		"L"
	]

	for i in range(TOTAL_SLOTS):

		var nome = slots[i]

		if nome == "":
			nome = "(vazio)"

		print(
			"Slot %d (%s): %s"
			% [i + 1, teclas[i], nome]
		)
