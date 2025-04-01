extends TileMapLayer

var altitude = FastNoiseLite.new()
var moisture = FastNoiseLite.new()

const GRASS_TILES = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
const WATER_TILE = Vector2i(6, 0)
const ROCK_TILE = Vector2i(3, 0)

var map_width = 128
var map_height = 128

var terrain_data = {}

func _init_noise():
	altitude.seed = randi()
	moisture.seed = randi()
	print(altitude)
	print(moisture)


func _ready() -> void:
	_init_noise()
	generate_map()
	
func generate_map():
	var tile_pos = local_to_map(Vector2(0, 0))
	for x in range(map_width):
		for y in range(map_height):
			var map_x = tile_pos.x - map_width / 2 + x
			var map_y = tile_pos.y - map_height / 2 + y
			
			var moisture_cur = moisture.get_noise_2d(map_x, map_y) * 10
			var altitute_cur = altitude.get_noise_2d(map_x, map_y) * 10
			
			var coords: Vector2i
			if altitute_cur < 2:
				coords = WATER_TILE
			elif altitute_cur >=2 and moisture_cur > 5:
				coords = ROCK_TILE
			else:
				coords = GRASS_TILES[randi() % GRASS_TILES.size()]
			
			terrain_data[Vector2i(x, y)] = coords
			set_cell(Vector2i(x, y), 0, coords)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





func _on_button_pressed() -> void:
	_init_noise()
	generate_map()
