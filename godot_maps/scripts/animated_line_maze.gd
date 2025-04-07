extends Node2D

# Button reference
@onready var generate_button = $GenerateButton

# Canvas dimensions
var canvas_width = 800
var canvas_height = 800
var cell_size = 50
var rows
var cols

# Maze data
var maze = []
var visited_cells = []
var generate_id = 0

# Colors
var colors = {
	"bg": Color.WHITE,
	"wall": Color.BLACK,
	"visited": Color.ORANGE
}

# Stack for backtracking
var stack = []
var is_generating = false

func _ready():
	# Calculate grid dimensions based on canvas size
	rows = canvas_width / cell_size
	cols = canvas_height / cell_size
	
	# Connect button signal
	generate_button.connect("pressed", Callable(self, "_on_generate_button_pressed"))
	
	# Initialize and start generation
	init_maze()
	start_generation()

func init_maze():
	# Reset maze data
	maze = []
	visited_cells = []
	
	# Create maze grid
	for i in range(rows):
		var maze_row = []
		var visited_row = []
		
		for j in range(cols):
			# Each cell has four walls: top, right, bottom, left
			maze_row.append({"x": j, "y": i, "walls": [true, true, true, true]})
			visited_row.append(false)
			
		maze.append(maze_row)
		visited_cells.append(visited_row)

func start_generation():
	if is_generating:
		# Cancel current generation
		generate_id += 1
	
	var current_generation_id = generate_id
	is_generating = true
	
	# Initialize maze
	init_maze()
	stack = []
	
	# Choose random starting point
	var start_x = randi() % int(rows)
	var start_y = randi() % int(cols)
	
	# Mark as visited and add to stack
	visited_cells[start_y][start_x] = true
	stack.push_back({"x": start_x, "y": start_y})
	
	# Start the generation process
	queue_redraw()
	continue_generation(current_generation_id)

func continue_generation(current_generation_id):
	# Process a few steps per frame to show animation
	var steps_this_frame = 1
	
	while steps_this_frame > 0 and stack.size() > 0 and current_generation_id == generate_id:
		var current = stack.back()
		
		# Find unvisited neighbors
		var neighbors = unvisited_neighbors(current.x, current.y)
		
		if neighbors.size() == 0:
			# No unvisited neighbors, backtrack
			stack.pop_back()
		else:
			# Choose random neighbor
			var next = neighbors[randi() % neighbors.size()]
			
			# Remove walls between current and next
			remove_walls(current, next)
			
			# Mark as visited and add to stack
			visited_cells[next.y][next.x] = true
			stack.push_back(next)
		
		steps_this_frame -= 1
	
	# Redraw the maze
	queue_redraw()
	
	if stack.size() > 0 and current_generation_id == generate_id:
		# Continue generation in the next frame
		await get_tree().create_timer(0.05).timeout
		continue_generation(current_generation_id)
	else:
		is_generating = false

func unvisited_neighbors(x, y):
	var neighbors = []
	
	# Define the four directions: top, right, bottom, left
	var directions = [
		{"x": 0, "y": -1},  # Top
		{"x": 1, "y": 0},   # Right
		{"x": 0, "y": 1},   # Bottom
		{"x": -1, "y": 0}   # Left
	]
	
	for dir in directions:
		var new_x = x + dir.x
		var new_y = y + dir.y
		
		# Check if new position is valid and unvisited
		if new_x >= 0 and new_x < cols and new_y >= 0 and new_y < rows and not visited_cells[new_y][new_x]:
			neighbors.append({"x": new_x, "y": new_y})
	
	return neighbors

func remove_walls(a, b):
	var dx = a.x - b.x
	var dy = a.y - b.y
	
	# Remove walls between cells
	if dx == 1:  # a is to the right of b
		maze[a.y][a.x].walls[3] = false  # Remove left wall of a
		maze[b.y][b.x].walls[1] = false  # Remove right wall of b
	elif dx == -1:  # a is to the left of b
		maze[a.y][a.x].walls[1] = false  # Remove right wall of a
		maze[b.y][b.x].walls[3] = false  # Remove left wall of b
	
	if dy == 1:  # a is below b
		maze[a.y][a.x].walls[0] = false  # Remove top wall of a
		maze[b.y][b.x].walls[2] = false  # Remove bottom wall of b
	elif dy == -1:  # a is above b
		maze[a.y][a.x].walls[2] = false  # Remove bottom wall of a
		maze[b.y][b.x].walls[0] = false  # Remove top wall of b

func _draw():
	# Fill background
	draw_rect(Rect2(0, 0, canvas_width, canvas_height), colors.bg)
	
	# Draw maze
	for i in range(rows):
		for j in range(cols):
			var cell = maze[i][j]
			var x = j * cell_size
			var y = i * cell_size
			
			# Draw visited cells
			if visited_cells[i][j]:
				draw_rect(Rect2(x, y, cell_size, cell_size), colors.visited)
			
			# Draw walls
			if cell.walls[0]:  # Top wall
				draw_line(Vector2(x, y), Vector2(x + cell_size, y), colors.wall, 2)
			if cell.walls[1]:  # Right wall
				draw_line(Vector2(x + cell_size, y), Vector2(x + cell_size, y + cell_size), colors.wall, 2)
			if cell.walls[2]:  # Bottom wall
				draw_line(Vector2(x, y + cell_size), Vector2(x + cell_size, y + cell_size), colors.wall, 2)
			if cell.walls[3]:  # Left wall
				draw_line(Vector2(x, y), Vector2(x, y + cell_size), colors.wall, 2)

func _on_generate_button_pressed():
	start_generation()
