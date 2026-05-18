extends Node2D

@onready var jogador = $Jogador
@onready var passos_label = $CanvasLayer/PassosLabel
@onready var animacao = $Jogador/Sprite2D/AnimatedSprite2D

var passos_restantes = 0
var esta_andando = false
var pode_girar_roleta = true
var casa_atual = 1
var historico_caminho = [] 

var eventos_do_mapa = {
	1: "vila",          # Casa 1 é o início, segura.
	8: "bau",           # Outro baú na casa 8
	9: "portao_fogo",
	15: "loja_pocao",   # Casa 15 será a sua primeira loja
	19: "portao_fogo",  # porta para chefe fogo
}

var conexoes = {
	1: {"esq": 2},
	2: {"esq": 5, "dir": 1, "cima": 3},
	3: {"baixo": 2, "esq": 4},
	4: {"baixo": 5, "dir":3},
	5: {"esq": 6, "dir": 2, "cima": 4},
	6: {"esq": 11, "baixo": 12,"dir": 5,"cima":7},
	7: {"baixo": 6, "esq": 8},
	8: {"esq": 9, "dir": 7},
	9: {"dir": 8, "baixo": 10},
	10: {"dir": 11,"cima":9},
	11: {"dir": 6, "esq": 10},
	12: {"dir": 16, "esq": 13,"cima":6},
	13: {"baixo": 14, "dir":12},
	14: {"dir": 15, "cima": 13},
	15: {"esq":14},
	16: {"baixo":17,"esq":12},
	17: {"dir": 18, "cima": 16},
	18: {"dir": 19, "esq": 17},
	19: {"esq":18},
}

func _ready():
	casa_atual = DadosGlobais.casa_pausa
	ir_para_casa(casa_atual, false)
	atualizar_ui()

func _process(_delta):
	# Se a bolsa estiver aberta, o código para aqui e ignora roleta e setinhas!
	if DadosGlobais.menu_aberto:
		return 
		
	if pode_girar_roleta and Input.is_action_just_pressed("ui_accept"):
		girar_roleta()
	
	# SÓ PERMITE ANDAR SE TIVER PASSOS E NÃO ESTIVER NO MEIO DE UM MOVIMENTO
	if passos_restantes > 0 and not esta_andando:
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
		# ---> TRANCA A PORTA AQUI ANTES DELE DAR O PASSO <---
		esta_andando = true 
		
		var proxima_casa = conexoes[casa_atual][direcao]
		animacao.play("andar_" + direcao) 
		
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
			tween.tween_property(jogador, "position", no_casa.position, 0.5)
			
			# O jogo espera o movimento acabar fisicamente
			await tween.finished 
			
			# Para a perninha e fica respirando
			animacao.stop()
			animacao.play("parado")
			
		else:
			jogador.position = no_casa.position
			
	atualizar_ui()
	
	if passos_restantes == 0 and not pode_girar_roleta:
		finalizar_turno()
		
	# ---> DESTRAVA A PORTA PARA O PRÓXIMO PASSO SÓ AQUI NO FINAL <---
	esta_andando = false

func atualizar_ui():
	$CanvasLayer/PontosLabel.text = "Pontos: " + str(DadosGlobais.pontos)
	if passos_label:
		if pode_girar_roleta:
			passos_label.text = "Aperte ESPAÇO para Girar"
		else:
			passos_label.text = "Passos Restantes: " + str(passos_restantes)

func abrir_bau():
	print("Você encontrou um Baú!")
	
	# Dá 1 poção ao jogador
	DadosGlobais.inventario["porcoes"] += 1
	
	atualizar_ui() 
	
	print("Você ganhou 1 Poção! Total: ", DadosGlobais.inventario["porcoes"])
	
func finalizar_turno():
	# Descobre o que tem na casa atual
	var tipo_evento = eventos_do_mapa.get(casa_atual, "luta")
	
	if tipo_evento == "luta":
		print("Iniciando transição de Batalha!")
		DadosGlobais.casa_pausa = casa_atual
		DadosGlobais.cena_anterior = "res://MapaMundi.tscn" 
		
		# 1. Faz a fumaça aparecer e tocar!
		var fumaca = $Jogador/Fumaca
		fumaca.visible = true
		fumaca.play("explosao") # Coloque o nome que você deu para a animação aqui
		
		# 2. Espera a fumaça terminar
		await fumaca.animation_finished
		fumaca.visible = false # Esconde a fumaça de novo
		
		# 3. Faz a tela escurecer suavemente (de transparente para 100% preto)
		var tela_preta = $CanvasLayer/TelaPreta
		var tween = create_tween()
		tween.tween_property(tela_preta, "color:a", 1.0, 0.5) # Leva meio segundo pra ficar preta
		
		# 4. Espera a tela ficar totalmente preta
		await tween.finished
		
		# 5. Só agora, com a tela preta escondendo o travamento, ele muda de cena!
		get_tree().change_scene_to_file("res://Luta.tscn")
		
	elif tipo_evento == "portao_fogo":
		print("Entrando no Vulcão...")
		# Forçamos a posição inicial para a Casa 1 do novo mapa
		DadosGlobais.casa_pausa = 1 
		get_tree().change_scene_to_file("res://SalaChefeFogo.tscn")
		
	elif tipo_evento == "bau":
		abrir_bau()
		# O turno no mapa acabou e você já pode girar a roleta para andar de novo!
		pode_girar_roleta = true 
		
	elif tipo_evento == "loja_pocao":
		print("Entrando na Loja...")
		# Salva a posição para você voltar para o lugar certo depois
		DadosGlobais.casa_pausa = casa_atual 
		get_tree().change_scene_to_file("res://Loja.tscn")
		
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
	DadosGlobais.menu_aberto = true 
	$CanvasLayer/Bolsa.atualizar_dados()
	$CanvasLayer/Bolsa.verificar_contexto()
