extends Node2D

@onready var jogador_visual = $JogadorLuta
@onready var inimigo_visual = $Inimigo
@onready var hp_jogador_label = $CanvasLayer/HPJogador
@onready var hp_inimigo_label = $CanvasLayer/HPInimigo
@onready var menu_principal = $CanvasLayer/MenuPrincipal
@onready var menu_ataque = $CanvasLayer/MenuAtaque
@onready var menu_magia = $CanvasLayer/MenuMagia
@onready var menu_pocoes = $CanvasLayer/MenuPocoes

# Variável para saber se o jogador está defendendo neste turno
var defendendo = false
var hp_inimigo = 30
var turno_jogador = true

func _ready():		
	$JogadorLuta/AnimatedSprite2D.play("parado")
	atualizar_texto_hp()
	$JogadorLuta/AnimatedSprite2D.play("parado")
	
	# ADICIONE ESTA LINHA:
	$Inimigo/AnimatedSprite2D.play("parado") 
	
	atualizar_texto_hp()

func atualizar_texto_hp():
	# Atualiza o texto do Jogador mostrando HP e MP juntos
	$CanvasLayer/HPJogador.text = "HP: " + str(DadosGlobais.hp_atual) + " / MP: " + str(DadosGlobais.mp_atual)
	
	# Atualiza o texto do Inimigo (verifique se a variável hp_inimigo tem esse nome mesmo)
	$CanvasLayer/HPInimigo.text = "HP Inimigo: " + str(hp_inimigo)
	
	
	
func turno_inimigo():
	
	# 1. Toca a animação de ataque do Goblin
	$Inimigo/AnimatedSprite2D.play("Ataque")
	
	# 2. Espera a animação de ataque terminar de tocar
	await $Inimigo/AnimatedSprite2D.animation_finished
	
	# 3. Volta para a animação de respirar
	$Inimigo/AnimatedSprite2D.play("parado")
	
	# --- A PARTIR DAQUI FICA O SEU CÓDIGO DE DANO QUE JÁ EXISTIA ---
	var dano_monstro = 10
	
	if defendendo:
		dano_monstro = dano_monstro / 2
		print("Você defendeu! Recebeu apenas ", dano_monstro, " de dano.")
		defendendo = false
	else:
		print("O monstro atacou! Você recebeu ", dano_monstro, " de dano.")
		
	DadosGlobais.hp_atual -= dano_monstro
	atualizar_texto_hp()
	
	if DadosGlobais.hp_atual <= 0:
		derrota()
	else:
		# Passa o turno de volta para o jogador
		turno_jogador = true
		
		# ---> ADICIONE ESTA LINHA AQUI: <---
		# Ela faz os botões de ATACAR, DEFENDER e FUGIR reaparecerem!
		$CanvasLayer/MenuPrincipal.visible = true

func vitoria():
	var pontos_ganhos = 50 # Monstros comuns dão menos pontos
	DadosGlobais.pontos += pontos_ganhos
	print("Vitória! Você ganhou ", pontos_ganhos, " pontos.")
	# ... código para voltar ao mapa ...
	print("Venceu!")
	DadosGlobais.moedas += 10
	get_tree().change_scene_to_file(DadosGlobais.cena_anterior)
func derrota():
	DadosGlobais.hp_atual = DadosGlobais.hp_max
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
func _on_btn_fugir_pressed():
	if turno_jogador:
		print("Você fugiu correndo para a vila!")
		
		# 1. Define que o jogador vai nascer na Casa 1 (Vila)
		DadosGlobais.casa_pausa = 1
		
		# 2. Punição: Perde 1 poção se tiver alguma
		if DadosGlobais.inventario["porcoes"] > 0:
			DadosGlobais.inventario["porcoes"] -= 1
			print("Você deixou cair 1 poção enquanto fugia!")
		
		# 3. Volta para o Mapa
		get_tree().change_scene_to_file("res://MapaMundi.tscn")
func usar_item_passar_turno():
	atualizar_texto_hp() # Atualiza o número de HP na tela de batalha
	turno_jogador = false
	
	print("Item usado! Turno do monstro.")
	
	# Espera 1 segundo para o jogador ler e então o monstro ataca
	await get_tree().create_timer(1.0).timeout
	turno_inimigo()
func _on_btn_bolsa_pressed() -> void:
	$CanvasLayer/Bolsa.visible = true
	$CanvasLayer/Bolsa.atualizar_dados()
	$CanvasLayer/Bolsa.verificar_contexto()
