tool
extends Node
class_name DanceDetector

export(NodePath) var WormNode setget _set_worm_node
onready var worm = get_node(WormNode) as WormKB2D


# Called when the node enters the scene tree for the first time.
func _ready():
#	test_save()
	pass
	
func calculate_score():
	var move : DanceMove = null
	var worm_anim : WormAnimation = move.animation as WormAnimation
	if not worm_anim:
		push_warning("dance move does not have valid Worm Animatino!")
		return
		
	
	var head = worm.get_head()
	var idx = 0
	var time = 0.0
	
	var anim_values = worm_anim.worm_value_tracks_interpolate(worm, time) as Dictionary
	var position_anim = anim_values['position']
	var rotation_anim = anim_values['rotation']
	var velocity_anim = anim_values['velocity']
	
	for seg_idx in worm.num_segments:	
		var segment = worm.get_segment(seg_idx) as WormBodyKB2D
		var position_rel = head.to_local(segment.position)
		var rotation_rel = segment.rotation_degrees - head.rotation_degrees
		var velocity_rel = segment.velocity.rotated(-head.rotation)

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
