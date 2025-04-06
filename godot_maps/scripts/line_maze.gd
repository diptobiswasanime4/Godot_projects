extends Node2D

const N = 1
const E = 2
const S = 4
const W = 8

var cell_walls = {
	Vector2i(0, -1): N,
	Vector2i(1, 0): E,
	Vector2i(0, 1): S,
	Vector2i(-1, 0): W
}

var tile_size = 16
var width = 20
var height = 20

@onready var Map = $TileMapLayer

func _ready() -> void:
	randomize()
	make_maze()
	
func make_maze():
	var unvisited = []
	var stack = []
	Map.clear()
	
	for x in range(width):
		for y in range(height):
			unvisited.append(Vector2i(x, y))
			Map.set_cell(Vector2i(x, y), 0, Vector2i(3, 3))
	var cur = Vector2i(0, 0)
	unvisited.erase(cur)
	
	while unvisited:
		var neighbors = check_neighbors(cur, unvisited)
		if neighbors.size() > 0:
			var next = neighbors
	
func check_neighbors(cell, unvisited):
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list

func _process(delta: float) -> void:
	pass
