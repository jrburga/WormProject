extends Node2D


export(bool) var draw_debug = true
export(bool) var draw_position = true
export(bool) var draw_velocity = true
export(bool) var draw_rotation = true
export(bool) var draw_text = true

var position_draw = []
var rotation_draw = []
var velocity_draw = []

var worm : WormKB2D = null

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
		
	var label_debug = $CanvasLayer/Label_Debug as Label
	label_debug.visible = true
	if label_debug:
		var debug_text = ""
		debug_text += "Move : %s\n" % values.move_name
		debug_text += "Score : %5.3f\n" % values.score
		debug_text += "Pct In Move: %5.3f\n" % values.pct_in_move
		label_debug.text = debug_text

func _draw():
	if not draw_debug:
		return
	
	if not worm:
		return
		
	var num_segments = position_draw.size()
	
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
			var end_point = pos + Vector2(100, 0).rotated(deg2rad(rot))
			draw_line(pos, end_point, Color.blue)
			
		for idx in worm.num_segments:
			var segment = worm.get_segment(idx)
			var pos = segment.position
			var end_point = pos + Vector2(100, 0).rotated(segment.rotation)
			draw_line(pos, end_point, Color.green)
