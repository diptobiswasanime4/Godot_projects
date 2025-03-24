extends Node2D

var state = "bush_apple"
var player_in = false

func _ready() -> void:
	if state == "no_bush_apple":
		$Timer.start()

func _process(delta: float) -> void:
	if state == "no_bush_apple":
		$AnimatedSprite2D.play("no_bush_apple")
	if state == "bush_apple":
		$AnimatedSprite2D.play("bush_apple")
		if player_in:
			if Input.is_action_just_pressed("ui_accept"):
				state = "no_bush_apple"
				$Timer.start()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in = false

func _on_timer_timeout() -> void:
	if state == "no_bush_apple":
		state = "bush_apple"
