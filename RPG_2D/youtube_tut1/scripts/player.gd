extends CharacterBody2D

const speed = 100

func _physics_process(delta: float) -> void:
	player_movement(delta)
	
func player_movement(delta):
	
	if Input.is_action_pressed("ui_right"):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("side")
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("side")
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_up"):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("up")
		velocity.x = 0
		velocity.y = -speed
	elif Input.is_action_pressed("ui_down"):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("down")
		velocity.x = 0
		velocity.y = speed
	else:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("idle")
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()
