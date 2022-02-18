tool
extends MeshInstance2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var segments : int = 10
var radius : float = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh = ArrayMesh.new()
	
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)

	# PoolVectorXXArrays for mesh construction.
	var verts = PoolVector3Array()
	var uvs = PoolVector2Array()
	var normals = PoolVector3Array()
	var indices = PoolIntArray()

	#######################################
	## Insert code here to generate mesh ##
	#######################################
	
	var draw_squares = false
	var draw_circles = true
	if draw_circles:
		
		var tris = 4
		var uv_center = Vector2(0.5, 0.75)
		var uv_radius = 0.25
		
		for tri in tris:
			var index = tri * 3
			
			var uv_0 = uv_center
			var vert_0 = Vector3(0, 0, 0)
			uvs.append(uv_0)
			normals.append(Vector3())
			verts.append(vert_0)
			indices.append(index)
			
			var theta_1 = PI * tri / float(tris)
			var uv_1 = uv_center + Vector2(-uv_radius * cos(theta_1), uv_radius * sin(theta_1))
			print(uv_1)
			var vert_1 = Vector3(radius * cos(theta_1), radius * sin(theta_1), 0)
			uvs.append(uv_1)
			normals.append(Vector3())
			verts.append(vert_1)
			indices.append(index + 1)
			
			var theta_2 = PI * (tri + 1) / float(tris)
			var uv_2 = uv_center + Vector2(-uv_radius * cos(theta_2), uv_radius * sin(theta_2))
			var vert_2 = Vector3(radius * cos(theta_2), radius * sin(theta_2), 0)
			uvs.append(uv_2)
			normals.append(Vector3())
			verts.append(vert_2)
			indices.append(index + 3)
		
		
	if draw_squares:
		for segment in segments:
			
			var index = segment * 6
			var uv_o = Vector2(0, segment / float(segments))
			var uv_y = Vector2(0, 1 / float(segments))
			var uv_x = Vector2(1, 0)
			
			var height = radius / 2
			var width = radius
			var xy_o = Vector3(0, height * segment, 0)
			
			uvs.append(uv_o)
			normals.append(Vector3(0, 0, 0))
			verts.append(Vector3(-width/2, 0, 0) + xy_o)
			indices.append(index)

			uvs.append(uv_o + uv_x)
			normals.append(Vector3(0, 0, 0))
			verts.append(Vector3(width/2, 0, 0) + xy_o)
			indices.append(index + 1)

			uvs.append(uv_o + uv_y)
			normals.append(Vector3(0, 0, 0))
			verts.append(Vector3(-width/2, height, 0) + xy_o)
			indices.append(index + 2)
			
			uvs.append(uv_o + uv_x)
			normals.append(Vector3(0, 0, 0))
			verts.append(Vector3(width/2, 0, 0) + xy_o)
			indices.append(index + 3)

			uvs.append(uv_o + uv_x + uv_y)
			normals.append(Vector3(0, 0, 0))
			verts.append(Vector3(width/2, height, 0) + xy_o)
			indices.append(index + 4)

			uvs.append(uv_o + uv_y)
			normals.append(Vector3(0, 0, 0))
			verts.append(Vector3(-width/2, height, 0) + xy_o)
			indices.append(index + 5)

		# Assign arrays to mesh array.
		arr[Mesh.ARRAY_VERTEX] = verts
		arr[Mesh.ARRAY_TEX_UV] = uvs
		arr[Mesh.ARRAY_NORMAL] = normals
		arr[Mesh.ARRAY_INDEX] = indices

		# Create mesh surface from mesh array.
		
		
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr) # No blendshapes or compression used.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
