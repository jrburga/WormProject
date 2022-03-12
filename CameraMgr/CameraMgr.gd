extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const node_path : String = "/root/CameraMgr"

func get_current_camera():
	var cameras = get_tree().get_nodes_in_group("Camera2D")
	for child in get_tree().current_scene.get_children():
		if child is Camera2D and child.current:
			return child
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
