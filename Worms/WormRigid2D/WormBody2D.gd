tool
extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var color = Color.white setget _set_color, _get_color
export var drag_coef = 0.5
export var fric_coef_dragging = .5
export var fric_coef = 25

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
	
	var drag_force = Vector2()
	if body:
		var drag_direction = - linear_velocity.normalized()
		var connect_vector = transform.origin - body.transform.origin 
		drag_direction = - (linear_velocity - linear_velocity.project(connect_vector)).normalized()
		drag_force = linear_velocity * linear_velocity * drag_direction * drag_coef / 2.0
#		drag_direction = - (linear_velocity).normalized()
		
	var f_direction = -linear_velocity.normalized()
	var friction_force = Vector2()
	if not worm.is_dragging():
		friction_force = f_direction * fric_coef
	else:
		friction_force = f_direction * fric_coef_dragging
	applied_force = friction_force + drag_force

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
