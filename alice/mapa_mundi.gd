extends Node2D

@onready var jogador = $Jogador
@onready var passos_label = $CanvasLayer/PassosLabel

var passos_restantes = 0
var pode_girar_roleta = true
var casa_atual = 1
var historico_caminho = [] 
var eventos_do_mapa = {
	1: "vila",          # Casa 1 é o início, segura.
	3: "bau",           # Casa 3 tem um baú de poção
	5: "loja_pocao",    # Casa 5 será a sua primeira loja
	8: "bau"            # Outro baú na casa 8
}

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
	
	# ISSO AQUI RESOLVE O ERRO DE VOLTAR PRO COMEÇO:
	# O mapa lê onde você parou antes de posicionar o jogador
	casa_atual = DadosGlobais.casa_pausa
	
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
			
			# ESSA LINHA FAZ O JOGO ESPERAR O MOVIMENTO ACABAR:
			await tween.finished 
			
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
func abrir_bau():
	print("Você encontrou um Baú!")
	
	# Dá 1 poção ao jogador
	DadosGlobais.inventario["porcoes"] += 1
	
	# Se a bolsa estiver aberta ou o UI precisar atualizar
	atualizar_ui() 
	
	# Aqui no futuro podemos tocar um som de "Tcharam!" 
	print("Você ganhou 1 Poção! Total: ", DadosGlobais.inventario["porcoes"])
	
func finalizar_turno():
	# Descobre o que tem na casa atual
	var tipo_evento = eventos_do_mapa.get(casa_atual, "luta")
	
	if tipo_evento == "luta":
		print("Entrando em Batalha!")
		DadosGlobais.casa_pausa = casa_atual
		get_tree().change_scene_to_file("res://Luta.tscn")
		
	elif tipo_evento == "bau":
		abrir_bau()
		
		# IMPORTANTE: Como não mudamos de cena, precisamos avisar
		# o jogo que o seu turno no mapa acabou e você já pode
		# girar a roleta para andar de novo!
		# (Mude "pode_girar_roleta" para o nome exato da sua variável que libera o botão)
		pode_girar_roleta = true 
		
	elif tipo_evento == "loja_pocao":
		print("Bem-vindo à loja de poções!")
		pode_girar_roleta = true
		
	elif tipo_evento == "vila":
		print("Você está seguro no vilarejo.")
		pode_girar_roleta = true

func iniciar_luta():
	print("MONSTRO APARECEU!")
	DadosGlobais.casa_pausa = casa_atual
	# Transição para a cena de luta
	get_tree().change_scene_to_file("res://Luta.tscn")


func _on_button_pressed() -> void:
	$CanvasLayer/Bolsa.visible = true
	$CanvasLayer/Bolsa.atualizar_dados()
	$CanvasLayer/Bolsa.verificar_contexto()# Replace with function body.
