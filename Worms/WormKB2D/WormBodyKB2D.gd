extends KinematicBody2D

class_name WormBodyKB2Dt

export(NodePath) var ParentNode;
var parent = null
var child = null
var index = -1
var radius = 10 setget _set_radius, _get_radius


func _set_radius(value):
	radius = value
	$DrawNode.radius = value
	
func _get_radius():
	return $DrawNode.radius
	
# worm should always just be the parent
func get_worm():
	return get_parent()

func get_speed():
	return get_worm().speed
	
func get_seg_distance():
	return get_worm().seg_distance
	
func get_f_spring():
	return get_worm().f_spring
	
func get_is_head():
	return get_worm().segments[0] == self
	
func get_w_parent():
	return clamp(get_worm().w_parent, 0, 1)
	
func get_w_child():
	return clamp(1 - get_worm().w_parent, 0, 1)
	
func get_drag_coef():
	return get_worm().drag_coef
	
func get_mouse_button_down():
	return get_worm().mouse_button_down
	
func get_mouse_position():
	return get_worm().mouse_position
	
func get_is_dragging():
	return get_worm().is_dragging(self)
	
func get_index():
	return index
	
func get_dragging_segment():
	return get_worm().dragging_segment

# Called when the node enters the scene tree for the first time.
func _ready():
	var child_count = get_parent().get_child_count()
	for child_index in child_count:
		var child = get_parent().get_child(child_index)
		if child == self:
			parent = get_parent().get_child(child_index - 1)

func _position_from_event(event):
	return event.position - get_canvas_transform().origin

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	pass
		

var velocity = Vector2()
func _physics_process(delta):				
	if get_is_dragging():
		var L = (get_mouse_position() - position)
		var direction = L.normalized()
		
#			velocity = direction * get_speed()
		velocity = (L.length_squared() * direction).clamped(get_speed())
		move_and_slide(velocity)
		return
	else:
		var dir_drag = -velocity.normalized()
		var acc_drag = velocity.length_squared() * dir_drag * get_drag_coef() / 2.0
		velocity += acc_drag
			
#		move_and_slide(velocity)
#		return
			
			
	var w_forward = get_w_parent()
	var w_backward = get_w_child()
	
	var dragging_segment = get_dragging_segment()
	if dragging_segment:
		if dragging_segment.index < index:
			w_forward = get_w_parent()
			w_backward = get_w_child()
		else:
			w_forward = get_w_child()
			w_backward = get_w_parent()
	
	velocity = Vector2()
	if parent:
		var L : Vector2 = parent.position - position
		if L.length() > get_seg_distance():
			var delta_L = L - L.normalized() * get_seg_distance()
			var direction = delta_L.normalized()
			velocity = delta_L.length_squared() * direction * get_f_spring() * w_forward
		
	if child:
		var L : Vector2 = child.position - position
		if L.length() > get_seg_distance():
			var delta_L = L - L.normalized() * get_seg_distance()
			var direction = delta_L.normalized()
			velocity += delta_L.length_squared() * direction * get_f_spring() * w_backward
		
	velocity = velocity.clamped(get_speed())
	move_and_slide(velocity)
