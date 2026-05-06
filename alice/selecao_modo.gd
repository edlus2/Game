extends Node2D

func _ready():
	# Desabilita o modo 2 Players por enquanto
	$Btn2Player.disabled = true

func _on_btn_1_player_pressed():
	get_tree().change_scene_to_file("res://SelecaoPersonagem.tscn")


func _on_btn_2_player_pressed() -> void:
	pass # Replace with function body.
