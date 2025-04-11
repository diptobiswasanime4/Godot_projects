extends Node2D

const WATER = Vector2i(3, 0)
const SAND = Vector2i(2, 0)
const GRASS = Vector2i(1, 0)
const HILL = Vector2i(0, 0)

var tile_types = [WATER, SAND, GRASS, HILL]
var map_width = 25
var map_height = 25
var cells = []
var collapsed_cells = []

var adjacency_rules = {
	WATER: [WATER, SAND],
	SAND: [WATER, SAND, GRASS],
	GRASS: [SAND, GRASS, HILL],
	HILL: [GRASS, HILL]
}

@onready var tilemap = $TileMapLayer

func _ready():
	initialize_cells()
	wave_function_collapse()
	apply_to_tilemap()

func initialize_cells():
	
	cells = []
	collapsed_cells = []
	for y in range(map_height):
		cells.append([])
		for x in range(map_width):
			cells[y].append(tile_types.duplicate())

func get_entropy(x, y):
	if x < 0 or y < 0 or x >= map_width or y >= map_height:
		return 999
	return cells[y][x].size()

func find_lowest_entropy_cell():
	var min_entropy = 999
	var candidates = []
	
	for y in range(map_height):
		for x in range(map_width):
			# Skip already collapsed cells
			if Vector2i(x, y) in collapsed_cells:
				continue
				
			var entropy = get_entropy(x, y)
			if entropy <= 1:
				continue  # Skip cells with 0 or 1 options
			
			if entropy < min_entropy:
				min_entropy = entropy
				candidates = [Vector2i(x, y)]
	
	if candidates.size() > 0:
		# Return a random cell from those with the lowest entropy
		return candidates[randi() % candidates.size()]
	return null





# Update constraints for a neighbor based on adjacency rules
func update_neighbor_constraints(cell_pos, neighbor_pos):
	var possible_tiles = []
	
	# Get the allowed tiles for this cell
	for cell_tile in cells[cell_pos.y][cell_pos.x]:
		# Get valid neighbors for this tile
		var allowed_neighbors = adjacency_rules[cell_tile]
		
		# Add allowed neighbors to possible tiles
		for tile in cells[neighbor_pos.y][neighbor_pos.x]:
			if tile in allowed_neighbors and not tile in possible_tiles:
				possible_tiles.append(tile)
	
	# Update the neighbor's possible tiles
	cells[neighbor_pos.y][neighbor_pos.x] = possible_tiles
	
# Propagate constraints based on adjacency rules
func propagate_constraints(pos):
	var x = pos.x
	var y = pos.y
	
	# Check each neighbor (up, right, down, left)
	var neighbors = [
		Vector2i(x, y-1),  # Up
		Vector2i(x+1, y),  # Right
		Vector2i(x, y+1),  # Down
		Vector2i(x-1, y)   # Left
	]
	
	for neighbor in neighbors:
		if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= map_width or neighbor.y >= map_height:
			continue  # Skip out of bounds
		
		# Update constraints without tracking for further propagation
		update_neighbor_constraints(pos, neighbor)
	
# Collapse a cell to a single state
func collapse_cell(pos):
	var x = pos.x
	var y = pos.y
	
	# Pick a random tile from the available options
	var random_index = randi() % cells[y][x].size()
	var chosen_tile = cells[y][x][random_index]
	
	# Set the cell to only have this tile
	cells[y][x] = [chosen_tile]
	collapsed_cells.append(pos)
	
	# Propagate constraints to neighbors
	propagate_constraints(pos)
	return true

# Run the wave function collapse algorithm
func wave_function_collapse():
	# Seed the random number generator
	randomize()
	
	# Pick a random starting point and collapse it
	var start_x = randi() % map_width
	var start_y = randi() % map_height
	collapse_cell(Vector2i(start_x, start_y))
	
	# Continue until all cells are collapsed
	while true:
		var cell = find_lowest_entropy_cell()
		if cell == null:
			break  # No more cells to collapse
		
		collapse_cell(cell)

# Apply the generated map to the TileMap
func apply_to_tilemap():
	for y in range(map_height):
		for x in range(map_width):
			if cells[y][x].size() > 0:
				var tile = cells[y][x][0]
				tilemap.set_cell(Vector2i(x, y), 0, tile)


func _on_button_pressed() -> void:
	initialize_cells()
	wave_function_collapse()
	apply_to_tilemap()
