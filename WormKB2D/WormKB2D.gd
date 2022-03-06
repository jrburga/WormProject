extends Node2D


const scnWormBodyKB2D = preload("./WormBodyKB2D.tscn")
const WormBodyKB2D = preload("./WormBodyKB2D.gd")


export(int) var num_segments = 10
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var segments = []
# Called when the node enters the scene tree for the first time.
func _ready():
	for index in num_segments:
#		print(index)
		var new_worm_body = scnWormBodyKB2D.instance() as WormBodyKB2D
		new_worm_body.is_head = index == 0
		if index > 0:
			new_worm_body.parent = segments[index - 1]
		segments.append(new_worm_body)
		
		self.add_child(new_worm_body)
		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
