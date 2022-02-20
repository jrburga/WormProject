tool
extends Polygon2D

const util = preload("res://Util.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(bool) var do_regenerate_polygon = false setget _set_regenerate_polygon, _get_regenerate_polygon
export(bool) var do_generate_bone_weights = false setget _set_generate_bone_weights, _get_generate_bone_weights
export(bool) var test_something = false setget _set_test, _get_test
export(int) var joint_index = 0

var radius = 20 setget _set_radius, _get_radius
var r_pixels = 256
var radial_segs = 10
var lateral_segs = 3

func _set_radius(value):
	radius = value
	regenerate_polygon()
	
func _get_radius():
	return radius
	
func _set_test(value):
	if value:
		test()
		
func _get_test():
	return false
	
func test():
	print(range_lerp(0.25, 0, 1, 100, 0))
	
func generate_bone_weights():
	var bone_index = joint_index * 2
	var bone_index_next = (joint_index + 1) * 2
	var bone_index_prev = (joint_index - 1) * 2
	var w_min = 0
	var w_max = 0.5
	
	for b_index in bones.size() / 2:
		var weights = []
		weights.resize(polygon.size())
		for w_i in weights.size():
			weights[w_i] = 0
		bones[b_index * 2 + 1] = weights
	
	if bone_index >= 0 and bone_index < bones.size():
		var bone = bones[bone_index]
		var weights = bones[bone_index + 1]
		
		var weights_0 = []
		for v_index in polygon.size():
			weights_0.append(1)
			
		bones[bone_index + 1] = weights_0
		
	if bone_index_next >= 0 and bone_index_next < bones.size():
		var weights = []
		for v_index in polygon.size():
			var v_x = (polygon[v_index] as Vector2).x
			var w = range_lerp(v_x, 0, radius*3, w_min, w_max)
			weights.append(w)
		bones[bone_index_next + 1] = weights
		
	if bone_index_prev >= 0 and bone_index_prev < bones.size():
		var weights = []
		for v_index in polygon.size():
			var v_x = (polygon[v_index] as Vector2).x
			var w = range_lerp(v_x, 0, radius*3, w_max, w_min)
			weights.append(w)
		bones[bone_index_prev + 1] = weights
	
	

# Called when the node enters the scene tree for the first time.
func _ready():
#	regenerate_polygon()
	regenerate_polygon()
	var worm = util.find_first_parent_witd_method(self, 'get_segment')
	print(worm)
	
func regenerate_polygon():
	var uvs = PoolVector2Array()
	var vertices = PoolVector2Array()
	
	var t_width = texture.get_width()
	var t_height = texture.get_height()
	
	var delta_theta = PI / radial_segs
	var theta_0 = PI / 2
	var center_pixels_0 = Vector2(r_pixels, r_pixels)
	
	var epsilon_p = 2
	var r_pixels_epsilon = r_pixels - epsilon_p
	for var_index in radial_segs + 1:
		var theta = theta_0 + delta_theta * var_index
		var x_p = cos(theta) * r_pixels_epsilon
		var y_p = sin(theta) * r_pixels_epsilon
		
		var x = cos(theta) * radius
		var y = sin(theta) * radius
		uvs.append(Vector2(x_p, y_p) + center_pixels_0)
		vertices.append(Vector2(x, y) + Vector2(radius, radius))
#		vertices.append(Vector2(x_p, y_p) + center_pixels_0)

	var delta_pct = 1.0 / lateral_segs
	var delta_p = delta_pct * r_pixels_epsilon
	var delta = delta_pct * radius
	for lat_index in range(1, lateral_segs):
		var x_p = delta_p * lat_index + center_pixels_0.x
		var y_p = 0
		
		var x = delta * lat_index + radius
		var y = 0
		
		uvs.append(Vector2(x_p, y_p))
		vertices.append(Vector2(x, y))
		
		
	var theta_1 = 3 * PI / 2
	var center_pixels_1 = Vector2(t_width - r_pixels, r_pixels)
	for var_index in radial_segs + 1:
		var theta = theta_1 + delta_theta * var_index
		var x_p = cos(theta) * r_pixels_epsilon
		var y_p = sin(theta) * r_pixels_epsilon
		
		var x = cos(theta) * radius
		var y = sin(theta) * radius
		uvs.append(Vector2(x_p, y_p) + center_pixels_1)
		vertices.append(Vector2(x, y) + Vector2(2 * radius, radius))
#		vertices.append(Vector2(x_p, y_p) + center_pixels_1)

	for lat_index in range(lateral_segs - 1, -1, -1):
		var x_p = delta_p * lat_index + center_pixels_0.x
		var y_p = t_height
		
		var x = delta * lat_index + radius
		var y = 2 * radius
		
		uvs.append(Vector2(x_p, y_p))
		vertices.append(Vector2(x, y))
			
	var l_circle = []
	for l_index in radial_segs + 1:
		l_circle.append(l_index)
	
	var c_square = []
	for lat_index in lateral_segs + 1:
		c_square.append(radial_segs + lat_index)
		
	for lat_index in lateral_segs + 1:
		c_square.append(radial_segs * 2 + lateral_segs + lat_index)
		
	var r_circle = []
	for r_index in radial_segs + 1:
		r_circle.append(radial_segs + lateral_segs + r_index)
		
	polygons = [l_circle, c_square, r_circle]
	polygon = vertices
	uv = uvs
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _set_regenerate_polygon(value):
	if value:
		regenerate_polygon()
		
func _get_regenerate_polygon():
	return false
	
func _set_generate_bone_weights(value):
	if value:
		generate_bone_weights()
		
func _get_generate_bone_weights():
	return false
