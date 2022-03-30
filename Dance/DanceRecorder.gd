tool
extends Node

onready var button_record : Button = $CanvasLayer/AnimationPopup/Btn_Record
onready var button_playback : Button = $CanvasLayer/AnimationPopup/Btn_Playback
onready var line_edit_playback : LineEdit = $CanvasLayer/AnimationPopup/Edit_Playback
onready var slider_playback : Slider = $CanvasLayer/AnimationPopup/AnimationControls/Slider_Playback

export(NodePath) var WormNode : NodePath setget _set_worm_node
onready var worm : WormKB2D = get_node(WormNode) as WormKB2D

# seconds per key frame
export(float) var sec_per_frame : float = 0.01

var recording : bool = false
var animation : WormAnimation = null
var num_segs : int = 0

func _unhandled_input(event):
	if event.is_action_pressed("toggle_animation_debug"):
		var animation_popup = $CanvasLayer/AnimationPopup as Control
		if animation_popup:
			animation_popup.visible = !animation_popup.visible


func _ready():
	pass
	
var time : float = 0.0
func _process(delta):
	if Engine.editor_hint:
		return
		
	if worm and worm.animation_player:
		if button_record:
			button_record.text = "stop recording" if is_recording() else "start recording"
			
		if button_playback:
			button_playback.text = "stop playback" if worm.animation_player.is_playing() else "start playback"
		
		$CanvasLayer/AnimationPopup/AnimationControls.visible = worm.animation_player.is_playing()
		
	if not is_recording():
		return
	record_keys(time)
	time += delta

func record_keys(key_time : float):
	animation.worm_tracks_insert_keys(worm, key_time)

func make_animation():
	var new_animation = WormAnimation.new()
	new_animation.worm_add_tracks(worm)
	return new_animation

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
		
	animation = make_animation()
	recording = true
	time = 0
		
func stop_recording():
	if not is_recording():
		push_warning("can't stop recording, not recording!")
		return
		
	animation.length = time
	recording = false
	time = 0
	
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
		Autoload.get_dances_db(self).save_raw_animation(anim_name, animation)
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
		var current_animation : WormAnimation = worm.animation_player.get_animation(anim_name)
		var trim_time = slider_playback.value * current_animation.length
		worm.animation_player.stop()

		current_animation.tracks_trim_left(trim_time)

		Autoload.get_dances_db(self).save_animation(anim_name, current_animation)
		worm.animation_player.play(anim_name, -1, 0, false)

func _on_Btn_TrimRight_pressed():
	if worm.animation_player.is_playing():
		var anim_name : String = worm.animation_player.current_animation
		var current_animation : WormAnimation = worm.animation_player.get_animation(anim_name)
		var trim_time = slider_playback.value * current_animation.length
		worm.animation_player.stop()

		current_animation.tracks_trim_right(trim_time)

		Autoload.get_dances_db(self).save_animation(anim_name, current_animation)
		worm.animation_player.play(anim_name, -1, 0, false)

func _on_Button_pressed():
	if worm.animation_player.is_playing():
		var anim_name : String = worm.animation_player.current_animation
		var current_animation : WormAnimation = worm.animation_player.get_animation(anim_name)
		var trim_time = slider_playback.value * current_animation.length
		worm.animation_player.stop()
		
		current_animation.tracks_take_single_frame(trim_time)
		
		Autoload.get_dances_db(self).save_animation(anim_name, current_animation)
		worm.animation_player.play(anim_name, -1, 0, false)
