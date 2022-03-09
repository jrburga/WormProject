extends Node2D

class_name WormKB2D


#const scnWormBodyKB2D = preload("./WormBodyKB2D.tscn")

var TouchTracker = load("res://Scripts/TouchTracker.gd")

export(PackedScene) var scnWormBodyKB2D = null
export(Resource) var worm_settings = null
export(float) var seg_radius = 20 setget _set_seg_radius, _get_seg_radius
export(int) var num_segments = 10


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var debug_draw = false
var touch_tracker : TouchTracker = null
var segments = []
# Called when the node enters the scene tree for the first time.

func _set_seg_radius(value):
	seg_radius = value
	for segment in segments:
		segment.radius = seg_radius
		
func _get_seg_radius():
	return seg_radius

func get_head():
	return segments[0] if segments.size() > 0 else null
	
func _process(delta):
	if debug_draw:
		update()
	
func _draw():
	if debug_draw:
		for tracker in touch_tracker.tracker_objects:
			if tracker and tracker.object:
				draw_circle(tracker.touch_position, 20, Color.red)
	
func _ready():
	
	touch_tracker = TouchTracker.new() as TouchTracker
	
	segments = [$Worm0]
	$Worm0.index = 0
	$Worm0.radius = seg_radius
	for index in range(1, num_segments):
		var new_worm_body = scnWormBodyKB2D.instance()
		new_worm_body.set_name("Worm" + str(index))
		new_worm_body.index = index
		new_worm_body.parent = segments[index - 1]
		new_worm_body.radius = seg_radius
		segments[index - 1].child = new_worm_body
		segments.append(new_worm_body)
		
		self.add_child(new_worm_body)
		
		new_worm_body.position = segments[index - 1].position - Vector2(0, seg_radius)
		
	for segment in segments:
		segment._worm_ready()
		
	
		
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
		
func _get_position_from_event(event):
	return event.position - get_canvas_transform().origin
	
var ctrl_down = false
var emulate_index = 0
var mouse_button_down = false
func _input(event):
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
				touch_tracker.set_tracker_object(emulate_index, mouse_position, get_head())
			else:
				touch_tracker.set_tracker_object(emulate_index, mouse_position, dragging_segment)
		else:
			touch_tracker.clear_tracker_object_at(emulate_index)
			
	elif event is InputEventMouseMotion and mouse_button_down:
		var mouse_position = _get_position_from_event(event)
		touch_tracker.update_tracker_object(emulate_index, mouse_position)

	# touch screen events
	elif event is InputEventScreenTouch:
		if event.pressed:
			var touch_position = _get_position_from_event(event)
			var dragging_segment = _get_closest_segment(touch_position, worm_settings.grab_radius)
			if dragging_segment:
				touch_tracker.set_tracker_object(event.index, touch_position, dragging_segment)
			else:
				touch_tracker.set_tracker_object(event.index, touch_position, get_head())
		else:
			touch_tracker.clear_tracker_object_at(event.index)
		
	elif event is InputEventScreenDrag:
		var touch_position = _get_position_from_event(event)
		touch_tracker.update_tracker_object(event.index, touch_position)

func is_dragging(segment) -> bool:
	return touch_tracker.find_tracker_object(segment) != null
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass