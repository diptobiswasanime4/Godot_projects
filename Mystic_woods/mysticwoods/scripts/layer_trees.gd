extends TileMapLayer

var width = 128
var height = 128

# Tree tiles
const CUT_TREE_TILE = Vector2i(0, 0)
const APPLE_TREE_TILE = Vector2i(1, 0)
const NORMAL_TREE_TILE = Vector2i(2, 0)

# Reference to terrain layer
@onready var terrain_layer = get_parent()

func _ready() -> void:
	generate_chunk()

func generate_chunk():
	# Clear previous trees
	clear()
	
	# Get terrain data from parent
	var terrain_data = terrain_layer.terrain_data
	
	for x in range(width):
		for y in range(height):
			var pos = Vector2i(x, y)
			var terrain_tile = terrain_data.get(pos)
			
			# Only place trees on grass or snow
			if terrain_tile == terrain_layer.GRASS_TILE or terrain_tile == terrain_layer.SNOW_TILE:
				# Randomly decide if a tree should be placed (e.g., 10% chance)
				if randf() < 0.1:
					var tree_type = randi() % 3  # Randomly pick one of 3 tree types
					var atlas_coords: Vector2i
					match tree_type:
						0:
							atlas_coords = CUT_TREE_TILE
						1:
							atlas_coords = APPLE_TREE_TILE
						2:
							atlas_coords = NORMAL_TREE_TILE
					set_cell(pos, 0, atlas_coords)
