extends Control

# O @onready carrega o nó assim que a cena abre.
# ATENÇÃO: Se o erro continuar, apague apenas o "$MoedasLabel" abaixo, 
# clique no seu nó MoedasLabel lá na esquerda e arraste ele para cá!
@onready var texto_moedas = %MoedasLabel

func _ready():
	atualizar_tela()

func atualizar_tela():
	# Agora usamos a variável garantida, sem chance de erro de caminho!
	texto_moedas.text = "Suas Moedas: " + str(DadosGlobais.moedas)

func _on_btn_comprar_hp_pressed():
	var preco = 10
	if DadosGlobais.moedas >= preco:
		DadosGlobais.moedas -= preco
		DadosGlobais.inventario["porcoes"] += 1
		print("Comprou Poção HP!")
		atualizar_tela()
	else:
		print("Moedas insuficientes!")

func _on_btn_comprar_mp_pressed():
	var preco = 15
	if DadosGlobais.moedas >= preco:
		DadosGlobais.moedas -= preco
		DadosGlobais.inventario["porcoes_mp"] += 1
		print("Comprou Poção MP!")
		atualizar_tela()
	else:
		print("Moedas insuficientes!")

func _on_btn_sair_pressed():
	# Desbloqueia o movimento do mapa caso estivesse travado
	DadosGlobais.menu_aberto = false 
	get_tree().change_scene_to_file("res://MapaMundi.tscn")
