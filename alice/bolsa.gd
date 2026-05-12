extends Control

@onready var label_vida = $VBoxContainer/Vida
@onready var label_ataque = $VBoxContainer/Ataque
# Pegamos o caminho do botão que acabamos de criar (Verifique se o nome bate com o seu)
@onready var btn_porcao = $"TabContainer/Poções/BtnUsarPorcao"

func _ready():
	atualizar_dados()
	verificar_contexto()

func atualizar_dados():
	label_vida.text = "HP: " + str(DadosGlobais.hp_atual) + "/" + str(DadosGlobais.hp_max)
	label_ataque.text = "Ataque: " + str(DadosGlobais.ataque)
	
	# Atualiza o texto do botão mostrando quantas poções restam
	if btn_porcao:
		btn_porcao.text = "Usar Poção (" + str(DadosGlobais.inventario["porcoes"]) + "x)"

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

# LÓGICA DE USAR A POÇÃO
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
