extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	$DespawnTimer.connect("timeout", self, "_on_DespawnTimer_timeout")

func _on_DespawnTimer_timeout():
	queue_free()

func _process(delta):
	move_and_slide(velocity)
	if velocity.x > 0:
		$Draw2D.scale = Vector2(1, 1)
	if velocity.x < 0:
		$Draw2D.scale = Vector2(-1, 1)
