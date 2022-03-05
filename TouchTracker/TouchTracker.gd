extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var tracking = false

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
		if (event.button_index == 1):
			tracking == true
		
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(1):
#			print(event.position)
#			print(event.global_position)
			
#			print(get_viewport_transform())
#			print(get_viewport(), get_viewport().get_camera())
#			var current_camera : Camera2D = get_node(CameraMgr.node_path).get_current_camera()
#			if current_camera:
#				print(current_camera.get_camera_position())

			var new_position = event.global_position - get_canvas_transform().origin
			global_position = new_position

#			global_position += event.relative
