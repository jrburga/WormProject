tool
extends Node
class_name DanceDetector

enum Type { MSE, MaxDistance }

export(Resource) var settings
export(Type) var detector_type = Type.MSE
export(NodePath) var WormNode setget _set_worm_node
export(Resource) var TestMove setget _set_test_move

# broadcast once time in move > 0
signal move_detected(move)
# broadcast move once executed successfully
signal move_executed(move)

# broadcast once first move in dance is detected
signal dance_detected(dance)
# broadcast dance once executed successfully
signal dance_executed(dance)

# Called when the node enters the scene tree for the first time.
func _ready():
	$DebugDraw.worm = get_node(WormNode)
	pass
		
var time_in_move = 0
func _process(delta):
	if Engine.editor_hint:
		return
		
	if detector_type == Type.MSE:
		var values = calculate_score_mse(TestMove, time_in_move)
		$DebugDraw.update()
		$DebugDraw.update_label_mse(values)
		
	elif detector_type == Type.MaxDistance and settings is MaxDistanceSettings:
		var values = calculate_score_max_dist(TestMove, time_in_move)
		
		var score_threshold = settings.score_threshold_detect
		if values.pct_in_move > 0:
			score_threshold = settings.score_threshold_drop

		if values.score > score_threshold:
			time_in_move += delta
		else:
			time_in_move = 0
			
		if values.pct_in_move >= 1:
			time_in_move = 0
			
		$DebugDraw.update()
		$DebugDraw.update_label_area(values)
		
	
func calculate_score_max_dist(move : DanceMove, time : float = 0):
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
		
	var anim_values = worm_anim.worm_value_tracks_interpolate_local_to_worm(worm, time) as Dictionary
	var position_anim = anim_values['position'] as Array
	var rotation_anim = anim_values['rotation'] as Array
	var velocity_anim = anim_values['velocity'] as Array
	
	$DebugDraw.position_draw = position_anim
	$DebugDraw.rotation_draw = rotation_anim
	$DebugDraw.velocity_draw = velocity_anim
	
	if worm.num_segments != position_anim.size():
		push_warning("num anim positions != num worm segments")
		return

	var num_vel_close = 0
	var num_inside = 0
	
	if not settings is MaxDistanceSettings:
		push_warning("settings aren't MaxDistanceSettings, but using max distance")
		return
		
	for idx in worm.num_segments:
		var segment = worm.get_segment(idx)
		var distance = segment.position.distance_to(position_anim[idx])
		if distance <= settings.max_distance:
			num_inside += 1
			
		var theta = (segment.velocity as Vector2).angle_to(velocity_anim[idx])
		var length_vel = segment.velocity.length()
		var length_vel_anim = velocity_anim[idx].length()
		var accept_velocity = true
		
		var epsilon = 0.001
		if abs(length_vel_anim) > epsilon:
			var error = abs(length_vel_anim - length_vel) / length_vel_anim
			accept_velocity = accept_velocity and not error > settings.max_velocity_error
		else:
			accept_velocity = accept_velocity and length_vel < epsilon
			
		accept_velocity = accept_velocity and rad2deg(theta) <= settings.max_angle_degrees
		
		if accept_velocity:
			num_vel_close += 1
			
	# score is from 0.0 to 100.0
	var pct_inside = num_inside / float(worm.num_segments)
	var pct_vel_close = num_vel_close / float(worm.num_segments)
	
	var weight_pos = .25
	var weight_vel = .76
	var summed = pct_inside * weight_pos + pct_vel_close * weight_vel
	var pct =  summed / (weight_pos + weight_vel)
	var score : float = pct * 100
			
	var pct_in_move = time / worm_anim.length if worm_anim.length > 0 else 0.0
			
	return {
		'score': score,
		'pct_in_move': pct_in_move,
		'move_name': move.display_name,
		'num_inside': num_inside, 
		'num_vel_close': num_vel_close
		}
	
func calculate_score_mse(move : DanceMove, time : float = 0):
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
	
	var anim_values = worm_anim.worm_value_tracks_interpolate_local_to_worm(worm, time) as Dictionary
	var position_anim = anim_values['position'] as Array
	var rotation_anim = anim_values['rotation'] as Array
	var velocity_anim = anim_values['velocity'] as Array
	
	$DebugDraw.position_draw = position_anim
	$DebugDraw.rotation_draw = rotation_anim
	$DebugDraw.velocity_draw = velocity_anim
	
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
	
	var score : float = 0
	
	var pct_in_move = time / worm_anim.length if worm_anim.length > 0 else 0
	
	return {
		'score': score,
		'pct_in_move': 0,
		'mse_pos': mse_pos, 
		'mse_rot': mse_rot, 
		'mse_vel': mse_vel
		}
	
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
