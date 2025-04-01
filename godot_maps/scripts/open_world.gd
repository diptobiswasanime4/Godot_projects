extends TileMapLayer

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

var width = 1024
var height = 1024

@onready var player = get_parent().get_child(1)

func _ready() -> void:
	moisture.seed = randi()
	temperature.seed = randi()
	altitude.seed = randi()

func _process(delta: float) -> void:
	generate_chunk(player.position)
	
func generate_chunk(position):
	var tile_pos = local_to_map(position)
	for x in range(width):
		for y in range(height):
			var map_x = tile_pos.x + x - width / 2
			var map_y = tile_pos.y + y - height / 2
			
			var moist = moisture.get_noise_2d(map_x, map_y) * 10
			var temp = temperature.get_noise_2d(map_x, map_y) * 10
			var alt = altitude.get_noise_2d(map_x, map_y) * 10
			
			if alt < 2:
				set_cell(Vector2i(map_x, map_y), 0, Vector2i(3, round(temp + 10) / 5))
			else:
				set_cell(Vector2i(map_x, map_y), 0, Vector2i(round(moist + 10) / 5, round(temp + 10) / 5))
