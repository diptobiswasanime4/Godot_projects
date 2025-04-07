extends Node2D

const WIDTH = 40
const HEIGHT = 25
const MIN_ROOM_SIZE = 5
const MAX_ROOM_SIZE = 8
const MAX_ROOMS = 3

const TILE_FLOOR = Vector2i(1, 1)
const TILE_CAVE = Vector2i(3, 0)
const TILE_WALL_N = Vector2i(1, 0)
const TILE_WALL_S = Vector2i(1, 2)
const TILE_WALL_E = Vector2i(2, 1)
const TILE_WALL_W = Vector2i(0, 1)
const TILE_CORNER_NW = Vector2i(0, 0)
const TILE_CORNER_NE = Vector2i(2, 0)
const TILE_CORNER_SW = Vector2i(0, 2)
const TILE_CORNER_SE = Vector2i(2, 2)
const TILE_CORRIDOR_NW = Vector2i(3, 1)
const TILE_CORRIDOR_NE = Vector2i(3, 2)
const TILE_CORRIDOR_SW = Vector2i(0, 3)
const TILE_CORRIDOR_SE = Vector2i(1, 3)


var grid = []
var rooms = []

var source_id = 1

@onready var tilemap = $TileMapLayer
@onready var player = $Runa

func _ready() -> void:
	randomize()
	initialize_grid()
	generate_dungeon()
	draw_dungeon_with_tilemap()
	spawn_player_in_first_room()
	
func spawn_player_in_first_room():
	if rooms.size() == 0:
		return
		
	var first_room = rooms[0]
	var center = Vector2(
		first_room.position.x + first_room.size.x / 2,
		first_room.position.y + first_room.size.y / 2,
	)
	player.position = tilemap.map_to_local(Vector2i(center)).floor()

func initialize_grid():
	grid = []
	for x in range(WIDTH):
		var row = []
		for y in range(HEIGHT):
			row.append(1)
		grid.append(row)
		
func generate_dungeon():
	for i in range(MAX_ROOMS):
		var room = generate_room()
		if place_room(room):
			if (rooms.size() > 0):
				connect_rooms(rooms[-1], room)
			rooms.append(room)
		
func generate_room():
	var room_width = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	var room_height = room_width
	var x = randi() % (WIDTH - room_width)
	var y = randi() % (HEIGHT - room_height)
	return Rect2(x, y, room_width, room_height)
	
func place_room(room):
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			if grid[x][y] == 0:
				return false
	
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			grid[x][y] = 0
	return true
	
func connect_rooms(room1, room2, corridor_width=2):
	var start = Vector2(
		int(room1.position.x + room1.size.x / 2),
		int(room1.position.y + room1.size.y / 2)
	)
	var end = Vector2(
		int(room2.position.x + room2.size.x / 2),
		int(room2.position.y + room2.size.y / 2)
	)
	
	var current = start
	
	while current.x != end.x:
		if end.x > current.x:
			current.x += 1
		else:
			current.x -= 1
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				if current.y + j >= 0 and current.y + j < HEIGHT and current.x + i >= 0 and current.x + i < WIDTH:
					grid[current.x + i][current.y + j] = 0
	
	while current.y != end.y:
		if end.y > current.y:
			current.y += 1
		else:
			current.y -= 1
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				if current.x + j >= 0 and current.x + j < HEIGHT and current.y + i >= 0 and current.y + i < WIDTH:
					grid[current.x + i][current.y + j] = 0
	
func is_valid_pos(x, y):
	return x >= 0 and x < WIDTH and y >= 0 and y < HEIGHT

func draw_dungeon_with_tilemap():
	tilemap.clear()
	
	for x in range(WIDTH):
		for y in range(HEIGHT):
			if grid[x][y] == 0:
				tilemap.set_cell(Vector2i(x, y), source_id, TILE_FLOOR)
			else:
				tilemap.set_cell(Vector2i(x, y), source_id, TILE_CAVE)
	
	for x in range(WIDTH):
		for y in range(HEIGHT):
			if grid[x][y] == 0:
				var is_floor_N = is_valid_pos(x, y-1) and grid[x][y-1] == 1
				var is_floor_S = is_valid_pos(x, y+1) and grid[x][y+1] == 1
				var is_floor_E = is_valid_pos(x+1, y) and grid[x+1][y] == 1
				var is_floor_W = is_valid_pos(x-1, y) and grid[x-1][y] == 1
				
				var is_floor_NW = is_valid_pos(x-1, y-1) and grid[x-1][y-1] == 1
				var is_floor_NE = is_valid_pos(x+1, y-1) and grid[x+1][y-1] == 1
				var is_floor_SW = is_valid_pos(x-1, y+1) and grid[x-1][y+1] == 1
				var is_floor_SE = is_valid_pos(x+1, y+1) and grid[x+1][y+1] == 1
				
				if is_floor_NW and not is_floor_N and not is_floor_W:
					tilemap.set_cell(Vector2i(x, y), source_id, TILE_CORRIDOR_NW)
				elif is_floor_NE and not is_floor_N and not is_floor_E:
					tilemap.set_cell(Vector2i(x, y), source_id, TILE_CORRIDOR_NE)
				elif is_floor_SW and not is_floor_S and not is_floor_W:
					tilemap.set_cell(Vector2i(x, y), source_id, TILE_CORRIDOR_SW)
				elif is_floor_SE and not is_floor_S and not is_floor_E:
					tilemap.set_cell(Vector2i(x, y), source_id, TILE_CORRIDOR_SE) 
				elif is_floor_N and is_floor_E:
					tilemap.set_cell(Vector2i(x, y), source_id, TILE_CORNER_NE)
				elif is_floor_N and is_floor_W:
					tilemap.set_cell(Vector2i(x, y), source_id, TILE_CORNER_NW)
				elif is_floor_S and is_floor_E:
					tilemap.set_cell(Vector2i(x, y), source_id, TILE_CORNER_SE)
				elif is_floor_S and is_floor_W:
					tilemap.set_cell(Vector2i(x, y), source_id, TILE_CORNER_SW)
				elif is_floor_N:
					tilemap.set_cell(Vector2i(x, y), source_id, TILE_WALL_N)
				elif is_floor_S:
					tilemap.set_cell(Vector2i(x, y), source_id, TILE_WALL_S)
				elif is_floor_E:
					tilemap.set_cell(Vector2i(x, y), source_id, TILE_WALL_E)
				elif is_floor_W:
					tilemap.set_cell(Vector2i(x, y), source_id, TILE_WALL_W)

func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	randomize()
	initialize_grid()
	generate_dungeon()
	draw_dungeon_with_tilemap()


func _on_button_2_pressed() -> void:
	if source_id == 1:
		source_id = 2
	elif source_id == 2:
		source_id = 1
	draw_dungeon_with_tilemap()
