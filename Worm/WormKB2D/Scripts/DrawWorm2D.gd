tool
extends Node2D
class_name DrawWorm2D

#const Worm2D = preload("res://Worm2D/Worm2D.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(float) var radius = 10 setget _set_radius, _get_radius
export(float) var length = radius setget _set_length, _get_length
export(Color) var color = Color.white setget _set_color, _get_color;
export(bool) var redraw = false setget _set_redraw, _get_redraw
export(NodePath) var NodeWormPolygon;

export(bool) var enabled = false setget _set_enabled, _get_enabled

var worm_polygon : WormPolygon2D = null
# Called when the node enters the scene tree for the first time.
func _ready():
	worm_polygon = get_node(NodeWormPolygon) as WormPolygon2D
	if worm_polygon:
		worm_polygon.length = length


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _set_enabled(value):
	enabled = value
	update()
	
func _get_enabled():
	return enabled


func _draw():
	if not enabled:
		return
		
	if !Engine.is_editor_hint():
		return
		
	if radius != 0:
		draw_circle(Vector2(-length, 0), radius, color)
		draw_rect(Rect2(Vector2(-length, -radius), Vector2(length, 2 * radius)), color)
		draw_circle(Vector2(0, 0), radius, color)
			
func _set_radius(value):
	radius = value
	if enabled:
		update()
	
func _get_radius():
	return radius
	
func _set_length(value):
	length = value
	if worm_polygon:
		worm_polygon.length = value
	if enabled:
		update()
	
func _get_length():
	return length
	
func _set_color(value):
	color = value
	if worm_polygon:
		worm_polygon.color = color
	if enabled:
		update()
	
func _get_color():
	return color
	
func _set_redraw(value):
	if value:
		if enabled:
			update()
		
func _get_redraw():
	return false
