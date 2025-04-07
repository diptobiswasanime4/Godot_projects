extends Node2D

const WIDTH = 80
const HEIGHT = 80
const CELL_SIZE = 10
const MIN_ROOM_SIZE = 6
const MAX_ROOM_SIZE = 10
const MAX_ROOMS = 5

var grid = []
var rooms = []

func _ready() -> void:
	randomize()
	initialize_grid()
	generate_dungeon()
	draw_dungeon()

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
			if rooms.size() > 0:
				connect_rooms(rooms[-1], room)
			rooms.append(room)
		
func generate_room():
	var room_width = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	var room_height = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
	var x = randi() % (WIDTH - room_width - 1) + 1
	var y = randi() % (HEIGHT - room_height - 1) + 1
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
	
func draw_dungeon():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var cell = ColorRect.new()
			cell.size = Vector2(CELL_SIZE, CELL_SIZE)
			cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
			cell.color = Color.WHITE if grid[x][y] == 0 else Color.BLACK
			add_child(cell)
			
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

func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	randomize()
	initialize_grid()
	generate_dungeon()
	draw_dungeon()
