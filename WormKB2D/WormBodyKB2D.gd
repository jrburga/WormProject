extends KinematicBody2D

class_name WormKB2D

export(float) var speed = 300
export(float) var seg_distance = 20
export(bool) var is_head = false

export(NodePath) var ParentNode;
var parent = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var child_count = get_parent().get_child_count()
	for child_index in child_count:
		var child = get_parent().get_child(child_index)
		if child == self:
			parent = get_parent().get_child(child_index - 1)

func _position_from_event(event):
	return event.position - get_canvas_transform().origin

var mouse_button_down = false
var mouse_position = Vector2()

func _input(event):
	if not is_head:
		return
		
	if event is InputEventMouseButton:
		mouse_button_down = event.pressed
		mouse_position = _position_from_event(event)
	if event is InputEventMouseMotion:
		mouse_position = _position_from_event(event)

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	if is_head:
		if mouse_button_down:
			var direction = (mouse_position - position).normalized()
			move_and_slide(direction * speed)
			
	elif parent:
		var distance = (parent.position - position) as Vector2
		if distance.length_squared() > pow(seg_distance, 2):
			var direction = distance.normalized()
			move_and_slide(direction * speed)
		

func _physics_process(delta):
	pass
#	if 
#	move_and_slide()
