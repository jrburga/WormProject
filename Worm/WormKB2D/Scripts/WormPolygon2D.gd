tool
extends Polygon2D
class_name WormPolygon2D

export(bool) var do_regenerate_polygon = false setget _set_regenerate_polygon, _get_regenerate_polygon
export(bool) var test_something = false setget _set_test, _get_test
export(int) var joint_index = 0

export(float) var radius = 20 setget _set_radius, _get_radius
export(float) var length = 10 setget _set_length, _get_length
var r_pixels = 256
var radial_segs = 20
var lateral_segs = 1

func _set_radius(value):
	radius = value
	regenerate_polygon()
	
func _get_radius():
	return radius
	
func _set_length(value):
	length = value
	regenerate_polygon()
	
func _get_length():
	return length
	
func _set_test(value):
	if value:
		test()
		
func _get_test():
	return false
	
func test():
	print(bones)

# Called when the node enters the scene tree for the first time.
func _ready():
#	regenerate_polygon()
	regenerate_polygon()
	var worm = Util.find_first_parent_with_method(self, 'get_segment')
	
func regenerate_polygon():
	var uvs = PoolVector2Array()
	var vertices = PoolVector2Array()

	var t_width = 30
	var t_height = 10
	
	if texture:
		t_width = texture.get_width()
		t_height = texture.get_height()
	
	var delta_theta = PI / radial_segs
	var theta_0 = PI / 2
	var center_pixels_0 = Vector2(r_pixels, r_pixels)
	
	var center_0 = Vector2(2 * radius - length, radius)
	var center_1 = Vector2(2 * radius, radius)
	
	var epsilon_p = 2
	var r_pixels_epsilon = r_pixels - epsilon_p
	for var_index in radial_segs + 1:
		var theta = theta_0 + delta_theta * var_index
		var x_p = cos(theta) * r_pixels_epsilon
		var y_p = sin(theta) * r_pixels_epsilon
		
		var x = cos(theta) * radius
		var y = sin(theta) * radius
		uvs.append(Vector2(x_p, y_p) + center_pixels_0)
		vertices.append(Vector2(x, y) + center_0)
#		vertices.append(Vector2(x_p, y_p) + center_pixels_0)

	var delta_pct = 1.0 / lateral_segs
	var delta_p = delta_pct * r_pixels_epsilon
	var delta = delta_pct * length
	for lat_index in range(1, lateral_segs):
		var x_p = delta_p * lat_index + center_pixels_0.x
		var y_p = 0
		
		var x = delta * lat_index + center_0.x
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
		vertices.append(Vector2(x, y) + center_1)
#		vertices.append(Vector2(x_p, y_p) + center_pixels_1)

	for lat_index in range(lateral_segs - 1, -1, -1):
		var x_p = delta_p * lat_index + center_pixels_0.x
		var y_p = t_height
		
		var x = delta * lat_index + center_0.x
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
