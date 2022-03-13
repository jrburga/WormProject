tool
extends Spatial

enum WormMove {
	None,
	Slither,
	Wiggle,
	Slither2,
	FollowPath
}

export(WormMove) var move = WormMove.Slither;
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.



var time = 0
func _process(delta):
#	_animate_wiggle(delta)
#	_animate_slither(delta)

	
	
	match (move):
		WormMove.None:
			_reset_pose()
		WormMove.Slither:
			_animate_slither(delta)
		WormMove.Wiggle:
			_animate_wiggle(delta)
		WormMove.Slither2:
			_animate_slither_2(delta)
		WormMove.FollowPath:
			_snap_to_path()
			
	if time > 100:
		time = 0
	pass
	
func _snap_to_path():
	var count = $Armature/Skeleton.get_bone_count()
	
	count = $Path.get_curve().get_point_count()
	for point_index in range(count):
		var new_transform = Transform()
		new_transform.basis = Basis()
		
		var absolute = $Path.get_curve().get_point_position(point_index)
#		$Path.get_curve().set_point_position(point_index, absolute * Vector3(0, 1, 0))
		var parent = Vector3()
		if point_index > 0:
			parent = $Path.get_curve().get_point_position(point_index - 1)
			
		var child = absolute * 2
		if point_index < count - 1:
			child = $Path.get_curve().get_point_position(point_index + 1)
			
		var phi = $Path.get_curve().get_point_tilt(point_index)
		
		var position = absolute - parent
		var out = child - absolute
		new_transform.origin = position
		var cross = Vector3(1, 0, 0).cross(out)
		
		new_transform.basis = Basis(
			Vector3(1, 0, 0),
			out.normalized(),
			cross.normalized())
		
		$Armature/Skeleton.set_bone_pose(point_index, new_transform)	
	
func _reset_pose():
	var count = $Armature/Skeleton.get_bone_count()
	for bone_index in range(count):
		var new_transform = Transform()
		new_transform.basis = Basis()
		var x = 0
		var y = 0 
		var z = 0
		new_transform.origin = Vector3(x, y, 0)
		$Armature/Skeleton.set_bone_pose(bone_index, new_transform)

func _animate_slither_2(delta):
	var count = $Armature/Skeleton.get_bone_count()
	var f = 1 / (float(count) / 2)
	var amp = 1
	var speed = 3.0
	for bone_index in range(count):
		var new_transform = Transform()
		new_transform.basis = Basis()
		
		var shift = sin(bone_index)
		var x = cos(time * speed + bone_index * .5) * f * amp
		var y = 0 
		var z = 0
		new_transform.origin = Vector3(x, y, 0)
		$Armature/Skeleton.set_bone_pose(bone_index, new_transform)
		
	
#	transform.origin.y = time
	time += delta
	
func _animate_slither(delta):
	var count = $Armature/Skeleton.get_bone_count()
	var f = 1 / (float(count) / 2)
	var amp = 1
	var speed = 3.0
	for bone_index in range(count):
		var new_transform = Transform()
		new_transform.basis = Basis()
		
		var shift = sin(bone_index)
		var x = cos(time * speed) * f * amp * shift
		var y = 0 
		var z = 0
		new_transform.origin = Vector3(x, y, 0)
		$Armature/Skeleton.set_bone_pose(bone_index, new_transform)
	
	time += delta


func _animate_wiggle(delta):
	var count = $Armature/Skeleton.get_bone_count()
	var f = 1 / (float(count) / 2)
	var amp = 0.05
	var speed = 3.0
	for bone_index in range(count):
		var new_transform = Transform()
		new_transform.basis = Basis()
		
		var t_index = bone_index - (count / 2)
		var x = cos(time * speed) * f * amp * t_index
		var y = sin(time * speed) * f * amp * t_index
		var z = 0
		new_transform.origin = Vector3(x, y, 0)
		$Armature/Skeleton.set_bone_pose(bone_index, new_transform)
	
	time += delta
	
