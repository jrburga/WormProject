tool
extends Node

export(NodePath) var WormNode : NodePath
onready var worm : WormKB2D = get_node(WormNode)

func _ready():
	var worm
	
func _get_configuration_warning():
	if get_node(WormNode) == null:
		return "WormNode is not a worm!"
	return ""
