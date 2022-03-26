extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	return
	
func _play_animation():
	for animation in Autoload.get_dances_db(self).animations:
		if animation is Animation:
			add_animation(animation.resource_name, animation)
			print("added animation: ", animation.resource_name)
			print("find: ", find_animation(animation))

	for anim_name in get_animation_list():
		play(anim_name)
