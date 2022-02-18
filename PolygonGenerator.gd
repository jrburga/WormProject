tool
extends Polygon2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var s_width = 2
	var s_height = 10
	var segments = 10
	var t_width = texture.get_width()
	var t_height = texture.get_height()

	var vertices = PoolVector2Array()
	var uvs = PoolVector2Array()

	clear_bones()
	for index_r in segments + 1:
		var length = s_height / float(segments)
		var length_uv = 1 / float(segments)
		vertices.append(Vector2(s_width, length * index_r))
		var uv_point  = Vector2(t_width, t_height * index_r * length_uv)
		uvs.append(uv_point)

	for index_l in segments + 1:
		var length = s_height / float(segments)
		var length_uv = 1 / float(segments)
		vertices.append(Vector2(0, length * (segments - index_l)))
		var uv_point  = Vector2(0, t_height * length_uv * (segments - index_l))
		uvs.append(uv_point)
		
	var skeleton_2d = get_node(skeleton) as Skeleton2D
	if skeleton_2d:
		var vertex_count = vertices.size()
		var bone_count = skeleton_2d.get_bone_count()
		for bone_index in bone_count:
			var weight_index = bone_count - bone_index
			var bone_path = skeleton_2d.get_path_to(skeleton_2d.get_bone(bone_index))
			var weights = []
			weights.resize(vertex_count)
			weights[weight_index] = 1
			weights[vertex_count - weight_index] = 1
			weights[weight_index - 1] = 0.5
			weights[vertex_count - weight_index - 1] = 0.5
			add_bone(bone_path, weights)

#	polygons = []
	polygon = vertices
	uv = uvs
	print(bones)
#	print(get_bone_weights(0))
#	print(polygons)

#	print(polygon)
#	print(uv)
#	print(polygons)
	print('hello')
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
