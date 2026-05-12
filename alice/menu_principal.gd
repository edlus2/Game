extends Control

func _on_btn_iniciar_pressed():
	# Muda da tela de menu para a tela de seleção de modo (1P/2P)
	get_tree().change_scene_to_file("res://SelecaoModo.tscn")
