extends Node2D



# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(NodePath) var NodeWorm
export(int) var segment_index
var worm_segment : Node2D
export(Vector2) var line_origin = Vector2(-1000, -1000)
export(float) var thickness

func _draw():
	var curve = $Path2D.curve as Curve2D
	if curve and worm_segment:
		var point_count = curve.get_point_count()
		curve.set_point_position(point_count - 1, worm_segment.position)
		curve.set_point_position(0, line_origin)
		var draw_points : PoolVector2Array = curve.tessellate(11)
		
		var num = draw_points.size()
		for index in num - 1:
			draw_line(draw_points[index], draw_points[index + 1], Color.lightblue, thickness)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var worm = get_node(NodeWorm) as WormKB2D
	if worm:
		worm_segment = worm.get_segment(segment_index)
		update()
