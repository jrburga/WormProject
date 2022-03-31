extends Node2D
class_name WormKB2D


onready var animation_player : AnimationPlayer = $AnimationPlayer
export(PackedScene) var scnWormBodyKB2D = null
export(Resource) var worm_settings = null
export(float) var seg_radius = 20 setget _set_seg_radius, _get_seg_radius
export(int) var num_segments = 10

export(Color) var color : Color = Color.white setget _set_color, _get_color

signal segment_grabbed(segment)
signal segment_released(segment)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var debug_draw = false
var touch_tracker : TouchTracker = null
var segments = []
# Called when the node enters the scene tree for the first time.

func _on_PlayerConfig_worm_color_changed(new_color):
	_set_color(new_color)

func _set_color(value):
	color = value
	for segment in segments:
		segment.color = color
	
func _get_color() -> Color:
	return color

func _set_seg_radius(value):
	seg_radius = value
	for segment in segments:
		segment.radius = seg_radius
		
func _get_seg_radius() -> float:
	return seg_radius

func get_head():
	return segments[0] if segments.size() > 0 else null
	
func get_segment(index : int):
	return segments[index] if index >=0 and index < segments.size() else null

	
func _process(delta):
	update()
		
	
func _draw():
	if debug_draw:
		for tracker in touch_tracker.tracker_objects:
			if tracker and tracker.object:
				draw_circle(tracker.touch_position, 20, Color.red)
				
		for segment in segments:
			var end_point = segment.velocity.normalized() * 100
			draw_line(segment.position, segment.position + end_point, Color.red)
			draw_circle(segment.position + end_point, 5, Color.red)
	
func _ready():
	if not Engine.editor_hint:
		var player_config = Autoload.get_player_config(self)
		player_config.connect("worm_color_changed", self, "_on_PlayerConfig_worm_color_changed")
	
		touch_tracker = TouchTracker.new() as TouchTracker
	
	var head = $Worm0
	segments = [head]
	head.index = 0
	head.radius = seg_radius
	for index in range(1, num_segments):
		var new_worm_body = scnWormBodyKB2D.instance()
		new_worm_body.set_name("Worm" + str(index))
		new_worm_body.index = index
		new_worm_body.parent = segments[index - 1]
		new_worm_body.radius = seg_radius
		segments[index - 1].child = new_worm_body
		segments.append(new_worm_body)
		
		self.add_child(new_worm_body)
		
		new_worm_body.position = segments[index - 1].position - Vector2(seg_radius, 0)
		
	for segment in segments:
		segment._worm_ready()
		
	
func get_num_dragging_segments() -> int:
	var num = 0
	for tracker in touch_tracker.tracker_objects:
		if tracker and tracker.object != null:
			num += 1
	return num
	
func get_dragged_segments() -> Array:
	var dragged_segments = []
	for tracker in touch_tracker.tracker_objects:
		if tracker and tracker.object != null:
			dragged_segments.append(tracker.object)
	return dragged_segments
	
func get_dragged_segment_indices() -> Array:
	var dragged_segments = []
	for tracker in touch_tracker.tracker_objects:
		var worm_body = tracker.object if tracker else null
		if worm_body:
			dragged_segments.append(worm_body.index)
	return dragged_segments
	
# returns grabbed segments as an integer
# interpreted as flags
func get_dragged_segments_flags() -> int:
	var flags = 0
	for tracker in touch_tracker.tracker_objects:
		var worm_body = tracker.object if tracker else null
		if worm_body:
			flags |= 1 << worm_body.index
	return flags
	
func _get_closest_segment(location : Vector2, radius : float = 0):
	var n_dist = Vector2()
	var n_segment = null
	var r_squared = radius * radius
	
	for segment in segments:
		var dist = (segment.position as Vector2).distance_squared_to(location)
		if radius <= 0 or dist <= r_squared:
			if n_segment == null or dist < n_dist:
				n_segment = segment
				n_dist = dist
			
	return n_segment
		
func _get_position_from_event(event) -> Vector2:
	return event.position - get_canvas_transform().origin
	
func _grab_segment(touch_index, init_position, segment):
	touch_tracker.set_tracker_object(touch_index, init_position, segment)
	emit_signal("segment_grabbed", segment)
	
func _release_touch(touch_index):
	var tracker = touch_tracker.find_tracker_object_at(touch_index)
	var release = tracker.object if tracker else null
	touch_tracker.clear_tracker_object_at(touch_index)
	if release:
		emit_signal("segment_released", release)
		
var ctrl_down = false
var emulate_index = 0
var mouse_button_down = false
func _unhandled_input(event):
	if event is InputEventKey:
		if event.scancode == KEY_CONTROL:
			ctrl_down = event.pressed
			
		if event.scancode == KEY_0:
			emulate_index = 0
		elif event.scancode == KEY_1:
			emulate_index = 1
		elif event.scancode == KEY_2:
			emulate_index = 2
			
	elif event is InputEventMouseButton and event.button_index == 1:
		if event.pressed:
			mouse_button_down = true
			var mouse_position = _get_position_from_event(event)
			var dragging_segment = _get_closest_segment(mouse_position, worm_settings.grab_radius)
			if dragging_segment == null:
				_grab_segment(emulate_index, mouse_position, get_head())
			else:
				_grab_segment(emulate_index, mouse_position, dragging_segment)
		else:
			_release_touch(emulate_index)
			
	elif event is InputEventMouseMotion and mouse_button_down:
		var mouse_position = _get_position_from_event(event)
		touch_tracker.update_tracker_object(emulate_index, mouse_position)

	# touch screen events
	elif event is InputEventScreenTouch:
		if event.pressed:
			var touch_position = _get_position_from_event(event)
			var dragging_segment = _get_closest_segment(touch_position, worm_settings.grab_radius)
			if dragging_segment:
				_grab_segment(event.index, touch_position, dragging_segment)
			else:
				_grab_segment(event.index, touch_position, get_head())
		else:
			_release_touch(event.index)
		
	elif event is InputEventScreenDrag:
		var touch_position = _get_position_from_event(event)
		touch_tracker.update_tracker_object(event.index, touch_position)

func is_dragging(segment) -> bool:
	return touch_tracker.find_tracker_object(segment) != null
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
