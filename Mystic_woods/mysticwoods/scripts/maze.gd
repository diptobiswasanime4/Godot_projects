extends Node2D

# Maze dimensions
const ROWS = 25
const COLS = 25
const CELL_SIZE = 20

# Colors
const WALL_COLOR = Color("#333333")
const PATH_COLOR = Color("#eeeeee")

# Maze data
var maze = []

# UI elements
var generate_button: Button

# Node for storing walls
var walls_container: Node2D

func _ready():
	# Setup the scene
	setup_ui()
	
	# Create container for wall collision objects
	walls_container = Node2D.new()
	walls_container.name = "Walls"
	add_child(walls_container)
	
	# Initialize maze array
	initialize_maze()
	
	# Generate initial maze
	generate_maze()
	
	# Force redraw
	queue_redraw()

func setup_ui():
	# Create a generate button
	generate_button = Button.new()
	generate_button.text = "Generate New Maze"
	generate_button.position = Vector2(10, ROWS * CELL_SIZE + 10)
	generate_button.size = Vector2(150, 30)
	generate_button.connect("pressed", Callable(self, "_on_generate_button_pressed"))
	add_child(generate_button)

func initialize_maze():
	# Create a 2D array filled with walls (1)
	maze = []
	for r in range(ROWS):
		var row = []
		for c in range(COLS):
			row.append(1)
		maze.append(row)

func generate_maze():
	# Reset maze to all walls
	for r in range(ROWS):
		for c in range(COLS):
			maze[r][c] = 1
	
	# Start at position (1,1)
	var start_row = 1
	var start_col = 1
	maze[start_row][start_col] = 0
	
	# Start carving passages
	carve_passages(start_row, start_col)
	
	# Create the collision walls
	create_collision_walls()

func carve_passages(r, c):
	# Define the four possible directions (up, right, down, left) with a step of 2
	var directions = [
		[-2, 0],  # Up
		[0, 2],   # Right
		[2, 0],   # Down
		[0, -2]   # Left
	]
	
	# Randomize direction order
	directions.shuffle()
	
	# Try each direction
	for direction in directions:
		var dr = direction[0]
		var dc = direction[1]
		
		var new_r = r + dr
		var new_c = c + dc
		
		# Check if the new position is valid and still a wall
		if new_r > 0 and new_r < ROWS - 1 and new_c > 0 and new_c < COLS - 1 and maze[new_r][new_c] == 1:
			# Carve passage by making the wall between current and new cell a path
			maze[r + dr/2][c + dc/2] = 0
			# Make the new cell a path
			maze[new_r][new_c] = 0
			# Continue from the new cell
			carve_passages(new_r, new_c)

func create_collision_walls():
	# Remove old walls
	for child in walls_container.get_children():
		child.queue_free()
	
	# Create new collision walls for each wall cell
	for r in range(ROWS):
		for c in range(COLS):
			if maze[r][c] == 1:  # This is a wall
				var wall = StaticBody2D.new()
				wall.position = Vector2(c * CELL_SIZE + CELL_SIZE/2, r * CELL_SIZE + CELL_SIZE/2)
				
				var collision = CollisionShape2D.new()
				var shape = RectangleShape2D.new()
				shape.size = Vector2(CELL_SIZE, CELL_SIZE)
				collision.shape = shape
				
				wall.add_child(collision)
				walls_container.add_child(wall)

func _draw():
	# Draw the maze
	for r in range(ROWS):
		for c in range(COLS):
			var color = WALL_COLOR if maze[r][c] == 1 else PATH_COLOR
			var rect = Rect2(c * CELL_SIZE, r * CELL_SIZE, CELL_SIZE, CELL_SIZE)
			draw_rect(rect, color)

func _on_generate_button_pressed():
	# Generate a new maze and redraw
	generate_maze()
	queue_redraw()
