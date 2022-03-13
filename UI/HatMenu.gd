tool
extends HBoxContainer
class_name HatMenu

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal select_hat(hat_id)


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in self.get_children():
		if child is HatItem:
			child.connect("pressed", self, "_on_item_pressed", [child.hat_id])

func _on_item_pressed(hat_id : String):
	emit_signal("select_hat", hat_id)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
