extends Node2D

const WATER = Vector2i(3, 0)
const SAND = Vector2i(2, 0)
const GRASS = Vector2i(1, 0)
const HILL = Vector2i(0, 0)

var tile_types = [WATER, SAND, GRASS, HILL]
var map_width = 25
var map_height = 25
var cells = []

# Perlin noise parameters
var noise = FastNoiseLite.new()
var moisture_noise = FastNoiseLite.new()
var noise_scale = 0.1
var moisture_scale = 0.08

@onready var tilemap = $TileMapLayer

func _ready():
	# Initialize noise generators
	randomize()
	noise.seed = randi()
	noise.frequency = noise_scale
	noise.fractal_octaves = 4
	
	moisture_noise.seed = randi()
	moisture_noise.frequency = moisture_scale
	moisture_noise.fractal_octaves = 3
	
	generate_map()

func generate_map():
	# Initialize cells array
	cells = []
	for y in range(map_height):
		cells.append([])
		for x in range(map_width):
			cells[y].append(null)
	
	# Generate terrain using Perlin noise
	for y in range(map_height):
		for x in range(map_width):
			# Generate elevation and moisture values using Perlin noise
			var elevation = noise.get_noise_2d(x, y)
			var moisture = moisture_noise.get_noise_2d(x, y)
			
			# Convert noise values (-1 to 1) to a 0 to 1 range
			elevation = (elevation + 1) / 2
			moisture = (moisture + 1) / 2
			
			# Determine tile type based on elevation and moisture
			var tile
			
			if elevation < 0.3:
				tile = WATER
			elif elevation < 0.4:
				tile = SAND
			elif elevation < 0.7:
				tile = GRASS
			else:
				tile = HILL
				
			# Adjust based on moisture
			if elevation >= 0.3 and elevation < 0.7:
				if moisture > 0.7 and elevation > 0.4:
					# More moisture can make grass in higher elevations
					tile = GRASS
				elif moisture < 0.2 and elevation > 0.4:
					# Dry areas more likely to be sand
					tile = SAND
			
			cells[y][x] = tile
			
	apply_to_tilemap()

# Apply the generated map to the TileMap
func apply_to_tilemap():
	for y in range(map_height):
		for x in range(map_width):
			tilemap.set_cell(Vector2i(x, y), 0, cells[y][x])

# For debugging - print the current state of the map
func print_map():
	var tile_chars = {
		WATER: "~",
		SAND: ".",
		GRASS: ",",
		HILL: "^"
	}
	
	var map_str = ""
	for y in range(map_height):
		var row = ""
		for x in range(map_width):
			row += tile_chars[cells[y][x]] + " "
		map_str += row + "\n"
	
	print(map_str)

# Generate a new map with a different seed
func generate_new_map():
	noise.seed = randi()
	moisture_noise.seed = randi()
	generate_map()

func _on_button_pressed() -> void:
	generate_new_map()
