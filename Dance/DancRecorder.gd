tool
extends Node

onready var button_record : Button = $CanvasLayer/AnimationPopup/Btn_Record
onready var button_playback : Button = $CanvasLayer/AnimationPopup/Btn_Playback
onready var line_edit_playback : LineEdit = $CanvasLayer/AnimationPopup/Edit_Playback
onready var slider_playback : Slider = $CanvasLayer/AnimationPopup/Control/Slider_Playback

export(NodePath) var WormNode : NodePath setget _set_worm_node
onready var worm : WormKB2D = get_node(WormNode) as WormKB2D

# seconds per key frame
export(float) var sec_per_frame : float = 0.01

var recording : bool = false
var animation : Animation = null
var num_segs : int = 0

func _unhandled_input(event):
	if event.is_action_pressed("toggle_animation_debug"):
		var animation_popup = $CanvasLayer/AnimationPopup as Control
		if animation_popup:
			animation_popup.visible = !animation_popup.visible


func _ready():
	pass
	
var time : float = 0.0
var frame_time : float = 0.0
func _physics_process(delta):
	if button_record:
		button_record.text = "stop recording" if is_recording() else "start recording"
		
	if button_playback:
		button_playback.text = "stop playback" if worm.animation_player.is_playing() else "start playback"
	
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
	var return_string = ""
	for error in errors:
		return_string += error
		return_string += "\n"
	return return_string

func _set_worm_node(value):
	WormNode = value
	if is_inside_tree():
		get_tree().emit_signal("node_configuration_warning_changed", self)
		

func _on_Btn_Record_pressed():
	if worm.animation_player.is_playing():
		push_warning("Can't start recording while playback is playing!")
	elif is_recording():
		stop_recording()
		var anim_name = "Anim_Worm_" + str(animation.get_instance_id())
		Autoload.get_dances_db(self).save_animation(anim_name, animation)
		line_edit_playback.text = animation.resource_name
	else:
		start_recording()


func _on_Btn_Playback_pressed():
	if is_recording():
		push_warning("Can't start playback while recording!")
	elif worm.animation_player.is_playing():
		worm.animation_player.stop()
	else:
		var anim_name = line_edit_playback.text
		var playback_animation = Autoload.get_dances_db(self).find_animation(anim_name)
		
		if playback_animation:
			if not worm.animation_player.has_animation(playback_animation.resource_name):
				worm.animation_player.add_animation(playback_animation.resource_name, playback_animation)
			worm.animation_player.play(playback_animation.resource_name, -1, 0, false)

func _on_Slider_Playback_value_changed(value):
	var current_length = worm.animation_player.current_animation_length
	worm.animation_player.seek(value * current_length)


func _on_Btn_TrimLeft_pressed():
	if worm.animation_player.is_playing():
		var anim_name : String = worm.animation_player.current_animation
		var current_animation : Animation = worm.animation_player.get_animation(anim_name)
		var trim_time = slider_playback.value * current_animation.length
		worm.animation_player.stop()

		animation_trim_left(current_animation, trim_time)

		Autoload.get_dances_db(self).save_animation(anim_name, current_animation)
		worm.animation_player.play(anim_name, -1, 0, false)

func _on_Btn_TrimRight_pressed():
	if worm.animation_player.is_playing():
		var anim_name : String = worm.animation_player.current_animation
		var current_animation : Animation = worm.animation_player.get_animation(anim_name)
		var trim_time = slider_playback.value * current_animation.length
		worm.animation_player.stop()

		animation_trim_right(current_animation, trim_time)

		Autoload.get_dances_db(self).save_animation(anim_name, current_animation)
		worm.animation_player.play(anim_name, -1, 0, false)

func _on_Button_pressed():
	if worm.animation_player.is_playing():
		var anim_name : String = worm.animation_player.current_animation
		var current_animation : Animation = worm.animation_player.get_animation(anim_name)
		var trim_time = slider_playback.value * current_animation.length
		worm.animation_player.stop()
		
		animation_single_frame(current_animation, trim_time)
		
		Autoload.get_dances_db(self).save_animation(anim_name, current_animation)
		worm.animation_player.play(anim_name, -1, 0, false)
		
func animation_single_frame(in_animation : Animation, frame_time : float):
	animation_trim_left(in_animation, frame_time)
	animation_trim_right(in_animation, 0)
	
	
func animation_trim_left(in_animation : Animation, trim_time : float):
	var key_count = in_animation.track_get_key_count(0)
	var trim_index = 0
	for key_idx in key_count:
		var key_time = in_animation.track_get_key_time(0, key_idx)
		if key_time >= trim_time:
			trim_index = key_idx
			break
			
	print("trim left: %d - %d - %d" % [trim_index, 0, key_count])
	if trim_index > 0:
		var trim_key_time = in_animation.track_get_key_time(0, trim_index)
		var track_count = in_animation.get_track_count()
		for key_idx in trim_index:
			for track_idx in track_count:
				in_animation.track_remove_key(track_idx, 0)
				
		var new_key_count = in_animation.track_get_key_count(0)
		for key_idx in new_key_count:
			for track_idx in track_count:
				var key_time = in_animation.track_get_key_time(track_idx, key_idx)
				var new_time = key_time - trim_key_time
				in_animation.track_set_key_time(track_idx, key_idx, new_time)
				
		in_animation.length = in_animation.track_get_key_time(0, new_key_count - 1)
		
func animation_trim_right(in_animation : Animation, trim_time : float):
	var key_count = in_animation.track_get_key_count(0)
	var trim_index = key_count - 1
	for key_idx in range(key_count-1, -1, -1):
		var key_time = in_animation.track_get_key_time(0, key_idx)
		if key_time <= trim_time:
			trim_index = key_idx
			break
			
	print("trim right: %d - %d - %d" % [trim_index, 0, key_count])
	if trim_index < key_count - 1:
		var trim_key_time = in_animation.track_get_key_time(0, trim_index)
		var track_count = in_animation.get_track_count()
		for key_idx in range(key_count-1, trim_index, -1):
			for track_idx in track_count:
				in_animation.track_remove_key(track_idx, key_idx)
				
		var new_key_count = in_animation.track_get_key_count(0)
		in_animation.length = in_animation.track_get_key_time(0, new_key_count - 1)
