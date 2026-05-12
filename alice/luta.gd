extends Node2D

@onready var jogador_visual = $JogadorLuta
@onready var inimigo_visual = $Inimigo
@onready var hp_jogador_label = $CanvasLayer/HPJogador
@onready var hp_inimigo_label = $CanvasLayer/HPInimigo
@onready var menu_principal = $CanvasLayer/MenuPrincipal
@onready var menu_ataque = $CanvasLayer/MenuAtaque

# Variável para saber se o jogador está defendendo neste turno
var defendendo = false
var hp_inimigo = 30
var turno_jogador = true

func _ready():
	# Define a cor do jogador
	if DadosGlobais.personagem_escolhido == "homem":
		jogador_visual.color = Color.BLUE
	else:
		jogador_visual.color = Color.MAGENTA
	
	atualizar_texto_hp()

func atualizar_texto_hp():
	hp_jogador_label.text = "Seu HP: " + str(DadosGlobais.hp_atual)
	hp_inimigo_label.text = "HP Inimigo: " + str(hp_inimigo)

func turno_inimigo():
	var dano_monstro = 10 # Substitua pelo dano real do seu monstro
	
	if defendendo:
		print("Dano reduzido pela metade!")
		dano_monstro /= 2
		# Reseta a defesa para o próximo turno
		defendendo = false 
		
	DadosGlobais.hp_atual -= dano_monstro
	atualizar_texto_hp()
	
	print("Você recebeu ", dano_monstro, " de dano.")
	
	if DadosGlobais.hp_atual <= 0:
		game_over()
	else:
		turno_jogador = true
		menu_principal.visible = true

func vitoria():
	print("Venceu!")
	DadosGlobais.moedas += 10
	get_tree().change_scene_to_file("res://MapaMundi.tscn")

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
	
	# Essa função é chamada pela Bolsa quando usamos um item na batalha
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


# Quando clica no primeiro "ATACAR"
func _on_btn_atacar_pressed():
	if turno_jogador:
		# Esconde o menu principal e mostra as opções de ataque
		menu_principal.visible = false
		menu_ataque.visible = true

# Quando escolhe o ataque FÍSICO
# Quando escolhe o ataque FÍSICO
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

# Quando escolhe MAGIA (Deixaremos preparado para o futuro)
func _on_btn_magia_pressed():
	print("Menu de magias em construção!")
	# No futuro, faremos menu_ataque.visible = false e abriremos o MenuMagia

# Quando escolhe POÇÕES
func _on_btn_pocoes_pressed():
	# 1. Esconde o menu de ataque e garante que o principal fique "pronto" embaixo
	menu_ataque.visible = false
	menu_principal.visible = true
	
	# 2. Abre a bolsa na aba de poções
	$CanvasLayer/Bolsa.visible = true
	$CanvasLayer/Bolsa.atualizar_dados()
	$CanvasLayer/Bolsa.verificar_contexto()
	# Como já criamos a bolsa para abrir na aba de poções, vamos reutilizá-la!
	$CanvasLayer/Bolsa.visible = true
	$CanvasLayer/Bolsa.atualizar_dados()
	$CanvasLayer/Bolsa.verificar_contexto()
	
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
