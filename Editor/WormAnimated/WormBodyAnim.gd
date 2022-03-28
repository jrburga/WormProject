tool
extends Node2D
class_name WormBodyAnim

export(Vector2) var velocity = Vector2()
export(float) var radius = 25
export(Color) var color = Color.salmon

func _draw():
	var length = radius
	draw_circle(Vector2(-length, 0), radius, color)
	draw_rect(Rect2(Vector2(-length, -radius), Vector2(length, 2 * radius)), color)
	draw_circle(Vector2(0, 0), radius, color)
	
func _process(delta):
	update()
