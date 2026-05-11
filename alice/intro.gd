extends Node2D

func _ready():
	# Mensagem para confirmar quem foi escolhido
	if DadosGlobais.personagem_escolhido == "homem":
		print("Carregando jornada do Homem (Quadrado)...")
	else:
		print("Carregando jornada da Mulher (Redondo)...")

# ESTA É A FUNÇÃO QUE TROCA DE CENA
func _on_timer_timeout():
	print("Tempo esgotado! Indo para o Mapa...")
	get_tree().change_scene_to_file("res://MapaMundi.tscn")
