extends StaticBody2D

func _ready() -> void:
	fallFrom()
	
func fallFrom():
	$AnimationPlayer.play("fallFromTree")
	await get_tree().create_timer(1).timeout
	print("+1 apples")
	await get_tree().create_timer(0.5).timeout
	queue_free()
