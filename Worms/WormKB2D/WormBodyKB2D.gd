extends KinematicBody2D

class_name WormBodyKB2D

const WormKB2DRes = preload('./WormKB2DRes.gd')
const PHYS_MODE = preload('./WormKB2DRes.gd').PHYS_MODE
var TouchTracker = preload("res://Scripts/TouchTracker.gd")

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
	return get_parent() as WormKB2D
	
func get_worm_settings() -> WormKB2DRes:
	return get_worm().worm_settings

func get_speed():
	return get_worm_settings().speed
	
func get_seg_distance():
	return get_worm_settings().seg_distance
	
func get_f_spring():
	return get_worm_settings().f_spring
	
func get_is_head():
	if get_worm().segments.size() == 0:
		return false
	return get_worm().segments[0] == self
	
func get_is_tail():
	if get_worm().segments.size() == 0:
		return false
	var idx_last = get_worm().segments.size() - 1
	return get_worm().segments[idx_last] == self
	
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



func _velocity_curve(distance):
	var max_distance = 30
	var offset = 0.0
	if get_worm_settings().normalize_dist > 0:
		offset = distance / get_worm_settings().normalize_dist
	return (get_worm_settings().curve_velocity as Curve).interpolate(offset)
	pass
	
func _process(delta):
	var squash = get_worm_settings().squash
	var stretch = get_worm_settings().stretch
	var rest_length = get_worm_settings().seg_distance
	var rest_radius = get_worm().seg_radius
	var node = child if child else parent
	if node:
		var L = (node.position - position).length()
		L = min(max(L, rest_length * (1 - stretch)), rest_length * (1 + stretch))
		$DrawNode.length = L
		
		var R = rest_radius + (rest_length - L) * .25
		R = min(max(R, rest_radius * (1 - squash)), rest_radius * (1 + squash))
		$DrawNode.radius = R
		
func _physics_process_rotate(delta):
	if parent:
		var L : Vector2 = (position - parent.position)
		desired_angle = L.angle()
		rotation = L.angle()
	elif get_is_head():
		if get_is_dragging():
			var L : Vector2 = (position - get_drag_position())
			desired_angle = L.angle()			
		elif child:
			var L : Vector2 = (child.position - position)
			desired_angle = L.angle()

		rotation = lerp_angle(rotation, desired_angle, 0.25)

var velocity = Vector2()
func _physics_process(delta):
	if get_worm_settings().physics_mode == PHYS_MODE.Velocity:
		_physics_process_velocities(delta)
	elif get_worm_settings().physics_mode == PHYS_MODE.Force:
		_physics_proccess_accels(delta)
	_physics_process_rotate(delta)
	
var v_move = Vector2()
var v_spring = Vector2()
func _physics_proccess_accels(delta):
	
	var nodes = [parent, child]
	var v_max = get_worm_settings().max_velocity

	if get_is_dragging():
		var p2d = get_drag_position() - position
		var k = get_worm_settings().f_drag
		var d = 0
		if get_is_head():
			d = get_worm_settings().drag_min_dist
		var f = k * (p2d.length() - d)
		var b = get_worm_settings().damping_drag
		var acc = f * p2d.normalized() - v_move * b
		v_move += acc * delta
		v_spring = Vector2()
		v_move = v_move.clamped(v_max)
		move_and_slide(v_move)
	else:
		var dv = Vector2()
		for node in nodes:
			if node == null:
				continue
			var p2n = node.position - position
			var k = get_worm_settings().f_spring
			var d = get_worm_settings().seg_distance
			var f = k * (p2n.length() - d)
			var b = get_worm_settings().damping
			var acc = f * p2n.normalized() - (v_spring) * b 
			v_spring += acc * delta
		v_spring = v_spring.clamped(v_max)

		v_move *= .95
		velocity = v_spring + v_move
	#	var v_drag = -velocity.normalized() * (0.0002 * velocity.length_squared() / 2.0)
	#	velocity += v_drag
		velocity = velocity.clamped(v_max) 
		move_and_slide(velocity)	
	
var desired_angle = 0

func _physics_process_velocities(delta):
	if get_worm() == null:
		return
		
	if get_is_dragging():
		var L = (get_drag_position() - position)
		var direction = L.normalized()
		
#			velocity = direction * get_speed()
		v_move = (_velocity_curve(L.length()) * direction * get_speed()).clamped(get_speed())
#		print(v_move)
	else:
		v_move *= 0.95
			
#		move_and_slide(velocity)
#		return

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
