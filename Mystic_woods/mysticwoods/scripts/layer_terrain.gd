extends TileMapLayer

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

var width = 128
var height = 128

# Terrain tiles
const GRASS_TILE = Vector2i(0, 0)
const SNOW_TILE = Vector2i(1, 0)
const WATER_TILE = Vector2i(0, 1)
const ROCK_TILE = Vector2i(1, 1)

# Store the generated terrain for reference by the tree layer
var terrain_data = {}

func _init_noise():
	moisture.seed = randi()
	temperature.seed = randi()
	altitude.seed = randi()

func _ready() -> void:
	_init_noise()
	generate_chunk()

func generate_chunk():
	var tile_pos = local_to_map(Vector2(0, 0))
	for x in range(width):
		for y in range(height):
			var world_x = tile_pos.x - width / 2 + x
			var world_y = tile_pos.y - height / 2 + y
			
			var moist = moisture.get_noise_2d(world_x, world_y) * 10
			var temp = temperature.get_noise_2d(world_x, world_y) * 10
			var alt = altitude.get_noise_2d(world_x, world_y) * 10
			
			var atlas_coords: Vector2i
			if alt < 2:
				atlas_coords = WATER_TILE
			elif alt >= 2 and moist > 5:
				atlas_coords = ROCK_TILE
			else:
				if y < height / 3:
					atlas_coords = SNOW_TILE
				elif y > height * 2 / 3:
					atlas_coords = GRASS_TILE
				else:
					atlas_coords = GRASS_TILE if randf() < 0.5 else SNOW_TILE
			
			# Store the terrain type
			terrain_data[Vector2i(x, y)] = atlas_coords
			set_cell(Vector2i(x, y), 0, atlas_coords)





func _on_button_pressed() -> void:
	_init_noise()
	generate_chunk()
	# Trigger tree layer regeneration if it exists
	if has_node("TreeLayer"):
		get_node("TreeLayer").generate_chunk()
