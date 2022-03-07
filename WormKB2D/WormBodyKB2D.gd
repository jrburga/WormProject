extends KinematicBody2D

class_name WormKB2D

export(float) var speed = 300
export(float) var seg_distance = 20
export(bool) var is_head = false
export(float) var w_follow = .75

export(NodePath) var ParentNode;
var parent = null
var child = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var child_count = get_parent().get_child_count()
	for child_index in child_count:
		var child = get_parent().get_child(child_index)
		if child == self:
			parent = get_parent().get_child(child_index - 1)

func _position_from_event(event):
	return event.position - get_canvas_transform().origin

var mouse_button_down = false
var mouse_position = Vector2()

func _input(event):
	if not is_head:
		return
	if event is InputEventMouseButton:
		mouse_button_down = event.pressed
		mouse_position = _position_from_event(event)
	if event is InputEventMouseMotion:
		mouse_position = _position_from_event(event)

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	pass
		

func _physics_process(delta):			
#	elif parent and child:
	var child_position = child.position if child else position
	var parent_position = parent.position if parent else position
	
	if is_head:
		if mouse_button_down: # AND grabbing the head
#			parent_position = mouse_position
			var direction = (mouse_position - position).normalized()
			move_and_slide(direction * speed)
#			return
#		elif grabbing_another segment:
#			pass
#			we actually want to go to the child
#		else:
#			return

	if (not parent) or (not child):
		return
		
	var to_parent = parent_position - position
	var to_child = child_position - position
	
	if to_parent.length() <= seg_distance and to_child.length() <= seg_distance:
		return
	
	var cp = parent_position - child_position 
	
	var m_p = to_parent.length()
	var m_c = to_child.length()
	if m_p <= seg_distance and m_c <= seg_distance:
		return
	
	var v_p = to_parent - (to_parent.normalized() * seg_distance)
	var v_c = to_child - (to_child.normalized() * seg_distance)
	
#		print(v_p)
#		print(v_c)
	var m = v_p.length() + v_c.length()
	
	var w_p = v_p / m

#	var factor = 1	
	var factor = clamp( v_p.length() / m, 0, 1)

	var desired_position = child_position +  cp * factor
#	$DebugDraw.global_position = desired_position
	position = position.linear_interpolate(desired_position, w_follow)
#	position = desired_position
	
#	elif child:
		
			
#		var direction = (parent.position - position) as Vector2
#		if direction.length_squared() > seg_distance * seg_distance:
#			var desired_position = parent.position - (direction.normalized() * seg_distance)
#
#			position = position.linear_interpolate(desired_position, w_follow)
#		
#		if distance.length_squared() > pow(seg_distance, 2):
#			var direction = distance.normalized()
#			move_and_slide(direction * speed)
#	if 
#	move_and_slide()
