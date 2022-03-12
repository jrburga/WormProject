tool
extends HBoxContainer
class_name ColorMenu

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal select_color(color)


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in self.get_children():
		if child is ColorItem:
			child.connect("pressed", self, "_on_select_color", [child.color])

func _on_select_color(color : Color):
	emit_signal("select_color", color)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
