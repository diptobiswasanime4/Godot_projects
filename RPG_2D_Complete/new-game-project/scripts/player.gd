extends CharacterBody2D

var speed = 200
var player_state = "none"

@export var inv: Inv

func _physics_process(delta):
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if dir.x == 0 and dir.y == 0:
		player_state = "idle"
	elif dir.x != 0 or dir.y != 0:
		player_state = "walk"

	velocity = dir * speed
	move_and_slide()
	
	animate(dir)
	
func animate(dir):
	if player_state == "idle":
		$AnimatedSprite2D.play("idle_down")
	if player_state == "walk":
		if dir.x == -1:
			$AnimatedSprite2D.play("walk_left")
		elif dir.x == 1:
			$AnimatedSprite2D.play("walk_right")
		if dir.y == -1:
			$AnimatedSprite2D.play("walk_up")
		elif dir.y == 1:
			$AnimatedSprite2D.play("walk_down")
		
		if dir.x > 0.5 and dir.y > 0.5:
			$AnimatedSprite2D.play("walk_se")
		if dir.x > 0.5 and dir.y < -0.5:
			$AnimatedSprite2D.play("walk_ne")
		if dir.x < -0.5 and dir.y > 0.5:
			$AnimatedSprite2D.play("walk_sw")
		if dir.x < -0.5 and dir.y < -0.5:
			$AnimatedSprite2D.play("walk_nw")
		 
func player():
	pass

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
