extends Node

var animations = []

# Called when the node enters the scene tree for the first time.
func _ready():
	load_animations()

func load_animations():
	var path = "res://Dance/Animation/"
	Util.load_resources_in_directory(path, animations)
	print('animations loaded', animations)
	for animation in animations:
		if animation is Animation:
			print(animation.resource_name)
	
func add_animation(animation : Animation):
	animations.append(animation)
