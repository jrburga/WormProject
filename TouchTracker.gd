extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventScreenTouch:
		if event.pressed == false:
			queue_free()
	
	if event is InputEventScreenDrag:
		print(event.position)
		
	if event is InputEventMouseButton:
		event.button_index == 1
		
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(1):
			print(event.position)
#			get_viewport().get_camera().project_position()
