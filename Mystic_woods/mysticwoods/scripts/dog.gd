extends CharacterBody2D

const speed = 300

func _physics_process(delta: float) -> void:
	player_movement(delta)
	
func player_movement(delta):
	
	if Input.is_action_pressed("ui_right"):
		$AnimatedSprite2D.play("dog_walk_right")
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		$AnimatedSprite2D.play("dog_walk_left")
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_up"):
		$AnimatedSprite2D.play("dog_walk_up")
		velocity.x = 0
		velocity.y = -speed
	elif Input.is_action_pressed("ui_down"):
		$AnimatedSprite2D.play("dog_walk_down")
		velocity.x = 0
		velocity.y = speed
	else:
		$AnimatedSprite2D.play("dog_idle_down")
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()
