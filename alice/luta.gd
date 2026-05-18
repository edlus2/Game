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
	$Inimigo/AnimatedSprite2D.play("parado") 
	atualizar_texto_hp()

func atualizar_texto_hp():
	# Atualiza o texto do Jogador mostrando HP e MP juntos
	$CanvasLayer/HPJogador.text = "HP: " + str(DadosGlobais.hp_atual) + " / MP: " + str(DadosGlobais.mp_atual)
	
	# Atualiza o texto do Inimigo (verifique se a variável hp_inimigo tem esse nome mesmo)
	$CanvasLayer/HPInimigo.text = "HP Inimigo: " + str(hp_inimigo)
	
func turno_inimigo():
	# 1. Descobre quem são os nós e onde eles estão
	var goblin = $Inimigo
	var heroi = $JogadorLuta
	var posicao_original = goblin.position
	
	# Calcula a posição de ataque
	var alvo_ataque = Vector2(heroi.position.x + 50, goblin.position.y)
	
	# 2. A INVESTIDA (Toca animação de andar e vai)
	$Inimigo/AnimatedSprite2D.play("andar")
	var tween_ida = create_tween()
	tween_ida.tween_property(goblin, "position", alvo_ataque, 0.4) 
	
	# Espera o Goblin chegar no herói
	await tween_ida.finished
	
	# 3. O ATAQUE!
	$Inimigo/AnimatedSprite2D.play("Ataque")
	await $Inimigo/AnimatedSprite2D.animation_finished
	
	# --- CÁLCULO DE DANO ---
	var dano_monstro = 10 
	
	if defendendo:
		dano_monstro = dano_monstro / 2
		print("Você defendeu! Recebeu apenas ", dano_monstro, " de dano.")
		defendendo = false
	else:
		print("O monstro atacou! Você recebeu ", dano_monstro, " de dano.")
		
	DadosGlobais.hp_atual -= dano_monstro
	atualizar_texto_hp()
	
	# 4. O RETORNO (Toca animação de recuar e volta)
	$Inimigo/AnimatedSprite2D.play("recuar")
	var tween_volta = create_tween()
	tween_volta.tween_property(goblin, "position", posicao_original, 0.4)
	
	# Espera ele voltar
	await tween_volta.finished
	
	# 5. VOLTA A RESPIRAR E ENCERRA O TURNO
	$Inimigo/AnimatedSprite2D.play("parado")
	
	if DadosGlobais.hp_atual <= 0:
		derrota()
	else:
		turno_jogador = true
		$CanvasLayer/MenuPrincipal.visible = true

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

func _on_btn_fisico_pressed():
	menu_ataque.visible = false
	menu_principal.visible = false
	
	var dano_causado = DadosGlobais.ataque
	hp_inimigo -= dano_causado 
	atualizar_texto_hp()
	print("Você atacou e causou ", dano_causado, " de dano no monstro!")
	
	if hp_inimigo <= 0:
		vitoria()
	else:
		turno_jogador = false
		await get_tree().create_timer(1.0).timeout
		turno_inimigo()

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
