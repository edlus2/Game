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
var menu_aberto = false # Se for true, o jogador não pode rodar dados
var pontos = 0
var recorde_pontos = 0
var inventario = {
	"porcoes": 3,
	"porcoes_mp": 3,   # Nova: Poção de MP
	"magias": ["Fogo Inicial"],
	"equipamentos": ["Espada de Madeira"]
}
# Adicione ou atualize estas informações no DadosGlobais.gd
var magias_desbloqueadas = {
	"fogo": true,
	"agua": false
}
var cena_anterior = "res://MapaMundi.tscn" # Lembra de onde o jogador veio
var equipamentos_possuidos = {
	"espada_ferro": true, # Começa com uma
	"escudo_madeira": false
}

# --- SISTEMA DE GÊNERO ---
# Pode ser "masculino" ou "feminino". Você mudará isso no menu de seleção depois!
var genero_heroi = "masculino" 

# --- SISTEMA DE MAPAS E MONSTROS ---
var mapa_atual = "vilarejo"  # Registra em qual território o jogador está andando
var inimigo_atual = "goblin" # Salva qual monstro foi sorteado para a luta atual

# Tabelas de monstros por território (aqui você colocará os 8 de cada mapa no futuro)
var pools_de_monstros = {
	"vilarejo": ["goblin", "gosma"],
	"vulcao": ["monstro_fogo1", "monstro_fogo2"] # Exemplo para o futuro
}

# Atributos e configurações de cada monstro
var banco_de_monstros = {
	"goblin": {
		"hp": 30,
		"ataque": 10,
		"sprite_folder": "res://img/goblin_side_view_sprite.png" # Exemplo do caminho da sua imagem
	},
	"gosma": {
		"hp": 20,
		"ataque": 6,
		"sprite_folder": "res://img/gosma_sprite.png"
	}
}
