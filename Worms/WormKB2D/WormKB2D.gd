extends Node2D

class_name WormKB2D

const scnWormBodyKB2D = preload("./WormBodyKB2D.tscn")
const WormBodyKB2D = preload("./WormBodyKB2D.gd")

export(float) var seg_radius = 20 setget _set_seg_radius, _get_seg_radius
export(int) var num_segments = 10
export(int) var speed = 300
export(float) var seg_distance = 10
export(float) var f_spring = 10
export(float) var w_parent = 0.75
export(float) var drag_coef = .01
export(float) var grab_radius = 20


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var mouse_button_down = false
var mouse_position = Vector2()
var segments = []
var dragging_segments = []
var dragging_segment = null
# Called when the node enters the scene tree for the first time.

func _set_seg_radius(value):
	seg_radius = value
	for segment in segments:
		segment.radius = seg_radius
		
func _get_seg_radius():
	return seg_radius

func get_head():
	return segments[0] if segments.size() > 0 else null
	
func _ready():
	segments = [$Worm0]
	$Worm0.index = 0
	$Worm0.radius = seg_radius
	for index in range(1, num_segments):
#		print(index)
		var new_worm_body = scnWormBodyKB2D.instance() as WormBodyKB2D
		new_worm_body.set_name("Worm" + str(index))
		new_worm_body.index = index
		new_worm_body.parent = segments[index - 1]
		new_worm_body.radius = seg_radius
		segments[index - 1].child = new_worm_body
		segments.append(new_worm_body)
		
		self.add_child(new_worm_body)
		
		new_worm_body.position = segments[index - 1].position - Vector2(0, seg_radius)
		
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
	
func _input(event):
	if event is InputEventMouseButton:
		mouse_button_down = event.pressed
		mouse_position = _get_position_from_event(event)
		if mouse_button_down:
			dragging_segment = _get_closest_segment(mouse_position, grab_radius)
			if dragging_segment == null:
				dragging_segment = get_head()
		else:
			dragging_segment = null
			
	if event is InputEventMouseMotion:
		mouse_position = _get_position_from_event(event)

func is_dragging(segment) -> bool:
	return segment == dragging_segment if segment != null else false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
