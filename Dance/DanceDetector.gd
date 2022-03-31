tool
extends Node
class_name DanceDetector

enum Type { MSE, MaxDistance }

enum State { Idle, Dancing }

export(Resource) var settings
export(Type) var detector_type = Type.MSE
export(NodePath) var WormNode setget _set_worm_node

# broadcast once time in move > 0
signal move_detected(move)
signal move_continued(move)
signal move_dropped(move)
# broadcast move once executed successfully
signal move_executed(move)

# broadcast once first move in dance is detected
signal dance_detected(dance)
signal dance_continued(dance)
signal dance_dropped(dance)
# broadcast dance once executed successfully
signal dance_executed(dance)

class MoveTracker:
	var score : float = 0
	var time_in_move : float = 0
	var pct_in_move : float = 0
	
class DanceTracker:
	var num_moves_completed : int = 0
	

var current_move_sequence = []

var possible_moves = {
	# move: MoveTracker(), 
	# move: MoveTracker()
}
var possible_dances = {
	# dance: (num_moves_completed)
}
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("move_executed", self, "_on_move_executed")
	connect("move_detected", self, "_on_move_detected")
	connect("move_dropped", self, "_on_move_dropped")
	connect("dance_executed", self, "_on_dance_executed")
	connect("dance_continued", self, "_on_dance_continued")
	connect("dance_detected", self, "_on_dance_detected")
	if not Engine.editor_hint:
		$DebugDraw.worm = get_node(WormNode)
		
func get_current_state():
	if possible_dances.size() > 0:
		return State.Dancing
	else:
		return State.Idle
	
func _on_move_executed(move : DanceMove):
	current_move_sequence.append(move)
	$DanceTimer.paused = false
	$DanceTimer.start(settings.time_between_moves)
	update_possible_dances()
	
func _on_move_detected(move : DanceMove):
	$DanceTimer.paused = true
	
func _on_move_dropped(move : DanceMove):
	$DanceTimer.paused = false
		
func _on_DanceTimer_timeout():
	current_move_sequence.clear()
	update_possible_dances()
	
func _on_dance_executed(dance : DanceSequence):
	$DebugDraw.display_detected_dance(dance)
	possible_dances.erase(dance)
	
func _on_dance_continued(dance : DanceSequence):
	pass
	
func _on_dance_detected(dance : DanceSequence):
	pass
	
func get_moves() -> Array:
	if !Engine.editor_hint:
		return Autoload.get_dances_db(self).moves
	return []
	
func get_dances() -> Array:
	if not Engine.editor_hint:
		return Autoload.get_dances_db(self).dances
	return []

	
func update_possible_moves(delta : float):
	var worm = get_node(WormNode) as WormKB2D
	
	for move in get_moves():
		move = move as DanceMove
		if not move:
			continue

		var flags = worm.get_dragged_segments_flags()
		
		# hmm?
		if not move.grabbed_segments && flags:
			possible_moves.erase(move)
			continue
			
		var time_in_move : float = 0
		if possible_moves.has(move):
			time_in_move = possible_moves[move].time_in_move

		var result = calculate_score_max_dist(move, time_in_move)
		var score_threshold = settings.score_threshold_detect
		if result.get('pct_in_move', 0) > 0:
			score_threshold = settings.score_threshold_drop
		
		if result.get('score', 0) > score_threshold:
			time_in_move += delta
			
			if result.get('pct_in_move', 0) >= 1.0:
				possible_moves.erase(move)
				time_in_move = 0
				emit_signal('move_executed', move)
				
			var move_tracker : MoveTracker = null
			var new_move = false
			if possible_moves.has(move):
				move_tracker = possible_moves[move]
			else:
				move_tracker = MoveTracker.new()
				possible_moves[move] = move_tracker
				new_move = true
				
			possible_moves[move].time_in_move = time_in_move
			possible_moves[move].score = result.get('score', 0)
			possible_moves[move].pct_in_move = result.get('pct_in_move', 0)
			
			if new_move:
				emit_signal('move_detected', move)
			else:
				emit_signal('move_continued', move)
		elif possible_moves.has(move):
			possible_moves.erase(move)
			emit_signal('move_dropped', move)
			
