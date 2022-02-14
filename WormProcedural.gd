tool
extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	_generate_mesh()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _generate_mesh():
	var mesh = $MeshInstance.mesh as ArrayMesh
	mesh.clear_surfaces()
	
	if mesh == null:
		return
		
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	var verts = PoolVector3Array()
	var uvs = PoolVector2Array()
	var normals = PoolVector3Array()
	var indices = PoolIntArray()
	
	
	var height = 10
	var radius = 1
	var segments = 6
	var index = 0
	for h in range(height):
		for s in range(segments):
			
			# bottom tri
			var theta_0 = 2 * PI * s / float(segments)
			var x_0 = cos(theta_0) * radius
			var z_0 = sin(theta_0) * radius
			var y_0 = h	
			normals.append(Vector3(x_0, 0, z_0).normalized())
			uvs.append(Vector2(theta_0, y_0 / float(height)))
			verts.append(Vector3(x_0, y_0, z_0))
			indices.append(index)
			
			index += 1
	
			var theta_1 = 2 * PI * (s + 1) / float(segments)
			var x_1 = cos(theta_1) * radius
			var z_1 = sin(theta_1) * radius
			var y_1 = h
			normals.append(Vector3(x_1, 0, z_1).normalized())
			uvs.append(Vector2(theta_1, y_1 / float(height)))
			verts.append(Vector3(x_1, y_1, z_1))
			indices.append(index)
			
			index += 1
			
			var theta_2 = theta_0
			var x_2 = x_0
			var z_2 = z_0
			var y_2 = h + 1
			normals.append(Vector3(x_2, 0, z_2).normalized())
			uvs.append(Vector2(theta_2, y_2 / float(height)))
			verts.append(Vector3(x_2, y_2, z_2))
			indices.append(index)
			
			index += 1
			# top tri
			
			var theta_3 = theta_1
			var x_3 = x_1
			var z_3 = z_1
			var y_3 = h + 1
			normals.append(Vector3(x_3, 0, z_3).normalized())
			uvs.append(Vector2(theta_3, y_3 / float(height)))
			verts.append(Vector3(x_3, y_3, z_3))
			indices.append(index)
			
			index += 1

			var theta_4 = theta_0
			var x_4 = x_0
			var z_4 = z_0
			var y_4 = h + 1
			normals.append(Vector3(x_4, 0, z_4).normalized())
			uvs.append(Vector2(theta_4, y_4 / float(height)))
			verts.append(Vector3(x_4, y_4, z_4))
			indices.append(index)
			
			index += 1
			
			var theta_5 = theta_1
			var x_5 = x_1
			var z_5 = z_1
			var y_5 = h
			normals.append(Vector3(x_5, 0, z_5).normalized())
			uvs.append(Vector2(theta_5, y_5 / float(height)))
			verts.append(Vector3(x_5, y_5, z_5))
			indices.append(index)
			
			index += 1
			
	arr[Mesh.ARRAY_VERTEX] = verts;
	arr[Mesh.ARRAY_TEX_UV] = uvs;
	arr[Mesh.ARRAY_NORMAL] = normals;
	arr[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)

func _generate_immediate_geometry():
	var ig : ImmediateGeometry = $ImmediateGeometry
	if ig == null:
		return
		
	ig.clear()
	ig.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var height = 1
	var radius = 1
	var segments = 4
	for h in range(height):
		for s in range(segments):
			
			# bottom tri
			var theta_0 = 2 * PI * s / float(segments)
			var x_0 = cos(theta_0) * radius
			var z_0 = sin(theta_0) * radius
			var y_0 = h	
			ig.set_normal(Vector3(x_0, 0, z_0).normalized())
			ig.set_uv(Vector2(theta_0, y_0 / float(height)))
			ig.add_vertex(Vector3(x_0, y_0, z_0))

			var theta_1 = 2 * PI * (s + 1) / float(segments)
			var x_1 = cos(theta_1) * radius
			var z_1 = sin(theta_1) * radius
			var y_1 = h
			ig.set_normal(Vector3(x_1, 0, z_1).normalized())
			ig.set_uv(Vector2(theta_1, y_1 / float(height)))
			ig.add_vertex(Vector3(x_1, y_1, z_1))
			
			var theta_2 = theta_0
			var x_2 = x_0
			var z_2 = z_0
			var y_2 = h + 1
			ig.set_normal(Vector3(x_2, 0, z_2).normalized())
			ig.set_uv(Vector2(theta_2, y_2 / float(height)))
			ig.add_vertex(Vector3(x_2, y_2, z_2))
			
			# top tri
			
			var theta_3 = theta_1
			var x_3 = x_1
			var z_3 = z_1
			var y_3 = h + 1
			ig.set_normal(Vector3(x_3, 0, z_3).normalized())
			ig.set_uv(Vector2(theta_3, y_3 / float(height)))
			ig.add_vertex(Vector3(x_3, y_3, z_3))

			var theta_4 = theta_0
			var x_4 = x_0
			var z_4 = z_0
			var y_4 = h + 1
			ig.set_normal(Vector3(x_4, 0, z_4).normalized())
			ig.set_uv(Vector2(theta_4, y_4 / float(height)))
			ig.add_vertex(Vector3(x_4, y_4, z_4))
			
			var theta_5 = theta_1
			var x_5 = x_1
			var z_5 = z_1
			var y_5 = h
			ig.set_normal(Vector3(x_5, 0, z_5).normalized())
			ig.set_uv(Vector2(theta_5, y_5 / float(height)))
			ig.add_vertex(Vector3(x_5, y_5, z_5))
						
	ig.end()
	
