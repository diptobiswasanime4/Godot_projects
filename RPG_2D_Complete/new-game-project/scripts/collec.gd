extends StaticBody2D


func _ready() -> void:
	fall()

func fall():
	$AnimationPlayer.play("fallingfromtree")
	await get_tree().create_timer(1).timeout
	print("+1 apples")
	queue_free()