func update_possible_dances():
	var num_moves = current_move_sequence.size()
	var dance_executed = false
	if num_moves == 0:
		var dropped_dances = []
		for possible_dance in possible_dances:
			dropped_dances.append(possible_dances)
			
		possible_dances.clear()
		for dropped_dance in dropped_dances:
			emit_signal("dance_dropped", dropped_dance)
			
		return
		
	for dance in get_dances():
		var prev_num_moves_completed = possible_dances.get(dance, 0)
		for index in num_moves:
			var move_in_seq = current_move_sequence[index]
			
			if num_moves <= dance.dance_moves.size():
				var move_in_dance = dance.dance_moves[index]
				if move_in_dance == move_in_seq:
					possible_dances[dance] = index + 1
				else:
					possible_dances.erase(dance)
					break
					
		var new_num_moves_completed = possible_dances.get(dance, 0)
		if new_num_moves_completed == 1 and prev_num_moves_completed == 0:
			emit_signal("dance_detected", dance)
		elif new_num_moves_completed == dance.dance_moves.size():
			possible_dances.erase(dance)
			dance_executed = true
			emit_signal("dance_executed", dance)
		elif new_num_moves_completed > prev_num_moves_completed:
			emit_signal("dance_continued", dance)
		elif new_num_moves_completed < prev_num_moves_completed:
			emit_signal("dance_dropped", dance)
	
	if possible_dances.size() == 0:
		print('resetting current move sequence')
		if current_move_sequence.size() > 1 and not dance_executed:
			var last_move = current_move_sequence[-1]
			current_move_sequence.clear()
			current_move_sequence.append(last_move)
			update_possible_dances()
		else:
			current_move_sequence.clear()
		
func _process(delta):
	if Engine.editor_hint:
		return
	
	update_possible_moves(delta)
	$DebugDraw.update()
	$DebugDraw.update_label_moves(possible_moves)
	$DebugDraw.update_label_dances(possible_dances)

		
	
func calculate_score_max_dist(move : DanceMove, time : float = 0) -> Dictionary:
	var worm = get_node(WormNode) as WormKB2D
	if not worm is WormKB2D:
		return {}
	
	if worm.num_segments <= 0:
		push_error("num of segments on worm is 0!")
		return {}
		
	if not move:
		push_error("no dance move to calculate score on!")
		return {}
		
	var worm_anim : WormAnimation = move.animation as WormAnimation
	if not worm_anim:
		push_error("dance move does not have valid Worm Animation!")
		return {}
		
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
		return {}

	var num_vel_close = 0
	var num_inside = 0
	
	if not settings is MaxDistanceSettings:
		push_warning("settings aren't MaxDistanceSettings, but using max distance")
		return {}
		
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
	
func calculate_score_mse(move : DanceMove, time : float = 0) -> Dictionary:
	var worm = get_node(WormNode) as WormKB2D
	if not worm is WormKB2D:
		return {}
	
	if worm.num_segments <= 0:
		push_warning("num of segments on worm is 0!")
		return {}
		
	if not move:
		push_warning("no dance move to calculate score on!")
		return {}
		
	var worm_anim : WormAnimation = move.animation as WormAnimation
	if not worm_anim:
		push_warning("dance move does not have valid Worm Animatino!")
		return {}
		
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
		return {}
		
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
	
	var pct_in_move = time / worm_anim.length if worm_anim.length > 0 else 0.0
	
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

func _get_configuration_warning():
	var errors = []
	if WormNode.is_empty() or not get_node(WormNode) is WormKB2D:
		errors.append("WormNode is not a WormKB2D! Path:'" + str(WormNode) + "'")
	var return_string = ""
	for error in errors:
		return_string += error
		return_string += "\n"
	return return_string