func _on_btn_atacar_pressed():
	if turno_jogador:
		# Esconde o menu principal e mostra as opções de ataque
		menu_principal.visible = false
		menu_ataque.visible = true
func _on_btn_fisico_pressed():
	# 1. Esconde todos os menus para o jogador não clicar duas vezes
	menu_ataque.visible = false
	menu_principal.visible = false
	
	# 2. Causa o dano ao inimigo (Pegando a força do herói nos DadosGlobais)
	var dano_causado = DadosGlobais.ataque
	hp_inimigo -= dano_causado # ATENÇÃO: se a sua variável de vida do inimigo tiver outro nome, mude aqui!
	
	# 3. Atualiza os números na tela
	atualizar_texto_hp()
	print("Você atacou e causou ", dano_causado, " de dano no monstro!")
	
	# 4. Verifica se o monstro morreu com esse ataque
	if hp_inimigo <= 0:
		vitoria()
	else:
		# Se não morreu, passa a vez e manda o monstro atacar
		turno_jogador = false
		
		# Espera 1 segundo para você ver o dano antes do monstro revidar
		await get_tree().create_timer(1.0).timeout
		turno_inimigo()
func _on_btn_magia_pressed():
	# Esconde as opções de Físico/Magia/Poção e mostra a lista de feitiços
	menu_ataque.visible = false
	menu_magia.visible = true
func _on_btn_voltar_magia_pressed():
	# Volta para o menu de escolher o tipo de ataque
	menu_magia.visible = false
	menu_ataque.visible = true
func _on_btn_pocoes_pressed():
	menu_ataque.visible = false
	menu_pocoes.visible = true
	atualizar_botoes_pocoes() # Vamos criar essa função abaixo
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
		
		# Opcional: mostrar um textinho ou animação de escudo aqui
		
		# Passa a vez para o inimigo após um pequeno atraso
		await get_tree().create_timer(1.0).timeout
		turno_inimigo()
func game_over():
	print("Você foi derrotado na batalha!")
	
	# 1. Define que o jogador vai nascer na Casa 1 (Vila)
	DadosGlobais.casa_pausa = 1
	
	# 2. Punição: Perde 1 poção se tiver alguma
	if DadosGlobais.inventario["porcoes"] > 0:
		DadosGlobais.inventario["porcoes"] -= 1
		print("Os monstros roubararam 1 poção sua enquanto você estava desmaiado!")
	
	# 3. Recupera o HP do jogador para ele não voltar morto para o mapa
	DadosGlobais.hp_atual = DadosGlobais.hp_max
	
	# 4. Volta para o Mapa
	get_tree().change_scene_to_file("res://MapaMundi.tscn")
func _on_btn_fogo_pressed():
	var custo_mp = 5
	
	# 1. Verifica se o jogador tem MP suficiente
	if DadosGlobais.mp_atual >= custo_mp:
		
		# 2. Esconde o menu de magias
		menu_magia.visible = false
		
		# 3. Gasta o MP e causa o dano
		DadosGlobais.mp_atual -= custo_mp
		var dano_causado = DadosGlobais.ataque_magico
		hp_inimigo -= dano_causado
		
		print("Você lançou Bola de Fogo e causou ", dano_causado, " de dano mágico!")
		print("MP restante: ", DadosGlobais.mp_atual)
		
		# Atualiza a interface (HP e agora MP se você tiver criado o texto na tela)
		atualizar_texto_hp() 
		
		# 4. Verifica se o monstro morreu
		if hp_inimigo <= 0:
			vitoria()
		else:
			# Passa a vez para o monstro
			turno_jogador = false
			await get_tree().create_timer(1.0).timeout
			turno_inimigo()
			
	else:
		# Se não tiver MP, o jogo avisa e NÃO passa o turno!
		print("MP Insuficiente! Escolha outro ataque ou use uma poção.")
func _on_btn_usar_hp_pressed():
	if DadosGlobais.inventario["porcoes"] > 0:
		DadosGlobais.inventario["porcoes"] -= 1
		DadosGlobais.hp_atual = min(DadosGlobais.hp_atual + 20, DadosGlobais.hp_max) # Cura 20
		
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
	menu_principal.visible = false # Esconde para o monstro atacar
	atualizar_texto_hp()
	
	turno_jogador = false
	await get_tree().create_timer(1.0).timeout
	turno_inimigo()
