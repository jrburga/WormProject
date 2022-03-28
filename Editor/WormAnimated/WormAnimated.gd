tool
extends Node2D
class_name WormAnimated

export(float) var radius = 25
export(int) var num_segments = 13
export(Color) var color = Color.salmon

var segments = []

# Called when the node enters the scene tree for the first time.
func _ready():
	segments = [$Worm0]
	for index in range(1, num_segments):
		var body = Node2D.new()
		body.set_script(load("res://Editor/WormAnimated/WormBodyAnim.gd"))
		if body is WormBodyAnim:
			body.radius = radius
			body.color = color
			body.position = Vector2(-index * radius, 0)
			
		body.set_name("Worm" + str(index))
		segments.append(body)
		add_child(body)
		
func _draw():
	for segment in segments:
		if segment is WormBodyAnim:
			var end_point = segment.position + segment.velocity
			draw_line(segment.position, end_point, Color.red)
			
func _process(delta):
	update()
