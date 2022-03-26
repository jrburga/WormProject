tool
extends Node

export(NodePath) var WormNode : NodePath
onready var worm : WormKB2D = get_node(WormNode) as WormKB2D

# seconds per key frame
var sec_per_frame : float = 1.0

var recording : bool = false
var animation : Animation = null
var num_tracks : int = 0

func _ready():
	pass
	
var time : float = 0.0
func _process(delta):
	if not is_recording():
		return
		
	for idx in num_tracks:
		var segment = worm.get_segment(idx) as KinematicBody2D
		animation.track_insert_key(idx, time, segment.position)
		
	time += delta
	
func save_animation(anim_name : String):
	if animation != null:
		ResourceSaver.save("res://Dance/Animation/" + anim_name + ".tres", animation)
		
func clear_animation():
	animation = null
	
func worm_track_path(idx, value_name) -> String:
	return "Worm" + str(idx) + ":" + value_name

		
func start_recording():
	if is_recording():
		push_warning("can't start recording, already recording!")
		return
		
	if worm == null:
		push_warning("no worm to start recording")
		return
		
	num_tracks = worm.num_segments
	if num_tracks <= 0:
		push_warning("can't start recording, num tracks (worm segments) is 0")
		return
		
	animation = Animation.new()
	for idx in num_tracks:
		animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(idx, worm_track_path(idx, "position"))
		
	recording = true
	time = 0
		
func stop_recording():
	if not is_recording():
		push_warning("can't stop recording, not recording!")
		return

	recording = false
	time = 0
	
func is_recording():
	return recording and animation != null
	
	
func _get_configuration_warning():
	if get_node(WormNode) == null:
		return "WormNode is not a worm!"
	return ""
