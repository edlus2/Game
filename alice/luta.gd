extends Node2D

@onready var jogador_visual = $JogadorLuta
@onready var inimigo_visual = $Inimigo
@onready var hp_jogador_label = $CanvasLayer/HPJogador
@onready var hp_inimigo_label = $CanvasLayer/HPInimigo

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

func _on_btn_atacar_pressed():
	if turno_jogador:
		turno_jogador = false
		hp_inimigo -= DadosGlobais.ataque
		atualizar_texto_hp()
		
		if hp_inimigo <= 0:
			vitoria()
		else:
			await get_tree().create_timer(1.0).timeout
			turno_inimigo()

func turno_inimigo():
	var dano = 5
	DadosGlobais.hp_atual -= dano
	atualizar_texto_hp()
	
	if DadosGlobais.hp_atual <= 0:
		derrota()
	else:
		turno_jogador = true

func vitoria():
	print("Venceu!")
	DadosGlobais.moedas += 10
	get_tree().change_scene_to_file("res://MapaMundi.tscn")

func derrota():
	DadosGlobais.hp_atual = DadosGlobais.hp_max
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")

func _on_btn_fugir_pressed():
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
