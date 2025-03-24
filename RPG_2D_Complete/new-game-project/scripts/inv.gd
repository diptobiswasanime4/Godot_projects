extends Control

@onready var inv: Inv = preload("res://inventory/playerinv.tres")
@onready var slots: Array = $NinePatchRect.get_children()

var is_open = true

func _ready():
	update_slots()
	close()
	
func update_slots():
	for i in range(min(inv.items.size(), slots.size())):
		slots[i].update(inv.items[i])
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if is_open:
			close()
		else:
			open()
		
	
func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false
