tool
extends Node
class_name DanceDetector

export(NodePath) var WormNode setget _set_worm_node
onready var worm = get_node(WormNode) as WormKB2D


# Called when the node enters the scene tree for the first time.
func _ready():
#	test_save()
	pass
	
func _set_worm_node(value):
	WormNode = value
	if is_inside_tree():
		get_tree().emit_signal("node_configuration_warning_changed", self)

func _get_configuration_warning():
	var errors = []
	if WormNode.is_empty() or not get_node(WormNode) is WormKB2D:
		errors.append("WormNode is not a WormKB2D! Path:'" + str(WormNode) + "'")
	var return_string = ""
	for error in errors:
		return_string += error
		return_string += "\n"
	return return_string
