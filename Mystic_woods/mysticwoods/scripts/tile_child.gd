extends TileMapLayer

var width = 128
var height = 128

# Tree tiles (use Vector2i for TileMapLayer)
const TREE_A = [Vector2i(0, 0), Vector2i(1, 0)]  # Two variations of Tree A
const TREE_B = Vector2i(1, 1)                    # Single Tree B
const TREE_C = Vector2i(0, 1)                    # Single Tree C

# Reference to terrain layer
@onready var terrain_layer = get_parent()

# Customization options
var tree_density = 0.1  # 10% chance of placing a tree on grass

func _ready() -> void:
	generate_chunk()

func generate_chunk():
	# Clear previous trees
	clear()
	
	# Get terrain data from parent
	var terrain_data = terrain_layer.terrain_data
	
	# Optional: Track tree counts for debugging
	var tree_counts = {"A": 0, "B": 0, "C": 0}
	
	for x in range(width):
		for y in range(height):
			var pos = Vector2i(x, y)
			var terrain_tile = terrain_data.get(pos)
			
			# Only place trees on grass tiles
			if terrain_tile in terrain_layer.GRASS_TILES:
				# Randomly decide if a tree should be placed
				if randf() < tree_density:
					var tree_type = randi() % 3  # Pick between 0 (A), 1 (B), 2 (C)
					var atlas_coords: Vector2i
					match tree_type:
						0:  # TREE_A (randomly pick one of the two variations)
							atlas_coords = TREE_A[randi() % TREE_A.size()]
							tree_counts["A"] += 1
						1:  # TREE_B
							atlas_coords = TREE_B
							tree_counts["B"] += 1
						2:  # TREE_C
							atlas_coords = TREE_C
							tree_counts["C"] += 1
					set_cell(pos, 0, atlas_coords)
	
	# Debug output to verify tree placement
	print("Tree Counts: A: %d, B: %d, C: %d" % [tree_counts["A"], tree_counts["B"], tree_counts["C"]])
