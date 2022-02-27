tool
extends Node2D

const WormBody2D = preload("res://Worm2D/WormBody2D.gd")
const scnWormBody2D = preload("res://Worm2D/WormBody2D.tscn")


# the speed of the worm
export(int, 0, 20) var num_segments = 3 setget _set_num_segments, _get_num_segments
export(float, 0, 100) var segment_radius = 10
export(float) var speed = 10
export(float) var force_pull = 1
export(float) var force_attract = 1
export(float) var max_force = 100
export(float, 0, 10) var segments_mass = 10 setget _set_segments_mass, _get_segments_mass
export(int) var segments_length = 20 setget _set_segments_length, _get_segments_length
export(int) var segments_rest_length = 20 setget _set_segments_rest_length, _get_segments_rest_length
export(float, 0, 64) var segments_stiffness = 20 setget _set_segments_stiffness, _get_segments_stiffness
export(float, 0, 16) var segments_damping = 1 setget _set_segments_damping, _get_segments_damping
export(float, 0, 1) var segments_drag = .5 setget _set_segments_drag, _get_segments_drag

var segments = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_worm()
	
func get_segment(index : int):
	return segments[index] if index >= 0 and index < segments.size() else null
	
func get_index_of_segment(node):
	return segments.find(node)

func _generate_worm():
	$Worm0.collision_mask = 0
	segments = [$Worm0]
	for index in num_segments - 1:
#		print(index)
		var new_worm_body = scnWormBody2D.instance() as WormBody2D
		var new_spring_joint = DampedSpringJoint2D.new()
		segments.append(new_worm_body)
		
		self.add_child(new_worm_body)
		self.add_child(new_spring_joint)
		
#		new_worm_body.name = "Worm" + str(index + 1)
#		new_spring_join.name = "SpringJoint" + str(index + 1)
		
		new_worm_body.transform.origin.y = segments_length * (index + 1)
		
		new_spring_joint.transform.origin.y = segments_length * index
		new_spring_joint.length = segments_length

		new_worm_body.collision_mask = 0
		new_worm_body.mass = segments_mass
		new_worm_body.drag_coef = segments_drag
#		print(new_spring_joint.get_path())
		new_spring_joint.node_a = segments[index].get_path()
		new_spring_joint.node_b = segments[index + 1].get_path()
		
		new_spring_joint.rest_length = segments_rest_length
		new_spring_joint.stiffness = segments_stiffness
		new_spring_joint.damping = segments_damping
		new_spring_joint.disable_collision = false
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _set_num_segments(value):
	num_segments = value
#	print('hello')
#	for child in self.get_children():
#		if child is DampedSpringJoint2D:
#			child.queue_free()
#
#	for segment in segments:
#		if segment != $Worm0:
#			segment.queue_free()
#
#	_generate_worm()

func _get_num_segments():
	return num_segments

var dragging = false
var dragging_segment : WormBody2D = null
var grab_radius = 40.0

func _get_closest_segment(in_global_position : Vector2, in_radius : float = 0):
	var min_dist = -1
	var out_segment = null
	var r_squared = in_radius * in_radius
	for segment in segments:
		var new_dist_squared = in_global_position.distance_squared_to((segment as WormBody2D).global_position)
		
		if (in_radius > 0) and (new_dist_squared > r_squared):
			continue
				
		if min_dist == -1 or new_dist_squared < min_dist:
			min_dist = new_dist_squared
			out_segment = segment
			
	return out_segment

func _input(event):
	var mouse_position = get_global_mouse_position() 
	if event.is_action_pressed("drag"):
		dragging = true
		dragging_segment = _get_closest_segment(mouse_position, grab_radius)
	elif event.is_action_released("drag"):
		dragging = false 
		if (dragging_segment):
			dragging_segment.applied_force = Vector2()
		dragging_segment = null
	elif event is InputEventScreenTouch and event.pressed:
		dragging = true
		dragging_segment = _get_closest_segment(mouse_position, grab_radius)
	elif event is InputEventScreenTouch and not event.pressed:
		dragging = false
		if (dragging_segment):
			dragging_segment.applied_force = Vector2()
		dragging_segment = null
	
func _physics_process(delta):
	if Engine.editor_hint:
		return
		
	if not (dragging_segment is RigidBody2D):
		return
		
	if dragging_segment:
		print(dragging)
		var mouse_dist = get_global_mouse_position() - dragging_segment.position
		var force = clamp(force_pull * mouse_dist.length(), 0, max_force)
		if mouse_dist.length_squared() > pow(0.01, 2):
			force += clamp(dragging_segment.mass * force_attract / mouse_dist.length_squared(), 0, max_force)
		dragging_segment.applied_force = force * mouse_dist.normalized()
	else:
		for segment in segments:
			segment.applied_force = Vector2()
		
		
func _set_segments_mass(value):
	segments_mass = value
	for child in self.get_children():
		if child is WormBody2D:
			child.mass = value
			
func _get_segments_mass():
	return segments_mass

func _set_segments_length(value):
	segments_length = value
	for child in self.get_children():
		if child is DampedSpringJoint2D:
			child.length = value
			
func _get_segments_length():
	return segments_length
			
func _set_segments_rest_length(value):
	segments_rest_length = value
	for child in self.get_children():
		if child is DampedSpringJoint2D:
			child.rest_length = value
			
func _get_segments_rest_length():
	return segments_rest_length
			
func _set_segments_stiffness(value):
	segments_stiffness = value
	for child in self.get_children():
		if child is DampedSpringJoint2D:
			child.stiffness = value

func _get_segments_stiffness():
	return segments_stiffness

func _set_segments_damping(value):
	segments_damping = value
	for child in self.get_children():
		if child is DampedSpringJoint2D:
			child.damping = value
			
func _get_segments_damping():
	return segments_damping
	
func _set_segments_drag(value):
	segments_drag = value
	for child in self.get_children():
		if child == $Worm0:
			continue
		if child is WormBody2D:
			child.drag_coef = value
	
	
func _get_segments_drag():
	return segments_drag
