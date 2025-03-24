extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

var width = 32
var height = 32

const GRASS_TILES = [Vector2(0, 0), Vector2(1, 0)]
const ROCK_TILE = Vector2(1, 1)
const WATER_TILE = Vector2(0, 1)

func _init_noise():
	moisture.seed = randi()
	temperature.seed = randi()
	altitude.seed = randi()

func generate_chunk():
	var tile_pos = local_to_map(Vector2(0, 0))
	for x in range(width):
		for y in range(height):
			var world_x = tile_pos.x - width / 2 + x
			var world_y = tile_pos.y - width / 2 + y
			
			var moist = moisture.get_noise_2d(world_x, world_y) * 10
			var temp = temperature.get_noise_2d(world_x, world_y) * 10
			var alt = altitude.get_noise_2d(world_x, world_y) * 10
			
			var atlas_coords: Vector2
			if alt < 2:
				atlas_coords = WATER_TILE
			elif alt >= 2 and moist > 4:
				atlas_coords = ROCK_TILE
			else:
				atlas_coords = GRASS_TILES[randi() % GRASS_TILES.size()]
				
			set_cell(0, Vector2i(x, y), 0, atlas_coords)
			
func _ready() -> void:
	print("Map")
	_init_noise()
	generate_chunk()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	print("Generating new map.")
	_init_noise()
	generate_chunk()
