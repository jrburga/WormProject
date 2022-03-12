extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var worm_color : Color setget _set_worm_color, _get_worm_color

signal worm_color_changed(new_color)

func _set_worm_color(value):
	worm_color = value
	emit_signal("worm_color_changed", worm_color)
	
func _get_worm_color():
	return worm_color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
