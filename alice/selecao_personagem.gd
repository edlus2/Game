extends Node2D

func _on_btn_homem_pressed():
	# Atribuímos o valor direto na variável, sem precisar da função
	DadosGlobais.personagem_escolhido = "homem"
	print("Escolheu Homem!")
	get_tree().change_scene_to_file("res://Intro.tscn")

func _on_btn_mulher_pressed():
	DadosGlobais.personagem_escolhido = "mulher"
	print("Escolheu Mulher!")
	get_tree().change_scene_to_file("res://Intro.tscn")
