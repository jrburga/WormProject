tool
extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var color = Color.white setget _set_color, _get_color
export var drag_coef = 0.5

export(NodePath) var click_area_node;

# Called when the node enters the scene tree for the first time.
func _ready():
	var click_area = get_node(click_area_node) as Area2D
	click_area.connect("input_event", self, "_on_ClickArea_input_event")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _integrate_forces(state):
	var worm = get_parent()
	var index = worm.get_index_of_segment(self)
	var body = worm.get_segment(index - 1) as PhysicsBody2D
	if not body:
		return
		
	var drag_direction = - linear_velocity.normalized()
	if (body):
		var connect_vector = transform.origin - body.transform.origin 
		drag_direction = - (linear_velocity - linear_velocity.project(connect_vector)).normalized()
		
	applied_force = linear_velocity * linear_velocity * drag_direction * drag_coef / 2.0

func _set_color(value):
	color = value
	update()

func _get_color():
	return color

func _on_ClickArea_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		pass
	elif event is InputEventScreenTouch:
		pass
