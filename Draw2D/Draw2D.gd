tool
extends Node2D

const util = preload("res://Scripts/Util.gd")
#const Worm2D = preload("res://Worm2D/Worm2D.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float) var radius = 10
export(Color) var color = Color.white setget _set_color, _get_color;
export(bool) var do_draw = false setget _set_do_draw, _get_do_draw

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _set_do_draw(value):
	do_draw = value
	update()
	
func _get_do_draw():
	return do_draw
	

func _draw():
	if not do_draw:
		return
		
	var body = get_parent()
	var worm = get_parent().get_parent()
	if worm.has_method("get_segment"):
		radius = worm.segment_radius
		draw_circle(Vector2(), radius, color)
		var index = worm.get_index_of_segment(body)
		var parent = worm.get_segment(index - 1)
		var child = worm.get_segment(index + 1)
		if (parent):
			draw_circle(Vector2(-radius, 0), radius, color)
			draw_rect(Rect2(Vector2(-radius, -radius), Vector2(radius, 2 * radius)), color)
		elif child:
			draw_rect(Rect2(Vector2(-radius, -radius), Vector2(radius, 2 * radius)), color)
	else:
		draw_circle(Vector2(-radius, 0), radius, color)
		draw_rect(Rect2(Vector2(-radius, -radius), Vector2(radius, 2 * radius)), color)
			
func _physics_process(delta):
	var body = get_parent()
	var worm = get_parent().get_parent()

	if worm.has_method("get_segment"):
		radius = worm.segment_radius
		var index = worm.get_index_of_segment(body)
		var parent = worm.get_segment(index - 1)
		var child = worm.get_segment(index + 1)
		if (parent):
			var direction : Vector2 = - (parent.transform.origin - body.transform.origin)
			self.rotation = direction.angle()
		elif child:

			var direction : Vector2 = body.transform.origin - child.transform.origin
			self.rotation = direction.angle()

	
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
