extends Node2D

@onready var jogador_visual = $JogadorLuta
@onready var inimigo_visual = $Inimigo
@onready var hp_jogador_label = $CanvasLayer/HPJogador
@onready var hp_inimigo_label = $CanvasLayer/HPInimigo
@onready var menu_principal = $CanvasLayer/MenuPrincipal
@onready var menu_ataque = $CanvasLayer/MenuAtaque
@onready var menu_magia = $CanvasLayer/MenuMagia
@onready var menu_pocoes = $CanvasLayer/MenuPocoes

# Variáveis arrumadas sem repetição
var defendendo = false
var hp_inimigo = 0
var turno_jogador = true

func _ready():		
	# --- 1. CARREGA O VISUAL DO HERÓI BASEADO NO GÊNERO ---
	if DadosGlobais.genero_heroi == "masculino":
		# Se você usar SpriteFrames diferentes, você carrega eles aqui:
		# $JogadorLuta/AnimatedSprite2D.sprite_frames = load("res://heroi_masculino.tres")
		print("Carregado visual Masculino")
	elif DadosGlobais.genero_heroi == "feminino":
		# $JogadorLuta/AnimatedSprite2D.sprite_frames = load("res://heroi_feminino.tres")
		print("Carregado visual Feminino")
		
	$JogadorLuta/AnimatedSprite2D.play("parado")
	
	# --- 2. CARREGA STATUS E CONFIGURAÇÕES DO MONSTRO SORTEADO ---
	var nome_do_monstro = DadosGlobais.inimigo_atual
	var dados_do_monstro = DadosGlobais.banco_de_monstros[nome_do_monstro]
	$Inimigo/AnimatedSprite2D.sprite_frames = load("res://animacoes_" + nome_do_monstro + ".tres")
	
	$Inimigo/AnimatedSprite2D.play("parado")
	# Aplica a vida máxima que configuramos para ele lá no DadosGlobais
	hp_inimigo = dados_do_monstro["hp"] 
	
	# Se você tiver SpriteFrames prontos para cada monstro, pode carregar dinamicamente:
	# $Inimigo/AnimatedSprite2D.sprite_frames = load("res://animacoes_" + nome_do_monstro + ".tres")
	
	$Inimigo/AnimatedSprite2D.play("parado") 
	atualizar_texto_hp()

func atualizar_texto_hp():
	$CanvasLayer/HPJogador.text = "HP: " + str(DadosGlobais.hp_atual) + " / MP: " + str(DadosGlobais.mp_atual)
	$CanvasLayer/HPInimigo.text = "HP Inimigo: " + str(hp_inimigo)

# --- NOVA FUNÇÃO PARA O EFEITO DE DANO ---
func piscar_vermelho(sprite):
	sprite.modulate = Color(1, 0, 0) # Pinta a imagem de vermelho
	await get_tree().create_timer(0.2).timeout # Espera um instante
	sprite.modulate = Color(1, 1, 1) # Volta para a cor original
	
func turno_inimigo():
	var goblin = $Inimigo
	var heroi = $JogadorLuta
	var animacao_heroi = $JogadorLuta/AnimatedSprite2D
	var posicao_original = goblin.position
	
	var alvo_ataque = Vector2(heroi.position.x + 50, goblin.position.y)
	
	$Inimigo/AnimatedSprite2D.play("andar")
	var tween_ida = create_tween()
	tween_ida.tween_property(goblin, "position", alvo_ataque, 0.4) 
	
	await tween_ida.finished
	
	$Inimigo/AnimatedSprite2D.play("Ataque")
	await $Inimigo/AnimatedSprite2D.animation_finished
	
	# Pega o dano real do monstro sorteado lá do DadosGlobais
	var nome_do_monstro = DadosGlobais.inimigo_atual
	var dano_monstro = DadosGlobais.banco_de_monstros[nome_do_monstro]["ataque"]
	
	if defendendo:
		dano_monstro = dano_monstro / 2
		print("Você defendeu! Recebeu apenas ", dano_monstro, " de dano.")
		defendendo = false
	else:
		print("O monstro atacou! Você recebeu ", dano_monstro, " de dano.")
		
	DadosGlobais.hp_atual -= dano_monstro
	atualizar_texto_hp()
	
	# ---> FAZ O HERÓI PISCAR VERMELHO <---
	piscar_vermelho(animacao_heroi)
	
	$Inimigo/AnimatedSprite2D.play("recuar")
	var tween_volta = create_tween()
	tween_volta.tween_property(goblin, "position", posicao_original, 0.4)
	
	await tween_volta.finished
	
	$Inimigo/AnimatedSprite2D.play("parado")
	
	if DadosGlobais.hp_atual <= 0:
		derrota()
	else:
		turno_jogador = true
		$CanvasLayer/MenuPrincipal.visible = true

func _on_btn_fisico_pressed():
	menu_ataque.visible = false
	menu_principal.visible = false
	
	var heroi = $JogadorLuta
	var animacao_heroi = $JogadorLuta/AnimatedSprite2D
	var goblin = $Inimigo
	var animacao_goblin = $Inimigo/AnimatedSprite2D
	var posicao_original = heroi.position
	
	# Calcula a posição de ataque
	var alvo_ataque = Vector2(goblin.position.x - 50, heroi.position.y)
	
	# A INVESTIDA DO HERÓI 
	animacao_heroi.play("parado") 
	var tween_ida = create_tween()
	tween_ida.tween_property(heroi, "position", alvo_ataque, 0.4)
	
	await tween_ida.finished
	
	# O ATAQUE 
	animacao_heroi.play("parado") 
	await get_tree().create_timer(0.2).timeout
	
	var dano_causado = DadosGlobais.ataque
	hp_inimigo -= dano_causado 
	atualizar_texto_hp()
	print("Você atacou e causou ", dano_causado, " de dano no monstro!")
	
	# ---> FAZ O INIMIGO PISCAR VERMELHO <---
	piscar_vermelho(animacao_goblin)
	
	# O RETORNO
	animacao_heroi.play("parado") 
	var tween_volta = create_tween()
	tween_volta.tween_property(heroi, "position", posicao_original, 0.4)
	
	await tween_volta.finished
	
	animacao_heroi.play("parado")
	
	if hp_inimigo <= 0:
		vitoria()
	else:
		turno_jogador = false
		await get_tree().create_timer(0.5).timeout
		turno_inimigo()

