extends CharacterBody2D

var speed_x = 200  # Speed along X-axis
var speed_y = 100  # Speed along Y-axis
var target_position = null  # Stores the clicked position
var move_threshold = 2  # Distance at which we consider the player "arrived"

func player_movement(delta):
	# Check for left mouse button click to set target position
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target_position = get_global_mouse_position()

	# If we have a target position, move toward it
	if target_position != null:
		var direction = (target_position - global_position).normalized()
		var distance = global_position.distance_to(target_position)

		# Stop if close enough to the target
		if distance < move_threshold:
			target_position = null
			$AnimatedSprite2D.play("idle")
			velocity.x = 0
			velocity.y = 0
		else:
			# Set velocity based on direction
			velocity.x = direction.x * speed_x
			velocity.y = direction.y * speed_y

			# Play appropriate animation based on direction
			if abs(direction.x) > abs(direction.y):
				if direction.x > 0:
					$AnimatedSprite2D.play("wolf_run_ne")
				else:
					$AnimatedSprite2D.play("wolf_run_sw")
			else:
				if direction.y > 0:
					$AnimatedSprite2D.play("wolf_run_se")
				else:
					$AnimatedSprite2D.play("wolf_run_nw")
	else:
		# Keyboard movement (optional)
		if Input.is_action_pressed("ui_right"):
			$AnimatedSprite2D.play("wolf_run_ne")
			velocity.x = speed_x
			velocity.y = -speed_y
		elif Input.is_action_pressed("ui_left"):
			$AnimatedSprite2D.play("wolf_run_sw")
			velocity.x = -speed_x
			velocity.y = speed_y
		elif Input.is_action_pressed("ui_up"):
			$AnimatedSprite2D.play("wolf_run_nw")
			velocity.x = -speed_x
			velocity.y = -speed_y
		elif Input.is_action_pressed("ui_down"):
			$AnimatedSprite2D.play("wolf_run_se")
			velocity.x = speed_x
			velocity.y = speed_y
		else:
			$AnimatedSprite2D.play("idle")
			velocity.x = 0
			velocity.y = 0

	move_and_slide()

func _physics_process(delta: float) -> void:
	player_movement(delta)

func player():
	pass

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
