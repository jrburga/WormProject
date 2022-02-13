tool
extends Spatial

enum WormMove {
	Slither,
	Wiggle
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
		WormMove.Slither:
			_animate_slither(delta)
		WormMove.Wiggle:
			_animate_wiggle(delta)
			
	if time > 100:
		time = 0
	pass

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
	
