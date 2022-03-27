extends Node

var moves = []
var dances = []
var animations = []
var raw_animations = []

var path_anims = "res://Dance/Animation/"
var path_raw_anims = "res://Dance/RawAnimation/"
var path_moves = "res://Dance/Moves"
var path_dances = "res://Dance/Dances"

# Called when the node enters the scene tree for the first time.
func _ready():
	load_animations()

func load_animations():
	Util.load_resources_in_directory(path_anims, animations)
	Util.load_resources_in_directory(path_raw_anims, raw_animations)
	Util.load_resources_in_directory(path_moves, moves)
	Util.load_resources_in_directory(path_dances, dances)
	
func find_move(move_id : String) -> DanceMove:
	for move in moves:
		if move is DanceMove:
			if move.id == move_id:
				return move
	return null
	
func find_dance(dance_id : String) -> DanceSequence:
	for dance in dances:
		if dance is DanceSequence:
			if dance.id == dance_id:
				return dance
	return null

func add_animation(animation : Animation):
	animations.append(animation)
	
func add_raw_animation(animation : Animation):
	raw_animations.append(animation)

func find_animation(animation_name : String) -> Animation:
	for animation in animations:
		if animation is Animation:
			if animation.resource_name == animation_name:
				return animation
				
	for animation in raw_animations:
		if animation is Animation:
			if animation.resource_name == animation_name:
				return animation
	return null
	
func save_animation(anim_name : String, animation : Animation):
	if animation != null:
		animation.resource_name = anim_name
		animation.loop = true
		ResourceSaver.save(path_anims + anim_name + ".tres", animation)
		add_animation(animation)

func save_raw_animation(anim_name : String, animation : Animation):
	if animation != null:
		animation.resource_name = anim_name
		animation.loop = true
		ResourceSaver.save(path_raw_anims + anim_name + ".tres", animation)
		add_raw_animation(animation)
