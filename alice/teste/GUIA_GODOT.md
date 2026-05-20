# Guia de Uso dos Assets no Godot 4

## Estrutura de Pastas

```
final/
├── TILESET_GODOT_32x32.png   ← Tileset unificado para o TileMap (256x64px, 16 tiles)
├── tiles/
│   ├── ground_01.png  → Grama
│   ├── ground_02.png  → Terra/Caminho de areia
│   ├── ground_03.png  → Calçada de pedra
│   ├── ground_04.png  → Água
│   ├── ground_05.png  → Chão de floresta
│   ├── ground_06.png  → Areia/Deserto
│   ├── ground_07.png  → Neve
│   ├── ground_08.png  → Lava
│   ├── deco_01.png    → Árvore redonda
│   ├── deco_02.png    → Pinheiro
│   ├── deco_03.png    → Arbusto
│   ├── deco_04.png    → Pedra/Rocha
│   ├── deco_05.png    → Cerca de madeira
│   ├── deco_06.png    → Flores
│   ├── deco_07.png    → Cogumelos
│   └── deco_08.png    → Capim alto
├── characters/
│   ├── hero_32x32.png         → Personagem principal (32x32)
│   ├── npc_enemy_01.png       → NPC: Velho sábio (32x32)
│   ├── npc_enemy_02.png       → NPC: Mercador (32x32)
│   ├── npc_enemy_03.png       → Inimigo: Slime (32x32)
│   ├── npc_enemy_04.png       → Inimigo: Goblin (32x32)
│   ├── miniboss_64x64.png     → Sub-chefe: Cavaleiro sombrio (64x64)
│   └── boss_128x128.png       → Chefe: Rei Demônio (128x128)
├── items/
│   ├── item_01.png  → Baú fechado
│   ├── item_02.png  → Baú aberto com moedas
│   ├── item_03.png  → Poção de cura vermelha
│   ├── item_04.png  → Saco de moedas
│   ├── item_05.png  → Barril
│   ├── item_06.png  → Caixa de madeira
│   ├── item_07.png  → Orbe mágico azul
│   └── item_08.png  → Espada no chão
└── buildings/
	├── house_128x128.png   → Casa simples (128x128)
	├── shop_128x128.png    → Lojinha (128x128)
	├── base_160x160.png    → Casa Base Inicial (160x160)
	└── castle_256x256.png  → Castelo (256x256)
```

---

## Como Usar o TileMap no Godot 4

### 1. Importar o Tileset Unificado

1. Arraste o arquivo `TILESET_GODOT_32x32.png` para a pasta `res://assets/tiles/` no FileSystem do Godot.
2. Nas propriedades de importação da textura, configure:
   - **Filter**: `Nearest` (essencial para pixel art!)
   - **Mipmaps**: `Off`

### 2. Criar o TileMap

1. Adicione um nó **TileMap** na cena.
2. No painel de propriedades, clique em **TileSet** → **New TileSet**.
3. No editor de TileSet, clique em **+** e selecione a textura `TILESET_GODOT_32x32.png`.
4. Configure o **Tile Size** como `32 x 32`.
5. Clique em **Setup Atlas** e o Godot detectará automaticamente os 16 tiles.

### 3. Usar Sprites de Personagens e Estruturas

Para personagens, itens e edifícios, use nós **Sprite2D** ou **AnimatedSprite2D**:

```gdscript
# Exemplo: carregar o herói
var hero_texture = preload("res://assets/characters/hero_32x32.png")
$HeroSprite.texture = hero_texture
```

**Importante:** Sempre defina o filtro da textura como `Nearest` para manter o visual pixel art.

### 4. Alinhamento ao Grid

Para garantir que os sprites fiquem alinhados ao grid de 32x32:

```gdscript
# Snap de posição ao grid
func snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		floor(pos.x / 32) * 32,
		floor(pos.y / 32) * 32
	)
```

Para estruturas maiores (ex: castelo 256x256 = 8x8 tiles), posicione sempre em múltiplos de 32:

| Asset             | Tamanho    | Tiles ocupados |
|-------------------|------------|----------------|
| Tile de chão      | 32x32      | 1x1            |
| Herói / NPC       | 32x32      | 1x1            |
| Mini-boss         | 64x64      | 2x2            |
| Boss              | 128x128    | 4x4            |
| Casa / Loja       | 128x128    | 4x4            |
| Base Inicial      | 160x160    | 5x5            |
| Castelo           | 256x256    | 8x8            |

### 5. Configuração do Projeto (Project Settings)

Em **Project → Project Settings → Display → Window**:
- **Stretch Mode**: `canvas_items`
- **Aspect**: `keep`

Em **Rendering → Textures**:
- **Default Texture Filter**: `Nearest`

---

## Dicas de Pixel Art no Godot

- Sempre use **filtro Nearest** em todas as texturas pixel art para evitar borrão.
- Use **CanvasItem → Texture Filter: Nearest** em cada Sprite2D individualmente se necessário.
- O **TileMap** com grid de 32x32 é perfeito para o estilo de tabuleiro do Dokapon.
- Para o mapa de tabuleiro, use o TileMap como chão e coloque os edifícios como Sprite2D filhos de um Node2D separado.
