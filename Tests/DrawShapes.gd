tool
extends Node2D

#const Worm2D = preload("res://Worm2D/Worm2D.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float) var radius = 10
export(Color) var color = Color.white setget _set_color, _get_color;
export(bool) var redraw = false setget _set_redraw, _get_redraw

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	draw_circle(Vector2(-radius, 0), radius, color)
	draw_rect(Rect2(Vector2(-radius, -radius), Vector2(radius, 2 * radius)), color)
	draw_circle(Vector2(0, 0), radius, color)
			
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
	
func _set_redraw(value):
	if value:
		update()
		
func _get_redraw():
	return false