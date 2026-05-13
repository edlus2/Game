extends Control

@onready var label_vida = $VBoxContainer/HPLabel
@onready var label_ataque = $VBoxContainer/Ataque

func _ready():
	atualizar_dados()
	verificar_contexto()

func atualizar_dados():
	# Atualiza o HP e MP no painel de status
	$VBoxContainer/HPLabel.text = "HP: " + str(DadosGlobais.hp_atual) + " / " + str(DadosGlobais.hp_max)
	$VBoxContainer/MPlabel.text = "MP: " + str(DadosGlobais.mp_atual) + " / " + str(DadosGlobais.mp_max)
	
	# Atualiza as quantidades nos botões da aba de poções
	$TabContainer/Pocoes/BtnUsarHPBolsa.text = "Poção HP (" + str(DadosGlobais.inventario["porcoes"]) + ")"
	$TabContainer/Pocoes/BtnUsarMPBolsa.text = "Poção MP (" + str(DadosGlobais.inventario["porcoes_mp"]) + ")"

func verificar_contexto():
	var cena_atual = get_tree().current_scene.name
	
	if cena_atual == "Luta":
		# 1. Esconde as abas que não são de poções (índice 0 é Equipamento, 2 é Magia)
		$TabContainer.set_tab_hidden(0, true)
		$TabContainer.set_tab_hidden(2, true)
		
		# 2. Força a bolsa a abrir direto na aba de Poções (índice 1)
		$TabContainer.current_tab = 1
		
		# 3. OPCIONAL: Esconde a barra de abas no topo para parecer um menu único
		$TabContainer.tabs_visible = false
		
		# 4. OPCIONAL: Se quiser esconder os status (HP/Ataque) na luta para focar só nos itens:
		$VBoxContainer.visible = false
		
	else:
		# No Mapa Mundi, mostramos tudo de novo
		$TabContainer.set_tab_hidden(0, false)
		$TabContainer.set_tab_hidden(2, false)
		$TabContainer.tabs_visible = true
		$VBoxContainer.visible = true

func _on_button_pressed():
	visible = false

# LÓGICA DE USAR A POÇÃO DE HP
func _on_btn_usar_porcao_pressed():
	# Verifica se tem poção E se a vida não está cheia
	if DadosGlobais.inventario["porcoes"] > 0 and DadosGlobais.hp_atual < DadosGlobais.hp_max:
		
		# 1. Gasta 1 poção e cura 20 de HP
		DadosGlobais.inventario["porcoes"] -= 1
		DadosGlobais.hp_atual += 20
		
		# 2. Impede que a vida passe do máximo
		if DadosGlobais.hp_atual > DadosGlobais.hp_max:
			DadosGlobais.hp_atual = DadosGlobais.hp_max
			
		# 3. Atualiza os textos da bolsa na mesma hora
		atualizar_dados()
		
		# 4. O "PULO DO GATO": Se estiver na batalha, gasta o turno!
		if get_tree().current_scene.name == "Luta":
			visible = false # Fecha a bolsa
			get_tree().current_scene.usar_item_passar_turno() 
			
	elif DadosGlobais.inventario["porcoes"] <= 0:
		print("Você não tem mais poções!")
	else:
		print("Sua vida já está cheia!")

# LÓGICA DE USAR A POÇÃO DE MP
func _on_btn_usar_mp_bolsa_pressed():
	if DadosGlobais.inventario["porcoes_mp"] > 0:
		if DadosGlobais.mp_atual < DadosGlobais.mp_max:
			# Tira 1 poção e recupera o MP
			DadosGlobais.inventario["porcoes_mp"] -= 1
			DadosGlobais.mp_atual = min(DadosGlobais.mp_atual + DadosGlobais.mp_recuperado, DadosGlobais.mp_max)
			
			print("Você usou Poção de MP na bolsa!")
			
			# Atualiza os textos da bolsa na hora
			atualizar_dados()
			
			# Se estivermos na luta, avisa a cena de luta para atualizar também
			var cena_atual = get_tree().current_scene.name
			if cena_atual == "Luta":
				get_tree().current_scene.usar_item_passar_turno()
				visible = false # Fecha a bolsa na luta após usar
		else:
			print("Seu MP já está cheio!")
	else:
		print("Você não tem poções de MP!")
