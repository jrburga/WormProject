extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	add_worm_animations()
	
func add_worm_animations():
	for animation in Autoload.get_dances_db(self).animations:
		if animation is Animation:
			add_animation(animation.resource_name, animation)
			print("added animation: ", animation.resource_name)
			print("find: ", find_animation(animation))
