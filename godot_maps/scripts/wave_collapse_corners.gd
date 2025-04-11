extends Node2D

const WATER = Vector2i(1, 1)
const WATER_N = Vector2i(1, 0)
const WATER_NE = Vector2i(2, 0)
const WATER_E = Vector2i(2, 1)
const WATER_SE = Vector2i(2, 2)
const WATER_S = Vector2i(1, 2)
const WATER_SW = Vector2i(0, 2)
const WATER_W = Vector2i(0, 1)
const WATER_NW = Vector2i(0, 0)
const GRASS = Vector2i(3, 0)

@export var map_width: int = 40
@export var map_height: int = 30

@onready var tile_map: TileMapLayer = $TileMapLayer

var all_tiles = [WATER, WATER_N, WATER_NE, WATER_E, WATER_SE, WATER_S, WATER_SW, WATER_W, WATER_NW, GRASS]

var adjacency_rules = {}

var grid = []
var collapsed_cells = []
var to_process = []

func _ready():
	initialize_adjacency_rules()
	generate_map()

func initialize_adjacency_rules():
	
	adjacency_rules[WATER] = {
		0: [WATER, WATER_N, WATER_NE, WATER_NW], # North
		1: [WATER, WATER_E, WATER_NE, WATER_SE], # East
		2: [WATER, WATER_S, WATER_SE, WATER_SW], # South
		3: [WATER, WATER_W, WATER_NW, WATER_SW]  # West
	}
	
	adjacency_rules[WATER_N] = {
		0: [GRASS],
		1: [WATER_NE, WATER_E],
		2: [WATER, WATER_E, WATER_W],
		3: [WATER_NW, WATER_W]
	}
	
	adjacency_rules[WATER_NE] = {
		0: [GRASS],
		1: [GRASS],
		2: [WATER_E, WATER, WATER_SE],
		3: [WATER_N, WATER, WATER_NW]
	}
	
	adjacency_rules[WATER_E] = {
		0: [WATER_NE, WATER_N],
		1: [GRASS],
		2: [WATER_SE, WATER_S],
		3: [WATER, WATER_N, WATER_S]
	}
	
	adjacency_rules[WATER_SE] = {
		0: [WATER_E, WATER, WATER_NE],
		1: [GRASS],
		2: [GRASS],
		3: [WATER_S, WATER, WATER_SW]
	}
	
	adjacency_rules[WATER_S] = {
		0: [WATER, WATER_E, WATER_W],
		1: [WATER_SE, WATER_E],
		2: [GRASS],
		3: [WATER_SW, WATER_W]
	}
	
	adjacency_rules[WATER_SW] = {
		0: [WATER_W, WATER, WATER_NW],
		1: [WATER_S, WATER, WATER_SE],
		2: [GRASS],
		3: [GRASS]
	}
	
	adjacency_rules[WATER_W] = {
		0: [WATER_NW, WATER_N],
		1: [WATER, WATER_N, WATER_S],
		2: [WATER_SW, WATER_S],
		3: [GRASS]
	}
	
	adjacency_rules[WATER_NW] = {
		0: [GRASS],
		1: [WATER_N, WATER, WATER_NE],
		2: [WATER_W, WATER, WATER_SW],
		3: [GRASS]
	}
	
	adjacency_rules[GRASS] = {
		0: [GRASS, WATER_S, WATER_SE, WATER_SW],
		1: [GRASS, WATER_W, WATER_NW, WATER_SW],
		2: [GRASS, WATER_N, WATER_NE, WATER_NW],
		3: [GRASS, WATER_E, WATER_NE, WATER_SE]
	}

func generate_map():
	grid = []
	for y in range(map_height):
		var row = []
		for x in range(map_width):
			row.append(all_tiles.duplicate())
		grid.append(row)
	
	to_process = []
	collapsed_cells = []
	for y in range(map_height):
		for x in range(map_width):
			to_process.append(Vector2i(x, y))
	
	# Start by collapsing a random cell
	var start_cell = to_process[randi() % to_process.size()]
	collapse_cell(start_cell.x, start_cell.y)
	
	# Continue wave function collapse until all cells are processed
	while not to_process.is_empty():
		# Find cell with minimum entropy (fewest possible tiles)
		var min_entropy = INF
		var min_entropy_cell = null
		
		for cell in to_process:
			var entropy = grid[cell.y][cell.x].size()
			if entropy < min_entropy and entropy > 0:
				min_entropy = entropy
				min_entropy_cell = cell
		
		if min_entropy_cell == null:
			break
		
		# Collapse this cell
		collapse_cell(min_entropy_cell.x, min_entropy_cell.y)
	
	# Render the map
	render_map()

func collapse_cell(x, y):
	if grid[y][x].is_empty():
		return
	
	var options = grid[y][x]
	var chosen_tile = options[randi() % options.size()]
	
	grid[y][x] = [chosen_tile]
	
	to_process.erase(Vector2i(x, y))
	collapsed_cells.append(Vector2i(x, y))
	
	propagate_constraints(x, y)

func propagate_constraints(x, y):
	var queue = [Vector2i(x, y)]
	
	while not queue.is_empty():
		var current = queue.pop_front()
		var cx = current.x
		var cy = current.y
		
		var directions = [
			Vector2i(0, -1),
			Vector2i(1, 0),
			Vector2i(0, 1),
			Vector2i(-1, 0)
		]
		
		for dir_idx in range(directions.size()):
			var dir = directions[dir_idx]
			var nx = cx + dir.x
			var ny = cy + dir.y
			
			if nx < 0 or nx >= map_width or ny < 0 or ny >= map_height:
				continue
			
			var opposite_dir = (dir_idx + 2) % 4
			
			# Get allowed tiles based on current cell's options
			var allowed_tiles = []
			for tile in grid[cy][cx]:
				if adjacency_rules.has(tile) and adjacency_rules[tile].has(dir_idx):
					allowed_tiles.append_array(adjacency_rules[tile][dir_idx])
			
			# Constrain the neighbor's options
			var neighbor_options = grid[ny][nx]
			var new_options = []
			
			for option in neighbor_options:
				if allowed_tiles.has(option):
					new_options.append(option)
			
			# If options changed, update and add to queue
			if new_options.size() != neighbor_options.size():
				grid[ny][nx] = new_options
				if not queue.has(Vector2i(nx, ny)) and not collapsed_cells.has(Vector2i(nx, ny)):
					queue.append(Vector2i(nx, ny))

func render_map():
	# Clear the tile map
	tile_map.clear()
	
	# Set each tile based on the collapsed state
	for y in range(map_height):
		for x in range(map_width):
			var cell_options = grid[y][x]
			if cell_options.size() > 0:
				# Choose the first (and likely only) option
				var tile = cell_options[0]
				tile_map.set_cell(Vector2i(x, y), 0, tile)
			else:
				# If somehow we have no valid options, use grass as a fallback
				tile_map.set_cell(Vector2i(x, y), 0, GRASS)


func _on_button_pressed() -> void:
	generate_map()
