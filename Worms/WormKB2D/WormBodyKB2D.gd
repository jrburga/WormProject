extends KinematicBody2D

class_name WormBodyKB2Dt

var TouchTracker = preload("res://Scripts/TouchTracker.gd")

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
	
func get_mouse_button_down():
	return get_worm().mouse_button_down
	
func get_mouse_position():
	return get_worm().mouse_position
	
func get_drag_position():
	var touch_tracker = get_worm().touch_tracker as TouchTracker
	var tracker = touch_tracker.find_tracker_object(self)
	if tracker:
		return tracker.touch_position
	return Vector2()
	
func get_is_dragging():
	var touch_tracker = get_worm().touch_tracker as TouchTracker
	var tracker = touch_tracker.find_tracker_object(self)
	return tracker != null
	
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
			
func _worm_ready():
	if get_is_head():
		if child:
			var L : Vector2 = child.position - position
			rotation = L.angle()

func _position_from_event(event):
	return event.position - get_canvas_transform().origin

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	pass
		

var desired_angle = 0
var v_move = Vector2()
var v_spring = Vector2()

var velocity = Vector2()
func _physics_process(delta):
	if get_worm() == null:
		return
		
	if get_is_dragging():
		var L = (get_drag_position() - position)
		var direction = L.normalized()
		
#			velocity = direction * get_speed()
		v_move = (L.length_squared() * direction).clamped(get_speed())
		
	else:
		v_move *= 0.95
			
#		move_and_slide(velocity)
#		return

	if parent:
		var L : Vector2 = position - parent.position
		desired_angle = L.angle()
		rotation = L.angle()
	elif get_is_head():
		if get_is_dragging():
			var L : Vector2 = position - get_drag_position()
			desired_angle = L.angle()			
		elif child:
			var L : Vector2 = child.position - position
			desired_angle = L.angle()

		rotation = lerp_angle(rotation, desired_angle, 0.25)
	
	v_spring = Vector2()
	if parent:
		
		var L : Vector2 = parent.position - position
		
		if L.length() > get_seg_distance():
			var delta_L = L - L.normalized() * get_seg_distance()
			var direction = delta_L.normalized()
			
			var clamp_speed = delta_L.length() / delta if delta > 0 else 0
			
			var v_to_parent = delta_L.length_squared() * direction * get_f_spring()
			v_spring = v_to_parent.clamped(clamp_speed)
		
	if child:
		var L : Vector2 = child.position - position
		if L.length() > get_seg_distance():
			var delta_L = L - L.normalized() * get_seg_distance()
			var direction = delta_L.normalized()
			var clamp_speed = delta_L.length() / delta if delta > 0 else 0
			var v_to_child = delta_L.length_squared() * direction * get_f_spring()
			v_spring += v_to_child.clamped(clamp_speed)
	
	velocity = v_spring + v_move
	velocity = velocity.clamped(get_speed())
	move_and_slide(velocity)
