extends Node

var personagem_escolhido = ""
var casa_pausa = 1

# Status do Jogador
var hp_max = 50
var hp_atual = 50
var ataque = 10
var defesa = 5
var escudo = 0
var moedas = 0
var mp_max = 20
var mp_atual = 20
var ataque_magico = 15 # O dano que a magia vai causar
var mp_recuperado = 10 # Quanto a poção de MP cura
# Inventário
var inventario = {
	"porcoes": 3,
	"porcoes_mp": 3,   # Nova: Poção de MP
	"magias": ["Fogo Inicial"],
	"equipamentos": ["Espada de Madeira"]
}