func vitoria():
	var pontos_ganhos = 50 
	DadosGlobais.pontos += pontos_ganhos
	print("Vitória! Você ganhou ", pontos_ganhos, " pontos.")
	print("Venceu!")
	DadosGlobais.moedas += 10
	get_tree().change_scene_to_file(DadosGlobais.cena_anterior)

func derrota():
	DadosGlobais.hp_atual = DadosGlobais.hp_max
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")

func _on_btn_fugir_pressed():
	if turno_jogador:
		print("Você fugiu correndo para a vila!")
		DadosGlobais.casa_pausa = 1
		if DadosGlobais.inventario["porcoes"] > 0:
			DadosGlobais.inventario["porcoes"] -= 1
			print("Você deixou cair 1 poção enquanto fugia!")
		get_tree().change_scene_to_file("res://MapaMundi.tscn")

func usar_item_passar_turno():
	atualizar_texto_hp() 
	turno_jogador = false
	print("Item usado! Turno do monstro.")
	await get_tree().create_timer(1.0).timeout
	turno_inimigo()

func _on_btn_bolsa_pressed() -> void:
	$CanvasLayer/Bolsa.visible = true
	$CanvasLayer/Bolsa.atualizar_dados()
	$CanvasLayer/Bolsa.verificar_contexto()

func _on_btn_atacar_pressed():
	if turno_jogador:
		menu_principal.visible = false
		menu_ataque.visible = true

func _on_btn_magia_pressed():
	menu_ataque.visible = false
	menu_magia.visible = true

func _on_btn_voltar_magia_pressed():
	menu_magia.visible = false
	menu_ataque.visible = true

func _on_btn_pocoes_pressed():
	menu_ataque.visible = false
	menu_pocoes.visible = true
	atualizar_botoes_pocoes() 

func atualizar_botoes_pocoes():
	$CanvasLayer/MenuPocoes/BtnUsarHP.text = "Poção HP (" + str(DadosGlobais.inventario["porcoes"]) + ")"
	$CanvasLayer/MenuPocoes/BtnUsarMP.text = "Poção MP (" + str(DadosGlobais.inventario["porcoes_mp"]) + ")"

func _on_btn_voltar_pocao_pressed():
	menu_pocoes.visible = false
	menu_ataque.visible = true

func _on_btn_defender_pressed():
	if turno_jogador:
		print("Jogador assumiu postura de defesa!")
		defendendo = true
		turno_jogador = false
		await get_tree().create_timer(1.0).timeout
		turno_inimigo()

func game_over():
	print("Você foi derrotado na batalha!")
	DadosGlobais.casa_pausa = 1
	if DadosGlobais.inventario["porcoes"] > 0:
		DadosGlobais.inventario["porcoes"] -= 1
		print("Os monstros roubararam 1 poção sua enquanto você estava desmaiado!")
	DadosGlobais.hp_atual = DadosGlobais.hp_max
	get_tree().change_scene_to_file("res://MapaMundi.tscn")

func _on_btn_fogo_pressed():
	var custo_mp = 5
	if DadosGlobais.mp_atual >= custo_mp:
		menu_magia.visible = false
		DadosGlobais.mp_atual -= custo_mp
		var dano_causado = DadosGlobais.ataque_magico
		hp_inimigo -= dano_causado
		
		print("Você lançou Bola de Fogo e causou ", dano_causado, " de dano mágico!")
		print("MP restante: ", DadosGlobais.mp_atual)
		atualizar_texto_hp() 
		
		piscar_vermelho($Inimigo/AnimatedSprite2D)
		
		if hp_inimigo <= 0:
			vitoria()
		else:
			turno_jogador = false
			await get_tree().create_timer(1.0).timeout
			turno_inimigo()
	else:
		print("MP Insuficiente! Escolha outro ataque ou use uma poção.")

func _on_btn_usar_hp_pressed():
	if DadosGlobais.inventario["porcoes"] > 0:
		DadosGlobais.inventario["porcoes"] -= 1
		DadosGlobais.hp_atual = min(DadosGlobais.hp_atual + 20, DadosGlobais.hp_max)
		finalizar_uso_item("Você usou Poção de HP!")
	else:
		print("Você não tem mais poções de HP!")

func _on_btn_usar_mp_pressed():
	if DadosGlobais.inventario["porcoes_mp"] > 0:
		DadosGlobais.inventario["porcoes_mp"] -= 1
		DadosGlobais.mp_atual = min(DadosGlobais.mp_atual + DadosGlobais.mp_recuperado, DadosGlobais.mp_max)
		finalizar_uso_item("Você usou Poção de MP!")
	else:
		print("Você não tem mais poções de MP!")

func finalizar_uso_item(mensagem):
	print(mensagem)
	menu_pocoes.visible = false
	menu_principal.visible = false 
	atualizar_texto_hp()
	
	turno_jogador = false
	await get_tree().create_timer(1.0).timeout
	turno_inimigo()
