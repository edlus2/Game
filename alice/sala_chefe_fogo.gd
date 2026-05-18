extends Node2D

@onready var jogador = $Jogador
@onready var passos_label = $CanvasLayer/PassosLabel

var passos_restantes = 0
var pode_girar_roleta = true
var casa_atual = 1
var historico_caminho = [] 

# Aqui você define o que tem no vulcão!
var eventos_do_mapa = {
	1: "saida_vulcao", 
	# Pela sua foto, vi que você criou até a Casa 10!
	# Então se a casa 10 for a boca da caveira, mude o 8 para 10 aqui:
	8: "luta_chefe" 
}

# ATENÇÃO: Como você fez 10 casas, depois você precisa arrumar essas conexões
# para ligar a Casa 1 até a Casa 10 do jeito que você desenhou!
var conexoes = {
	1: {"cima": 2,"dir":10},
	2: {"cima": 3,"baixo":1}, # Bifurcação no meio do vulcão
	3: {"baixo": 2,"cima":4}, # Vai direto pro chefe
	4: {"baixo": 3,"cima":5}, # Caminho sem saída
	5: {"dir":6, "baixo":4 }, # Caminho sem saída
	6: {"esq": 3,"cima":7,"dir":9}, # Boca da caveira
	7: {"cima":8,"baixo":6},
	8: {"baixo":7},
	9: {"esq":6,"baixo":10},
	10:{"cima":9,"baixo":1}
}

func _ready():
	# Define a cor do jogador (mesma lógica)
	if DadosGlobais.personagem_escolhido == "homem":
		jogador.color = Color.BLUE
	else:
		jogador.color = Color.MAGENTA
		
	# --- O PULO DO GATO ESTÁ AQUI ---
	# Lemos a posição salva. Se for a primeira vez, será 1. 
	# Se estiver voltando da luta, será 8 (ou 10).
	casa_atual = DadosGlobais.casa_pausa
	
	ir_para_casa(casa_atual, false)
	atualizar_ui()

func _process(_delta):
	# Se a bolsa ou menu estiver aberto, trava o movimento
	if DadosGlobais.menu_aberto:
		return
		
	if pode_girar_roleta and Input.is_action_just_pressed("ui_accept"):
		girar_roleta()
	
	if passos_restantes > 0:
		verificar_movimento()

func girar_roleta():
	if DadosGlobais.menu_aberto:
		return
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
			await tween.finished 
		else:
			jogador.position = no_casa.position
	
	atualizar_ui()
	
	if passos_restantes == 0 and not pode_girar_roleta:
		finalizar_turno()

func finalizar_turno():
	var tipo_evento = eventos_do_mapa.get(casa_atual, "vazio")
	
	if tipo_evento == "luta_chefe":
		print("Você pisou na Caveira! O CHEFE ACORDOU!")
		DadosGlobais.casa_pausa = casa_atual # Salva que você está na Casa 10
		DadosGlobais.cena_anterior = "res://SalaChefeFogo.tscn" # <--- GRAVA A MEMÓRIA!
		get_tree().change_scene_to_file("res://Luta.tscn")
		
	elif tipo_evento == "saida_vulcao":
		print("Saindo do Vulcão...")
		# Coloque aqui o número da casa do portão lá do Mapa Mundi (ex: 10)
		DadosGlobais.casa_pausa = 10 
		get_tree().change_scene_to_file("res://MapaMundi.tscn")
		
	elif tipo_evento == "vazio":
		pode_girar_roleta = true

func atualizar_ui():
	if passos_label:
		if pode_girar_roleta:
			passos_label.text = "Aperte ESPAÇO para Girar"
		else:
			passos_label.text = "Passos Restantes: " + str(passos_restantes)
