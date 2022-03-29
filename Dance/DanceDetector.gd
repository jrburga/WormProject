tool
extends Node2D
class_name DanceDetector

enum Type { MSE, MaxDistance }

export(Type) var detector_type = Type.MSE
export(float) var max_distance = 100
export(float) var max_angle_degrees = 15
export(bool) var draw_debug = true
export(bool) var draw_position = true
export(bool) var draw_velocity = true
export(bool) var draw_rotation = true
export(bool) var draw_text = true
export(NodePath) var WormNode setget _set_worm_node
export(Resource) var TestMove setget _set_test_move

var position_draw = []
var rotation_draw = []
var velocity_draw = []
# Called when the node enters the scene tree for the first time.
func _ready():
#	test_save()
	pass
	
func _draw():
	if not draw_debug:
		return
	
	var num_segments = position_draw.size()
	var worm = get_node(WormNode) as WormKB2D
	
	if draw_position:
		for idx in num_segments:
			var pos = position_draw[idx]
			draw_circle(pos, 5, Color.salmon)
		
	if draw_velocity:
		for idx in num_segments:
			var pos = position_draw[idx]
			var vel = velocity_draw[idx]
			draw_line(pos, pos+vel, Color.red)
			
		for idx in worm.num_segments:
			var segment = worm.get_segment(idx)
			var vel = segment.velocity
			var pos = segment.position
			draw_line(pos, pos + vel, Color.magenta)
		
	if draw_rotation:
		for idx in num_segments:
			
			var pos = position_draw[idx]
			var rot = rotation_draw[idx]
			var end_point = pos + Vector2(100, 0).rotated(rot)
			draw_line(pos, end_point, Color.blue)
			
		for idx in worm.num_segments:
			var segment = worm.get_segment(idx)
			var pos = segment.position
			var end_point = pos + Vector2(100, 0).rotated(segment.rotation)
			draw_line(pos, end_point, Color.green)
		
func update_label_mse(values : Dictionary):
	if not draw_debug:
		var label_debug = $CanvasLayer/Label_Debug as Label
		label_debug.visible = false
		return
		
	var mse_pos = values['mse_pos']
	var mse_rot = values['mse_rot']
	var mse_vel = values['mse_vel']
	var label_debug = $CanvasLayer/Label_Debug as Label
	label_debug.visible = true
	if label_debug:
		var debug_text = ""
		debug_text += "MSE Position: (%f, %f)\n" % [mse_pos.x, mse_pos.y]
		debug_text += "MSE Rotation: %f\n" % mse_rot
		debug_text += "MSE Velocity: (%f, %f)\n" % [mse_vel.x, mse_vel.y]
		label_debug.text = debug_text
		
func update_label_area(values : Dictionary):
	if not draw_debug or not draw_text:
		var label_debug = $CanvasLayer/Label_Debug as Label
		label_debug.visible = false
		return
		
	var num_inside = values['num_inside']
	var num_vel_close = values['num_vel_close']
	var label_debug = $CanvasLayer/Label_Debug as Label
	label_debug.visible = true
	if label_debug:
		var debug_text = ""
		debug_text += "Segments Green: %d\n" %  num_inside
		debug_text += "Velocity Green: %d\n" % num_vel_close
		label_debug.text = debug_text
		
func _process(delta):
	if Engine.editor_hint:
		return
		
	if detector_type == Type.MSE:
		var values = calculate_score_mse(TestMove)
		update()
		update_label_mse(values)
		
	elif detector_type == Type.MaxDistance:
		var values = calculate_score_area(TestMove)
		update()
		update_label_area(values)
		
	
