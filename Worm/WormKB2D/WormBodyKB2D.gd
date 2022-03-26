extends KinematicBody2D

class_name WormBodyKB2D


const PHYS_MODE = WormSettings.PHYS_MODE

var parent = null
var child = null
var index = -1
var radius = 10 setget _set_radius, _get_radius
var color : Color = Color.white setget _set_color, _get_color

func _set_color(value):
	color = value
	$DrawNode.color = color
	
func _get_color():
	return color

func _set_radius(value):
	radius = value
	$DrawNode.radius = value
	
func _get_radius():
	return $DrawNode.radius
	
# worm should always just be the parent
func get_worm() -> WormKB2D:
	return get_parent() as WormKB2D
	
func get_worm_settings() -> WormSettings:
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
	
func get_is_dragging(node):
	var touch_tracker = get_worm().touch_tracker as TouchTracker
	var tracker = touch_tracker.find_tracker_object(node)
	return tracker != null
	
func get_is_dragging_any():
	var touch_tracker = get_worm().touch_tracker as TouchTracker
	for tracker in touch_tracker.tracker_objects:
		if tracker and tracker.object != null:
			return true
	return false
	
func get_index():
	return index
	
func get_dragging_segment():
	return get_worm().dragging_segment

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
			
func _worm_ready():
	if get_is_head():
		if child:
			var L : Vector2 = child.position - position
			rotation = L.angle()
			
	get_worm().connect("segment_grabbed", self, "_on_segment_grabbed")
	get_worm().connect("segment_released", self, "_on_segment_released")
	
var released_position = Vector2()
var was_dragging = false
func _on_segment_grabbed(segment):
	was_dragging = false
	
func _on_segment_released(segment):
	if segment == self:
		released_position = position
		was_dragging = !get_is_dragging_any()
	else:
		was_dragging = false

func _position_from_event(event):
	return event.position - get_canvas_transform().origin

func _velocity_curve(distance):
	var max_distance = 30
	var offset = 0.0
	if get_worm_settings().normalize_dist > 0:
		offset = distance / get_worm_settings().normalize_dist
	return (get_worm_settings().curve_velocity as Curve).interpolate(offset)
	pass
	
func _process(delta):
	if child:
		var squash = get_worm_settings().squash
		var stretch = get_worm_settings().stretch
		var rest_length = get_worm_settings().seg_distance
		var rest_radius = get_worm().seg_radius
		var L = (child.position - position).length()
		L = min(max(L, rest_length * (1 - stretch)), rest_length * (1 + stretch))
		$DrawNode.length = L
		
		var R = rest_radius + (rest_length - L) * .25
		R = min(max(R, rest_radius * (1 - squash)), rest_radius * (1 + squash))
		$DrawNode.radius = R
	else:
		$DrawNode.hide()
		$DrawNode.radius = 0
		$DrawNode.length = 0

var desired_angle = 0
func _physics_process_rotate(delta):
	
	if child:
		var L : Vector2 = (position - child.position)
		desired_angle = L.angle()
		rotation = L.angle()
	elif parent:
		var L : Vector2 = (position - parent.position)
		desired_angle = L.angle()
		rotation = L.angle()
	elif get_is_head():
		if get_is_dragging(self):
			var L : Vector2 = (position - get_drag_position())
			desired_angle = L.angle()			
		elif child:
			var L : Vector2 = (child.position - position)
			desired_angle = L.angle()

		rotation = lerp_angle(rotation, desired_angle, 0.25)

var velocity = Vector2()
func _physics_process(delta):
	if get_worm().animation_player:
		if get_worm().animation_player.is_playing():
			return
			
	_physics_process_rotate(delta)
	if get_worm_settings().physics_mode == PHYS_MODE.Velocity:
		_physics_process_velocities(delta)
	elif get_worm_settings().physics_mode == PHYS_MODE.Force:
		_physics_proccess_accels(delta)
	
	
func _calc_move_acc(var move_position : Vector2, var v_curr : Vector2):
		var p2d = move_position - position
		var k = get_worm_settings().f_drag
		var d = 0
		var f = k * (p2d.length() - d)
		var b = get_worm_settings().damping_drag
		var acc = f * p2d.normalized() - v_curr * b
		return acc
		
func _calc_spring_acc(v_curr : Vector2):
	var acc = Vector2()
	for node in [parent, child]:
		if node == null:
			continue
		var p2n = node.position - position
		var k = get_worm_settings().f_spring
		var d = get_worm_settings().seg_distance
		var f = k * (p2n.length() - d)
		var b = get_worm_settings().damping
		acc += f * p2n.normalized() - v_curr * b 
	return acc
	
func _calc_align_acc(v_curr : Vector2):
	var acc = Vector2()
	
	var s2p = parent.position - position if parent else Vector2()
	var s2c = child.position - position if child else Vector2()
	
	var p_looking = 1
	var c_looking = 0
	if parent and child:
		var v_normal = v_curr.normalized()
		p_looking = v_normal.dot(s2p.normalized())
		c_looking = v_normal.dot(s2c.normalized())
	
	var v_perp = Vector2()
	if parent and p_looking > c_looking:
		v_perp = v_curr - v_curr.project(s2p)
	elif child:
		v_perp = v_curr - v_curr.project(s2c)
	
	acc = -v_perp * 20
	return acc
		
var v_move = Vector2()
var v_spring = Vector2()
func _physics_proccess_accels(delta):
	
	var v_max = get_worm_settings().max_velocity

	if get_is_dragging(self):
		released_position = position
		var acc_move = _calc_move_acc(get_drag_position(), velocity)
		v_move = acc_move * delta
		v_move = v_move.clamped(v_max)
#		move_and_slide(v_move)
	elif was_dragging and !get_is_dragging_any():
		var acc_move = _calc_move_acc(released_position, velocity)
		v_move = acc_move * delta
		v_move = v_move.clamped(v_max)
	else:
		v_move *= .9
		
	# drag force when not dragging anything
	if !get_is_dragging_any():
		velocity *= .9
	
	velocity += v_move 
	
	var acc_spring = _calc_spring_acc(velocity)
	velocity += acc_spring * delta
#	v_spring = v_spring.clamped(v_max)
	
	var acc_align = Vector2()
	if get_worm().get_num_dragging_segments() <= 1:
		acc_align = _calc_align_acc(velocity)
	
	velocity += acc_align * delta
#	velocity = v_spring + v_move
#	var v_drag = -velocity.normalized() * (0.0002 * velocity.length_squared() / 2.0)
#	velocity += v_drag
	velocity = velocity.clamped(v_max) 
	move_and_slide(velocity)	
	

func _physics_process_velocities(delta):
	if get_worm() == null:
		return
		
	if get_is_dragging(self):
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
