tool
extends Node2D

const WormBody2D = preload("res://Worm2D/WormBody2D.gd")
const scnWormBody2D = preload("res://Worm2D/WormBody2D.tscn")


# the speed of the worm
export(int, 0, 20) var num_segments = 3 setget _set_num_segments, _get_num_segments
export(float) var speed = 10
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
#	$Worm0.collision_mask = 0
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

#		new_worm_body.collision_mask = 0
		new_worm_body.mass = segments_mass
		new_worm_body.drag_coef = segments_drag
#		print(new_spring_joint.get_path())
		new_spring_joint.node_a = segments[index].get_path()
		new_spring_joint.node_b = segments[index + 1].get_path()
		new_spring_joint.length = segments_length
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
	
func _physics_process(delta):
	if Engine.editor_hint:
		return
		
	var head = $Worm0 as RigidBody2D
	
	if head:	
		if Input.is_action_pressed("drag"):
			var mouse_pos_loc = head.to_local(get_global_mouse_position())
			var velocity = (mouse_pos_loc.normalized() * speed).clamped(mouse_pos_loc.length() * 4)
			
			head.applied_force = head.mass * velocity
			
	head = $Worm0 as KinematicBody2D
	
	if head:	
		if Input.is_action_pressed("drag"):
			var mouse_pos_loc = head.to_local(get_global_mouse_position())
			var velocity = (mouse_pos_loc.normalized() * speed).clamped(mouse_pos_loc.length() * 4)
			
			head.move_and_slide(velocity)
		
		
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
	print(segments_drag)
	for child in self.get_children():
		if child is WormBody2D:
			child.drag_coef = value
	
	
func _get_segments_drag():
	return segments_drag
