tool
extends Node

export(NodePath) var ButtonNode : NodePath setget _set_button_node
onready var button_record : Button = get_node(ButtonNode) as Button
export(NodePath) var WormNode : NodePath setget _set_worm_node
onready var worm : WormKB2D = get_node(WormNode) as WormKB2D

# seconds per key frame
export(float) var sec_per_frame : float = 0.5

var recording : bool = false
var animation : Animation = null
var num_segs : int = 0

func _ready():
	pass
	
var time : float = 0.0
var frame_time : float = 0.0
func _process(delta):
	if button_record:
		button_record.text = "stop recording" if is_recording() else "start recording"
	
	if not is_recording():
		return
		
	
	var idx = 0
	if frame_time >= sec_per_frame:
		# record key frame
		for seg_idx in num_segs:
			var segment = worm.get_segment(seg_idx) as KinematicBody2D
			
			animation.track_insert_key(idx, time, segment.position)
			idx += 1
			
			animation.track_insert_key(idx, time, segment.rotation_degrees)
			idx += 1
			
		frame_time = 0
		
	time += delta
	frame_time += delta
	
func save_animation(anim_name : String):
	if animation != null:
		animation.resource_name = anim_name
		ResourceSaver.save("res://Dance/Animation/" + anim_name + ".tres", animation)
		Autoload.get_dances_db(self).add_animation(animation)
		
		
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
		
	num_segs = worm.num_segments
	if num_segs <= 0:
		push_warning("can't start recording, num worm segments is 0")
		return
		
	animation = Animation.new()
	var idx = 0
	for seg_idx in num_segs:
		animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(idx, worm_track_path(seg_idx, "position"))
		idx += 1
		
		animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(idx, worm_track_path(seg_idx, "rotation_degrees"))
		idx += 1
		
	recording = true
	time = 0
	frame_time = 0
		
func stop_recording():
	if not is_recording():
		push_warning("can't stop recording, not recording!")
		return

	animation.length = time
	recording = false
	time = 0
	frame_time = 0
	
func is_recording():
	return recording and animation != null
	

func _get_configuration_warning():
	var errors = []
	var as_worm = get_node(WormNode) as WormKB2D
	if not as_worm:
		errors.append("WormNode is not a WormKB2D! " + str(as_worm))
	var as_button = get_node(ButtonNode) as Button
	if not as_button:
		errors.append("ButtonNode is not a Button! " + str(as_button))
		
	var return_string = ""
	for error in errors:
		return_string += error
		return_string += "\n"
	return return_string
	
func _set_button_node(value):
	ButtonNode = value
	if is_inside_tree():
		get_tree().emit_signal("node_configuration_warning_changed", self)

func _set_worm_node(value):
	WormNode = value
	if is_inside_tree():
		get_tree().emit_signal("node_configuration_warning_changed", self)

func _on_Btn_Record_pressed():
	if is_recording():
		stop_recording()
		save_animation("Anim_Worm_" + str(animation.get_instance_id()))
	else:
		start_recording()
