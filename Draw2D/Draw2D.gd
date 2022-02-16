tool
extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float) var radius = 10 setget _set_radius, _get_radius;
export(Color) var color = Color.white setget _set_color, _get_color;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	
	draw_circle(Vector2(), radius, color)
	draw_circle(Vector2(0, -radius), radius, color)
	
func _set_radius(value):
	radius = value
	update()
	
func _get_radius():
	return radius
	
func _set_color(value):
	color = value
	update()
	
func _get_color():
	return color
