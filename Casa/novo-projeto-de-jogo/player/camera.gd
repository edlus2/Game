extends Camera2D

var target: Node2D

func _ready() -> void:
	get_target()

func _process(_delta: float) -> void:
	# Verifica se o target existe antes de tentar seguir
	if target:
		position = target.position

func get_target():
	# Retorna um Array com os nós, não a contagem
	var nodes = get_tree().get_nodes_in_group("Player")
	if nodes.size() == 0:
		push_error("Player não encontrado no grupo!")
		return
		
	target = nodes[0]
