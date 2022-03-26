tool
extends Node

export(NodePath) var RecordButtonNode : NodePath setget _set_record_button_node
onready var button_record : Button = get_node(RecordButtonNode) as Button

export(NodePath) var PlaybackButtonNode : NodePath setget _set_playback_button_node
onready var button_playback : Button = get_node(PlaybackButtonNode)

export(NodePath) var PlaybackLineEditNode : NodePath setget _set_playback_line_edit
onready var line_edit_playback : LineEdit = get_node(PlaybackLineEditNode)

export(NodePath) var WormNode : NodePath setget _set_worm_node
onready var worm : WormKB2D = get_node(WormNode) as WormKB2D

# seconds per key frame
export(float) var sec_per_frame : float = 0.01

var recording : bool = false
var animation : Animation = null
var num_segs : int = 0

func _ready():
	pass
	
var time : float = 0.0
var frame_time : float = 0.0
func _physics_process(delta):
	if button_record:
		button_record.text = "stop recording" if is_recording() else "start recording"
	
	if not is_recording():
		return
		
	
	var idx = 0
#	if frame_time >= sec_per_frame:
		# record key frame
		
	var head = worm.get_head()
	var offset_transform = Transform2D()
	for seg_idx in num_segs:
		var segment = worm.get_segment(seg_idx) as WormBodyKB2D
		
		var position_rel = head.to_local(segment.position)
		animation.track_insert_key(idx, time, position_rel)
		idx += 1
		
		var rotation_rel = segment.rotation_degrees - head.rotation_degrees
		animation.track_insert_key(idx, time, rotation_rel)
		idx += 1
		
		var velocity_rel = segment.velocity.rotated(-head.rotation)
		animation.track_insert_key(idx, time, velocity_rel)
		idx += 1
		
#	frame_time = 0
		
	time += delta
	frame_time += delta
	
func save_animation(anim_name : String):
	if animation != null:
		animation.resource_name = anim_name
		ResourceSaver.save("res://Dance/Animation/" + anim_name + ".tres", animation)
		Autoload.get_dances_db(self).add_animation(animation)
		line_edit_playback.text = animation.resource_name
		
		
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
		
		animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(idx, worm_track_path(seg_idx, "velocity"))
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
	if not WormNode.is_empty() and not get_node(WormNode) is WormKB2D:
		errors.append("WormNode is not a WormKB2D! " + str(WormNode))
	if not RecordButtonNode.is_empty() and not get_node(RecordButtonNode) is Button:
		errors.append("RecordButtonNode is not a Button! " + str(RecordButtonNode))
	if not PlaybackButtonNode.is_empty() and not get_node(PlaybackButtonNode) is Button:
		errors.append("PlaybackButtonNode is not a Button! " + str(PlaybackButtonNode))
	if not PlaybackLineEditNode.is_empty() and not get_node(PlaybackLineEditNode) is LineEdit:
		errors.append("PlaybackLineEdit is not a LineEdit!" + str(PlaybackLineEditNode))
		
	var return_string = ""
	for error in errors:
		return_string += error
		return_string += "\n"
	return return_string
	
func _set_record_button_node(value):
	RecordButtonNode = value
	if is_inside_tree():
		get_tree().emit_signal("node_configuration_warning_changed", self)
		
func _set_playback_button_node(value):
	PlaybackButtonNode = value
	if is_inside_tree():
		get_tree().emit_signal("node_configuration_warning_changed", self)
		
func _set_playback_line_edit(value):
	PlaybackLineEditNode = value
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


func _on_Btn_Playback_pressed():
	if is_recording():
		push_warning("Can't do playback while recording!")
		
	else:
		var anim_name = line_edit_playback.text
		var playback_animation = Autoload.get_dances_db(self).find_animation(anim_name)
		
		if playback_animation:
			if not worm.animation_player.has_animation(playback_animation.resource_name):
				worm.animation_player.add_animation(playback_animation.resource_name, playback_animation)
			worm.animation_player.play(playback_animation.resource_name)
	
	