func calculate_score_area(move : DanceMove):
	var worm = get_node(WormNode) as WormKB2D
	if not worm is WormKB2D:
		return
	
	if worm.num_segments <= 0:
		push_warning("num of segments on worm is 0!")
		return
		
	if not move:
		push_warning("no dance move to calculate score on!")
		return
		
	var worm_anim : WormAnimation = move.animation as WormAnimation
	if not worm_anim:
		push_warning("dance move does not have valid Worm Animatino!")
		return
		
	var head = worm.get_head()
	var time = 0.0
		
	var anim_values = worm_anim.worm_value_tracks_interpolate_local_to_worm(worm, time) as Dictionary
	var position_anim = anim_values['position'] as Array
	var rotation_anim = anim_values['rotation'] as Array
	var velocity_anim = anim_values['velocity'] as Array
	
	position_draw = position_anim
	rotation_draw = rotation_anim
	velocity_draw = velocity_anim
	
	if worm.num_segments != position_anim.size():
		push_warning("num anim positions != num worm segments")
		return

	var num_vel_close = 0
	var num_inside = 0
	
	for idx in worm.num_segments:
		var segment = worm.get_segment(idx)
		var distance = segment.position.distance_to(position_anim[idx])
		if distance <= max_distance:
			num_inside += 1
			
		var theta = (segment.velocity as Vector2).angle_to(velocity_anim[idx])
		if rad2deg(theta) <= max_angle_degrees:
			num_vel_close += 1
			
	return {'num_inside': num_inside, 'num_vel_close': num_vel_close}
	
func calculate_score_mse(move : DanceMove):
	var worm = get_node(WormNode) as WormKB2D
	if not worm is WormKB2D:
		return
	
	if worm.num_segments <= 0:
		push_warning("num of segments on worm is 0!")
		return
		
	if not move:
		push_warning("no dance move to calculate score on!")
		return
		
	var worm_anim : WormAnimation = move.animation as WormAnimation
	if not worm_anim:
		push_warning("dance move does not have valid Worm Animatino!")
		return
		
	var head = worm.get_head()
	var time = 0.0
	
	var anim_values = worm_anim.worm_value_tracks_interpolate_local_to_worm(worm, time) as Dictionary
	var position_anim = anim_values['position'] as Array
	var rotation_anim = anim_values['rotation'] as Array
	var velocity_anim = anim_values['velocity'] as Array
	
	position_draw = position_anim
	rotation_draw = rotation_anim
	velocity_draw = velocity_anim
	
	if worm.num_segments != position_anim.size():
		push_warning("num anim positions != num worm segments")
		return
		
	var mse_pos = Vector2()
	var mse_rot = 0
	var mse_vel = Vector2()
	for idx in worm.num_segments:
		var segment = worm.get_segment(idx)
		var delta_pos = segment.position - position_anim[idx]
		var delta_rot = segment.rotation - rotation_anim[idx]
		var delta_vel = segment.velocity.normalized() - velocity_anim[idx].normalized()
		
		mse_pos += Vector2(pow(delta_pos.x, 2), pow(delta_pos.y, 2))
		mse_rot += pow(delta_rot, 2)
		mse_vel += Vector2(pow(delta_vel.x, 2), pow(delta_vel.y, 2))
		
	mse_pos /= worm.num_segments
	mse_rot /= worm.num_segments
	mse_vel /= worm.num_segments
	
	return {'mse_pos': mse_pos, 'mse_rot': mse_rot, 'mse_vel': mse_vel}
	
func _set_worm_node(value):
	WormNode = value
	if is_inside_tree():
		get_tree().emit_signal("node_configuration_warning_changed", self)

func _set_test_move(value):
	TestMove = value
	if is_inside_tree():
		get_tree().emit_signal("node_configuration_warning_changed", self)

func _get_configuration_warning():
	var errors = []
	if WormNode.is_empty() or not get_node(WormNode) is WormKB2D:
		errors.append("WormNode is not a WormKB2D! Path:'" + str(WormNode) + "'")
	if not TestMove is DanceMove:
		errors.append("TestMove is not a DanceMove!")
	var return_string = ""
	for error in errors:
		return_string += error
		return_string += "\n"
	return return_string
