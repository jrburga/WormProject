extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var drag_coef = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _integrate_forces(state):
	var worm = get_parent()
	var index = worm.get_index_of_segment(self)
	
	var body = worm.get_segment(index - 1) as PhysicsBody2D
	
	var connect_vector = transform.origin - body.transform.origin 
	var drag_direction = - (linear_velocity - linear_velocity.project(connect_vector)).normalized()
	applied_force = linear_velocity * linear_velocity * drag_direction * drag_coef / 2.0
