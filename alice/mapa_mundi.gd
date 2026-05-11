extends Node2D

@onready var jogador = $Jogador
@onready var passos_label = $CanvasLayer/PassosLabel

var passos_restantes = 0
var pode_girar_roleta = true
var casa_atual = 1
var historico_caminho = [] 

var conexoes = {
	1: {"esq": 2, "dir":8, "cima": 6},
	2: {"dir": 1, "esq": 3},
	3: {"cima": 4, "dir": 2},
	4: {"baixo": 3, "dir":5},
	5: {"esq": 4, "dir": 6},
	6: {"esq": 5, "baixo": 1,"dir": 7},
	7: {"baixo": 8, "dir": 9, "esq": 6},
	8: {"esq": 1, "dir": 9, "cima": 7},
	9: {"cima": 7, "dir": 10, "baixo": 8},
	10: {"esq": 9}
}

func _ready():
	if DadosGlobais.personagem_escolhido == "homem":
		jogador.color = Color.BLUE
	else:
		jogador.color = Color.MAGENTA
	
	ir_para_casa(casa_atual, false)
	atualizar_ui()

func _process(_delta):
	if pode_girar_roleta and Input.is_action_just_pressed("ui_accept"):
		girar_roleta()
	
	if passos_restantes > 0:
		verificar_movimento()

func girar_roleta():
	pode_girar_roleta = false
	passos_restantes = randi_range(1, 6)
	historico_caminho = [casa_atual] 
	atualizar_ui()

func verificar_movimento():
	var direcao = ""
	if Input.is_action_just_pressed("ui_right"): direcao = "dir"
	if Input.is_action_just_pressed("ui_left"): direcao = "esq"
	if Input.is_action_just_pressed("ui_up"): direcao = "cima"
	if Input.is_action_just_pressed("ui_down"): direcao = "baixo"
	
	if direcao != "" and conexoes[casa_atual].has(direcao):
		var proxima_casa = conexoes[casa_atual][direcao]
		
		if historico_caminho.size() > 1 and proxima_casa == historico_caminho[-2]:
			historico_caminho.pop_back()
			passos_restantes += 1
			ir_para_casa(proxima_casa, true)
		elif passos_restantes > 0:
			historico_caminho.append(proxima_casa)
			passos_restantes -= 1
			ir_para_casa(proxima_casa, true)

func ir_para_casa(numero, animar):
	casa_atual = numero
	var no_casa = get_node("Casas/Casa" + str(numero))
	
	if no_casa:
		if animar:
			var tween = create_tween()
			tween.tween_property(jogador, "position", no_casa.position, 0.2)
		else:
			jogador.position = no_casa.position
	
	atualizar_ui()
	
	if passos_restantes == 0 and not pode_girar_roleta:
		finalizar_turno()

func atualizar_ui():
	if passos_label:
		if pode_girar_roleta:
			passos_label.text = "Aperte ESPAÇO para Girar"
		else:
			passos_label.text = "Passos Restantes: " + str(passos_restantes)

func finalizar_turno():
	print("Turno encerrado na casa: ", casa_atual)
	# Removemos o sorteio por enquanto para testar o combate sempre
	iniciar_luta() 

func iniciar_luta():
	print("MONSTRO APARECEU!")
	DadosGlobais.casa_pausa = casa_atual
	# Transição para a cena de luta
	get_tree().change_scene_to_file("res://Luta.tscn")
